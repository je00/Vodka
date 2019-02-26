import QtQuick 2.5;
import QtQuick.Controls 2.4

Rectangle {
    id: bound_bt
    height: 30
    width: 50
    radius: 5
    color:  "#F5F5F5"
    border.color:  "#1AAC19"
    border.width: 1
    x: ____x____
    y: ____y____
    property string path:  "bound_bt"
    property string name: bound_bt_name.text
    onXChanged: {
        x = (x - x%4)
    }
    onYChanged: {
        y = (y - y%4)
    }
    MouseArea {
        anchors.fill: parent
        drag.target: parent
        drag.axis: (!sys_manager.lock)?Drag.XAndYAxis:Drag.None
        drag.minimumY: -bound_bt.height/2
        drag.maximumY: ctrl_panel.height - bound_bt.height/2
        drag.minimumX: -bound_bt.width/2
        drag.maximumX: root.width - bound_bt.width/2 -16
        hoverEnabled: true
        onEntered: {
            parent.border.width = 2;
        }
        onExited: {
            parent.border.width = 1;
        }
        onPressed: {
            parent.color =  "#1AAC19";
            bound_bt_name.color =  "white ";
            if (sys_manager.connected)
                sys_manager.send_string( "" + bound_bt_name.text +  ":1\n");
        }
        onReleased: {
            parent.color =  "#F5F5F5";
            bound_bt_name.color =  "black";
            if (sys_manager.connected)
                sys_manager.send_string( "" + bound_bt_name.text +  ":0\n");
        }
    }
    TextInput {
        selectByMouse: true
        id: bound_bt_name
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        font.family: theme_font
        font.pixelSize: theme_font_pixel_size
        font.bold: theme_font_bold
        text: "____name____"
        enabled: !sys_manager.lock
    }
    Text {
        id: light_delete
        property bool bind: false
        color:  "blue "
        font.family: theme_font
        font.pixelSize: theme_font_pixel_size
        font.bold: theme_font_bold
        text:  "[-] "
        visible: !sys_manager.lock
        anchors.left: parent.right
        anchors.top: parent.top
        MouseArea {
            anchors.fill: parent
            onClicked: {
                bound_bt.destroy();
            }
        }
    }

    function onBind() {
    }

    function onUnbind() {
    }
}
