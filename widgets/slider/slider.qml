import QtQuick 2.12;
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 1.4 as QQC1
import MyModules 1.0

ResizableRectangle {
    id: root
    property var id_map: {
        'slider':        slider,
        'argument_menu': argument_menu,
        'cmd_menu':      cmd_menu,
        'ch_menu':       ch_menu,
        'value_menu':    value_menu,
        'name_menu':     name_menu
    }
    property string path: "slider"
    property real from: 0
    property real to: 1000
    property real step_size: 1
    property real value: 0
    property bool fix_size: true
    border.color: "#D0D0D0"
    height: minimumHeight
    width: appTheme.applyHScale(204)
    minimumHeight: slider.height +
                   name_text.height + appTheme.applyVScale(16) + radius +
                   value_text.height
    minimumWidth: appTheme.applyHScale(204)
    radius: appTheme.applyHScale(5)
    border.width: appTheme.applyHScale(1)

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

    onClicked: {
        if (mouse.button === Qt.RightButton)
            menu.popup();
    }


    Item {
        //        border.width: 1
        anchors {
            bottom: slider.top
            //            bottomMargin: appTheme.applyVScale(2)
            left: slider.left
            right: slider.right
            top: parent.top
        }

        MyText {
            id: value_text
            visible: value_menu.attr.visible
            text: (ch_menu.bind_obj?
                       ch_menu.bind_obj.value:
                       slider.value).toFixed(value_menu.attr.decimal)
            color: value_menu.attr.color
            enabled: !sys_manager.lock
            font.pixelSize: value_menu.attr.font_size
            anchors {
                verticalCenter: parent.verticalCenter
                horizontalCenter: parent.horizontalCenter
            }
        }
    }
    QQC1.Slider {
        id: slider
        height: appTheme.applyVScale(10)
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
            leftMargin: root.radius
            rightMargin: anchors.leftMargin
        }

        minimumValue: root.from
        maximumValue: root.to
        stepSize: root.step_size
        onValueChanged: {
            root_spinbox.value = value;
            argument_model.get(0).hex_value = sys_manager.float_to_hex(value);
            argument_model.get(0).float_value = value;

            var press_argument = argument_model.get(0);
            sys_manager.send_command(name_menu.attr.name,
                                     cmd_menu.bind_obj,
                                     press_argument,
                                     argument_menu.hex_on
                                     );

        }
    }

    Item {
        //        border.width: 1
        anchors {
            top: slider.bottom
            left: slider.left
            right: slider.right
            bottom: parent.bottom
        }
        MyText {
            id: name_text
            visible: name_menu.attr.visible
            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
            }
            font.pixelSize: name_menu.attr.font_size
            color: name_menu.attr.color
            width: parent.width/2
            elide: Text.ElideMiddle
            editable: name_menu.attr.editable
            tips_text: name_menu.attr.tips_text
            text: name_menu.attr.name
            onText_inputed: name_menu.set_name(text);
        }
        QQC1.SpinBox {
            id: root_spinbox
            anchors {
                verticalCenter: parent.verticalCenter
                right: parent.right
            }
            width: parent.width/2
            decimals: value_menu.attr.decimal
            minimumValue: root.from
            maximumValue: root.to
            stepSize: root.step_size
            horizontalAlignment: Qt.AlignLeft
            onEditingFinished: {
                focus = false;
                slider.value = value;
            }
            onValueChanged: {
                if (!focus) {
                    slider.value = value;
                }
            }
        }
    }

    MyMenu {
        id: menu
        DeleteMenuItem {
            target: root
        }
        CmdMenu {
            id: cmd_menu
            title: qsTr("绑定命令")
        }
        ChMenu {
            id: ch_menu
            checked: bind_obj
            indicator_color: bind_obj?bind_obj.color:"red"
        }
        ArgumentMenu {
            id: argument_menu
            cmd_obj: cmd_menu.bind_obj
            model: ListModel {
                id: argument_model
                ListElement {
                    name: qsTr("滑动条数值更新时发送，当前")
                    float_value: 0
                    hex_value: "00 00 00 00"
                    enabled: true
                    changable: false
                }
            }
        }
        ValueMenu {
            id: value_menu
            ch_menu: ch_menu
        }
        NameMenu {
            id: name_menu
            ch_menu: ch_menu
            cmd_menu: cmd_menu
        }
        MyMenuItem {
            text_center: true
            text: qsTr("step size:")
            plus_minus_on: true
            value_text: "" + root.step_size
            value_editable: true
            onPlus_triggered: {
                root.step_size = root.step_size + 1;
            }
            onMinus_triggered: {
                root.step_size = Math.max(
                            0,
                            root.step_size - 1
                            );
            }
            onValue_inputed: {
                root.step_size = Math.max(
                            0,
                            parseFloat(text)
                            );
            }
        }
    }


    function onBind() {

    }
    function onUnbind() {
    }
    function widget_ctx() {
        var ctx = {
            "path": path,
            "ctx": [
                {                    P:'ctx',       V: get_ctx()                },
                {                    P:'from',      V: from                     },
                {                    P:'to',        V: to                       },
                {                    P:'step_size', V: step_size                },
                { T:"slider",        P:'value',     V: slider.value             },
                { T:"argument_menu", P:'ctx',       V: argument_menu.get_ctx()  },
                { T:"cmd_menu",      P:'ctx',       V: cmd_menu.get_ctx()       },
                { T:"ch_menu",       P:'ctx',       V: ch_menu.get_ctx()        },
                { T:"value_menu",    P:'ctx',       V: value_menu.get_ctx()     },
                { T:"name_menu",     P:'ctx',       V: name_menu.get_ctx()      }

            ]};
        return ctx;
    }

    function apply_widget_ctx(ctx) {
        __set_ctx__(root, ctx.ctx);
    }

}
