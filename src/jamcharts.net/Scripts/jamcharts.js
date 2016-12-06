function convertText(input) {
    return transposeText(input, 'C', 0);
}

function transposeText(input, key, transposition) {
    // This cryptic little regex ensures that all the barline characters
    // are properly tokenized, even if the raw input doesn't include spaces
    input = input.replace(/([aAbBcCdDeE&\$@]:|[|\:\[\],]+[1234]?)/g, " $1 ");
    
    // Next deal with pesky commas
    input = input.replace(/([,])/g, " $1 ");

    // Split the input into lines so we can force line breaks in output    
    var lines = input.split(/\n/);
    var result = "";
    for (var l = 0; l < lines.length; l++) {
        if (lines[l].length > 0) { // Blank lines waste too much space on output
            if (l > 0) // add breaks between lines
                result += "<br/>";
            
            // First prepreosses to remove quoted strings
            var line = RemoveQuotedStrings(lines[l]);
            
            // Split the line into tokens such as chords, barlines, etc
            var tokens = line.split(" ");
            for (var t = 0; t < tokens.length; t++) {
                var text = tokens[t]; // process the next token
                
                if (text.length > 0) { // ignore empty tokens

                    if (text == "SINGLEQUOTE" || text == "DOUBLEQUOTE") {
                        result += text + "&nbsp; ";
                    } else {

                        // Handle escaped characters
                        text = RemoveEscapedCharacters(text);

                        // Special handling if the token is a chord
                        var haveChord = false;
                        if ((text[0] >= 'A' && text[0] <= 'G') || (text[0] >= 'a' && text[0] <= 'g')) {
                            // This is to prevent the risk of call letters from being transposed
                            if (text.length == 0 || text[1] != ":")
                                haveChord = true;
                        }
                        if (haveChord) {
                            text = TransposeChord(text, key, transposition);
                            text = applyPrefixSubstitutions(scaleToneSubstitutions, text);
                        }

                        // Apply the other font-related substitutions
                        text = applySubstitutions(otherSubstitutions, text);

                        text = RestoreEscapedCharacters(text);

                        // Make sure chords don't get split across lines
                        if (haveChord)
                            result += "<span style='white-space: nowrap'>" + text + "</span> &nbsp;";
                        else
                            result += text + " ";
                    }
                }
            }

             result = RestoreQuotedStrings(result);
        }
    }
    return result;
}

var singleQuotedStringList;
var doubleQuotedStringList;

function RemoveQuotedStrings(text) {
    // Start by initializing our temp stores of escaped strings
    singleQuotedStringList = new Array();
    doubleQuotedStringList = new Array();

    return RecursiveRemoveQuotedStrings(text);
}

function RecursiveRemoveQuotedStrings(text) {
    // if nothing is quoted, there's nothing more to do
    if (text == null || (text.indexOf('\'') < 0 &&  text.indexOf('\"') < 0))
        return text;
    
    var startPos;
    var pos = 0;
    while (pos < text.length) {
        var ch = text[pos];
        if (ch == '\'') {
            startPos = pos;
            pos++;
            while (pos < text.length && text[pos] != '\'') {
                pos++;
            }
            text = ReplaceQuotedSubstring(text, startPos, pos, "SINGLEQUOTE", singleQuotedStringList);
            return RecursiveRemoveQuotedStrings(text);
        } else if (ch == '\"') {
            startPos = pos;
            pos++;
            while (pos < text.length && text[pos] != '\"') {
                pos++;
            }
            text = ReplaceQuotedSubstring(text, startPos, pos, "DOUBLEQUOTE", doubleQuotedStringList);
            return RecursiveRemoveQuotedStrings(text);
        } else {
            pos = pos + 1;
        }
    }
    return text;
}

function RestoreQuotedStrings(text) {
    for (var i = 0; i < singleQuotedStringList.length; i++) {
        text = text.replace("SINGLEQUOTE", FormatSingleQuotedString(i));
    }
    for (var j = 0; j < doubleQuotedStringList.length; j++) {
        text = text.replace("DOUBLEQUOTE", FormatDoubleQuotedString(j));
    }

    return text;
}

function FormatSingleQuotedString(index)
{
    var quote = singleQuotedStringList[index];
    return "<span class=\'quote1\'>" + quote + "</span>";
}

function FormatDoubleQuotedString(index) {
    var quote = doubleQuotedStringList[index];
    return "<span class=\'quote2\'>" + quote + "</span>";
}

function ReplaceQuotedSubstring(text, start, end, replacement, list) {
    if (end < start)
        end = text.length;
    var len = end - start - 1;
    
    var prefix = "";
    if (start > 1)
        prefix = text.substring(0, start);

    var old = "";
    if (len > 0)
        old = text.substring(start+1, end);
        
    var suffix = "";
    if (end < text.length - 1)
        suffix = text.substring(end+1);

    list.push(old);
    return prefix + " " + replacement + " " + suffix;
}

var escapedCharacterList;

function RemoveEscapedCharacters(text) {
    escapedCharacterList = new Array();
    var pos = text.indexOf('\\');
    while (pos >= 0 && text.length > pos + 1) {
        escapedCharacterList.push(text[pos + 1]); // save the escaped character for later
        var newText = "";
        if (pos > 0)
            newText = text.substring(0, pos);
        newText += "\u0001"; // swap in a placeholder that won't otherwise be used
        if (pos < text.length - 2)
            newText += text.substr(pos + 2);
        text = newText;
        pos = text.indexOf('\\');
    }
    return text;
}

function RestoreEscapedCharacters(text) {
    for (var i = 0; i < escapedCharacterList.length; i++ ) {
        text = text.replace("\u0001", escapedCharacterList[i]); // reinstate the escaped character
    }
    return text;
}

function applySubstitutions(substitutions, text) {
    for (var s = 0; s < substitutions.length; s++) {
        text = text.replace(substitutions[s][0], substitutions[s][1]);
    }
    return text;
}

function applyPrefixSubstitutions(substitutions, text) {
    for (var s = 0; s < substitutions.length; s++) {
        var pattern = substitutions[s][0];
        var match = text.substr(0, pattern.length);
        if (match == pattern)
            text = substitutions[s][1] + text.substr(pattern.length);
    }
    return text;
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

function copyValue(srcId, dstId) {
    var content = document.getElementById(dstId);
    var input = document.getElementById(srcId).value;
    content.innerHTML = convertText(input.value);
}

function getQuerystring(key, defaultValue) {
    if (defaultValue == null) defaultValue = "";
    key = key.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]");
    var regex = new RegExp("[\\?&]" + key + "=([^&#]*)");
    var qs = regex.exec(window.location.href);
    if (qs == null)
        return defaultValue;
    else
        return qs[1];
}
