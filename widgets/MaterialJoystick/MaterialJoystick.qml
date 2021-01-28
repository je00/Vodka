import QtQuick 2.12;
//import QtQuick.Extras 1.4
//import QtQuick.Controls 2.12
//import QtQuick.Layouts 1.12
import MyModules 1.0
import "../Library/Material"

ResizableRectangle {
    id: root
    height_width_ratio: 1
    color: "transparent"
    property Item ref: Loader {
        active: false
        sourceComponent: Component {
            Item {
                property var ref_slider_inside :   slider_inside
                property var ref_argument_menu :   argument_menu
                property var ref_cmd_menu      :   cmd_menu
                property var ref_name_menu     :   name_menu
                property var ref_theme         :   theme
            }
        }
    }

    property string path: "MaterialJoystick"
    property real from: -1000
    property real to: 1000
    property real step_size: 1
    property alias boundEnabled: slider_inside.boundEnabled

    property bool loading: false
    border.width: ((hovered)?
                       g_settings.applyHScale(1):0)

    width: g_settings.applyHScale(120)
    height: g_settings.applyVScale(120)
    minimumWidth: Math.max(name_menu.attr.visible?name_text.width:0, g_settings.applyHScale(100))
    minimumHeight: minimumWidth

    Connections {
        target: mouse
        onClicked: {
            if (mouse.button === Qt.RightButton)
                menu.popup();
        }
    }

    Item {
        id: theme

        property bool colorBtFollow: true
        property bool colorBorderFollow: true

        property color colorBt: appTheme.mainColor
        property color colorBorder: appTheme.mainColor

        property color colorBt_: {
            if (colorBtFollow)
                appTheme.mainColor
            else
                colorBt
        }
        property color colorBorder_: {
            if (colorBorderFollow) {
                appTheme.mainColor
            } else
                colorBorder
        }

        property var ctx
        function reset() {
            colorBtFollow        = true
            colorBorderFollow   = true
        }

        function get_ctx() {
            var ctx = {
                '.': {
                    'colorBt'               : ""+colorBt            ,
                    'colorBorder'           : ""+colorBorder        ,
                    'colorBtFollow'         : colorBtFollow         ,
                    'colorBorderFollow'     : colorBorderFollow     ,
                }
            }

            return ctx;

        }
        function apply_ctx(ctx) {
            if (ctx) {
                __set_ctx__(theme, ctx);
            }
        }

        onCtxChanged: {
            if (ctx) {
                apply_ctx(ctx);
                ctx = undefined;
            }
        }
    }

    Joystick {
        id: slider_inside
        readonly property int stepSizeString: ""+stepSize
//        snapMode: Dial.SnapAlways
        color: theme.colorBorder_
        handleColor: theme.colorBt_
        width: Math.min(parent.width, parent.height)
        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
            bottom: name_menu.attr.visible?name_text.top:parent.bottom

            //            margins: g_settings.applyHScale(10)
            topMargin: g_settings.applyHScale(10)
            leftMargin: g_settings.applyHScale(10)
            rightMargin: g_settings.applyHScale(10)
            bottomMargin: name_menu.attr.visible?0:g_settings.applyHScale(10)
        }

        from: root.from
        to: root.to
        stepSize: root.step_size
        function send(index=0) {
            var send_value;
            var xvalue_string = slider_inside.xValue.toFixed(stepDecimals)
            var yvalue_string = slider_inside.yValue.toFixed(stepDecimals)
            //            root_spinbox.value = value_string;
            for (var i = 0; i < argument_model.count; i++) {
                argument_model.get(i).hex_values.get(0).value  = sys_manager.float_to_hex(slider_inside.xValue);
                argument_model.get(i).hex_values.get(1).value  = sys_manager.float_to_hex(slider_inside.yValue);
                argument_model.get(i).float_values.get(0).value = parseFloat(xvalue_string);
                argument_model.get(i).float_values.get(1).value = parseFloat(yvalue_string);
            }
            argument_menu.update_value();
            var argument = argument_model.get(index);
            if (!loading && sys_manager.connected) {
                sys_manager.send_command(name_menu.attr.name,
                                         cmd_menu.bind_obj,
                                         argument,
                                         argument_menu.hex_on
                                         );
            }
        }

        onValueChanged: {
            send(0);
        }

        onPressedChanged: {
            if (!pressed) {
                send(1);
            }
        }
    }

    MyText {
        id: name_text
        visible: name_menu.attr.visible
        z: 10
        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
        }
        width: slider_inside.width
        editable: true
        enter_edit_mode_by_click: false
        elide: Text.ElideMiddle
        text: name_menu.attr.name
        color: name_menu.attr.color
        font.bold: true
        font.pixelSize: name_menu.attr.font_size
        onText_inputed: name_menu.set_name(text);
    }

    Rectangle {
        color: "transparent"
        anchors {
            top: slider_inside.bottom
            left: slider_inside.left
            right: slider_inside.right
            bottom: parent.bottom
        }
    }

    MyIconMenu {
        id: menu

        DeleteMenuItem {
            target: root
        }

        FillParentMenu {
            target: root
        }

        SettingsMenu {
            MyMenuItem {
                text_center: true
                text: qsTr("重置")
                onTriggered: {
                    root.from = 0
                    root.to = 1000
                    root.step_size = 1
                    root.boundEnabled = true;
                }
            }

            MyMenuSeparator { }

            MyMenuItem {
                text_center: true
                text: qsTr("自动回弹")
                checked: root.boundEnabled
                onTriggered: {
                    root.boundEnabled = !root.boundEnabled;
                }
            }

            MyMenuItem {
                text_center: true
                text: qsTr("最小值") + ":"
                plus_minus_on: true
                value_text: "" + root.from
                value_editable: true
                onPlus_triggered: {
                    root.from = Math.min(
                                root.to,
                                root.from + 1
                                );

                }
                onMinus_triggered: {
                    root.from = root.from - 1;
                }
                onValue_inputed: {
                    var value = parseFloat(text);
                    if (!value)
                        value = 0;
                    root.from = Math.min(
                                root.to,
                                value
                                );
                }
            }

            MyMenuItem {
                text_center: true
                text: qsTr("最大值") + ":"
                plus_minus_on: true
                value_text: "" + root.to
                value_editable: true
                onPlus_triggered: {
                    root.to = root.to + 1;
                }
                onMinus_triggered: {
                    root.to = Math.max(
                                root.from,
                                root.to - 1
                                );
                }
                onValue_inputed: {
                    var value = parseFloat(text);
                    if (!value)
                        value = 0;
                    root.to = Math.max(
                                root.from,
                                value
                                );
                }
            }
            MyMenuItem {
                text_center: true
                text: qsTr("步进") + ":"
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

        MyMenuSeparator { }

        CmdMenu {
            id: cmd_menu
            title: qsTr("绑定命令")
            onBind_objChanged: {
                if (!name_menu)
                    return;
                if (bind_obj) {
                    if (!name_menu.attr.name_link_ch)
                        name_menu.attr.name_link_cmd = true;
                } else {
                    name_menu.attr.name_link_cmd = false;
                }
            }
        }

        ArgumentMenu {
            id: argument_menu
            cmd_obj: cmd_menu.bind_obj
            model: ListModel {
                id: argument_model
                ListElement {
                    name: qsTr("数值更新时发送，当前")
                    count: 2
                    float_values: [
                        ListElement{
                            value: 0
                        },
                        ListElement{
                            value: 0
                        }
                    ]
                    hex_values: [
                        ListElement{
                            value: "00 00 00 00"
                        },
                        ListElement{
                            value: "00 00 00 00"
                        }
                    ]
                    enabled: true
                    changable: false
                }
                ListElement {
                    name: qsTr("鼠标弹起时发送，当前")
                    count: 2
                    float_values: [
                        ListElement{
                            value: 0
                        },
                        ListElement{
                            value: 0
                        }
                    ]
                    hex_values: [
                        ListElement{
                            value: "00 00 00 00"
                        },
                        ListElement{
                            value: "00 00 00 00"
                        }
                    ]
                    enabled: false
                    changable: false
                }
            }
        }

        NameMenu {
            id: name_menu
            cmd_menu: cmd_menu
            ch_menu: null
        }

        ThemeMenu {
            id: theme_menu
            text_center: false
            MyMenuItem {
                text: qsTr("重置")
                text_center: true
                tips_text: qsTr("恢复默认配色")
                onTriggered: {
                    theme.reset();
                }
            }

            MyMenuSeparator {

            }
            Instantiator {
                model: ListModel {
                    ListElement {
                        text: qsTr("手柄颜色")
                        parameter: "colorBt"
                        follow: "mainColor"
                    }
                    ListElement {
                        text: qsTr("外环颜色")
                        parameter: "colorBorder"
                        follow: "mainColor"
                    }
                }
                onObjectAdded: theme_menu.addMenu(object);
                onObjectRemoved: theme_menu.removeMenu(object)
                delegate: MyMenu {
                    text_center: true
                    title: model.text
                    color_mark_on: true
                    indicator_color: theme[model.parameter+"_"]
                    MyMenuItem {
                        text: qsTr("自定义")
                        text_center: true
                        color_mark_on: true
                        //                    selected: sys_manager.color_dialog.target_obj === this
                        selected: (sys_manager.color_dialog.parameter ===
                                   model.parameter)
                        indicator_color: color_.length>0?
                                             color_:appTheme.lineColor
                        tips_text: checked?
                                       qsTr("已选中，再点击可修改颜色"):
                                       qsTr("点击可选中自定义颜色，再点击可修改颜色")
                        checked: !theme[model.parameter+"Follow"]
                        property string color_: theme[model.parameter]
                        onTriggered: {
                            if (checked) {
                                sys_manager.open_color_dialog(
                                            theme,
                                            model.parameter,
                                            color_
                                            );
                            }
                            theme[model.parameter+"Follow"] = false;
                        }

                    }
                    MyMenuItem {
                        text: qsTr("跟随") + g_settings.colorName[model.follow]
                        text_center: true
                        checked: theme[model.parameter + "Follow"]
                        color_mark_on: true
                        indicator_color: appTheme[model.follow]
                        onTriggered: {
                            theme[model.parameter + "Follow"] = !checked;
                        }
                    }
                }
            }
        }
    }

    MyToolTip {
        text: qsTr("鼠标位置数值") + ": " + slider_inside.mouseXValue + ", " + slider_inside.mouseYValue
        visible: slider_inside.hovered || slider_inside.pressed
    }

    function get_widget_ctx() {
        var ctx = {
            "path": path,
            'ctx': {

                '.': {
                    'ctx'           : get_ctx(),
                    'from'          : from     ,
                    'to'            : to       ,
                    'step_size'     : step_size,
                    'boundEnabled'  : boundEnabled,
                },
                'argument_menu': {
                    'ctx': argument_menu.get_ctx()
                },

                'cmd_menu': {
                    'ctx': cmd_menu.get_ctx()
                },
                'name_menu': {
                    'ctx': name_menu.get_ctx()
                },
                'theme': {
                    'ctx': theme.get_ctx()
                }
            }
        }

        return ctx;
    }

    function set_widget_ctx(ctx) {
        loading = true;
        __set_ctx__(root, ctx.ctx, ref);
        loading = false;
    }

}
