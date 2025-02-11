import QtQuick 2.1
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import MuseScore 3.0

//==================
// MuseScore 4.4+
//

MuseScore {
      version: "4.4"
      description: "Puts the valvenumber under the note."
      title: "Brass Tabs Plugin"
      thumbnailName: "brass.jpeg"
      pluginType: "dialog"
      requiresScore: true
      implicitHeight: 350;
      implicitWidth: 300 ; 

      property bool null_as_no_valve: true       
      property bool trompetcheck_visible: true
      property int valves: 3
     
      GridLayout 
      {
            id: walkingBassMainLayout
            columns: 2
            rowSpacing: 0
            anchors.fill: parent
            anchors.leftMargin: 5
            anchors.rightMargin: 5

            Label 
            {
                  Layout.columnSpan: 2
                  font.italic: true
                  text: "Only selected Notes will be affected.\nSelect Notes first than run the script."
                  bottomPadding: 10
            }

            ColumnLayout {
                  Layout.columnSpan: 2
                  RadioButton {
                        id: trompet
                        checked: true
                        text: "Trumpet"
                        onClicked: checkbox_visibility()
                  }
                  RadioButton {
                        id: trombone
                        text: "Trombone"
                        onClicked: checkbox_visibility()
                  }
                  RadioButton {
                        id: f_tuba
                        text: "Tuba(F)"
                        onClicked: checkbox_visibility()
                  }
                  RadioButton {
                        id: debug
                        text: "tpc and pitch and octave"
                        onClicked: checkbox_visibility()
                  }
            }

            ColumnLayout {
                  visible: f_tuba.checked || trompet.checked
                  RadioButton {
                        checked: true
                        text: "3 Valves"
                        onClicked: valves = 3
                  }
                  RadioButton {
                        text: "4 Valves"
                        onClicked: valves = 4
                  }
            }

            CheckBox 
            {
                  text: "write '0' for no valve"
                  checked: null_as_no_valve
                  visible: trompetcheck_visible
                  onClicked: { 
                        null_as_no_valve = !null_as_no_valve; 
                  }
            }
            
            RoundButton 
            {
                  id: aboutButton
                  text: "Help on Github"
                  radius: 5
                  onClicked: Qt.openUrlExternally("https://github.com/stefancs50/brass_tabs/blob/main/README.md")
            }

            RoundButton 
            {
                  text: qsTranslate("PrefsDialogBase", "Run")
                  font.bold: true
                  radius: 5
                  onClicked: writeValves()
            }
      }


      function checkbox_visibility()
      {
            trompetcheck_visible = (trompet.checked || f_tuba.checked ) ? true : false; 
      }

      function handleNote(note, staffIdx)
      {
            var tick = note.parent.parent.tick;
      
            var cursor = curScore.newCursor();
            cursor.rewind(1);
            cursor.staffIdx = staffIdx;
            cursor.rewindToTick(tick);
            
            var lyr = newElement(Element.LYRICS);
            lyr.text = getvalve(note.tpc, note.pitch);
            lyr.track = note.track ;
            cursor.add(lyr);
      }

      function getvalve(pct, pitch){
            var o = getOctave(pitch);   
            if(trompet.checked){
                  var trumpet_valvemap = { 52: "123", 53: "13", 54: "23", 55: "12", 56: "1", 57: "2", 58: "0", 59: "123", 60: "13", 61: "23", 62: "12", 63: "1",
                                          64: "2", 65: "0", 66: "23", 67: "12", 68: "1", 69: "2", 70: "0", 71: "12", 72: "1", 73: "2", 74: "0", 75: "1", 76: "2",
                                          77: "0", 78: "23", 79: "12", 80: "1", 81: "2", 82: "0", 83: "12", 84: "1", 85: "2"  };
                  return trumpet_valvemap[pitch] || 'p'+pitch;
            }
		if(trombone.checked){
                  var positionMap = { 40: "7",41: "6",42: "5",43: "4",44: "3",45: "2",46: "1",47: "7\nV2",48: "6\nV1",49: "5",50: "4",
                              51: "3",52: "2",53: "1",54: "5",55: "4",56: "3",57: "2",58: "1",59: "4",60: "3",61: "2",
                              62: "1\n(4)", 63: "3",64: "2",65: "1",66: "3+",67: "2+\n(4)",68: "(1)\n3",69: "1",70: "3",71: "2" };
                  return positionMap[pitch] || 'p'+pitch;                
            }
            if(f_tuba.checked){
                  var tuba_valveMap = { 35: "123",36: "13",37: "23",38: "12",39: "1",40: "2",41: "0",
                              42: "123",43: "13",44: "23",45: "12",46: "1",47: "2",48: "0",49: "23",
                              50: "12",51: "1",52: "2",53: "0",54: "12",55: "1",56: "2",57: "0",
                              58: "1",59: "2",60: "0",61: "23",62: "12",63: "1",64: "2",65: "0" };

                  return replaceValves(tuba_valveMap[pitch]) || 'p'+pitch; 
            }
            if(debug.checked){
                  return pct+'\n'+pitch+'\n'+o;
            }
      }

      function replaceValves(string_valve) {
            if(!null_as_no_valve && string_valve === "0"){
                  return "";
            }
            if(valves == 3){
                  return string_valve;
            }
            if(valves == 4){
                  return (string_valve == "123") ? "24": (string_valve == "13") ? "4" : string_valve;
            }
      }

      function pitchToNoteName(pitch) {

            var noteNames = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"];
            var note = noteNames[pitch % 12];  // Notenname berechnen
            var octave = Math.floor(pitch / 12) - 1;  // Oktave berechnen
            return note + octave;
      }

      //Trompete C1 = Octave 4
	function getOctave(pitch){
		var transposedPitch = pitch + 2;
		return (Math.floor(transposedPitch / 12) - 1);
	}
      
      function getLine(note, parts){
            for (var y = 0; y < parts.length; y++){
                  if(parts[y].longName === note.staff.part.longName){
                        return y;               
                  }
            }
      }

      function writeValves()
      {
            curScore.startCmd();
            
            var len = curScore.selection.elements.length;
            var parts = curScore.parts;
            
            if(len > 0)
            {
                  for (var i = 0; i < len; i++)
                  {
                        var note = curScore.selection.elements[i];
                        if(note.name == 'Note'){         
                              handleNote(note, getLine(note, parts))
                        }
                  }
            }
            curScore.endCmd();
	      quit();
      }
}