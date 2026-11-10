import QtQuick 2.12
Rectangle {
 property real minimumWidth: 0
 property real minimumHeight: 0
 property bool hovered: false
 property alias mouse: ma
 property var ctx
 MouseArea {id: ma; anchors.fill: parent; acceptedButtons: Qt.RightButton}
 function get_ctx() {return {x:x,y:y,width:width,height:height};}
 function __set_ctx__(target, state, references) {
  references.active=true;
  for (var id in state) {
   var obj=id==='.' ? target : references.item['ref_'+id];
   for(var key in state[id]) obj[key]=state[id][key];
  }
  references.active=false;
 }
}
