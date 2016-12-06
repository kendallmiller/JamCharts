using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace WebSandbox
{
    public partial class _Default : System.Web.UI.Page
    {
        private Song _prevVersion;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack)
            {
                if (SongChanged())
                {
                    var songId = UpdateSong();
                    Response.Redirect("/Default.aspx?songId=" + songId);
                }
                else
                {
                    if (string.IsNullOrWhiteSpace(SongId.Value))
                        Response.Redirect("/Default.aspx");
                    else
                        Response.Redirect("/Default.aspx?songId=" + SongId.Value);
                }
            }
        }

        /// <summary>
        /// Returns true if something has changed relative to the previous version of this song
        /// </summary>
        private bool SongChanged()
        {
            using (var ef = new jamchartsEntities())
            {
                // Get the id of the latest previous version of this song
                _prevVersion = (from s in ef.Songs
                              where s.Title == SongTitle.Value
                              orderby s.Version descending
                              select s).FirstOrDefault();

                // If there is no previous version, it's new
                if (_prevVersion == null)
                    return true;


                if (_prevVersion.Key != SongKey.Value)
                    return true;

                if (_prevVersion.Time != SongTime.Value)
                    return true;

                if (_prevVersion.Chords != SongChords.Value.Trim())
                    return true;

                if (_prevVersion.Lyrics != SongLyrics.Value.Trim())
                    return true;
            }

            // Skip this update, nothing has changed
            return false;
        }

        private int UpdateSong()
        {
            using (var ef = new jamchartsEntities())
            {
                var version = _prevVersion == null ? 1 : _prevVersion.Version + 1;
                var song = new Song
                               {
                                   Title = SongTitle.Value.Trim(),
                                   Version = version,
                                   Time = SongTime.Value,
                                   Key = SongKey.Value,
                                   Chords = SongChords.Value.Trim(),
                                   Lyrics = SongLyrics.Value.Trim(),
                                   DateAdded = DateTime.Now
                               };
                ef.Songs.AddObject(song);
                ef.SaveChanges();
                return song.SongId;
            }
        }
    }
}
