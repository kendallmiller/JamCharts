using System;
using System.Collections.Generic;
using System.Data.Services;
using System.Data.Services.Common;
using System.Linq;
using System.ServiceModel.Web;
using System.Web;
using DataServicesJSONP;

namespace WebSandbox
{
    public interface IJamCharts
    {
        int SaveSong(Song song);
    }

    // http://archive.msdn.microsoft.com/DataServicesJSONP/Release/ProjectReleases.aspx?ReleaseId=5660
    [JSONPSupportBehavior]
    public class JamChartsData : DataService<jamchartsEntities>
    {
        // This method is called only once to initialize service-wide policies.
        public static void InitializeService(DataServiceConfiguration config)
        {
            config.UseVerboseErrors = true;

            // Start out with making everything available
            config.SetEntitySetAccessRule("*", EntitySetRights.All);
            config.SetServiceOperationAccessRule("Songs", ServiceOperationRights.AllRead);
            config.SetServiceOperationAccessRule("SongTitles", ServiceOperationRights.AllRead);
            config.SetServiceOperationAccessRule("SongById", ServiceOperationRights.AllRead);
            config.SetServiceOperationAccessRule("SongHistoryById", ServiceOperationRights.AllRead);
            config.SetServiceOperationAccessRule("DeleteSongById", ServiceOperationRights.AllRead);
            config.SetServiceOperationAccessRule("SaveSong", ServiceOperationRights.All);

            //Set a reasonable paging site
            // config.SetEntitySetPageSize("*", 25);

            config.DataServiceBehavior.MaxProtocolVersion = DataServiceProtocolVersion.V2;
        }

        [WebGet]
        public int SaveSong(int songId, string title, string key, string time, string chords)
        {
            var song = new Song
                           {
                               Title = Decode(title).Trim(),
                               Chords = Decode(chords).Trim(),
                               Key = Decode(key),
                               Time = Decode(time)
                           };

            using (var ef = new jamchartsEntities())
            {
                // handle possibility that the song is being renamed
                if (songId > 0)
                {
                    // Get the id of the latest previous version of this song
                    var previousVersion = (from s in ef.Songs
                                          where s.SongId == songId
                                          select s).FirstOrDefault();
                    if (previousVersion != null)
                    {
                        var previousTitle = previousVersion.Title;
                        if (previousTitle != title)
                        {
                            ef.Songs
                                .Where(x=>x.Title==previousTitle)
                                .ToList()
                                .ForEach(a=>a.Title = title);
                            ef.SaveChanges();
                        }                       
                    }
                }

                // Get the id of the latest previous version of this song
                var latestVersion = (from s in ef.Songs
                                     where s.Title == song.Title
                                     orderby s.Version descending
                                     select s).FirstOrDefault();

                if (SongChanged(song, latestVersion))
                {
                    var version = latestVersion == null ? 1 : latestVersion.Version + 1;
                    song.Version = version;
                    song.DateAdded = DateTime.Now;
                    ef.Songs.AddObject(song);
                    ef.SaveChanges();
                    return song.SongId;
                }
                else
                {
                    return songId;
                }
            }
        }
        
        private static string Decode(string text)
        {
            var unencoded = Uri.UnescapeDataString(text);
            var unquoted = unencoded.Replace("&apos;", "'").Replace("&quot;", "\"").Replace("&#37;", "%");
            return unquoted;
        }

        /// <summary>
        /// Returns true if something has changed relative to the previous version of this song
        /// </summary>
        private static bool SongChanged(Song song, Song latestVersion)
        {
            // If there is no previous version, it's new
            if (latestVersion == null)
                return true;

            if (latestVersion.Key != song.Key)
                return true;

            if (latestVersion.Time != song.Time)
                return true;

            if (latestVersion.Chords != song.Chords)
                return true;

            // Skip this update, nothing has changed
            return false;
        }

        [WebGet]
        public IQueryable<Song> Songs()
        {
            var songs = (from s in this.CurrentDataSource.Songs select s);
            return songs;
        }

        [WebGet]
        public IQueryable<SongTitle> SongTitles()
        {
            var songTitles = (from s in this.CurrentDataSource.SongTitles  orderby s.Title select s );
            return songTitles;
        }

        [WebGet]
        public IQueryable<SongHistory> SongHistoryById(int songId)
        {
            // Figure out the title from the songId
            var song = (from s in this.CurrentDataSource.Songs
                        where s.SongId == songId
                        select s).FirstOrDefault();

            // return an empty list if we don't have a hit
            if (song == null)
                return (from s in this.CurrentDataSource.SongHistories where s.SongId == -1 select s);

            // Get all the versions of that title
            var songVersions = (from s in this.CurrentDataSource.SongHistories
                                where s.Title == song.Title && s.DateDeleted == null
                                orderby s.SongId descending select s);

            return songVersions;
        }

        [WebGet]
        public Song SongById(int songId)
        {
            var song = (from s in this.CurrentDataSource.Songs
                        where s.SongId == songId
                        select s).FirstOrDefault();

            return song ?? new Song { SongId = 0 };
        }

        [WebGet]
        public bool DeleteSongById(int songId)
        {
            var song = (from s in this.CurrentDataSource.Songs
                        where s.SongId == songId
                        select s).FirstOrDefault();

            if (song != null)
            {
                song.DateDeleted = DateTime.Now;
                this.CurrentDataSource.SaveChanges();
            }

            return song != null;
        }
    }
}
