using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;
using WebSandbox.Models;

namespace WebSandbox
{
    /// <summary>
    /// Summary description for Songs
    /// </summary>
    [WebService(Namespace = "http://tempuri.org/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [System.ComponentModel.ToolboxItem(false)]
    [System.Web.Script.Services.ScriptService]
    public class Songs : System.Web.Services.WebService
    {
        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public List<Song> SongList()
        {
            using (var db = new jamchartsEntities())
            {
                var songs = (from s in db.Songs select s).ToList();
                return songs;
            }
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public List<SongTitle> SongTitles()
        {
            using (var db = new jamchartsEntities())
            {
                var songTitles = (from s in db.SongTitles orderby s.Title select s).ToList();
                return songTitles;
            }
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
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
                        if (previousTitle != song.Title)
                        {
                            ef.Songs
                                .Where(x => x.Title == previousTitle)
                                .ToList()
                                .ForEach(a => a.Title = song.Title);
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



        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public List<SongHistory> SongHistoryById(int songId)
        {
            using (var db = new jamchartsEntities())
            {
                // Figure out the title from the songId
                var song = (from s in db.Songs
                            where s.SongId == songId
                            select s).FirstOrDefault();

                // return an empty list if we don't have a hit
                if (song == null)
                    return (from s in db.SongHistories where s.SongId == -1 select s).ToList();

                // Get all the versions of that title
                var songVersions = (from s in db.SongHistories
                                    where s.Title == song.Title && s.DateDeleted == null
                                    orderby s.SongId descending
                                    select s).ToList();

                return songVersions;
            }
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public Song SongById(int songId)
        {
            using (var db = new jamchartsEntities())
            {
                var song = (from s in db.Songs
                            where s.SongId == songId
                            select s).FirstOrDefault();

                return song ?? new Song {SongId = 0};
            }
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public bool DeleteSongById(int songId)
        {
            using (var db = new jamchartsEntities())
            {
                var song = (from s in db.Songs
                            where s.SongId == songId
                            select s).FirstOrDefault();

                if (song != null)
                {
                    song.DateDeleted = DateTime.Now;
                    db.SaveChanges();
                }

                return song != null;
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
    }
}
