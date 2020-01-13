import QtQuick 2.12;
import QtQuick.Controls 2.12
import QtQml 2.13
import QtGraphicalEffects 1.0

ResizableRectangle {
    id: root
    property var id_map: {
        'argument_menu': argument_menu,
        'cmd_menu':      cmd_menu
    }
    support_fill_parent: false
    width: appTheme.applyHScale(74)
    height: appTheme.applyVScale(54)
    minimumWidth: minimumHeight
    minimumHeight: bt_mouse.anchors.margins * 3
    radius: appTheme.applyHScale(5)

    property string path:  "bound_bt"
    property string color_normal: "#F5F5F5"
    property string color_hovered: "blue"
    property string color_pressed: "#0080ff"
    property string color_border: "#D0D0D0"
    property string color_text_1: "blue"
    property string color_text_2: "white"
    property int border_width: appTheme.applyHScale(1)
    property int font_size: -1
    property int font_size_: (font_size > 0)?font_size:appTheme.fontPixelSizeNormal
    property string name: qsTr("Button")
    color: {
        if (bt_mouse.containsPress)
            color_pressed
        else if (bt_mouse.containsMouse)
            color_hovered
        else
            color_normal
    }
    border.color: color_border
    border.width: border_width

    onClicked: {
        if (mouse.button === Qt.RightButton)
            menu.popup();
    }

    MouseArea {
        id: bt_mouse
        enabled: !bound_bt_name.editing
        anchors {
            fill: parent
            margins: appTheme.applyHScale(12)
        }
        hoverEnabled: !bound_bt_name.editing
        propagateComposedEvents: true
        onPressed: send_command(0)
        onReleased: send_command(1)
        function send_command(argment_index) {
            var press_argument = argument_model.get(argment_index);
            sys_manager.send_command(root.name,
                                     cmd_menu.bind_obj,
                                     press_argument,
                                     argument_menu.hex_on
                                     );
        }
    }

    LinearGradient  {
        id: text_gradient
        anchors.fill: bound_bt_name
        source: bound_bt_name
        visible: !bound_bt_name.visible
        property real effect_text_ratio1: (parent.width - font_size_)/bound_bt_name.width
        property real effect_text_ratio2: parent.width/bound_bt_name.width
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop {
                position: text_gradient.effect_text_ratio1
                color: bound_bt_name.color }
            GradientStop {
                position: text_gradient.effect_text_ratio2;
                color: "white" }
        }
    }

    MyText {
        id: bound_bt_name
        width: root.width
        editable: true
        enter_edit_mode_by_click: false
        elide: Text.ElideMiddle
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        text: root.name
        color: bt_mouse.containsMouse?
                   color_text_2:
                   color_text_1
        font.bold: true
        font.pixelSize: font_size_
        onText_inputed: root.name = text;
    }

    MyMenu {
        id: menu
        DeleteMenuItem {
            target: root
        }
        MyMenuItem {
            text: qsTr("输入名称")
            onTriggered: {
                bound_bt_name.enter_edit_mode();
                menu.visible = false;
            }
        }
        CmdMenu {
            id: cmd_menu
            title: qsTr("绑定命令")
        }
        ArgumentMenu {
            id: argument_menu
            cmd_obj: cmd_menu.bind_obj
            model: ListModel {
                id: argument_model
                ListElement {
                    name: qsTr("按下")
                    float_value: 1
                    hex_value: "3F 80 00 00"
                    enabled: true
                    changable: true
                }
                ListElement {
                    name: qsTr("抬起")
                    float_value: 0
                    hex_value: "00 00 00 00"
                    enabled: true
                    changable: true
                }
            }
        }

        MyMenuItem {
            text: qsTr("边框宽度:")
            plus_minus_on: true
            value_text: border_width
            value_editable: true
            onPlus_triggered: {
                border_width += 1;
            }
            onMinus_triggered: {
                border_width = Math.max(
                            0,
                            border_width - 1
                            );
            }

            onValue_inputed: {
                var tmp = parseInt(text);
                if (isNaN(tmp))
                    tmp = 0;
                border_width = tmp;
            }
        }
        MyMenuItem {
            text: qsTr("字体大小(px):")
            plus_minus_on: true
            value_text: font_size > 0?
                            font_size:
                            appTheme.fontPixelSizeNormal
            value_editable: true
            onPlus_triggered: {
                font_size = font_size_ + 1;
            }
            onMinus_triggered: {
                font_size = Math.max(
                            appTheme.fontPixelSizeNormal,
                            font_size - 1
                            );
            }

            onValue_inputed: {
                var tmp = parseInt(text);
                if (isNaN(tmp))
                    tmp = -1;
                font_size = tmp;
            }
        }
        MyMenu {
            id: color_menu
            title: qsTr("配色")
            MyMenuItem {
                text: qsTr("重置")
                tips_text: qsTr("恢复默认配色")
                onTriggered: {
                    color_border = "#D0D0D0";
                    color_normal = "#F5F5F5";
                    color_hovered = "blue";
                    color_pressed = "#0080ff";
                    color_text_1 = "blue";
                    color_text_2 = "white";
                }
            }

            Instantiator {
                model: ListModel {
                    ListElement {
                        text: qsTr("主体通常")
                        parameter: "color_normal"
                    }
                    ListElement {
                        text: qsTr("主体鼠标悬浮")
                        parameter: "color_hovered"
                    }
                    ListElement {
                        text: qsTr("主体鼠标按下")
                        parameter: "color_pressed"
                    }
                    ListElement {
                        text: qsTr("主体边框")
                        parameter: "color_border"
                    }
                    ListElement {
                        text: qsTr("文字通常")
                        parameter: "color_text_1"
                    }
                    ListElement {
                        text: qsTr("文字鼠标悬浮")
                        parameter: "color_text_2"
                    }
                }
                onObjectAdded: color_menu.addItem(object);
                onObjectRemoved: color_menu.removeItem(object)
                delegate: MyMenuItem {
                    text: model.text
                    property string color_: root[model.parameter]
                    color_mark_on: true
                    //                    selected: sys_manager.color_dialog.target_obj === this
                    selected: (sys_manager.color_dialog.parameter ===
                               model.parameter)
                    indicator_color: color_.length>0?
                                         color_:appTheme.lineColor
                    tips_text: text + ":" + indicator_color
                    onTriggered: {
                        sys_manager.open_color_dialog(
                                    root,
                                    model.parameter,
                                    color_
                                    );
                    }
                }
            }
        }
    }

    function onBind() {
        bound_bt_name.focus = false;
        var command = sys_manager.find_command_by_name(root.name);
        if (command) {
            bind = true;
            root.command = command;
        } else {
            bind = false;
        }
    }

    function onUnbind() {
        bound_bt_name.focus = false;
        bind = false;
        root.command = null;
    }

    function widget_ctx() {
        var ctx = {
            "path": path,
            "ctx": [
                {                       P:'ctx',           V: get_ctx()               },
                {                       P:'name',          V: name                    },
                {                       P:'color_normal',  V: color_normal            },
                {                       P:'color_hovered', V: color_hovered           },
                {                       P:'color_pressed', V: color_pressed           },
                {                       P:'color_border',  V: color_border            },
                {                       P:'color_text_1',  V: color_text_1            },
                {                       P:'color_text_2',  V: color_text_2            },
                {                       P:'border_width',  V: border_width            },
                {                       P:'font_size',     V: font_size               },
                {   T:"argument_menu",  P:'ctx',           V: argument_menu.get_ctx() },
                {   T:"cmd_menu",       P:'ctx',           V: cmd_menu.get_ctx()      }

            ]};
        return ctx;
    }

    function apply_widget_ctx(ctx) {
        __set_ctx__(root, ctx.ctx);
    }

    // called by sys_manager
    function set_color(parameter, color) {
        root[parameter] = "" + color;
    }

}
