import QtQuick 2.5
import QtQuick.Controls 2.4
import QtQuick.Extras 1.4

Rectangle {
    id: light
    property string path:  "light"
    property string name: light_name.text
    property bool value_visable: ____value_visable____
    property real bottom_value: parseFloat(light_bottom_value.text)
    property real top_value: parseFloat(light_top_value.text)
    property var command: null
    x: ____x____
    y: ____y____
    height: 68
    width: Math.max(40, light_name.width + 10)
    color: "transparent"
    radius: 5
    border.color: "#D0D0D0"
    border.width: sys_manager.lock?0:1
    onXChanged: {
        x = (x - x%4)
    }
    onYChanged: {
        y = (y - y%4)
    }
    MouseArea {
        anchors.fill: parent
        drag.target: parent
        drag.axis: Drag.XAndYAxis
        drag.minimumY: -light.height/2
        drag.maximumY: ctrl_panel.height - light.height/2
        drag.minimumX: -light.width/2
        drag.maximumX: root.width - light.width/2 -16
        drag.threshold: 0
        hoverEnabled: true
        enabled: !sys_manager.lock
        onPressed: {
            parent.border.color = theme_color;
            parent.border.width = Qt.binding(function(){return ((sys_manager.lock)?0:2)});
            sys_manager.increase_to_top(light);
        }
        onReleased: {
            parent.border.color = "#D0D0D0";
            parent.border.width = Qt.binding(function(){return ((sys_manager.lock)?0:1)});
        }
    }
    StatusIndicator {
        id: light_bt
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        color: "blue"
        height: 26
        width: 26
        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (!light_bind.value_bind) {
                    if (light.bottom_value === light.top_value) {
                        parent.active = !parent.active;
                        light_value.text = ((parent.active)?"1":"0");
                    } else if (light.bottom_value < light.top_value) {
                        parent.active = true;
                        if (light_value.text == "3") {
                            light_value.text = "1";
                            parent.color = "red";
                        } else if (light_value.text == "1") {
                            light_value.text = "2";
                            parent.color = "green";
                        } else if (light_value.text == "2") {
                            light_value.text = "3";
                            parent.color = "yellow";
                        } else {
                            light_value.text = "1";
                            parent.color = "red";
                        }
                    }
                    if (!command)
                        sys_manager.send_string("" + light_name.text + ":" + light_value.text + "\n");
                    else {
                        sys_manager.send_command(command, parseFloat(light_value.text));
                    }
                }
                else {
                    var s = light_value.text;
                    if (light.bottom_value === light.top_value) {
                        s = (parent.active)?"0":"1";
                    }
                    else if (light.bottom_value < light.top_value) {
                        if (parseFloat(light_value.text) > light.top_value) {
                            s = "1";
                        } else if (parseFloat(light_value.text) < light.bottom_value) {
                            s = "2";
                        } else {
                            s = "3";
                        }
                    }
                    if (!command)
                        sys_manager.send_string("" + light_name.text + ":" + s + "\n");
                    else {
                        sys_manager.send_command(command, parseFloat(s));
                    }
                }
            }
        }
    }
    Text {
        id: light_delete
        property bool bind: false
        color: "blue"
        font.family: theme_font
        font.pointSize: theme_font_point_size
        font.bold: theme_font_bold
        text: "[-]"
        visible: !sys_manager.lock
        anchors.left: parent.right
        anchors.top: parent.top
        anchors.topMargin: 0
        MouseArea {
            anchors.fill: parent
            onClicked: {
                light.destroy();
            }
        }
    }
    Text {
        id: light_bind
        property bool bind: false
        property bool value_bind: false
        color: "blue"
        font.family: theme_font
        font.pointSize: theme_font_point_size
        font.bold: theme_font_bold
        text: bind?"[★]":"[☆]"
        visible: !sys_manager.lock
        anchors.right: parent.left
        anchors.bottom: parent.bottom
        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (light_bind.bind == false)
                    light.onBind();
                else
                    light.onUnbind();
            }
        }
    }
    function onBind() {
        var rt_value = sys_manager.find_rt_value_obj_by_name(light_name.text);
        var line = sys_manager.find_line_obj_by_name(light_name.text);
        var command = sys_manager.find_command_obj_by_name(light_name.text);

        if (!((rt_value && line) || command)) {
            onUnbind();
            return;
        }
        light_bind.bind = true;

        if (rt_value && line) {
            light_bind.value_bind = true;
            light_value.text = Qt.binding(function() { return "" + rt_value.value; })
            light_value.color = line.color;
            light_name.color = line.color;
            if (light.bottom_value === light.top_value) {
                light_bt.color = Qt.binding(function() { return line.color });
                light_bt.active = Qt.binding(function() { return (rt_value.value>=light.top_value)?true:false; } )
            } else if (light.bottom_value < light.top_value) {
                light_bt.color = Qt.binding(function() {
                    if (rt_value.value<=light.bottom_value) return "red";
                    else if (rt_value.value > light.top_value) return "yellow";
                    else return "green";
                });
                light_bt.active = true;
            }
        }

        if (command)
            light.command = command;
        else
            light.command = null;
    }
    function onUnbind() {
        light_bind.bind = false;
        light_bind.value_bind = false;
        light_bt.color = "blue";
        light_value.text = "0";
        light_value.color = "black";
        light_name.color = "black";
        light_bt.active = false;
        light.command = null;
    }
    Text {
        id: light_value_show
        property bool bind: false
        //                color: bind?"red":"black"
        color: "blue"
        //                font.underline: true
        font.family: theme_font
        font.pointSize: theme_font_point_size
        font.bold: theme_font_bold
        text: parent.value_visable?"[★]":"[☆]"
        visible: !sys_manager.lock
        anchors.right: parent.left
        anchors.top: parent.top
        MouseArea {
            anchors.fill: parent
            onClicked: {
                parent.parent.value_visable = !parent.parent.value_visable;
            }
        }
    }
    TextInput {
        id: light_name
        selectByMouse: true
        color: "black"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 2
        text: "____name____"

        enabled: !light_bind.bind
        font.family: theme_font
        font.pixelSize: 15
        font.bold: theme_font_bold
        onFocusChanged: {
            if (!focus && text.length == 0) {
                text = "I0";
            }
        }
    }
    TextInput {
        id: light_bottom_value
        selectByMouse: true
        color: "black"
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.left
        anchors.rightMargin: 3
        text: "____bottom_value____"
        visible: !sys_manager.lock
        enabled: !light_bind.bind
        font.family: theme_font
        font.pointSize: theme_font_point_size
        font.bold: theme_font_bold
    }
    TextInput {
        id: light_top_value
        selectByMouse: true
        color: "black"
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.right
        anchors.leftMargin: 3
        text: "____top_value____"
        visible: !sys_manager.lock
        enabled: !light_bind.bind
        font.family: theme_font
        font.pointSize: theme_font_point_size
        font.bold: theme_font_bold
    }
    Text {
        id: light_value
        anchors.top: parent.top
        anchors.topMargin: 2
        anchors.horizontalCenter: parent.horizontalCenter
        text: "0"
        visible: parent.value_visable
        font.family: theme_font
        font.pixelSize: 15
        font.bold: theme_font_bold
    }
}
