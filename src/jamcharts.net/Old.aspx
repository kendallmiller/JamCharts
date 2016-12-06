<%@ Page Title="Home Page" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true"
    CodeBehind="Old.aspx.cs" Inherits="WebSandbox._Old" %>

<asp:Content ID="HeaderContent" runat="server" ContentPlaceHolderID="HeadContent">
    <script type="text/javascript" src="Scripts/jquery-1.8.2.min.js"></script>
    <script type="text/javascript" src="Scripts/jamcharts.js"></script>
    <script type="text/javascript" src="Scripts/substitions.js"></script>
    <script type="text/javascript">
        var introMsg;
        
        function initializePage() {
            document.getElementById("editButton").disabled = true;
            var songId = getQuerystring('songId', 0);

            // Get rid of the intro text if we're going to display a specific song anyway
            introMsg = document.getElementById('title').innerHTML;
            if (songId > 0)
                document.getElementById('title').innerHTML = "";

            // Now that we've decided what to do with the title area, we can 
            // display it without concern about flicker
            document.getElementById("title").style.display = "block";

            // prepare to load the list of song titles
            var list = document.getElementById('songListBox');
            var url = 'JamChartsData.svc/SongTitles';
            var selectedOption;

            // Request the song titles
            $.getJSON(url, function (data) {
                // Process the list of song titles
                list.options.length = 0;
                var songs = data['d'];

                $.each(songs, function (index, song) {
                    // Add the title to the list
                    var myOption = document.createElement("Option");
                    myOption.text = song.Title;
                    myOption.value = song.SongId;
                    list.appendChild(myOption);
                    
                    // Is this the selected song?
                    if (songId == song.SongId)
                        selectedOption = myOption;
                });
                
                // If a specific song was selected, display it
                if (songId > 0 && selectedOption) {
                    selectedOption.selected = true;
                    loadSong(songId);
                }
                else {
                    document.getElementById('title').innerHTML = introMsg;
                }
            }
            );
        }
        
        function loadSong(id) {
            //var url = 'JamChartsData.svc/Songs?$filter=startswith(Title,\'' + encodeURIComponent(title) + '\')';
            selectedSong = id;
            document.getElementById("editButton").disabled = false;
            var url = 'JamChartsData.svc/SongById?songId=' + encodeURIComponent(id);
            $.getJSON(url, function (data) {
                var song = data['d'];
                if (song['SongId'] == "0") {
                    document.getElementById('title').innerHTML = introMsg;
                    return;
                }
                document.getElementById('title').innerHTML = song['Title'];
                document.getElementById('content').innerHTML = convertText(song['Chords'].replace(/\\n/g, "\n"));

                var key = song['Key'].replace("b", "\u00D1");
                var minorIndex = key.indexOf("m");
                if (minorIndex > 0)
                    key = key.substring(0, minorIndex) + " Minor";
                else
                    key = key + " Major";

                document.getElementById('keyAndTimeSignatures').innerHTML = key + "&nbsp;" + song['Time'];
            });
        }

        var selectedSong;

    </script>
</asp:Content>
<asp:Content ID="BodyContent" runat="server" ContentPlaceHolderID="MainContent">
    <div id="main">
        <div id="inputArea" oncontextmenu="return false">
            <select id="songListBox" class="songList" onchange="loadSong(this.value);" size="20">
                <option id="loadingOption" disabled="disabled" >Loading...</option>
            </select><br/>
            <input class="actionButton" type="button" value="New" onclick="location.href='/Edit.aspx'" />
            <input class="actionButton" disabled="disabled" type="button" id="editButton" value="Edit" onclick="location.href='/Edit.aspx?songId='+ selectedSong" />
        </div>
        <div class="songArea">
            <div class="jazztext black">
                <div style="float: right; font-size:18pt;" id="keyAndTimeSignatures"></div>
                <div id="title" class="songTitle" style="display:none;"><span style="color:slategrey;">
                <span style="font-size:72pt; line-height:150%;">Welcome to JamCharts!</span><br/><br/>
                <span style="font-size:18pt;"><span style="color:darkred;">&lt;== Pick any song from the list on the left!<br/>
                or add your own songs!</span><br/><br/><br/>
                &lt;== Click the <span style="color:darkred;">New</span> button to add a song<br/>
                &lt;== Click the <span style="color:darkred;">Edit</span> button to fix a song</span></span>
                </div>
            </div>
            <div class="jamcharts black" id="content">
            </div>
        </div>
    </div>
</asp:Content>
