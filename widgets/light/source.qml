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
    x: ____x____
    y: ____y____
    height: 60
    width: 40
    color: "transparent"
    radius: 5
    border.color: "#1AAC19"
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
            parent.border.width = Qt.binding(function(){return ((sys_manager.lock)?0:3)});
        }
        onReleased: {
            parent.border.width = Qt.binding(function(){return ((sys_manager.lock)?0:2)});
        }
    }
    StatusIndicator {
        id: light_bt
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        color: "blue"
        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (!light_bind.bind) {
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
                    if (sys_manager.connected)
                        sys_manager.send_string("" + light_name.text + ":" + light_value.text + "\n");
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
                    if (sys_manager.connected)
                        sys_manager.send_string("" + light_name.text + ":" + s + "\n");
                }
            }
        }
    }
    Text {
        id: light_delete
        property bool bind: false
        color: "blue"
        font.family: theme_font
        font.pixelSize: theme_font_pixel_size
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
        color: "blue"
        font.family: theme_font
        font.pixelSize: theme_font_pixel_size
        font.bold: theme_font_bold
        text: bind?"[★]":"[☆]"
        visible: !sys_manager.lock
        anchors.right: parent.left
        anchors.bottom: parent.bottom
        MouseArea {
            anchors.fill: parent
            onClicked: {
                console.log("fuck here");
                if (light_bind.bind == false)
                    light.onBind();
                else
                    light.onUnbind();
            }
        }
    }
    function onBind() {
        var tmp = light_name.text.substring(1,light_name.text.length);
        var id = parseInt(tmp);
        if (light_name.text.charAt(0) == 'I' && id < sys_manager.lineNumber) {
            light_bind.bind = true;
            light_value.text = Qt.binding(function() { return "" + sys_manager.rt_values[id].value; })
            if (light.bottom_value === light.top_value) {
                light_bt.color = Qt.binding(function() { return sys_manager.lines[id].color });
                light_bt.active = Qt.binding(function() { return (sys_manager.rt_values[id].value>=light.top_value)?true:false; } )
            } else if (light.bottom_value < light.top_value) {
                light_bt.color = Qt.binding(function() {
                    if (sys_manager.rt_values[id].value<=light.bottom_value) return "red";
                    else if (sys_manager.rt_values[id].value > light.top_value) return "yellow";
                    else return "green";
                });
                light_bt.active = true;
            }
        } else {
            light_bind.bind = false;
            light_bt.color = "blue";
            light_value.text = "0";
            light_bt.active = false;
        }
    }
    function onUnbind() {
        light_bind.bind = false;
        light_bt.color = "blue";
        light_value.text = "0";
        light_bt.active = false;
    }
    Text {
        id: light_value_show
        property bool bind: false
        //                color: bind?"red":"black"
        color: "blue"
        //                font.underline: true
        font.family: theme_font
        font.pixelSize: theme_font_pixel_size
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
        anchors.bottomMargin: 3
        text: "____name____"

        enabled: !light_bind.bind
        font.family: theme_font
        font.pixelSize: theme_font_pixel_size
        font.bold: theme_font_bold
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
        font.pixelSize: theme_font_pixel_size
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
        font.pixelSize: theme_font_pixel_size
        font.bold: theme_font_bold
    }
    Text {
        id: light_value
        anchors.top: parent.top
        anchors.topMargin: 3
        anchors.horizontalCenter: parent.horizontalCenter
        text: "0"
        visible: parent.value_visable
        font.family: theme_font
        font.pixelSize: theme_font_pixel_size
        font.bold: theme_font_bold
    }
}
