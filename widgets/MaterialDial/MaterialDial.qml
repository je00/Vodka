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
                property var ref_ch_menu       :   ch_menu
                property var ref_value_menu    :   value_menu
                property var ref_name_menu     :   name_menu
                property var ref_theme         :   theme
            }
        }
    }

    property string path: "MaterialDial"
    property real from: 0
    property real to: 1000
    property real step_size: 1
    property bool loading: false
    border.width: ((hovered)?
                       g_settings.applyHScale(1):0)

    width: g_settings.applyHScale(120)
    height: g_settings.applyVScale(120)
    minimumWidth: Math.max(value_menu.attr.visible?value_text.width:0, g_settings.applyHScale(100))
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
        property bool colorTextFollow: false

        property bool colorBtFollowCh: false
        property bool colorBorderFollowCh: false
        property bool colorTextFollowCh: true

        property color colorBt: appTheme.bgColor
        property color colorText: appTheme.fontColor
        property color colorBorder: appTheme.lineColor

        property color colorBt_: {
            if (colorBtFollowCh) {
                if (ch_menu.bind_obj)
                    ch_menu.bind_obj.color
                else
                    appTheme.mainColor
            } else if (colorBtFollow)
                appTheme.mainColor
            else
                colorBt
        }
        property color colorText_: {
            if (colorTextFollowCh) {
                if (ch_menu.bind_obj)
                    ch_menu.bind_obj.color
                else
                    appTheme.fontColor
            } else if (colorTextFollow)
                appTheme.fontColor
            else
                colorText

        }
        property color colorBorder_: {
            if (colorBorderFollowCh) {
                if (ch_menu.bind_obj)
                    ch_menu.bind_obj.color
                else
                    appTheme.mainColor
            } else if (colorBorderFollow) {
                appTheme.mainColor
            } else
                colorBorder
        }

        property var ctx
        function reset() {
            colorBtFollow        = true
            colorBorderFollow   = true
            colorTextFollow        = true

            colorBtFollowCh      = false
            colorBorderFollowCh = false
            colorTextFollowCh      = true
        }

        function get_ctx() {
            var ctx = {
                '.': {
                    'colorBt'               : ""+colorBt            ,
                    'colorText'             : ""+colorText          ,
                    'colorBorder'           : ""+colorBorder        ,
                    'colorBtFollow'         : colorBtFollow         ,
                    'colorTextFollow'       : colorTextFollow       ,
                    'colorBorderFollow'     : colorBorderFollow     ,
                    'colorBtFollowCh'       : colorBtFollowCh       ,
                    'colorTextFollowCh'     : colorTextFollowCh     ,
                    'colorBorderFollowCh'   : colorBorderFollowCh   ,
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

    Dial {
        id: slider_inside
        snapMode: Dial.SnapAlways
        color: theme.colorBorder_
        handleColor: theme.colorBt_
        property real target_value: 0
        //        height: root.height
        //        anchors.fill: parent
        //        anchors.margins: g_settings.applyHScale(10)
        width: Math.min(parent.width, parent.height)
        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
            bottom: value_menu.attr.visible?value_text.top:parent.bottom

            //            margins: g_settings.applyHScale(10)
            topMargin: g_settings.applyHScale(10)
            leftMargin: g_settings.applyHScale(10)
            rightMargin: g_settings.applyHScale(10)
            bottomMargin: value_menu.attr.visible?0:g_settings.applyHScale(10)
        }

        from: root.from
        to: root.to
        stepSize: root.step_size
        value: target_value
        states: [
            State {
                when: slider_inside.pressed||slider_inside.hovered
                PropertyChanges {
                    explicit: true
                    target: slider_inside
                    value: target_value
                }
            }
        ]
        function send(index=0, use_force_value=false, force_value=0) {
            var send_value;
            if (use_force_value) {
                send_value = force_value;
                target_value = send_value;
            } else
                send_value = slider_inside.value;
            var value_string = send_value.toFixed(value_menu.attr.decimal)
            //            root_spinbox.value = value_string;
            for (var i = 0; i < argument_model.count; i++) {
                argument_model.get(i).hex_value = sys_manager.float_to_hex(send_value);
                argument_model.get(i).float_value = parseFloat(value_string);
            }

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
            if (!ch_menu.bind_obj) {
                target_value = value;
                send(0);
            } else {
                if (pressed || hovered) {
                    send(0);
                }
            }
        }
        onPressedChanged: {
            if (!pressed) {
                send(1);
            }
        }


    }

    MyText {
        id: value_text
        visible: value_menu.attr.visible
        //                && (slider_inside.pressed || slider_inside.hovered)
        //            visible: false
        text: (ch_menu.bind_obj?
                   ch_menu.bind_obj.value:
                   slider_inside.value).toFixed(value_menu.attr.decimal)
        color: value_menu.attr.color
        enabled: !sys_manager.lock
        font.family: g_settings.fontFamilyNumber
        font.pixelSize: value_menu.attr.font_size
        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
        }
        onTextChanged: {
            if (ch_menu.bind_obj)
                slider_inside.target_value = parseFloat(text);
        }
    }

    MyText {
        id: name_text
        z: 10
        anchors.centerIn: slider_inside
        width: slider_inside.width
        editable: true
        enter_edit_mode_by_click: false
        elide: Text.ElideMiddle
        anchors.horizontalCenter: parent.horizontalCenter
        text: name_menu.attr.name
        color: theme.colorText_
        visible: name_menu.attr.visible
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
                }
            }

            MyMenuSeparator { }

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
        ChMenu {
            id: ch_menu
            checked: bind_obj
            indicator_color: bind_obj?bind_obj.color:"red"
            onBind_objChanged: {
                if (!name_menu)
                    return;
                if (bind_obj) {
                    if (!name_menu.attr.name_link_cmd
                            && !name_menu.attr.name_link_ch) {
                        name_menu.attr.name_link_ch = true;
                        name_menu.attr.color_link_ch = true;
                    }
                } else {
                    name_menu.attr.name_link_ch = false;
                    name_menu.attr.color_link_ch = false;
                }
            }
        }

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
                    float_value: 0
                    hex_value: "00 00 00 00"
                    enabled: true
                    changable: false
                }
                ListElement {
                    name: qsTr("鼠标弹起时发送，当前")
                    float_value: 0
                    hex_value: "00 00 00 00"
                    enabled: false
                    changable: false
                }
            }
        }

        NameMenu {
            id: name_menu
            ch_menu: ch_menu
            cmd_menu: cmd_menu
        }

        ValueMenu {
            id: value_menu
            ch_menu: ch_menu
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
                        text: qsTr("字体颜色")
                        parameter: "colorText"
                        follow: "fontColor"
                    }
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
                        && !theme[model.parameter+"FollowCh"]
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
                            theme[model.parameter+"FollowCh"] = false;
                        }

                    }
                    MyMenuItem {
                        text: qsTr("跟随") + g_settings.colorName[model.follow]
                        text_center: true
                        checked: theme[model.parameter + "Follow"]
                        color_mark_on: true
                        indicator_color: appTheme[model.follow]
                        onTriggered: {
                            theme[model.parameter + "FollowCh"] = false;
                            theme[model.parameter + "Follow"] = !checked;
                        }
                    }
                    MyMenuItem {
                        text: qsTr("跟随已绑定通道")
                              + (ch_menu.bind_obj?"":qsTr("（暂无）"))
                        text_center: true
                        checked: theme[model.parameter + "FollowCh"]
                        color_mark_on: true
                        indicator_color: {
                            if (ch_menu.bind_obj) {
                                return ch_menu.bind_obj.color
                            } else {
                                return appTheme.bgColor
                            }
                        }

                        onTriggered: {
                            theme[model.parameter + "Follow"] = false;
                            theme[model.parameter + "FollowCh"] = !checked;
                        }
                    }
                }
            }
        }
    }

    MyToolTip {
        text: qsTr("鼠标位置数值") + ": " + slider_inside.mouseValue
        visible: slider_inside.hovered || slider_inside.pressed
    }

    function get_widget_ctx() {
        var ctx = {
            "path": path,
            'ctx': {

                '.': {
                    'ctx'       : get_ctx(),
                    'from'      : from     ,
                    'to'        : to       ,
                    'step_size' : step_size,
                },
                'slider_inside': {
                    'target_value': (Math.max(root.from, Math.min(root.to, slider_inside.target_value)))
                },

                'argument_menu': {
                    'ctx': argument_menu.get_ctx()
                },

                'cmd_menu': {
                    'ctx': cmd_menu.get_ctx()
                },
                'ch_menu': {
                    'ctx': ch_menu.get_ctx()
                },
                'value_menu': {
                    'ctx': value_menu.get_ctx()
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
