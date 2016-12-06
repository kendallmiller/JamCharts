<%@ Page Title="JamCharts!" Language="C#" MasterPageFile="~/Responsive.Master" AutoEventWireup="true"
    CodeBehind="Default.aspx.cs" Inherits="WebSandbox.View" %>

<asp:Content ID="HeaderContent" runat="server" ContentPlaceHolderID="head">
    <style type="text/css">
        #titleSearchContainer { height: auto; font-size: 50%; width: 98%; }
        #titleSearchContainer input { width: 98%; }
        .ui-autocomplete  { font-family: verdana,helvetica,arial,sans-serif; background-color: #fff; border: solid 1px #000; 
                            font-size: 50%; max-height: 184px; overflow-y: auto; overflow-x:hidden }
        .ui-autocomplete li:hover { background-color: #3399FF; color: #fff; }
        .ui-menu-item-highlight { font-weight: bold; }
        #jamGroupName { height: auto; font-size: 50%; }
        #groupJamContainer { display: none; }
        #groupJamContainer label { display: block; }
        /* #groupJoinMessage { float: right; margin: 5px; } */
        .panelButton { float: left; margin-right: 10px; }
    </style>
    <script type="text/javascript" src="Scripts/jquery-1.8.3.min.js"></script>
    <script type="text/javascript" src="Scripts/jquery-ui-1.9.2.min.js"></script>
    <script type="text/javascript" src="Scripts/jamcharts.js"></script>
    <script type="text/javascript" src="Scripts/substitions.js"></script>
    <script type="text/javascript" src="Scripts/transpose.js"></script>
    <script type="text/javascript" src="Scripts/jquery.signalR-1.0.0-rc1.min.js"></script>
    <script type="text/javascript" src='<%: ResolveClientUrl("~/signalr/hubs") %>'></script>
    <script type="text/javascript">

        var adminRole;
        var selectedSongId;

        function initializePage() {
            fixJavaScript();

            // Be forgiving about folks mistyping the songId parameters
            var songId = getQuerystring('songId', 0);
            if (songId == 0)
                songId = getQuerystring('songid', 0);
            if (songId == 0)
                songId = getQuerystring('id', 0);

            // We'll make admin mode easy for folks who know about it, but not automatic for everyone
            adminRole = getQuerystring('admin', false);

            UpdateControlPanel(songId);
            // Get rid of the intro text if we're going to display a specific song anyway
            if (songId > 0) {
                // Get rid of the intro text if we're going to display a specific song anyway
                document.getElementById('welcome').style.display = 'none';
                loadSong(songId);
            } else {
                document.getElementById('welcome').style.display = 'block';
            }

            initializeList();
            initializeHints();

            /* these lines for local debug only 
            document.getElementById('hints').style.display = 'block';
            document.getElementById('inputArea').style.display = 'block'; 
            document.getElementById('container').style.display = 'block';
            document.getElementById('welcome').style.display = 'none';
            */
        }

        function fixJavaScript() {
            if (!Array.prototype.indexOf) {
                Array.prototype.indexOf = function (elt /*, from*/) {
                    var len = this.length >>> 0;

                    var from = Number(arguments[1]) || 0;
                    from = (from < 0) ? Math.ceil(from) : Math.floor(from);
                    if (from < 0)
                        from += len;

                    for (; from < len; from++) {
                        if (from in this && this[from] === elt)
                            return from;
                    }
                    return -1;
                };
            }
        }

        function initializeHints() {
            $('td[class=hintSample]').each(function () {
                var raw = this.innerText;
                if (raw != null && raw.length > 0) {
                    this.innerHTML = convertText(raw);
                }
            });

        }

        function initializeList() {
            // prepare to load the list of song titles
            var list = document.getElementById('songListBox');
            var url = 'Songs.asmx/SongTitles';
            var selectedOption;

            $.ajax({
                type: "POST",
                url: url,
                dataType: "json",
                contentType: "application/json; charset=utf-8",
                processData: false,
                success: function (data) {
                    // Process the list of song titles
                    list.options.length = 0;

                    var defaultOption = document.createElement("Option");
                    defaultOption.text = '-- Welcome to JamCharts! --';
                    defaultOption.value = 0;
                    list.appendChild(defaultOption);

                    var songs = data['d'];

                    $.each(songs, function (index, song) {
                        // Add the title to the list
                        var myOption = document.createElement("Option");
                        myOption.text = song.Title;
                        myOption.value = song.SongId;
                        list.appendChild(myOption);

                        // Is this the selected song?
                        if (selectedSongId == song.SongId)
                            selectedOption = myOption;
                    });

                    // If a specific song was selected, display it
                    if (selectedSongId > 0 && selectedOption) {
                        selectedOption.selected = true;
                    }
                },
                error: function (result) {
                    if (result) {
                        var err = result.responseText;
                        if (err)
                            alert('Failure: ' + err);
                        else
                            alert('Failure: Unknown server error.');
                    } else {
                        alert('Failure: Null result.');
                    }
                }
            });
        }

        function UpdateControlPanel(songId) {
            if (songId && songId > 0) {
                document.getElementById('welcome').style.display = 'none';
                document.getElementById('container').style.display = 'block';
                document.getElementById('songOptions').style.display = 'block';
                document.getElementById('bookmark').style.visibility = 'visible';
                document.getElementById('editButton').style.visibility = 'visible';
            } else {
                document.getElementById('welcome').style.display = 'block';
                document.getElementById('container').style.display = 'none';
                document.getElementById('songOptions').style.display = 'none';
                document.getElementById('bookmark').style.visibility = 'hidden';
                document.getElementById('editButton').style.visibility = 'hidden';
            }
        }

        var requestedLoad; // set true just before call to get data
        var loadingSong; // True only while get handler is active
        function loadSong(id) {
            selectedSongId = id;
            UpdateControlPanel(id);
            if (id == 0)
                return;

            var url = "Songs.asmx/SongById";
            var urldata = "{'songId': '" + id + "'}";
            requestedLoad = true;
            $.ajax({
                type: "POST",
                url: url,
                data: urldata,
                dataType: "json",
                contentType: "application/json; charset=utf-8",
                processData: false,
                success: function (data) {
                    try {
                        loadingSong = true;
                        var song = data['d'];

                        document.getElementById('title').innerHTML = song['Title'];
                        document.getElementById('titleText').value = song['Title'];
                        $('#songListBox').val(id);
                        $('#titleSearch').val("");

                        var key = song['Key'];
                        var minorIndex = key.indexOf("m");
                        if (minorIndex > 0) {
                            key = key.substring(0, minorIndex);
                            selectOption('keyChoices', key);
                            selectOption('keyTonality', "Minor");
                        } else {
                            selectOption('keyChoices', key);
                            selectOption('keyTonality', "Major");
                        }
                        UpdateKeyList(key);

                        var chords = song['Chords'].replace(/\\n/g, "\n");

                        var transposition = parseInt($('#keyTranspose')[0].options[$('#keyTranspose')[0].selectedIndex].value);
                        document.getElementById('content').innerHTML = transposeText(chords, key, transposition);
                        document.getElementById('inputText').value = chords;
                        key = TransposeKey(key, transposition);

                        if (minorIndex > 0) {
                            key = key.substring(0, minorIndex) + " Minor";
                        } else {
                            key = key + " Major";
                        }
                        key = key.replace("b", "\u00D1");

                        var time = song['Time'].split("/");
                        selectOption('beatCount', time[0]);
                        selectOption('beatUnit', time[1]);

                        document.getElementById('keyAndTimeSignatures').innerHTML = key + "&nbsp;" + song['Time'];
                    } finally {
                        requestedLoad = false;
                        loadingSong = false;
                    }
                },
                error: function (result) {
                    if (result) {
                        var err = result.responseText;
                        if (err)
                            alert('Failure: ' + err);
                        else
                            alert('Failure: Unknown server error.');
                    } else {
                        alert('Failure: Null result.');
                    }
                }
            });
        }

        function selectOption(id, value) {
            var choices = document.getElementById(id);
            for (var i = 0; i < choices.length; i++) {
                if (choices[i].value == value) {
                    choices.selectedIndex = i;
                    break;
                }
            }
        }

        $.ui.autocomplete.prototype._renderItem = function (ul, item) {

            var keywords = $.trim(this.term).split(' ').join('|');
            var output = item.label.replace(new RegExp("(" + keywords + ")", "gi"), '<span class="ui-menu-item-highlight">$1</span>');

            return $("<li>")
                .append($("<a>").html(output))
                .appendTo(ul);
        };

        $(document).ready(function () {
            initializePage();
            $(".trigger").click(function () {
                $(".panel").toggle("fast");
                $(this).toggleClass("active");
                return false;
            });
            $("#titleSearch").autocomplete({
                source: function (request, response) {
                    $.ajax({
                        type: "POST",
                        contentType: "application/json; charset=utf-8",
                        url: "/Search.asmx/SongTitlesByName",
                        dataType: "json",
                        data: "{'term':'" + request.term + "'}"
                    }).done(function (data) {
                        response($.map(data.d, function (item) {
                            return {
                                label: item.Title,
                                value: item.Id
                            };
                        }));
                    });
                },
                minLength: 2,
                focus: function (event, ui) {
                    $("#titleSearch").html(ui.item.label);
                },
                select: function (event, ui) {
                    $("#titleSearch").html(ui.item.label);
                    $("#songListBox").val(ui.item.value);
                    SelectSong(ui.item.value);
                    $("#titleSearchContainer .ui-helper-hidden-accessible").hide();
                    return false;
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    alert(textStatus);
                }
            });

            var jam = $.connection.jam;
            $.connection.hub.error(function () {
                console.log("Error in hub");
            });
            jam.client.together = function (clientId, songId) {
                console.log("client " + clientId + " wants to jam to song " + songId);
                loadSong(songId);
            };
            $.connection.hub.start()
                .done(function () {
                    $("#groupJamContainer").show();

                    $("#joinJam").click(function () {
                        var jamGroupName = $("#jamGroupName").val();
                        if (jamGroupName === "")
                            return;

                        if ($("#joinJam").val() === "Join") {
                            jam.server.joinGroup(jamGroupName)
                                .done(function () {
                                    $("#joinJam").val("Leave");
                                    $("#songListBox").change(function () {
                                        jam.server.letsJam(jamGroupName, this.value);
                                    });
                                    $(window).on("song.saved", function (event, songId) {
                                        jam.server.letsJam(jamGroupName, songId);
                                    });
                                });
                        } else {
                            jam.server.leaveGroup(jamGroupName)
                                .done(function () {
                                    $("#joinJam").val("Join");
                                    $("#songListBox").unbind("change");
                                    $(window).on("song.saved", null);
                                });
                        }
                    });
                })
                .fail(function () {
                    console.log("Could not connect to hub");
                });
        });

        function Search(searchType) {
            var title = $("#titleText").val();
            var url = "http://www.google.com/search?q=%22"; // common prefix for all searches
            switch (searchType) {
                case "lyrics":
                    url += title + "%22+lyrics";
                    break;
                case "chords":
                    url += title + "%22+chords";
                    break;
                case "youtube":
                    url += title + "%22+site:youtube.com";
                    break;
                case "spotify":
                    url += title + "%22+site:spotify.com";
                    break;
            }
            window.open(url);
        }

        function BookmarkSong() {
            var url = "http://jamcharts.net?songId=" + selectedSongId;
            window.open(url);
        }


        /* Edit Song functions */

        function inputChanged() {
            if (loadingSong)
                return;
            var content = document.getElementById('content');
            var input = document.getElementById('inputText');
            content.innerHTML = convertText(input.value);
            validateSave();
        }

        function titleChanged() {
            if (loadingSong)
                return;
            var title = document.getElementById('titleText').value;
            var key = document.getElementById('keyChoices').value.replace("b", "\u00D1");
            var tonality = document.getElementById('keyTonality').value;
            var beatCount = document.getElementById('beatCount').value;
            var beatUnit = document.getElementById('beatUnit').value;
            document.getElementById('title').innerHTML = title;
            document.getElementById('keyAndTimeSignatures').innerHTML = key + "&#160;" + tonality + "&#160;" + beatCount + "/" + beatUnit;
            validateSave();
        }

        // Only enable the Save button is we have a title and chords
        function validateSave() {
            var title = document.getElementById('titleText').value;
            var chords = document.getElementById('inputText').value;
            document.getElementById("saveButton").disabled = title == null || title.trim().length == 0 || chords == null || chords.trim().length == 0;
        }

        function copyValue(srcId, dstId) {
            var content = document.getElementById(dstId);
            var input = document.getElementById(srcId).value;
            content.innerHTML = convertText(input.value);
        }

        function encode(text) {
            var line = text.replace(/\r?\n/g, "\\n");
            var quoted = line.replace(/\'/g, "&apos;").replace(/\"/g, "&quot;").replace(/\%/g, "&#37;");
            var encoded = encodeURIComponent(quoted);
            var fullyEncoded = encoded.replace(/([\~\!\*\(\)])/g, "\$1");
            return fullyEncoded;
        }

        function PostSongToServer(song) {
            var url = "Songs.asmx/SaveSong";
            var urldata = "{'songId': " + song.songId +
                ", 'title': '" + encode(song.title) + "'" +
                ", 'key': '" + encode(song.key) + "'" +
                ", 'time': '" + encode(song.time) + "'" +
                ", 'chords': '" + encode(song.chords) + "'" +
                "}";

            $.ajax({
                type: "POST",
                url: url,
                data: urldata,
                dataType: "json",
                contentType: "application/json; charset=utf-8",
                processData: false,
                success: function (result) {
                    selectedSongId = result.d;
                    CancelEditSong();
                    initializeList();
                    $(window).trigger("song.saved", selectedSongId);
                },
                error: function (result) {
                    if (result) {
                        var err = result.responseText;
                        if (err)
                            alert('Failure: ' + err);
                        else
                            alert('Failure: Unknown server error.');
                    } else {
                        alert('Failure: Null result.');
                    }
                }
            });
        }

        function SaveSong() {
            var title = document.getElementById('titleText').value;
            var key = document.getElementById('keyChoices').value;
            var tonality = document.getElementById('keyTonality').value;
            if (tonality == "Minor")
                key += "m";
            var beatCount = document.getElementById('beatCount').value;
            var beatUnit = document.getElementById('beatUnit').value;
            var time = beatCount + "/" + beatUnit;
            var chords = document.getElementById('inputText').value;
            if (!selectedSongId || isNewSong)
                selectedSongId = 0;

            var song = {
                "songId": selectedSongId,
                "title": title,
                "key": key,
                "time": time,
                "chords": chords
            };

            PostSongToServer(song);
        }

        function AutoTransposeChanged() {
            if (!document.getElementById('autoTranspose').checked) {
                $('#keyTranspose')[0].selectedIndex = 5; // this will reset to stock key
                keyChanged();
            }
        }

        function SelectSong(songId) {
            loadSong(songId);
            if (document.getElementById('autoClose').checked)
                $('#songTriggerButton').click();
        }

        function keyChanged() {
            // Guard against event echoes due to resetting keyTranspose in loadSong
            if (loadingSong)
                return;

            keyChangeRequested = true;
            loadSong(selectedSongId);
            if (document.getElementById('autoClose').checked)
                $('#songTriggerButton').click();
        }

        var isNewSong;
        function EditSong() {
            isNewSong = false;
            document.getElementById('editSongLabel').innerText = "Edit Song";
            document.getElementById('versionHistory').style.display = 'block';

            if (adminRole)
                document.getElementById('deleteButton').style.display = 'block';
            else
                document.getElementById('deleteButton').style.display = 'none';

            LoadSongHistory(selectedSongId);
            inputChanged();
            $('#songTriggerButton').click();
            document.getElementById('songTrigger').style.display = 'none';
            $("#inputArea").slideDown("slow");
        }

        function NewSong() {
            isNewSong = true;
            document.getElementById('editSongLabel').innerText = "New Song";
            document.getElementById('versionHistory').style.display = 'none';

            document.getElementById('titleText').value = "";
            document.getElementById('keyChoices').value = "C";
            document.getElementById('keyTonality').value = "Major";
            document.getElementById('beatCount').value = "4";
            document.getElementById('beatUnit').value = "4";
            document.getElementById('keyAndTimeSignatures').innerHTML = "C Major" + "&#160;" + "4/4";
            document.getElementById('content').innerHTML = "";
            document.getElementById('inputText').value = "";
            document.getElementById('title').innerHTML = "";
            validateSave();

            document.getElementById('welcome').style.display = 'none';
            document.getElementById('container').style.display = 'block';
            $('#songTriggerButton').click();
            document.getElementById('songTrigger').style.display = 'none';
            $("#inputArea").slideDown("slow");
        }

        function CancelEditSong() {
            document.getElementById('songTrigger').style.display = 'block';
            $("#hints").slideUp("fast");
            $("#inputArea").slideUp("fast");
            loadSong(selectedSongId);
        }

        function LoadSongHistory(songId) {
            // prepare to load the list of song titles
            var list = document.getElementById('versionHistoryList');
            var url = 'Songs.asmx/SongHistoryById';
            var urldata = "{'songId': '" + songId + "'}";
            var selectedOption;
            var latestVersionId;

            // Request the song titles
            $.ajax({
                type: "POST",
                url: url,
                data: urldata,
                dataType: "json",
                contentType: "application/json; charset=utf-8",
                processData: false,
                success: function (data) {
                    // Process the list of song titles
                    list.options.length = 0;
                    var songs = data['d'];

                    $.each(songs, function (index, song) {
                        // Add the title to the list
                        var myOption = document.createElement("Option");
                        myOption.innerHTML = "&nbsp;" + song.Timestamp + "&nbsp;";
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
                },
                error: function (result) {
                    if (result) {
                        var err = result.responseText;
                        if (err)
                            alert('Failure: ' + err);
                        else
                            alert('Failure: Unknown server error.');
                    } else {
                        alert('Failure: Null result.');
                    }
                }
            });
        }

        var showingHelp = false;
        function ToggleHelp() {
            if (showingHelp) {
                showingHelp = false;
                $("#hints").slideUp("fast");
            } else {
                showingHelp = true;
                $("#hints").slideDown("slow");
            }
        }

        function DeleteVersion() {
            if (!selectedSongId || selectedSongId == 0)
                return;

            // Call the server to delete in the database
            var url = 'Songs.asmx/DeleteSongById';
            var urldata = "{'songId': '" + selectedSongId + "'}";
            $.ajax({
                type: "POST",
                url: url,
                data: urldata,
                dataType: "json",
                contentType: "application/json; charset=utf-8",
                processData: false,
                success: function (data) {

                },
                error: function (result) {
                    if (result) {
                        var err = result.responseText;
                        if (err)
                            alert('Failure: ' + err);
                        else
                            alert('Failure: Unknown server error.');
                    } else {
                        alert('Failure: Null result.');
                    }
                }
            });

            var list = document.getElementById('versionHistoryList');
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

            loadSong(selectedSongId);
            if (selectedSongId == 0) {
                initializeList();
                CancelEditSong();
                $('#songTriggerButton').click();
            }
        }

        /*
        UpdateKeyList resets the keyTranspose listbox around the specified key.
        The specified key is placed in the middle of the list.  The surrounding
        keys are shown with their chromatic distance from the stock key. This
        facilitates transposition by horn players.  For example, if you play
        alto sax (an Eb instrument), you'll always want to transpose -3.
        Non-breaking spaces are used to simulate a multicolumn listbox.
        */
        var keyChangeRequested = false;
        function UpdateKeyList(key) {
            var retainTransposition = document.getElementById('autoTranspose').checked || keyChangeRequested;
            keyChangeRequested = false;
            var list = document.getElementById('keyTranspose');
            var selectedOffset = 0;
            if (retainTransposition && list.selectedIndex >= 0) {
                selectedOffset = parseInt(list.options[list.selectedIndex].value);
            }

            list.options.length = 0;

            for (var offset = -5; offset < 7; offset++) {
                CreateKeyOption(list, key, offset, selectedOffset);
            }
        }

        function CreateKeyOption(list, key, offset, selectedOffset) {
            var option = document.createElement("Option");

            var transposedKey = TransposeKey(key, offset);
            var text;
            if (offset < 0)
                text = '\u00A0' + offset + '\u00A0\u00A0\u00A0\u00A0\u00A0' + transposedKey + '\u00A0';
            else if (offset == 0)
                text = '\u00A0\u00A0\u00A0\u00A0\u00A0\u00A0\u00A0\u00A0\u00A0' + transposedKey + '\u00A0';
            else
                text = '\u00A0+' + offset + '\u00A0\u00A0\u00A0\u00A0' + transposedKey + '\u00A0';

            option.text = text;
            option.value = offset;
            if (offset == selectedOffset)
                option.selected = true;
            list.appendChild(option);
        }
    </script>
</asp:Content>
<asp:Content ID="BodyContent" runat="server" ContentPlaceHolderID="body">
    <div id="welcome">
        <h1>Welcome to JamCharts!</h1>
        <img src="Images/band1.png" width="35%" max-width="100%" style="float: left;"/>
        <p>Are you sick of playing the same old tired three-chord tunes because the other cats don't know the changes to the hipper songs you dig? </p>
        <p>Why are you still scrawling chord changes on napkins or dragging around a dog-eared binder and killing trees making copies?</p>
        <p>Dude, it&#39;s time to join the 21st century where everyone has a tablet or a smartphone and the internet is
        everywhere you want to be.
        </p>
        <div style="clear: both;"></div>
        <h2>Pick any chart from the library<br/>or add your own songs</h2>
        <img src="Images/band2.png" width="30%" max-width="100%" style="float: left;"/>
        <p>In the same time you'd waste scribbling changes on a sheet of paper,
        you could enter a tune in JamCharts and have it available to everyone, everywhere, forever.</p>
        <p>Think of JamCharts as Wikipedia for chord charts. Anyone can create or edit any page.
        A full change history is maintained for every song, so it's easy to undo mistakes.</p>
        <div style="clear: both;"></div>
        <h2>Wanna Help Make JamCharts Better?</h2>
        <img src="Images/band3.png" width="30%" max-width="100%" style="float: left;"/>
        <p>JamCharts is a labor of love. It will always remain completely free and unblemished by banner ads.
            Hosting is sponsored by <a href="http://www.GibraltarSoftware.com">Gibraltar Software</a>.
            The site is maintained by <a href="http://www.linkedin.com/in/jaycincotta">Jay Cincotta</a> and a group of other hacker/musicians
        who generously donate their time and talents.</p>
        <p>We have a backlog of feature ideas a mile long, but our time is limited. If you'd like to help,
        please <a href="mailto:Jay.Cincotta@GibraltarSoftware.com">email Jay</a>.</p>
        <p>Special thanks to Richard Sigler for bringing "Real Book" fonts to the web.
        You can check out Richard's work at <a href="http://www.jazzfont.com">Sigler Music Fonts</a>.</p>
    </div>
    <div id="hints">
        <div style="float: right"><span class="secondaryLink" style="font-size: .75em;"><a onclick="ToggleHelp();">Close&nbsp;</a></span></div>
        <h2 style="margin-top:0px;">Hints for entering songs into JamCharts</h2>
        <p>The basic idea of JamCharts is to make plain text chord charts pretty. Examples of all the characters it recognizes are shown below. In addition, you can hit <span class="character">Enter</span> to force line breaks. Give it a try!
        </p>
        <div class="hint">
            Use <span class="character">A</span> - <span class="character">G</span> or <span class="character">a</span> - <span class="character">g</span> for chord tones<br/>
            Uppercase is bolder, lowercase cleaner
            <table>
                <tr><th>as Typed</th><th>as Shown</th></tr>
                <tr><td>A B C D E F G</td><td class="hintSample">A B C D E F G</td></tr>
                <tr><td>a b c d e f g</td><td class="hintSample">a b c d e f g</td></tr>
            </table>
        </div>
        <div class="hint">
            Use <span class="character">pipe</span> for barlines, <span class="character">square brackets</span><br/>
            for sections and <span class="character">colon</span> for repeats
            <table>
                <tr><th>as Typed</th><th>as Shown</th></tr>
                <tr><td>[ G | C D ]</td><td class="hintSample">[ G | C D ]</td></tr>
                <tr><td>[: G | C D :]</td><td class="hintSample">[: G | C D :]</td></tr>
            </table>
        </div>
        <div style="clear:both;"></div>
        <div class="hint">
            Use <span class="character">lowercase b</span> for flat<br />
            and <span class="character">pound</span> for sharp
            <table>
                <tr><th>as Typed</th><th>as Shown</th></tr>
                <tr><td>Bb-7b5 F#7#9</td><td class="hintSample">Bb-7b5 F#7#9</td></tr>
            </table>
        </div>
        <div class="hint">
            Use <span class="character">caret</span> for major chords<br />
            and <span class="character">dash</span> for minor chords
            <table>
                <tr><th>as Typed</th><th>as Shown</th></tr>
                <tr><td>G^7 A-7</td><td class="hintSample">G^7 A-7</td></tr>
            </table>
        </div>
        <div class="hint">
            Use <span class="character">lowercase o</span> and <span class="character">zero</span> for<br />
            full and half-diminshed chords
            <table>
                <tr><th>as Typed</th><th>as Shown</th></tr>
                <tr><td>Co7 D07</td><td class="hintSample">Co7 D07</td></tr>
            </table>
        </div>
        <div style="clear:both;"></div>
        <div class="hint">
            Use <span class="character">pipe</span> with <span class="character">1</span> - <span class="character">4</span><br/>
            for numbered endings
            <table>
                <tr><th>as Typed</th></tr>
                <tr><td>|1 C D :|2 G7</td></tr>
                <tr><th>as Shown</th></tr>
                <tr><td class="hintSample" style="padding-top: .75em;">|1 C D :|2 G7</td></tr>
            </table>
        </div>
        <div class="hint">
            Use percent signs to repeat<br/>the previous 1, 2 or 4 bars
            <table>
                <tr><th>as Typed</th></tr>
                <tr><td>[ C | % | %% | %%%% ]</td></tr>
                <tr><th>as Shown</th></tr>
                <tr><td class="hintSample" style="padding-top: .5em;">[ C | % | %% | %%%% ]</td></tr>
            </table>
        </div>
        <div class="hint">
            Use <span class="character">slash</span> for polychords<br />
            and <span class="character">comma</span> for beats
            <table>
                <tr><th>as Typed</th></tr>
                <tr><td>f,f7/a, | bb,,,g7/b</td></tr>
                <tr><th>as Shown</th></tr>
                <tr><td class="hintSample" style="padding-top: .25em;">f,f7/a, | bb,,,g7/b</td></tr>
            </table>
        </div>
        <div style="clear:both;"></div>
        <div class="hint">
            Use <span class="character">A</span> - <span class="character">E</span> with <span class="character">colon</span><br/>
            for section labels
            <table>
                <tr><th>as Typed</th></tr>
                <tr><td>A: B: C: D: E:</td></tr>
                <tr><th>as Shown</th></tr>
                <tr><td class="hintSample" style="padding-top: 1em;">A: B: C: D: E:</td></tr>
            </table>
        </div>
        <div class="hint">
            Use <span class="character">ambersand</span> and <span class="character">dollar</span> <br/>
            for segno and coda symbols
            <table>
                <tr><th>as Typed</th></tr>
                <tr><td>@: @  $: $</td></tr>
                <tr><th>as Shown</th></tr>
                <tr><td class="hintSample" style="padding-top: 1em;">@: @   $: $</td></tr>
            </table>
        </div>
        <div style="clear:both;"></div>
        <div class="hint">
            Use <span class="character">single quotes</span> around<br/>
            small grey annotations
            <table>
                <tr><th>as Typed</th><th>as Shown</th></tr>
                <tr><td>'Vamp till cue'</td><td class="hintSample">'Vamp till cue'</td></tr>
            </table>
        </div>
        <div class="hint">
            Use <span class="character">double quotes</span> around<br/>
            large black annotations
            <table>
                <tr><th>as Typed</th><th>as Shown</th></tr>
                <tr><td>"Intro:"</td><td class="hintSample">"Intro:"</td></tr>
            </table>
        </div>
        <div style="clear:both;"></div>
    </div>
    <div id="inputArea" oncontextmenu="return false">
        <div class="editGroupbox">
            <div style="font: normal 100% jazztext;">
                <div style="float: right;  padding-right:2%;"><span class="secondaryLink" style="font-size: 1em;"><a id="helpButton" onclick="ToggleHelp();">Help</a></span></div>
                <h2 style="font-size: 100%; margin-top: 0; padding-top: 0;" id="editSongLabel">Edit Song</h2>
            </div>
            <div>
                <input class="inputControl" type="text" id="titleText" spellcheck="false" placeholder="Song Title" onkeyup="titleChanged();" />
            </div>
            <div style="padding-top: .25em;">
                <div id="versionHistory" style="float: right; padding-right: 2%;">
                    <span class="annotation">Version:</span>
                    <select class="inputControl" id="versionHistoryList" onchange="loadSong(this.value);">
                        <option id="Option1" disabled="disabled" >Loading...</option>
                    </select>
                    <input id="deleteButton" class="deleteButton" type="button" value="Delete" onclick="DeleteVersion();" />       
                </div>
                <div style="float: left; padding-right: 2%;">
                    <span class="annotation">Key:</span>
                    <select class="inputControl" id="keyChoices" onchange="titleChanged();">
                        <option value="C" selected="selected">C</option>
                        <option value="Db">Db</option>
                        <option value="D">D</option>
                        <option value="Eb">Eb</option>
                        <option value="E">E</option>
                        <option value="F">F</option>
                        <option value="Gb">Gb</option>
                        <option value="G">G</option>
                        <option value="Ab">Ab</option>
                        <option value="A">A</option>
                        <option value="Bb">Bb</option>
                        <option value="B">B</option>
                    </select>
                    <select class="inputControl" id="keyTonality" onchange="titleChanged();">
                        <option value="Major" selected="selected">Major</option>
                        <option value="Minor">Minor</option>
                    </select>
                </div>
                <div>
                    <span class="annotation">Time:</span>
                    <select class="inputControl" id="beatCount" onchange="titleChanged();">
                                <option value="2">2</option>
                                <option value="3">3</option>
                                <option value="4" selected="selected">4</option>
                                <option value="5">5</option>
                                <option value="6">6</option>
                                <option value="7">7</option>
                                <option value="8">8</option>
                                <option value="9">9</option>
                                <option value="10">10</option>
                                <option value="11">11</option>
                                <option value="12">12</option>
                                <option value="13">13</option>
                                <option value="14">14</option>
                                <option value="15">15</option>
                    </select>
                    <label>/</label>
                    <select class="inputControl" id="beatUnit" onchange="titleChanged();">
                        <option value="2">2</option>
                        <option value="4" selected="selected">4</option>
                        <option value="8">8</option>
                        <option value="16">16</option>
                    </select>
                </div>
            </div>
            <div>
                <textarea class="inputText" spellcheck="false" placeholder="Chord Changes" id="inputText" rows="12" cols="82" onchange="inputChanged();" onkeyup="inputChanged()"></textarea>
            </div>
            <div style="clear: both; margin-top: 1%">
                <input class="editButton" type="button" value="Save" id="saveButton" disabled="disabled" onclick="SaveSong();" />
                <input class="editButton" type="button" value="Cancel" onclick="CancelEditSong();" />
                <div>
                    <span class="secondaryLink" style="font-size: .75em;"><a id="A1" onclick="Search('lyrics');">Lyrics</a></span>&nbsp;
                    <span class="secondaryLink" style="font-size: .75em;"><a id="A4" onclick="Search('spotify');">Spotify</a></span>
                    <span class="secondaryLink" style="font-size: .75em;"><a id="A3" onclick="Search('youtube');">YouTube</a></span>&nbsp;
                    <span class="secondaryLink" style="font-size: .75em;"><a id="A2" onclick="Search('chords');">Chords</a></span>&nbsp;
                    <span class="annotation" style="float: right">Search:</span>
                </div>
            </div>
        </div>
    </div>        
    <div id="container">
        <div class="songArea">
            <div id="title" class="songTitle"></div>
            <div id="keyAndTimeSignatures" class="songInfo"></div>
            <div class="jamcharts songChords" id="content"></div>
        </div>
    </div>
    <div class="panel">
        <h1 style="margin-top: 0px; margin-bottom: 0px;">JamCharts!</h1>
        <p style="color: #000; text-align: center; margin-bottom: .25%; margin-top: 0.5%;" >Select a song from the list or add a new one</p>
        <div class="groupbox" style="margin-top: 0;">
            <div class="boxLabel">
                <h2>Song</h2>
                <label class="checkboxLabel"><input type="checkbox" id="autoClose" /> Auto-close</label>
            </div>
            <div class="boxContent">
                <span id="bookmark" class="secondaryLink" style="float: right; visibility: visible; margin-top: 0; margin-bottom: 0;"><a onclick="BookmarkSong();">Display in new window</a></span>
                <select id="songListBox" class="songList" onchange="SelectSong(this.value);" size="1">
                    <option id="loadingOption" disabled="disabled" >Loading...</option>
                </select>
                
                <div id="titleSearchContainer" class="ui-widget">
                    <input id="titleSearch" placeholder="Search"/>
                </div>

                <div style="clear:both;"></div>
                <input id="newButton" class="panelButton" type="button" value="New" onclick="NewSong();" />
                <input id="editButton" class="panelButton" type="button" value="Edit" onclick="EditSong();" />
            </div>         
        </div>        
        <div id="songOptions">
            <p style="color: #000; text-align: center; margin-bottom: .25%; margin-top: 1.5%;" >Transpose any song to any key</p>
            <div class="groupbox" style="margin-top: 0;">
                <div class="boxLabel">
                    <h2>Key</h2>
                    <label class="checkboxLabel"><input type="checkbox" id="autoTranspose" onchange="AutoTransposeChanged();" /> Auto-transpose</label>
                </div>
                <div class="boxContent">
                    <div style="float: left; margin-right: 5%;">
                        <select class="transposeSelect" id="keyTranspose" onchange="keyChanged();">
                            <option value="-5">&nbsp;-5&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;G&nbsp;</option>
                            <option value="-4">&nbsp;-4&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Ab&nbsp;</option>
                            <option value="-3">&nbsp;-3&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;A&nbsp;</option>
                            <option value="-2">&nbsp;-2&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Bb&nbsp;</option>
                            <option value="-1">&nbsp;-1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;B&nbsp;</option>
                            <option value="0" selected="selected">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;C&nbsp;</option>
                            <option value="1">&nbsp;+1&nbsp;&nbsp;&nbsp;&nbsp;Db&nbsp;</option>
                            <option value="2">&nbsp;+2&nbsp;&nbsp;&nbsp;&nbsp;D&nbsp;</option>
                            <option value="3">&nbsp;+3&nbsp;&nbsp;&nbsp;&nbsp;Eb&nbsp;</option>
                            <option value="4">&nbsp;+4&nbsp;&nbsp;&nbsp;&nbsp;E&nbsp;</option>
                            <option value="5">&nbsp;+5&nbsp;&nbsp;&nbsp;&nbsp;F&nbsp;</option>
                            <option value="6">&nbsp;+6&nbsp;&nbsp;&nbsp;&nbsp;Gb&nbsp;</option>
                        </select>
                    </div>
                    <div style="float:left;">
                    <span class="annotation" style="font-family: jazztext; font-size:50%;">Horn players: Try Auto-Transpose!<br/>-3 for E&#x00D1; horns, +2 for B&#x00D1 horns</span>
                    </div>
                </div>
            </div>
        </div>

        <p style="color: #000; text-align: center; margin-bottom: .25%; margin-top: 1.5%;" >Synchronize Song Selection with your Jam Buddies</p>
        <div class="groupbox" style="margin-top: 0;">
            <div id="groupJamContainer">
                <div class="boxLabel">
                    <h2>Live Jam</h2>
                </div>
                <div class="boxContent">
<%--                    <label for="jamGroupName">Group Name</label>--%>
<%--                    <span id="groupJoinMessage"></span>--%>
                    <input type="button" class="panelButton" id="joinJam" value="Join" />
                    <input type="text" id="jamGroupName" style="margin-top: .25em;"/>
                </div>
            </div>
        </div>
        <div style="clear:both;"></div>
    </div>
    <div id="songTrigger">
        <a id="songTriggerButton" class="trigger" href="#"><br/>songs<br/>&nbsp;</a>
    </div>
</asp:Content>
