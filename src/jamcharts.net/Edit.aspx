<%@ Page Title="Edit Song" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true"
    CodeBehind="Edit.aspx.cs" Inherits="WebSandbox._Default" %>

<asp:Content ID="HeaderContent" runat="server" ContentPlaceHolderID="HeadContent">
    <script type="text/javascript" src="Scripts/jquery-1.8.2.min.js"></script>
    <script type="text/javascript">

        function initializePage() {
            latestVersionId = getQuerystring('latestVersion', 0);
            var songId = getQuerystring('songId', 0);
            if (songId > 0)
                loadSong(songId);
        }

        function loadSong(id) {
            selectedSongId = id;
            var url = 'JamChartsData.svc/SongById?songId=' + encodeURIComponent(id);
            $.getJSON(url, function (data) {
                var song = data['d'];
                document.getElementById('titleText').value = song['Title'];
                document.getElementById('inputText').value = song['Chords'].replace(/\\n/g, "\n");

                var key = song['Key'];
                var minorIndex = key.indexOf("m");
                if (minorIndex > 0) {
                    key = key.substring(0, minorIndex);
                    document.getElementById('minorkey').checked = true;
                }

                selectOption('keyChoices', key);

                var time = song['Time'].split("/");
                selectOption('beatCount', time[0]);
                selectOption('beatUnit', time[1]);

                titleChanged();
                inputChanged();
                document.getElementById("historyButton").disabled = false;
            }
            );
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

        function fontSizeChanged() {
            var fontSize = document.getElementById("fontsize").value;
            document.getElementById("content").style.fontSize = fontSize;
        }

        function lineHeightChanged() {
            var lineHeight = document.getElementById("lineheight").value;
            document.getElementById("content").style.lineHeight = lineHeight;
        }

        function cycleSelectedOption(e, id) {
            e = e || window.event; //window.event for IE
            var change = 1;
            if (e.button == 2) { // detect right-click
                change = -1;
            }

            var element = document.getElementById(id);
            element.selectedIndex = (element.selectedIndex + change + element.options.length) % element.options.length;

            if (id == 'fontsize') {
                fontSizeChanged();
            } else if (id == 'lineheight') {
                lineHeightChanged();
            } else {
                titleChanged();
            }
        }

        function inputChanged() {
            var content = document.getElementById('content');
            var input = document.getElementById('inputText');
            content.innerHTML = convertText(input.value);
            validateSave();
        }
        
        function titleChanged() {
            var title = document.getElementById('titleText').value;
            var key = document.getElementById('keyChoices').value.replace("b", "\u00D1");
            var tonality = " Major";
            if (document.getElementById('minorkey').checked)
                tonality = " Minor";
            var beatCount = document.getElementById('beatCount').value;
            var beatUnit = document.getElementById('beatUnit').value;
            document.getElementById('title').innerHTML = title;
            document.getElementById('keyAndTimeSignatures').innerHTML = key + tonality + "&#160;" + beatCount + "/" + beatUnit;
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

        function SaveSong() {
            var title = document.getElementById('titleText').value;
            var key = document.getElementById('keyChoices').value;
            if (document.getElementById('minorkey').checked)
                key += "m";
            var beatCount = document.getElementById('beatCount').value;
            var beatUnit = document.getElementById('beatUnit').value;
            var time = beatCount + "/" + beatUnit;
            var chords = document.getElementById('inputText').value;
            
            var frm = document.getElementById('myForm');
            if (frm) {
                document.getElementById('<%=SongId.ClientID%>').value = selectedSongId;
                document.getElementById('<%=SongTitle.ClientID%>').value = title;
                document.getElementById('<%=SongKey.ClientID%>').value = key;
                document.getElementById('<%=SongTime.ClientID%>').value = time;
                document.getElementById('<%=SongChords.ClientID%>').value = chords;
                document.getElementById('<%=SongLyrics.ClientID%>').value = null;
                frm.submit();
            }
        }

        var latestVersionId;
        var selectedSongId;
       
        function CancelSong() {
            if (latestVersionId && latestVersionId > 0)
                location.href = '/Default.aspx?songId=' + latestVersionId;
            else if (selectedSongId)
                location.href = '/Default.aspx?songId=' + selectedSongId;
            else
                location.href = '/Default.aspx';
        }

        function ViewHistory() {
            if (selectedSongId)
                location.href = '/History.aspx?songId=' + selectedSongId;
            else
                location.href = '/Default.aspx';
        }


    </script>
    <script type="text/javascript" src="Scripts/jamcharts.js"></script>
    <script type="text/javascript" src="Scripts/substitions.js"></script>
</asp:Content>
<asp:Content ID="BodyContent" runat="server" ContentPlaceHolderID="MainContent" EnableViewState="false">
    <div id="main">
        <div id="inputArea" oncontextmenu="return false">
            <asp:HiddenField runat="server" ID="SongId" />
            <asp:HiddenField runat="server" ID="SongTitle" />
            <asp:HiddenField runat="server" ID="SongKey" />
            <asp:HiddenField runat="server" ID="SongTime" />
            <asp:HiddenField runat="server" ID="SongChords" />
            <asp:HiddenField runat="server" ID="SongLyrics" />
            <table>
                <tr>
                    <td>
                        <label>
                            Title</label>
                    </td>
                    <td>
                        <input class="inputControl" type="text" id="titleText" onkeyup="titleChanged();" />
                    </td>
                </tr>
                <tr>
                    <td>
                        <label onmousedown="cycleSelectedOption(event, 'keyChoices');">
                            Key</label>
                    </td>
                    <td>
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
                        <input type="radio" checked="checked" name="tonality" onclick="titleChanged();" />
                        Major
                        <input type="radio" id="minorkey" name="tonality" onclick="titleChanged();" />
                        Minor
                    </td>
                </tr>
                <tr>
                    <td>
                        <label>
                            Time</label>
                    </td>
                    <td>
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
                        /
                        <select class="inputControl" id="beatUnit" onchange="titleChanged();">
                            <option value="2">2</option>
                            <option value="4" selected="selected">4</option>
                            <option value="8">8</option>
                            <option value="16">16</option>
                        </select>
                    </td>
                </tr>
                <tr>
                    <td>
                        <label onmousedown="cycleSelectedOption(event, 'fontsize');">
                            Font</label>
                    </td>
                    <td>
                        <select class="inputControl" id="fontsize" onchange="fontSizeChanged();">
                            <option value="12pt">12</option>
                            <option value="14pt">14</option>
                            <option value="16pt">16</option>
                            <option value="18pt">18</option>
                            <option value="20pt">20</option>
                            <option value="22pt">22</option>
                            <option value="24pt" selected="selected">24</option>
                            <option value="30pt">30</option>
                            <option value="36pt">36</option>
                            <option value="42pt">42</option>
                            <option value="48pt">48</option>
                            <option value="54pt">54</option>
                            <option value="60pt">60</option>
                            <option value="66pt">66</option>
                            <option value="72pt">72</option>
                        </select>
                        <label onmousedown="cycleSelectedOption(event, 'lineheight');">
                            Space</label>
                        <select class="inputControl" id="lineheight" onchange="lineHeightChanged();">
                            <option value="225%">Narrow</option>
                            <option selected="selected" value="275%">Normal</option>
                            <option value="325%">Wide</option>
                        </select>
                    </td>
                </tr>
            </table>
            <textarea class="inputText" id="inputText" rows="60" cols="30" onkeyup="inputChanged();"
                onchange="inputChanged();"></textarea><br />
            <input id="saveButton" disabled="disabled" class="actionButton" type="submit" value="Save" onclick="SaveSong();" />
            <input id="historyButton" disabled="disabled" class="actionButton" type="button" value="History" onclick="ViewHistory()" />
            <input class="actionButton" type="button" value="Cancel" onclick="CancelSong();" />

        </div>
        <div class="songArea">
            <div class="jazztext black">
                <div style="float: right; font-size: 18pt;" id="keyAndTimeSignatures"></div>
                <div id="title" class="songTitle"></div>
            </div>
            <div class="jamcharts black" id="content"></div>
        </div>
    </div>
    <asp:EntityDataSource ID="EntityDataSource1" runat="server" ConnectionString="name=jamchartsEntities"
        DefaultContainerName="jamchartsEntities" EnableFlattening="False" EntitySetName="Songs">
    </asp:EntityDataSource>
</asp:Content>
