/*
TransposeKey will transpose a key by a specified number of half steps.
Note that this method is not general purpose; it expects to only be
passed key signatures as provided in the JamCharts combobox. In
particular, it doesn't understand lowercase, sharps, or double flats.
*/
function TransposeKey(key, distance) {
    while (distance < 0)
        distance += 12;
    distance = distance % 12;

    for (var i = 0; i < distance; i++) {
        switch (key) {
            case 'A': key = 'Bb'; break;
            case 'Bb': key = 'B'; break;
            case 'B': key = 'C'; break;
            case 'C': key = 'Db'; break;
            case 'Db': key = 'D'; break;
            case 'D': key = 'Eb'; break;
            case 'Eb': key = 'E'; break;
            case 'E': key = 'F'; break;
            case 'F': key = 'Gb'; break;
            case 'Gb': key = 'G'; break;
            case 'G': key = 'Ab'; break;
            case 'Ab': key = 'A'; break;
        }
    }
    return key;
}

/*
TransposeChord will transpose a chord from one key using reasonable enharmonic spellings.
The idea is to choose wisely between chords like F# vs Gb without getting pedantic and
ever showing double sharps or double flats. It handles both simple chords and polychords.
*/
function TransposeChord(chord, key, distance) {
    // Handle null input
    if (chord == null || chord.length == 0)
        return "";

    // Early out if we're not transposing
    if (distance == 0)
        return chord;
    
    // Handle polychords using recursion
    if (chord.indexOf('/') != -1) {
        var parts = chord.split('/', 2);
        return TransposeChord(parts[0], key, distance) + '/' + TransposeChord(parts[1], key, distance);
    }

    // From here down, we just have to address simple chords

    // To start, parse the raw chord and return an array containing
    // the information we need to transpose it.
    var parsedElements = ParseChord(chord);

    // The [2] element of the array returned from ParseChord is the chromotic distance from A.
    // The next line calculates an offset for the stock key of the song relative to A
    var offset = 12 - ParseChord(key)[2];

    // By adding together the chromatic distance of the chord from A with the offset
    // for the stock key, we get the scale tone of the chord relative to its stock key
    var scaleTone = parsedElements[2] + offset;

    // Next we transpose the stock key to the desired key.
    var newKey = TransposeKey(key, distance);

    // Transpose the new key to the correct scale tone to get the 
    // root of transposed chord in the new key.
    var newRoot = TransposeKey(newKey, scaleTone);

    // Switch enharmonic spellings where appropriate by applying two rules:
    // 1. Only use sharps for keys that have sharps in their key signature
    // 2. Don't bother with A# and D# because that's just being pedantic
    if (newKey == 'A' || newKey == 'B' || newKey == 'D' || newKey == 'E' || newKey == 'G') {
        switch (newRoot) {
            case 'Ab': newRoot = 'G#'; break;
            //case 'Bb': scaleTone = 'A#'; break;  
            case 'Db': newRoot = 'C#'; break;
            //case 'Eb': scaleTone = 'D#'; break;  
            case 'Gb': newRoot = 'F#'; break;
        }
    }

    // The TransposeKey method always returns uppercase. But JamCharts renders uppercase
    // and lowercase chord roots differently, so might need to reinstate lowercase
    if (chord[0].toString().match(/[a-g]/))
        newRoot = newRoot.toLowerCase();

    // Having transposed the chord root, just concatenate the tail of the chord symbol
    // specifying chord tonality and alterations
    var transposedChord = newRoot + parsedElements[3];
    return transposedChord;
}

/*
ParseChord is passed a string that must be at least 1 character long starting with
an upper or lowercase letter in the range [A-Ga-g]. It returns an array with three values:
parts[0] is an integer in the range 0-6 representing the scale tone A=0 through G=6
parts[1] is an integer in the range -2..2 representing alteration for flats or sharps
parts[2] is an integer in the range 0..11 representing the chromatic value A=0 through G#/Ab=11
parts[3] is the remainder of the string after the scale tone and alterations
*/
function ParseChord(chord) {
    var parts = new Array();
    parts[0] = chord[0].toUpperCase().charCodeAt(0) - 65;
    if (chord.length >= 3) {
        if (chord.substr(1, 2) == 'bb') {
            parts[1] = -2;
            parts[3] = chord.substr(3);
        } else if (chord.substr(1, 2) == '##') {
            parts[1] = 2;
            parts[3] = chord.substr(3);
        } else if (chord.substr(1, 1) == 'b') {
            parts[1] = -1;
            parts[3] = chord.substr(2);
        } else if (chord.substr(1, 1) == '#') {
            parts[1] = 1;
            parts[3] = chord.substr(2);
        } else {
            parts[1] = 0;
            parts[3] = chord.substr(1);
        }
    } else if (chord.length == 2) {
        if (chord.substr(1) == 'b') {
            parts[1] = -1;
            parts[3] = "";
        } else if (chord.substr(1) == '#') {
            parts[1] = 1;
            parts[3] = "";
        } else {
            parts[1] = 0;
            parts[3] = chord.substr(1);
        }
    } else {
        parts[1] = 0;
        parts[3] = "";
    }

    var scaleTones = [0, 2, 3, 5, 7, 8, 10]; // Cdist from A
    parts[2] = scaleTones[parts[0]] + parts[1];
    return parts;
}
