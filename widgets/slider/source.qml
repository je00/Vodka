import QtQuick 2.5;
import QtQuick.Controls 2.4
import QtQuick.Controls 1.4 as QQC1
Rectangle {
    id: ctrl0
    property string path: "slider"
    property real from: parseFloat((ctrl0_from.text.length>0)?ctrl0_from.text:0)
    property real to: parseFloat((ctrl0_to.text.length>0)?ctrl0_to.text:0)
    property real stepSize: parseFloat((ctrl0_stepSize.text.length>0)?ctrl0_stepSize.text:0)
    property string name: ctrl0_name.text
    x: ____x____
    y: ____y____
    border.color: "grey"
    height: 55
    width: 204
    radius: 5
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
        drag.minimumY: 0
        drag.maximumY: ctrl0.parent.height - parent.height
        drag.minimumX: 0
        drag.maximumX: ctrl0.parent.width - parent.width - 8
        drag.threshold: 0
        enabled: !sys_manager.lock
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
        font.pixelSize: theme_font_pixel_size
        font.bold: theme_font_bold
        onAccepted: {
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
        font.pixelSize: theme_font_pixel_size
        font.bold: theme_font_bold
        onAccepted: {
            if (text.length == 0)
                text = "" + ____to____;
        }
    }
    TextInput {
        id: ctrl0_name
        selectByMouse: true
        text: "____name____"
        width: 20
        enabled: (!sys_manager.lock)&&(!bind_text.bind)
        anchors.verticalCenter: ctrl0_spinbox.verticalCenter
        anchors.left: ctrl0_slider.left
        font.family: theme_font
        font.pixelSize: 12
        font.bold: theme_font_bold
    }
    Text {
        id: ctrl0_value
        text: "|"
        enabled: !sys_manager.lock
        anchors.verticalCenter: ctrl0_name.verticalCenter
        anchors.left: ctrl0_name.right
        font.family: theme_font
        font.pixelSize: 12
        font.bold: theme_font_bold
    }
    Text {
        id: ctrl0_stepSize_text
        text: "step: "
        anchors.left: ctrl0_from.right
        anchors.leftMargin: 10
        anchors.top: ctrl0_from.top
        font.family: theme_font
        font.pixelSize: theme_font_pixel_size
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
        font.pixelSize: theme_font_pixel_size
        font.bold: theme_font_bold
        onAccepted: {
            if (text.length == 0)
                text = "" + ____stepSize____;
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
        onEditingFinished: {
            ctrl0_slider.value = value;
            if (sys_manager.connected) {
                sys_manager.send_string(ctrl0_name.text + ":" + value + '\n');
            }
        }
        onValueChanged: {
            if (!focus) {
                ctrl0_slider.value = value;
                if (sys_manager.connected) {
                    sys_manager.send_string(ctrl0_name.text + ":" + value + '\n');
                }
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
        font.pixelSize: theme_font_pixel_size
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
        property bool bind: false
        visible: !sys_manager.lock
        font.family: theme_font
        font.pixelSize: theme_font_pixel_size
        font.bold: theme_font_bold
        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (bind_text.bind == false)
                    ctrl0.onBind();
                else
                    ctrl0.onUnbind();
            }
        }
    }
    function onBind() {
        var rt_value = sys_manager.find_rt_value_obj_by_name(ctrl0_name.text);
        var line = sys_manager.find_line_obj_by_name(ctrl0_name.text);
        if (rt_value && line) {
            bind_text.bind = true;
            ctrl0_name.color = Qt.binding(function(){ return line.color;})
            ctrl0_value.color = Qt.binding(function(){ return line.color;})
            ctrl0_value.text = Qt.binding(function() { return "| "+rt_value.value;})
        } else {
            bind_text.bind = false;
            ctrl0_name.color = "black";
            ctrl0_value.color = "black";
            ctrl0_value.text = "|";
        }
    }
    function onUnbind() {
        bind_text.bind = false;
        ctrl0_name.color = "black";
        ctrl0_value.color = "black";
        ctrl0_value.text = "|";
    }
}
