import QtQuick 2.12;
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import MyModules 1.0
import "../Library/Modules"

ResizableRectangle {
    id: root
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

    property string path: "slider"
    property real from: 0
    property real to: 1000
    property real step_size: 1
    property bool loading: false
    border.color: appTheme.lineColor
    border.width: (hovered||!theme.hideBorder)?g_settings.applyHScale(1):0
    height: minimumHeight
    width: g_settings.applyHScale(204)
    minimumHeight:
        (name_text.height + g_settings.applyVScale(16) + radius +
         value_text.height)/(5/6)
    //    minimumWidth: g_settings.applyHScale(204)
    minimumWidth: Math.max(g_settings.applyHScale(204), value_text.text_width)
    radius: g_settings.applyHScale(5)

    Connections {
        target: mouse
        onClicked: {
            if (mouse.button === Qt.RightButton)
                menu.popup();
        }
    }

    Rectangle {
        anchors {
            fill: parent
            margins: parent.border.width
        }
        radius: parent.radius
        opacity: theme.opacity
        color: theme.bgColor_
    }


    Item {
        id: theme
        property bool bgColorFollow: true
        property color bgColor: appTheme.bgColor
        property color bgColor_: bgColorFollow?appTheme.bgColor:bgColor
        property bool hideBorder: false
        property var ctx
        function get_ctx() {
            var ctx = {
                '.': {
                    'bgColorFollow': bgColorFollow,
                    'bgColor'      : "" + bgColor ,
                    'opacity'      : opacity      ,
                    'hideBorder'   : hideBorder   ,
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


    Item {
        //        border.width: 1
        anchors {
            bottom: slider_inside.top
            //            bottomMargin: g_settings.applyVScale(2)
            left: slider_inside.left
            right: slider_inside.right
            top: parent.top
        }

        MyText {
            id: value_text
            visible: value_menu.attr.visible
            text: (ch_menu.bind_obj?
                       ch_menu.bind_obj.value:
                       slider_inside.value).toFixed(value_menu.attr.decimal)
            color: value_menu.attr.color
            enabled: !sys_manager.lock
            font.family: g_settings.fontFamilyNumber
            font.pixelSize: value_menu.attr.font_size
            anchors {
                verticalCenter: parent.verticalCenter
                horizontalCenter: parent.horizontalCenter
            }
            onTextChanged: {
                if (ch_menu.bind_obj)
                    slider_inside.target_value = parseFloat(text);
            }
        }
    }

    MySlider {
        id: slider_inside
        z: 10
        color2: value_menu.attr.color
        property real target_value: 500
        height: root.height/6
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
            leftMargin: root.radius
            rightMargin: anchors.leftMargin
        }
        from: root.from
        to: root.to
        stepSize: root.step_size
        value: target_value
        //        Component.onCompleted: value = 500;
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
            root_spinbox.value = value_string;
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
                root_spinbox.value = value.toFixed(value_menu.attr.decimal);

                if (!root_spinbox.hovered) {
                    send(0);
                }
            } else {
                if (pressed || hovered) {
                    send(0);
                }
            }

            if (!root_spinbox.hovered) {
                root_spinbox.value = value.toFixed(value_menu.attr.decimal);
            }
        }
        onPressedChanged: {
            if (!pressed) {
                send(1);
            }
        }
    }

    Rectangle {
        color: "transparent"
        anchors {
            top: slider_inside.bottom
            left: slider_inside.left
            right: slider_inside.right
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
            width: Math.min(
                       parent.width - root_spinbox.width,
                       Math.max(this.text_width, parent.width/2)
                       )
            elide: Text.ElideMiddle
            editable: name_menu.attr.editable
            tips_text: name_menu.attr.tips_text
            text: name_menu.attr.name
            onText_inputed: name_menu.set_name(text);
        }
        MySpinBox {
            id: root_spinbox
            input_finished_dalay: 200
            anchors {
                verticalCenter: parent.verticalCenter
                right: parent.right
            }
            font.pixelSize: Math.max(g_settings.fontPixelSizeNormal,
                                     value_menu.attr.font_size/2)
            width: parent.width/2
            force_decimals: true
            decimals: value_menu.attr.decimal
            stepSize: root.step_size
            value: 500
            from: root.from
            to: root.to

            onInput_finished: {
                slider_inside.send(2, true, value);
            }
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
                    name: qsTr("滑块移动时发送，当前")
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
                ListElement {
                    name: qsTr("操作输入框时发送数值，当前")
                    float_value: 0
                    hex_value: "00 00 00 00"
                    enabled: true
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
            MyMenuItem {
                text_center: true
                text: qsTr("不透明度:")
                plus_minus_on: true
                value_text: theme.opacity.toFixed(2)
                value_editable: true
                onPlus_triggered: {
                    theme.opacity = Math.min(1, theme.opacity + 0.1);
                }
                onMinus_triggered: {
                    theme.opacity = Math.max(0, theme.opacity - 0.1);
                }

                onValue_inputed: {
                    var tmp = parseFloat(text);
                    if (isNaN(tmp))
                        return;
                    tmp = Math.max(0, tmp);
                    tmp = Math.min(1, tmp);
                    theme.opacity = tmp;
                }
            }
            MyMenuItem {
                text_center: true
                text: qsTr("自定义背景颜色")
                color_mark_on: true
                //                    selected: sys_manager.color_dialog.target_obj === this
                indicator_color: theme.bgColor
                tips_text: checked?
                               qsTr("已选中，再点击可修改颜色"):
                               qsTr("点击可选中自定义颜色，再点击可修改颜色")
                checked: !theme.bgColorFollow
                onTriggered: {
                    if (checked) {
                        sys_manager.open_color_dialog(
                                    theme,
                                    "bgColor",
                                    indicator_color
                                    );
                    }
                    theme.bgColorFollow = false;
                }

            }
            MyMenuItem {
                text_center: true
                text: qsTr("跟随") + g_settings.colorName["bgColor"]
                color_mark_on: true
                indicator_color: appTheme.bgColor
                checked: theme.bgColorFollow
                onTriggered: {
                    theme.bgColorFollow = !checked;
                }
            }
            MyMenuItem {
                text_center: true
                text: qsTr("隐藏外框")
                checked: theme.hideBorder
                onTriggered: {
                    theme.hideBorder =
                            !theme.hideBorder;
                }
            }
        }

    }

    MyToolTip {
        text: qsTr("鼠标位置数值") + ": " + slider_inside.mouseValue
        visible: slider_inside.hovered && !slider_inside.pressed
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
