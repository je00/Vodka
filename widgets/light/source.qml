import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Extras 1.4

Rectangle {
    id: light
    property string path:  "light"
    property bool bind: ____bind____
    property bool value_bind: false
    property string name: light_name.text
    property bool value_visable: ____value_visable____
    property real bottom_value: parseFloat(light_bottom_value.text)
    property real top_value: parseFloat(light_top_value.text)
    property var command: null
    property bool fix_size: true

    x: ____x____
    y: ____y____
    height: 68
    width: Math.max(40, light_name.width + 10)
    color: "transparent"
    radius: 5
    border.color: "#D0D0D0"
    border.width: sys_manager.lock?0:1
    Component.onCompleted: {
        if (bind)
            onBind();
    }

    onXChanged: {
        if (!enabled)
            return;

        x = (x - x%4)
    }
    onYChanged: {
        if (!enabled)
            return;

        y = (y - y%4)
    }
    Connections {
        target: sys_manager
        onName_changed: {
            if (light.command)
                light_name.text = light.command.name;
        }
    }

    MouseArea {
        anchors.fill: parent
        drag.target: parent
        drag.axis: Drag.XAndYAxis
        drag.minimumY: 0
        drag.minimumX: 0
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
                if (!value_bind) {
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
                    if (!command) {
                        if (bind)
                            onUnbind();
                        sys_manager.send_string("" + light_name.text + ":" + light_value.text + "\n");
                    } else {
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
                    if (!command) {
                        if (bind)
                            onUnbind();
                        sys_manager.send_string("" + light_name.text + ":" + s + "\n");
                    } else {
                        sys_manager.send_command(command, parseFloat(s));
                    }
                }
            }
        }
    }
    Text {
        id: light_delete
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
                if (bind == false)
                    light.onBind();
                else
                    light.onUnbind();
            }
        }
    }
    function onBind() {
        var settings_obj = sys_manager.find_settings_obj_by_name(light_name.text);
        var command = sys_manager.find_command_by_name(light_name.text);

        if (!(settings_obj || command)) {
            onUnbind();
            return;
        }
        bind = true;

        if (settings_obj) {
            value_bind = true;
            light_value.text = Qt.binding(function() { return settings_obj.value.toFixed(5); })
            light_value.color = Qt.binding(function() { return settings_obj.color });
            light_name.color = Qt.binding(function() { return settings_obj.color });
            if (light.bottom_value === light.top_value) {
                light_bt.color = Qt.binding(function() { return settings_obj.color });
                light_bt.active = Qt.binding(function() { return (settings_obj.value>=light.top_value)?true:false; } )
            } else if (light.bottom_value < light.top_value) {
                light_bt.color = Qt.binding(function() {
                    if (settings_obj.value<=light.bottom_value) return "red";
                    else if (settings_obj.value > light.top_value) return "yellow";
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
        bind = false;
        value_bind = false;
        light_bt.color = "blue";
        light_value.text = "0";
        light_value.color = "black";
        light_name.color = "black";
        light_bt.active = false;
        light.command = null;
    }
    Text {
        id: light_value_show
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

        enabled: !bind
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
        enabled: !bind
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
        enabled: !bind
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
