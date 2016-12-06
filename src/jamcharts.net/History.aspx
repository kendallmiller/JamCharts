<%@ Page Title="Song Version History" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true"
    CodeBehind="History.aspx.cs" Inherits="WebSandbox._Default" %>

<asp:Content ID="HeaderContent" runat="server" ContentPlaceHolderID="HeadContent">
    <script type="text/javascript" src="Scripts/jquery-1.8.2.min.js"></script>
    <script type="text/javascript" src="Scripts/jamcharts.js"></script>
    <script type="text/javascript" src="Scripts/substitions.js"></script>
    <script type="text/javascript">
        function initializePage() {
            document.getElementById("editButton").disabled = true;
            var songId = getQuerystring('songId', 0);

            // Redirect to home page if no parameter provided
            if (songId == 0)
                location.href = '/Default.aspx';

            // Now that we've decided what to do with the title area, we can 
            // display it without concern about flicker
            document.getElementById("title").style.display = "block";

            // prepare to load the list of song titles
            var list = document.getElementById('songListBox');
            var url = 'JamChartsData.svc/SongHistoryById?songId=' + encodeURIComponent(songId);
            var selectedOption;

            // Request the song titles
            $.getJSON(url, function (data) {
                // Process the list of song titles
                list.options.length = 0;
                var songs = data['d'];

                $.each(songs, function (index, song) {
                    // Add the title to the list
                    var myOption = document.createElement("Option");
                    myOption.text = song.Timestamp;
                    myOption.value = song.SongId;
                    list.appendChild(myOption);

                    // Is this the selected song?
                    if (songId == song.SongId)
                        selectedOption = myOption;

                    if (!latestVersionId)
                        latestVersionId = song.SongId;
                });

                // If a specific song was selected, display it
                if (songId > 0 && selectedOption) {
                    selectedOption.selected = true;
                    loadSong(songId);
                }

                if (list.options.length == 0)
                    location.href = "/Default.aspx";
            }
            );
        }
        
        function loadSong(id) {
            //var url = 'JamChartsData.svc/Songs?$filter=startswith(Title,\'' + encodeURIComponent(title) + '\')';
            selectedSongId = id;
            document.getElementById("editButton").disabled = false;
            var url = 'JamChartsData.svc/SongById?songId=' + encodeURIComponent(id);
            $.getJSON(url, function (data) {
                var song = data['d'];
                document.getElementById('historyTitle').innerHTML = song['Title'];
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

        var latestVersionId;
        var selectedSongId;

        function CancelSong() {
            if (selectedSongId)
                location.href = '/View.aspx?songId=' + selectedSongId + "&latestVersion=" + latestVersionId;
            else
                location.href = '/View.aspx';
        }

        function DeleteSong() {
            if (!selectedSongId || selectedSongId == 0)
                return;

            // Call the server to delete in the database
            var url = 'JamChartsData.svc/DeleteSongById?songId=' + encodeURIComponent(selectedSongId);
            $.getJSON(url, function () { });

            var list = document.getElementById('songListBox');
            var selectedIndex = list.selectedIndex;
            var selectedOption = list.options[selectedIndex];
            if (selectedOption)
                list.removeChild(selectedOption);
            if (selectedIndex >= 0 && selectedIndex < list.options.length)
                list.selectedIndex = selectedIndex;
            else if (list.options.length > 0)
                list.selectedIndex = list.options.length - 1;

            selectedIndex = list.selectedIndex;
            if (selectedIndex < 0)
                selectedSongId = 0;
            else {
                selectedOption = list.options[selectedIndex];
                selectedSongId = selectedOption.value;
            }
        }
        
    </script>
</asp:Content>
<asp:Content ID="BodyContent" runat="server" ContentPlaceHolderID="MainContent">
    <div id="main">
        <div id="inputArea" oncontextmenu="return false">
            <div id="historyTitle" class="jazztextLabel">Version History</div>
            <select id="songListBox" class="songList" onchange="loadSong(this.value);" size="20">
                <option id="loadingOption" disabled="disabled" >Loading...</option>
            </select><br/>
            <input class="actionButton" type="button" id="editButton" value="Edit" onclick="location.href='/Edit.aspx?songId='+ selectedSongId + '&amp;latestVersion=' + latestVersionId" />
            <input class="actionButton" type="button" value="Delete" onclick="DeleteSong();" />
            <input class="actionButton" type="button" value="Return" onclick="CancelSong();" />
        </div>
        <div class="songArea">
            <div class="jazztext black">
                <div style="float: right; font-size:18pt;" id="keyAndTimeSignatures"></div>
                <div id="title" class="songTitle"></div>
            </div>
            <div class="jamcharts black" id="content"></div>
        </div>
    </div>
</asp:Content>
