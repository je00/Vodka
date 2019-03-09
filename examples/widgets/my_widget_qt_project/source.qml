import QtQuick 2.9
import QtQuick.Controls 2.4

Rectangle {
    width: 200
    height: 200
    border.width: 1
    x: ____x____
    y: ____y____
    property string path: "my_widget"
    property string my_parameter1: text1.text
    property string my_parameter2: text2.text
    MouseArea {
        anchors.fill: parent
        drag.target: parent
        drag.minimumX: -parent.parent.width/2
        drag.minimumY: 0
    }
    Text {
        id: text1
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: 20
        anchors.leftMargin: 20
        font.family: theme_font
        font.pixelSize: theme_font_pixel_size
        font.bold: theme_font_bold
        
        text: "____my_parameter1____"
    }
    
    Text {
        id: text2
        anchors.top: text1.bottom
        anchors.left: text1.left
        anchors.topMargin: 20
        font.family: theme_font
        font.pixelSize: theme_font_pixel_size
        font.bold: theme_font_bold
        text: "____my_parameter2____"
    }
    Text {
        property bool bind: false
        color: "blue"
        font.family: theme_font
        font.pixelSize: theme_font_pixel_size
        font.bold: theme_font_bold
        text: "[-]"
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: 10
        anchors.topMargin: 10
        MouseArea {
            anchors.fill: parent
            onClicked: {
                parent.parent.destroy();
            }
        }
    }
    Text {
        id: text3
        font.family: theme_font
        font.pixelSize: theme_font_pixel_size
        font.bold: theme_font_bold
        anchors.top: text2.bottom
        anchors.topMargin: 20
        anchors.left: text2.left
        text: "null"
    }
    Button {
        id: button1
        anchors.top: text3.bottom
        anchors.topMargin: 20
        anchors.left: text3.left            
        text: "send"
        height: 25
        width: 80
        onClicked: {
            sys_manager.send_string("ok.\n");
        }
    }
    
    Text {
        id: bind_bt
        property bool bind: false
        color: "blue"
        font.family: theme_font
        font.pixelSize: theme_font_pixel_size
        font.bold: theme_font_bold
        text: bind?"[★]":"[☆]"
        visible: !sys_manager.lock
        anchors.left:parent.left
        anchors.top: parent.top
        anchors.leftMargin: 10
        anchors.topMargin: 10
        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (parent.bind == false) {
                    parent.bind = true;
                    onBind();
                }
                else {
                    parent.bind = false;
                    onUnbind();
                }
            }
        }
    }
    
    function onBind() {
        text3.text = Qt.binding(function() { return "" + sys_manager.rt_values[0].value; })
        text3.color = Qt.binding(function() { return sys_manager.lines[0].color });
    }
    
    function onUnbind() {
        text3.text = "null";
        text3.color = "black";
    }
}