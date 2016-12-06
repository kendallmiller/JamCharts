﻿//------------------------------------------------------------------------------
// <auto-generated>
//    This code was generated from a template.
//
//    Manual changes to this file may cause unexpected behavior in your application.
//    Manual changes to this file will be overwritten if the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

using System;
using System.Data.Objects;
using System.Data.Objects.DataClasses;
using System.Data.EntityClient;
using System.ComponentModel;
using System.Xml.Serialization;
using System.Runtime.Serialization;

[assembly: EdmSchemaAttribute()]

namespace WebSandbox
{
    #region Contexts
    
    /// <summary>
    /// No Metadata Documentation available.
    /// </summary>
    public partial class jamchartsEntities : ObjectContext
    {
        #region Constructors
    
        /// <summary>
        /// Initializes a new jamchartsEntities object using the connection string found in the 'jamchartsEntities' section of the application configuration file.
        /// </summary>
        public jamchartsEntities() : base("name=jamchartsEntities", "jamchartsEntities")
        {
            this.ContextOptions.LazyLoadingEnabled = true;
            OnContextCreated();
        }
    
        /// <summary>
        /// Initialize a new jamchartsEntities object.
        /// </summary>
        public jamchartsEntities(string connectionString) : base(connectionString, "jamchartsEntities")
        {
            this.ContextOptions.LazyLoadingEnabled = true;
            OnContextCreated();
        }
    
        /// <summary>
        /// Initialize a new jamchartsEntities object.
        /// </summary>
        public jamchartsEntities(EntityConnection connection) : base(connection, "jamchartsEntities")
        {
            this.ContextOptions.LazyLoadingEnabled = true;
            OnContextCreated();
        }
    
        #endregion
    
        #region Partial Methods
    
        partial void OnContextCreated();
    
        #endregion
    
        #region ObjectSet Properties
    
        /// <summary>
        /// No Metadata Documentation available.
        /// </summary>
        public ObjectSet<Song> Songs
        {
            get
            {
                if ((_Songs == null))
                {
                    _Songs = base.CreateObjectSet<Song>("Songs");
                }
                return _Songs;
            }
        }
        private ObjectSet<Song> _Songs;
    
        /// <summary>
        /// No Metadata Documentation available.
        /// </summary>
        public ObjectSet<SongTitle> SongTitles
        {
            get
            {
                if ((_SongTitles == null))
                {
                    _SongTitles = base.CreateObjectSet<SongTitle>("SongTitles");
                }
                return _SongTitles;
            }
        }
        private ObjectSet<SongTitle> _SongTitles;
    
        /// <summary>
        /// No Metadata Documentation available.
        /// </summary>
        public ObjectSet<SongHistory> SongHistories
        {
            get
            {
                if ((_SongHistories == null))
                {
                    _SongHistories = base.CreateObjectSet<SongHistory>("SongHistories");
                }
                return _SongHistories;
            }
        }
        private ObjectSet<SongHistory> _SongHistories;

        #endregion
        #region AddTo Methods
    
        /// <summary>
        /// Deprecated Method for adding a new object to the Songs EntitySet. Consider using the .Add method of the associated ObjectSet&lt;T&gt; property instead.
        /// </summary>
        public void AddToSongs(Song song)
        {
            base.AddObject("Songs", song);
        }
    
        /// <summary>
        /// Deprecated Method for adding a new object to the SongTitles EntitySet. Consider using the .Add method of the associated ObjectSet&lt;T&gt; property instead.
        /// </summary>
        public void AddToSongTitles(SongTitle songTitle)
        {
            base.AddObject("SongTitles", songTitle);
        }
    
        /// <summary>
        /// Deprecated Method for adding a new object to the SongHistories EntitySet. Consider using the .Add method of the associated ObjectSet&lt;T&gt; property instead.
        /// </summary>
        public void AddToSongHistories(SongHistory songHistory)
        {
            base.AddObject("SongHistories", songHistory);
        }

        #endregion
    }
    

    #endregion
    
    #region Entities
    
    /// <summary>
    /// No Metadata Documentation available.
    /// </summary>
    [EdmEntityTypeAttribute(NamespaceName="JamChartsModel", Name="Song")]
    [Serializable()]
    [DataContractAttribute(IsReference=true)]
    public partial class Song : EntityObject
    {
        #region Factory Method
    
        /// <summary>
        /// Create a new Song object.
        /// </summary>
        /// <param name="songId">Initial value of the SongId property.</param>
        /// <param name="title">Initial value of the Title property.</param>
        /// <param name="key">Initial value of the Key property.</param>
        /// <param name="time">Initial value of the Time property.</param>
        /// <param name="chords">Initial value of the Chords property.</param>
        /// <param name="version">Initial value of the Version property.</param>
        /// <param name="dateAdded">Initial value of the DateAdded property.</param>
        public static Song CreateSong(global::System.Int32 songId, global::System.String title, global::System.String key, global::System.String time, global::System.String chords, global::System.Int32 version, global::System.DateTime dateAdded)
        {
            Song song = new Song();
            song.SongId = songId;
            song.Title = title;
            song.Key = key;
            song.Time = time;
            song.Chords = chords;
            song.Version = version;
            song.DateAdded = dateAdded;
            return song;
        }

        #endregion
        #region Primitive Properties
    
        /// <summary>
        /// No Metadata Documentation available.
        /// </summary>
        [EdmScalarPropertyAttribute(EntityKeyProperty=true, IsNullable=false)]
        [DataMemberAttribute()]
        public global::System.Int32 SongId
        {
            get
            {
                return _SongId;
            }
            set
            {
                if (_SongId != value)
                {
                    OnSongIdChanging(value);
                    ReportPropertyChanging("SongId");
                    _SongId = StructuralObject.SetValidValue(value);
                    ReportPropertyChanged("SongId");
                    OnSongIdChanged();
                }
            }
        }
        private global::System.Int32 _SongId;
        partial void OnSongIdChanging(global::System.Int32 value);
        partial void OnSongIdChanged();
    
        /// <summary>
        /// No Metadata Documentation available.
        /// </summary>
        [EdmScalarPropertyAttribute(EntityKeyProperty=false, IsNullable=false)]
        [DataMemberAttribute()]
        public global::System.String Title
        {
            get
            {
                return _Title;
            }
            set
            {
                OnTitleChanging(value);
                ReportPropertyChanging("Title");
                _Title = StructuralObject.SetValidValue(value, false);
                ReportPropertyChanged("Title");
                OnTitleChanged();
            }
        }
        private global::System.String _Title;
        partial void OnTitleChanging(global::System.String value);
        partial void OnTitleChanged();
    
        /// <summary>
        /// No Metadata Documentation available.
        /// </summary>
        [EdmScalarPropertyAttribute(EntityKeyProperty=false, IsNullable=false)]
        [DataMemberAttribute()]
        public global::System.String Key
        {
            get
            {
                return _Key;
            }
            set
            {
                OnKeyChanging(value);
                ReportPropertyChanging("Key");
                _Key = StructuralObject.SetValidValue(value, false);
                ReportPropertyChanged("Key");
                OnKeyChanged();
            }
        }
        private global::System.String _Key;
        partial void OnKeyChanging(global::System.String value);
        partial void OnKeyChanged();
    
        /// <summary>
        /// No Metadata Documentation available.
        /// </summary>
        [EdmScalarPropertyAttribute(EntityKeyProperty=false, IsNullable=false)]
        [DataMemberAttribute()]
        public global::System.String Time
        {
            get
            {
                return _Time;
            }
            set
            {
                OnTimeChanging(value);
                ReportPropertyChanging("Time");
                _Time = StructuralObject.SetValidValue(value, false);
                ReportPropertyChanged("Time");
                OnTimeChanged();
            }
        }
        private global::System.String _Time;
        partial void OnTimeChanging(global::System.String value);
        partial void OnTimeChanged();
    
        /// <summary>
        /// No Metadata Documentation available.
        /// </summary>
        [EdmScalarPropertyAttribute(EntityKeyProperty=false, IsNullable=false)]
        [DataMemberAttribute()]
        public global::System.String Chords
        {
            get
            {
                return _Chords;
            }
            set
            {
                OnChordsChanging(value);
                ReportPropertyChanging("Chords");
                _Chords = StructuralObject.SetValidValue(value, false);
                ReportPropertyChanged("Chords");
                OnChordsChanged();
            }
        }
        private global::System.String _Chords;
        partial void OnChordsChanging(global::System.String value);
        partial void OnChordsChanged();
    
        /// <summary>
        /// No Metadata Documentation available.
        /// </summary>
        [EdmScalarPropertyAttribute(EntityKeyProperty=false, IsNullable=true)]
        [DataMemberAttribute()]
        public global::System.String Lyrics
        {
            get
            {
                return _Lyrics;
            }
            set
            {
                OnLyricsChanging(value);
                ReportPropertyChanging("Lyrics");
                _Lyrics = StructuralObject.SetValidValue(value, true);
                ReportPropertyChanged("Lyrics");
                OnLyricsChanged();
            }
        }
        private global::System.String _Lyrics;
        partial void OnLyricsChanging(global::System.String value);
        partial void OnLyricsChanged();
    
        /// <summary>
        /// No Metadata Documentation available.
        /// </summary>
        [EdmScalarPropertyAttribute(EntityKeyProperty=false, IsNullable=false)]
        [DataMemberAttribute()]
        public global::System.Int32 Version
        {
            get
            {
                return _Version;
            }
            set
            {
                OnVersionChanging(value);
                ReportPropertyChanging("Version");
                _Version = StructuralObject.SetValidValue(value);
                ReportPropertyChanged("Version");
                OnVersionChanged();
            }
        }
        private global::System.Int32 _Version;
        partial void OnVersionChanging(global::System.Int32 value);
        partial void OnVersionChanged();
    
        /// <summary>
        /// No Metadata Documentation available.
        /// </summary>
        [EdmScalarPropertyAttribute(EntityKeyProperty=false, IsNullable=false)]
        [DataMemberAttribute()]
        public global::System.DateTime DateAdded
        {
            get
            {
                return _DateAdded;
            }
            set
            {
                OnDateAddedChanging(value);
                ReportPropertyChanging("DateAdded");
                _DateAdded = StructuralObject.SetValidValue(value);
                ReportPropertyChanged("DateAdded");
                OnDateAddedChanged();
            }
        }
        private global::System.DateTime _DateAdded;
        partial void OnDateAddedChanging(global::System.DateTime value);
        partial void OnDateAddedChanged();
    
        /// <summary>
        /// No Metadata Documentation available.
        /// </summary>
        [EdmScalarPropertyAttribute(EntityKeyProperty=false, IsNullable=true)]
        [DataMemberAttribute()]
        public Nullable<global::System.DateTime> DateDeleted
        {
            get
            {
                return _DateDeleted;
            }
            set
            {
                OnDateDeletedChanging(value);
                ReportPropertyChanging("DateDeleted");
                _DateDeleted = StructuralObject.SetValidValue(value);
                ReportPropertyChanged("DateDeleted");
                OnDateDeletedChanged();
            }
        }
        private Nullable<global::System.DateTime> _DateDeleted;
        partial void OnDateDeletedChanging(Nullable<global::System.DateTime> value);
        partial void OnDateDeletedChanged();

        #endregion
    
    }
    
    /// <summary>
    /// No Metadata Documentation available.
    /// </summary>
    [EdmEntityTypeAttribute(NamespaceName="JamChartsModel", Name="SongHistory")]
    [Serializable()]
    [DataContractAttribute(IsReference=true)]
    public partial class SongHistory : EntityObject
    {
        #region Factory Method
    
        /// <summary>
        /// Create a new SongHistory object.
        /// </summary>
        /// <param name="songId">Initial value of the SongId property.</param>
        /// <param name="title">Initial value of the Title property.</param>
        /// <param name="dateAdded">Initial value of the DateAdded property.</param>
        /// <param name="version">Initial value of the Version property.</param>
        public static SongHistory CreateSongHistory(global::System.Int32 songId, global::System.String title, global::System.DateTime dateAdded, global::System.Int32 version)
        {
            SongHistory songHistory = new SongHistory();
            songHistory.SongId = songId;
            songHistory.Title = title;
            songHistory.DateAdded = dateAdded;
            songHistory.Version = version;
            return songHistory;
        }

        #endregion
        #region Primitive Properties
    
        /// <summary>
        /// No Metadata Documentation available.
        /// </summary>
        [EdmScalarPropertyAttribute(EntityKeyProperty=false, IsNullable=true)]
        [DataMemberAttribute()]
        public global::System.String Timestamp
        {
            get
            {
                return _Timestamp;
            }
            set
            {
                OnTimestampChanging(value);
                ReportPropertyChanging("Timestamp");
                _Timestamp = StructuralObject.SetValidValue(value, true);
                ReportPropertyChanged("Timestamp");
                OnTimestampChanged();
            }
        }
        private global::System.String _Timestamp;
        partial void OnTimestampChanging(global::System.String value);
        partial void OnTimestampChanged();
    
        /// <summary>
        /// No Metadata Documentation available.
        /// </summary>
        [EdmScalarPropertyAttribute(EntityKeyProperty=true, IsNullable=false)]
        [DataMemberAttribute()]
        public global::System.Int32 SongId
        {
            get
            {
                return _SongId;
            }
            set
            {
                if (_SongId != value)
                {
                    OnSongIdChanging(value);
                    ReportPropertyChanging("SongId");
                    _SongId = StructuralObject.SetValidValue(value);
                    ReportPropertyChanged("SongId");
                    OnSongIdChanged();
                }
            }
        }
        private global::System.Int32 _SongId;
        partial void OnSongIdChanging(global::System.Int32 value);
        partial void OnSongIdChanged();
    
        /// <summary>
        /// No Metadata Documentation available.
        /// </summary>
        [EdmScalarPropertyAttribute(EntityKeyProperty=true, IsNullable=false)]
        [DataMemberAttribute()]
        public global::System.String Title
        {
            get
            {
                return _Title;
            }
            set
            {
                if (_Title != value)
                {
                    OnTitleChanging(value);
                    ReportPropertyChanging("Title");
                    _Title = StructuralObject.SetValidValue(value, false);
                    ReportPropertyChanged("Title");
                    OnTitleChanged();
                }
            }
        }
        private global::System.String _Title;
        partial void OnTitleChanging(global::System.String value);
        partial void OnTitleChanged();
    
        /// <summary>
        /// No Metadata Documentation available.
        /// </summary>
        [EdmScalarPropertyAttribute(EntityKeyProperty=true, IsNullable=false)]
        [DataMemberAttribute()]
        public global::System.DateTime DateAdded
        {
            get
            {
                return _DateAdded;
            }
            set
            {
                if (_DateAdded != value)
                {
                    OnDateAddedChanging(value);
                    ReportPropertyChanging("DateAdded");
                    _DateAdded = StructuralObject.SetValidValue(value);
                    ReportPropertyChanged("DateAdded");
                    OnDateAddedChanged();
                }
            }
        }
        private global::System.DateTime _DateAdded;
        partial void OnDateAddedChanging(global::System.DateTime value);
        partial void OnDateAddedChanged();
    
        /// <summary>
        /// No Metadata Documentation available.
        /// </summary>
        [EdmScalarPropertyAttribute(EntityKeyProperty=false, IsNullable=true)]
        [DataMemberAttribute()]
        public Nullable<global::System.DateTime> DateDeleted
        {
            get
            {
                return _DateDeleted;
            }
            set
            {
                OnDateDeletedChanging(value);
                ReportPropertyChanging("DateDeleted");
                _DateDeleted = StructuralObject.SetValidValue(value);
                ReportPropertyChanged("DateDeleted");
                OnDateDeletedChanged();
            }
        }
        private Nullable<global::System.DateTime> _DateDeleted;
        partial void OnDateDeletedChanging(Nullable<global::System.DateTime> value);
        partial void OnDateDeletedChanged();
    
        /// <summary>
        /// No Metadata Documentation available.
        /// </summary>
        [EdmScalarPropertyAttribute(EntityKeyProperty=true, IsNullable=false)]
        [DataMemberAttribute()]
        public global::System.Int32 Version
        {
            get
            {
                return _Version;
            }
            set
            {
                if (_Version != value)
                {
                    OnVersionChanging(value);
                    ReportPropertyChanging("Version");
                    _Version = StructuralObject.SetValidValue(value);
                    ReportPropertyChanged("Version");
                    OnVersionChanged();
                }
            }
        }
        private global::System.Int32 _Version;
        partial void OnVersionChanging(global::System.Int32 value);
        partial void OnVersionChanged();

        #endregion
    
    }
    
    /// <summary>
    /// No Metadata Documentation available.
    /// </summary>
    [EdmEntityTypeAttribute(NamespaceName="JamChartsModel", Name="SongTitle")]
    [Serializable()]
    [DataContractAttribute(IsReference=true)]
    public partial class SongTitle : EntityObject
    {
        #region Factory Method
    
        /// <summary>
        /// Create a new SongTitle object.
        /// </summary>
        /// <param name="title">Initial value of the Title property.</param>
        /// <param name="songId">Initial value of the SongId property.</param>
        public static SongTitle CreateSongTitle(global::System.String title, global::System.Int32 songId)
        {
            SongTitle songTitle = new SongTitle();
            songTitle.Title = title;
            songTitle.SongId = songId;
            return songTitle;
        }

        #endregion
        #region Primitive Properties
    
        /// <summary>
        /// No Metadata Documentation available.
        /// </summary>
        [EdmScalarPropertyAttribute(EntityKeyProperty=true, IsNullable=false)]
        [DataMemberAttribute()]
        public global::System.String Title
        {
            get
            {
                return _Title;
            }
            set
            {
                if (_Title != value)
                {
                    OnTitleChanging(value);
                    ReportPropertyChanging("Title");
                    _Title = StructuralObject.SetValidValue(value, false);
                    ReportPropertyChanged("Title");
                    OnTitleChanged();
                }
            }
        }
        private global::System.String _Title;
        partial void OnTitleChanging(global::System.String value);
        partial void OnTitleChanged();
    
        /// <summary>
        /// No Metadata Documentation available.
        /// </summary>
        [EdmScalarPropertyAttribute(EntityKeyProperty=true, IsNullable=false)]
        [DataMemberAttribute()]
        public global::System.Int32 SongId
        {
            get
            {
                return _SongId;
            }
            set
            {
                if (_SongId != value)
                {
                    OnSongIdChanging(value);
                    ReportPropertyChanging("SongId");
                    _SongId = StructuralObject.SetValidValue(value);
                    ReportPropertyChanged("SongId");
                    OnSongIdChanged();
                }
            }
        }
        private global::System.Int32 _SongId;
        partial void OnSongIdChanging(global::System.Int32 value);
        partial void OnSongIdChanged();

        #endregion
    
    }

    #endregion
    
}
