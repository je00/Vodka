import QtQuick 2.5;
import QtQuick.Controls 2.4

Rectangle {
    id: bound_bt
    height: 30
    width: Math.max(bound_bt_name.width + 20, 50)
    radius: 5
    color: "#F5F5F5"
    border.color: "#D0D0D0"
    border.width: 1
    x: ____x____
    y: ____y____
    property string path:  "bound_bt"
    property string name: bound_bt_name.text
    property bool editing: false
    property bool bind: false
    property var command: null
    onXChanged: {
        x = (x - x%4);
    }
    onYChanged: {
        y = (y - y%4);
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        propagateComposedEvents: true
        onEntered: {
//            parent.border.width = 2;
//            parent.border.color = theme_color;
            parent.color = "blue";
            bound_bt_name.color = "white";
            bound_bt_name.font.bold = true;
        }
        onExited: {
            parent.color = "#F5F5F5";
            bound_bt_name.color = "blue";
            bound_bt_name.font.bold = theme_font_bold;
//            parent.border.width = 1;
//            parent.border.color = "#D0D0D0";
        }
        onPressed: {
            parent.color =  "#0080ff";
            bound_bt_name.color =  "white ";
            bound_bt_name.font.bold = true;
            if (!command) {
                sys_manager.send_string( "" + bound_bt_name.text +  ":1\n");
            } else if (command.support_arg) {
                sys_manager.send_command(command, 1);
            }
        }
        onReleased: {
            parent.color = "blue";
            bound_bt_name.color = "white";
            bound_bt_name.font.bold = true;
            if (!command) {
                sys_manager.send_string( "" + bound_bt_name.text +  ":0\n");
            } else if (command.support_arg) {
                sys_manager.send_command(command, 0);
            }
        }
        onClicked: {
            if (command && !command.support_arg) {
                sys_manager.send_command(command);
            }
        }
    }
    Rectangle {
        id: drag_bt
        //        anchors.right: parent.left
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        //        anchors.rightMargin: -6
        anchors.bottomMargin: -6
        height: 12
        width: 12
        color: theme_color
        visible: !sys_manager.lock
        MouseArea {
            anchors.fill: parent
            drag.target: bound_bt
            drag.axis: (!sys_manager.lock)?Drag.XAndYAxis:Drag.None
            drag.minimumY: -bound_bt.height/2
            drag.maximumY: ctrl_panel.height - bound_bt.height/2
            drag.minimumX: -bound_bt.width/2
            drag.maximumX: root.width - bound_bt.width/2 -16
            drag.threshold: 0

            onDoubleClicked: {
                editing = !editing;
                bound_bt_name.focus = !bound_bt_name.focus;
                if (editing)
                    bound_bt_name.selectAll();
                else
                    bound_bt_name.select(0,0);
            }
            onPressed: {
                sys_manager.increase_to_top(bound_bt);
                parent.opacity = 0.7;
            }
            onReleased: {
                parent.opacity = 1;
            }
        }
    }

    TextInput {
        id: bound_bt_name
        selectByMouse: true
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        font.family: theme_font
        font.pixelSize: 14
        font.bold: theme_font_bold
        //        text: qsTr("双击 ↓ 命名")
        text: "____name____"
        enabled: parent.editing
        color: "blue"

        onAccepted: {
            focus = false;
        }
        onFocusChanged: {
            if (!focus) {
                editing = false;
                select(0, 0);
                if (bind) {
                    onBind();
                } else {
                    onUnbind();
                }
            }
        }
    }
    Text {
        id: delete_bt
        color:  "blue "
        font.family: theme_font
        font.pointSize: theme_font_point_size
        font.bold: theme_font_bold
        text:  "[ - ] "
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

    Text {
        id: bind_bt
        color:  "blue "
        font.family: theme_font
        font.pointSize: theme_font_point_size
        font.bold: theme_font_bold
        text:  bind?"[★]":"[☆]"
        visible: !sys_manager.lock
        anchors.right: parent.left
        anchors.top: parent.top
        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (!bind)
                    onBind();
                else
                    onUnbind();
            }
        }
    }
    function onBind() {
        var command = sys_manager.find_command_obj_by_name(bound_bt.name);
        if (command) {
            bind = true;
            bound_bt.command = command;
        } else {
            bind = false;
        }
    }

    function onUnbind() {
        bind = false;
        bound_bt.command = null;
    }
}
