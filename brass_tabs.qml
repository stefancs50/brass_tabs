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
      categoryCode: "lyrics"
      thumbnailName: "brass.jpeg"
      pluginType: "dialog"
      requiresScore: true
      implicitHeight: 350;
      implicitWidth: 300 ; 

      property bool null_as_no_valve: true       
      property bool trompetcheck_visible: true

      GridLayout 
      {
            id: walkingBassMainLayout
            columns: 1
            rowSpacing: 0
            anchors.fill: parent
            anchors.leftMargin: 5
            anchors.rightMargin: 5

            Label 
            {
                  font.italic: true
                  text: "Only selected Notes will be affected.\nSelect Notes first than run the script."
                  bottomPadding: 10
            }

            ColumnLayout {
                  RadioButton {
                        id: trompet
                        checked: true
                        text: "Trumpet"
                        onClicked: checkbox_visibility()
                  }
                  RadioButton {
                        id: tenorhorn
                        text: "Tenorhorn"
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
                  text: qsTranslate("PrefsDialogBase", "Run")
                  font.bold: true
                  radius: 5
                  onClicked: writeValves()
            }

      }

      function checkbox_visibility()
      {
            trompetcheck_visible = (trompet.checked || f_tuba.checked || tenorhorn.checked) ? true : false; 
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
            console.log(trombone)
            if(trompet.checked){
                  return getTrumpetValve(pct, o);
            }
            if(tenorhorn.checked){
                  var transposedPitch = pitch + 2;
                  return trumpet_valvemap[transposedPitch] || 'p'+pitch;
            }
		if(trombone.checked){
                  return getTromboneValve(pct, pitch);
            }
            if(f_tuba.checked){
                  return getF_TubaValve(pct, o);
            }
            if(debug.checked){
                  return pct+'\n'+pitch+'\n'+o;
            }
      }

      function getTromboneValve(pct, pitch)
      {
            switch (pct) {          
                  case 18: return (pitch === 40) ? '7\n(2V)': '2'; break; //e
                  case 13: return (pitch === 41) ? '6\n(1V)': '1'; break;// f  
		      case 7: return   (pitch === 59) ? '4': (pitch === 47) ? '6\n(1V)' : pct+'.'+pitch         
                  case 8://ges
                  case 20: return (pitch === 42|| pitch === 54) ? '5': '3+'; break;//fis
                  case 15: return (pitch === 43 || pitch === 55) ? '4': '2+'; break;//G
                  case 10://as
                  case 22: return '3';break;//gis
                  case 17: return '2';break; //a
                  case 12: //b
                  case 24: return '1';break; //ais  
                  case 19: return (pitch === 47) ? '7\n(2V)' :(pitch === 59 ? '4': (pitch === 35) ?'\n(-7V)' : '2') ;break;  //h 
                  case 14: return (pitch === 48) ? '6\n(1V)' :(pitch === 60 ? '3': (pitch === 36) ?'\n(-6V)' : '1'); break;//C
                  case 9:
                  case 21: return  (pitch === 49) ? '5': (pitch === 37)  ? '\n(-5V)' : '2'; break;//cis
                  case 16: return  (pitch === 50) ? '4': (pitch === 38) ? '\n(-4V)' : '1'; break;//d
                  case 11://es
                  case 23: return (pitch === 39)  ? '\n(-3V)':  '3'; break;//dis                
                  default: return pct+'.'+pitch;
            }
      }

      function getTrumpetValve(pct, o)
      {
            switch (pct) {
                  //c
		      case 14: return null_as_no_valve ? '0' : ''; break;
                  //cis //des
                  case 21:
                  case 9: return o == 4 ? '123': '12'; break; 
                  //d
                  case 16: return  o == 4 ? '13': (o == 5) ? '1' : '1(0)'; break;
                  //dis //es
                  case 11:
                  case 23: return o == 4 ? '23' : '2'; break;
                  //e
                  case 18: return o == 4 ? '12': null_as_no_valve ? '0' : ''; break;
                  //f
                  case 13: return '1'; break;
                  //ges, fis,
		      case 8:
                  case 20: return o == 3 ? '123': '2'; break; 
                  //g
                  case 15: return o == 3 ? '13': null_as_no_valve ? '0' : ''; break;
                  //gis//as
                  case 22:
                  case 10: return '23'; break;
                  //a
                  case 17: return '12';break; 
                  //b//ais
                  case 12:
                  case 24: return '1';break;
                  //h
                  case 19: return '2';break;  
                  default: return 'err\n' + pct + 'uk'+pitch;
            }
      }

      function getF_TubaValve(pct, o)
      {
            switch (pct) {
                  //c
		      case 14: return null_as_no_valve ? ( (o == 2) ? '4': '0' ) : ''; break;
                  //cis //des
                  case 21:
                  case 9: return '23'; break; 
                  //d
                  case 16: return '12\n(3)'; break;
                  //dis //es
                  case 11:
                  case 23: return '1'; break;
                  //e
                  case 18: return '2'; break;
                  //f
                  case 13: return null_as_no_valve ? '0' : ''; break;
                  //ges, fis,
		      case 8:
                  case 20: return o == 3 ? '12': '24'; break; 
                  //g
                  case 15: return '4'; break;
                  //gis//as
                  case 22:
                  case 10: return '23'; break;
                  //a
                  case 17: return '12';break; 
                  //b//ais
                  case 12:
                  case 24: return '1';break;
                  //h
                  case 19: return '2';break;  
                  default: return 'err\n' + pct + 'uk'+pitch;
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

      var trumpet_valvemap = {
            54: "123", 55: "13", 56: "23", 57: "12", 58: "1", 59: "2", 60: "0",
            61: "23", 62: "12", 63: "1", 64: "2", 65: "0", 66: "23", 67: "12",
            68: "1", 69: "2", 70: "0", 71: "2", 72: "0", 73: "23", 74: "12",
            75: "1", 76: "2", 77: "0", 78: "23", 79: "12", 80: "1", 81: "2",
            82: "0", 83: "2", 84: "0"
      };


      // notes = {
      //       tpc = [14, 21, 9, 16, 11, 23, 18, 13, 8, 20, 15, 22, 10, 17, 12, 24, 19]
      //       readable_note = ['C', 'C♯', 'D♭', 'D', 'E♭', 'E♯', 'E', 'F', 'G♭','F♯', 'G', 'G♯', 'A♭', 'A', 'B♭', 'A♯', 'B']
      //       trumpet = { }
      // }

      onRun:{
           console.log("...............................script started......................................  ");
      }

}