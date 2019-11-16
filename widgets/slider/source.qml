import QtQuick 2.12;
import QtQuick.Controls 2.12
import QtQuick.Controls 1.4 as QQC1
Rectangle {
    id: ctrl0
    color: sys_manager.background_color

    property string path: "slider"
    property bool bind: ____bind____
    property bool value_bind: false
    property real from: parseFloat((ctrl0_from.text.length>0)?ctrl0_from.text:0)
    property real to: parseFloat((ctrl0_to.text.length>0)?ctrl0_to.text:0)
    property real stepSize: parseFloat((ctrl0_stepSize.text.length>0)?ctrl0_stepSize.text:0)
    property string name: ctrl0_name.text
    property var command: null
    property real value: ctrl0_slider.value
    property bool fix_size: true
    x: ____x____
    y: ____y____
    border.color: "#D0D0D0"
    height: 55
    width: 204
    radius: 5
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
            if (ctrl0.command)
                ctrl0_name.text = ctrl0.command.name;
        }
    }

    MouseArea {
        anchors.fill: parent
        drag.target: parent
        drag.axis: Drag.XAndYAxis
        drag.minimumY: 0
        drag.minimumX: 0
        drag.threshold: 0
        enabled: !sys_manager.lock
        onPressed: {
            parent.border.color = theme_color;
            parent.border.width = 2;
            sys_manager.increase_to_top(ctrl0);
        }
        onReleased: {
            parent.border.color = "#D0D0D0";
            parent.border.width = 1;
        }

    }
    TextInput {
        id: ctrl0_from
        selectByMouse: true
        text:"" + ____from____
        enabled: !sys_manager.lock
        anchors.left: ctrl0_slider.left
        anchors.topMargin: 5
        anchors.top: parent.top
        font.family: theme_font
        font.pointSize: theme_font_point_size
        font.bold: theme_font_bold
        onAccepted: {
            focus = false;
        }
        onFocusChanged: {
            if (!focus)
                if (text.length == 0)
                    text = "" + ____from____;
        }
    }
    TextInput {
        id: ctrl0_to
        selectByMouse: true
        text:"" + ____to____
        horizontalAlignment : TextInput.AlignRight
        width: 40
        enabled: !sys_manager.lock
        anchors.right: ctrl0_slider.right
        anchors.top: ctrl0_from.top
        font.family: theme_font
        font.pointSize: theme_font_point_size
        font.bold: theme_font_bold
        onAccepted: {
            focus = false;
        }
        onFocusChanged: {
            if (!focus)
                if (text.length == 0)
                    text = "" + ____to____;

        }
    }
    Rectangle {
        color: "transparent"
        anchors.verticalCenter: ctrl0_spinbox.verticalCenter
        anchors.left: ctrl0_slider.left
        anchors.right: ctrl0_spinbox.left
        height: ctrl0_name.height
        TextInput {
            id: ctrl0_name
            selectByMouse: true
            anchors.horizontalCenter: parent.horizontalCenter
            text: "____name____"
            //        width: 20
            enabled: (!sys_manager.lock)&&(!bind)
            font.family: theme_font
            font.pixelSize: 15
            font.bold: theme_font_bold
            onAccepted: {
                focus = false;
            }
        }
    }
    Text {
        id: ctrl0_value
        text: "|"
        enabled: !sys_manager.lock
        anchors.bottom: parent.top
        anchors.bottomMargin: 2
        anchors.left: parent.left
        font.family: theme_font
        font.pixelSize: 15
        font.bold: theme_font_bold
        visible: value_bind
    }
    Text {
        id: ctrl0_stepSize_text
        text: "step: "
        anchors.left: ctrl0_from.right
        anchors.leftMargin: 10
        anchors.top: ctrl0_from.top
        font.family: theme_font
        font.pointSize: theme_font_point_size
        font.bold: theme_font_bold
    }
    TextInput {
        id: ctrl0_stepSize
        selectByMouse: true
        text:"" + ____stepSize____
        width: 40
        anchors.left: ctrl0_stepSize_text.right
        anchors.top: ctrl0_stepSize_text.top
        font.family: theme_font
        font.pointSize: theme_font_point_size
        font.bold: theme_font_bold
        onFocusChanged: {
            if (!focus)
                if (text.length == 0)
                    text = "" + ____stepSize____;
        }

        onAccepted: {
            focus = true;
        }
    }
    QQC1.Slider {
        id: ctrl0_slider
        height: 10
        minimumValue: parent.from
        maximumValue: parent.to
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.rightMargin: 5
        anchors.leftMargin: 5
        anchors.top: ctrl0_from.bottom
        stepSize: parent.stepSize
        value: ____value____
        onValueChanged: {
            ctrl0_spinbox.value = value;
        }
    }
    QQC1.SpinBox {
        id: ctrl0_spinbox
        anchors.right: ctrl0_slider.right
        anchors.top: ctrl0_slider.bottom
        decimals: 5
        width: 100
        minimumValue: parent.from
        maximumValue: parent.to
        stepSize: parent.stepSize
        value: ____value____
        onEditingFinished: {
            focus = false;
            ctrl0_slider.value = value;
            if (!command) {
                if (bind)
                    onUnbind();
                sys_manager.send_string(ctrl0_name.text + ":" + value + '\n');
            } else
                sys_manager.send_command(command, value);
        }
        onValueChanged: {
            if (!focus) {
                ctrl0_slider.value = value;
                if (!command) {
                    if (bind)
                        onUnbind();
                    sys_manager.send_string(ctrl0_name.text + ":" + value + '\n');
                } else
                    sys_manager.send_command(command, value);
            }
        }
    }
    Text {
        id: delete_text
        text: "[-]"
        color: "blue"
        anchors.right: ctrl0_to.left
        anchors.bottom: ctrl0_to.bottom
        visible: !sys_manager.lock
        font.family: theme_font
        font.pointSize: theme_font_point_size
        font.bold: theme_font_bold
        MouseArea {
            anchors.fill: parent
            onClicked: {
                ctrl0.destroy();
            }
        }
    }
    Text {
        id: bind_text
        text: bind?"[★]":"[☆]"
        color: "blue"
        anchors.right: delete_text.left
        anchors.rightMargin: 8
        anchors.bottom: ctrl0_to.bottom
        visible: !sys_manager.lock
        font.family: theme_font
        font.pointSize: theme_font_point_size
        font.bold: theme_font_bold
        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (bind == false)
                    ctrl0.onBind();
                else
                    ctrl0.onUnbind();
            }
        }
    }
    function onBind() {
        var command = sys_manager.find_command_by_name(ctrl0_name.text);
        var settings_obj = sys_manager.find_settings_obj_by_name(ctrl0_name.text);
        if (!(settings_obj|| command)) {
            onUnbind();
            return;
        }
        bind = true;

        if (settings_obj) {
            value_bind = true;
            ctrl0_name.color = Qt.binding(function(){ return settings_obj.color;})
            ctrl0_value.color = Qt.binding(function(){ return settings_obj.color;})
            ctrl0_value.text = Qt.binding(function() { return "| "+settings_obj.value.toFixed(5);})
        }

        if (command)
            ctrl0.command = command;
        else
            ctrl0.command = null;

    }
    function onUnbind() {
        bind = false;
        value_bind = false;
        ctrl0_name.color = "black";
        ctrl0_value.color = "black";
        ctrl0_value.text = "|";
        ctrl0.command = null;
    }
}
