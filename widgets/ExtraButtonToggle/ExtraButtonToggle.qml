import QtQuick 2.12
import QtQuick.Extras 1.4
import QtQuick.Controls.Styles 1.4
import QtQml 2.13
import QtGraphicalEffects 1.0
import MyModules 1.0
import "../Library/Extras"

ResizableRectangle {
    id: root
    height_width_ratio: 1
    color: "transparent"
    property string path:  "ExtraButtonToggle"
    property Item ref: Loader {
        active: false
        sourceComponent: Component {
            Item {
                property var ref_argument_menu:  argument_menu
                property var ref_cmd_menu:       cmd_menu
                property var ref_ch_menu:       ch_menu
                property var ref_name_menu:      name_menu
                property var ref_theme:          theme
            }
        }
    }
    property bool reverse_logic: false
    property real threshold: 0

    full_parent_enabled: true
    width: g_settings.applyHScale(100)
    height: g_settings.applyVScale(100)
    minimumWidth: g_settings.applyHScale(80)
    minimumHeight: g_settings.applyHScale(80)
    radius: g_settings.applyHScale(5)

    border.width: ((hovered)?
                       g_settings.applyHScale(1):0)

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
        property bool colorOnFollow: false
        property bool colorOffFollow: true

        property bool colorBtFollowCh: false
        property bool colorBorderFollowCh: false
        property bool colorTextFollowCh: true
        property bool colorOnFollowCh: true
        property bool colorOffFollowCh: false

        property color colorBt: appTheme.bgColor
        property color colorText: appTheme.fontColor
        property color colorBorder: appTheme.lineColor
        property color colorOn: appTheme.goodColor
        property color colorOff: appTheme.badColor

        property color colorBt_: {
            if (colorBtFollowCh) {
                if (ch_menu.bind_obj)
                    ch_menu.bind_obj.color
                else
                    appTheme.bgColor
            } else if (colorBtFollow)
                appTheme.bgColor
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
                    appTheme.lineColor
            } else if (colorBorderFollow) {
                appTheme.lineColor
            } else
                colorBorder
        }
        property color colorOn_: {
            if (colorOnFollowCh) {
                if (ch_menu.bind_obj)
                    ch_menu.bind_obj.color
                else
                    appTheme.goodColor
            } else if (colorOnFollow) {
                appTheme.goodColor
            } else
                colorOn
        }

        property color colorOff_: {
            if (colorOffFollowCh) {
                if (ch_menu.bind_obj)
                    ch_menu.bind_obj.color
                else
                    appTheme.badColor
            } else if (colorOffFollow) {
                appTheme.badColor
            } else
                colorOff
        }

        property var ctx

        function reset() {
            colorBtFollow       =   true
            colorBorderFollow   =   true
            colorTextFollow     =   false
            colorOnFollow       =   false
            colorOffFollow      =   true

            colorBtFollowCh     =   false
            colorBorderFollowCh =   false
            colorTextFollowCh   =   true
            colorOnFollowCh     =   true
            colorOffFollowCh    =   false
        }

        function get_ctx() {
            var ctx = {
                '.': {
                    'colorBt'               : ""+colorBt            ,
                    'colorText'             : ""+colorText          ,
                    'colorBorder'           : ""+colorBorder        ,
                    'colorOn'               : ""+colorOn            ,
                    'colorBtFollow'         : colorBtFollow         ,
                    'colorTextFollow'       : colorTextFollow       ,
                    'colorBorderFollow'     : colorBorderFollow     ,
                    'colorOnFollow'         : colorOnFollow         ,
                    'colorOffFollow'        : colorOffFollow        ,
                    'colorBtFollowCh'       : colorBtFollowCh       ,
                    'colorTextFollowCh'     : colorTextFollowCh     ,
                    'colorBorderFollowCh'   : colorBorderFollowCh   ,
                    'colorOnFollowCh'       : colorOnFollowCh       ,
                    'colorOffFollowCh'      : colorOffFollowCh      ,
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
        // called by sys_manager
        //        function set_color(parameter, color) {
        //            root[parameter] = "" + color;
        //        }
    }

    ToggleButton {
        id: button
        property bool threshold_checked: {
            if (!ch_menu.bind_obj)
                return false;
            if (!root.reverse_logic)
                return ch_menu.bind_obj.value >= root.threshold
            else
                return ch_menu.bind_obj.value <= root.threshold
        }
        property bool waiting: false

        checked: false
        anchors.fill: parent
        anchors.margins: g_settings.applyHScale(10)
        style: ToggleButtonStyle {
            id: button_style
            resizing: root.mouse.pressed
            property var __appTheme: appTheme
            checkedDropShadowColor: theme.colorOn_
            on__AppThemeChanged: {
                checkedGradient.stops[0].color = Qt.lighter(theme.colorOn_, 1.2);
                checkedGradient.stops[1].color = theme.colorOn_;
                button_style.updateStyle();
            }

            Connections {
                target: theme
                function updateStyle() {
                    checkedGradient.stops[0].color = Qt.lighter(theme.colorOn_, 1.2);
                    checkedGradient.stops[1].color = theme.colorOn_;
                    uncheckedGradient.stops[0].color = Qt.lighter(theme.colorOff_, 1.2);
                    uncheckedGradient.stops[1].color = theme.colorOff_;
                    button_style.updateStyle();
                }

                onColorBt_Changed: {
                    updateStyle();
                }

                onColorOn_Changed: {
                    updateStyle();
                }

                onColorBorder_Changed: {
                    updateStyle();
                }
            }

            Component.onCompleted: {
                __commonStyleHelper.onColor = Qt.binding(function(){
                    return theme.colorOn_;
                });
                __commonStyleHelper.onColorShine = Qt.binding(function(){
                    return Qt.lighter(theme.colorOn_, 1.2)
                });
                __commonStyleHelper.offColor = Qt.binding(function(){
                    return theme.colorOff_;
                });
                __commonStyleHelper.offColorShine = Qt.binding(function(){
                    return Qt.lighter(theme.colorOff_, 1.2)
                });
                __commonStyleHelper.inactiveColor = Qt.binding(function(){
                    return theme.colorBorder_;
                });
                __commonStyleHelper.inactiveColorShine = Qt.binding(function(){
                    return Qt.darker(theme.colorBorder_, 1.2)
                });

                __buttonHelper.buttonColorUpTop = Qt.binding(function(){
                    var target_color;
                    if (sys_manager.lightness(theme.colorBt_) <= 0.001)
                        target_color = Qt.rgba(0.05, 0.05, 0.05, 1);
                    else
                        target_color = theme.colorBt_;
                    if (sys_manager.lightness(target_color) > 0.5) {
                        return target_color;
                    } else {
                        return Qt.lighter(target_color, 3.5);
                    }
                })
                __buttonHelper.buttonColorUpBottom = Qt.binding(function(){
                    var target_color;
                    if (sys_manager.lightness(theme.colorBt_) <= 0.001)
                        target_color = Qt.rgba(0.05, 0.05, 0.05, 1);
                    else
                        target_color = theme.colorBt_;

                    if (sys_manager.lightness(target_color) > 0.5) {
                        return Qt.darker(target_color,1.5);
                    } else {
                        return target_color;
                    }
                })
                __buttonHelper.buttonColorDownTop = Qt.binding(function(){
                    return Qt.darker(__buttonHelper.buttonColorUpBottom, 1.05);
                })
                __buttonHelper.buttonColorDownBottom = Qt.binding(function(){
                    return Qt.darker(__buttonHelper.buttonColorUpTop, 1.05);
                })

                __buttonHelper.outerArcColorTop = Qt.binding(function(){
                    return theme.colorBorder_
                })
                __buttonHelper.outerArcColorBottom = Qt.binding(function(){
                    return Qt.rgba(
                                theme.colorBorder_.r,
                                theme.colorBorder_.g,
                                theme.colorBorder_.b,
                                0.29)
                })
                __buttonHelper.innerArcColorTop = Qt.binding(function(){
                    return Qt.darker(theme.colorBorder_, 1.5);
                })
                __buttonHelper.innerArcColorBottom = Qt.binding(function(){
                    var target_color = Qt.lighter(theme.colorBorder_, 1.5);
                    return Qt.rgba(
                                target_color.r,
                                target_color.g,
                                target_color.b,
                                0.5);
                })
            }
        }

        onThreshold_checkedChanged: {
            if (button.pressed)
                return;
            if (ch_menu.bind_obj) {
                waiting = true;
                checked = threshold_checked;
                waiting = false;
            }
        }

        onCheckedChanged: {
            if (waiting)
                return;

            if (ch_menu.bind_obj) {
                waiting = true;
                if (checked) {
                    send_command(0);
                } else {
                    send_command(1);
                }
                checked = threshold_checked;
                waiting = false;
            } else {
                if (checked) {
                    send_command(0);
                } else {
                    send_command(1);
                }
            }
        }
    }
   function send_command(argment_index) {
       var press_argument = argument_model.get(argment_index);
       sys_manager.send_command(name_menu.attr.name,
                                cmd_menu.bind_obj,
                                press_argument,
                                argument_menu.hex_on
                                );
   }

    states: [
        State {
            when: theme.opacity!==1
            PropertyChanges {
                target: root
                color: "transparent"
            }
        }
    ]

    MyText {
        id: name_text
        style: Text.Outline
        styleColor: Qt.rgba(
                        theme.colorBt_.r,
                        theme.colorBt_.g,
                        theme.colorBt_.b,
                        0.5
                        )
        width: button.width
        editable: true
        enter_edit_mode_by_click: false
        elide: Text.ElideMiddle
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        text: name_menu.attr.name
        color: theme.colorText_
        visible: name_menu.attr.visible
        font.bold: true
        font.pixelSize: name_menu.attr.font_size
        onText_inputed: name_menu.set_name(text);
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
                text: qsTr("重置")
                text_center: true
                onTriggered: {
                    reverse_logic   = false
                    threshold       = 0
                }
            }

            MyMenuSeparator {
            }

            MyMenuItem {
                text: qsTr("通道数值") + ((reverse_logic?"<=":">=") +
                          qsTr("阈值时,按钮激活"))
                tips_text: qsTr("点击可切换逻辑")
                onTriggered: reverse_logic = !reverse_logic
            }

            MyMenuItem {
                text_center: true
                text: qsTr("阈值：")
                value_text: root.threshold
                value_editable: true
                plus_minus_on: true
                onPlus_triggered: root.threshold += 1;
                onMinus_triggered: root.threshold -= 1;
                onValue_inputed: {
                    var tmp = parseFloat(text);
                    if (isNaN(tmp))
                        tmp = 0;
                    root.threshold = tmp;
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

        ArgumentMenu {
            id: argument_menu
            cmd_obj: cmd_menu.bind_obj
            model: ListModel {
                id: argument_model
                ListElement {
                    name: qsTr("请求激活")
                    float_value: 1
                    hex_value: "00 00 80 3f"
                    enabled: true
                    changable: true
                }
                ListElement {
                    name: qsTr("请求关闭")
                    float_value: 0
                    hex_value: "00 00 00 00"
                    enabled: true
                    changable: true
                }
            }
        }

        NameMenu {
            id: name_menu
            cmd_menu: cmd_menu
            ch_menu: ch_menu
            support_color: false
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
                        text: qsTr("按钮颜色")
                        parameter: "colorBt"
                        follow: "bgColor"
                    }
                    ListElement {
                        text: qsTr("外环颜色")
                        parameter: "colorBorder"
                        follow: "lineColor"
                    }
                    ListElement {
                        text: qsTr("关闭颜色")
                        parameter: "colorOff"
                        follow: "badColor"
                    }
                    ListElement {
                        text: qsTr("激活颜色")
                        parameter: "colorOn"
                        follow: "goodColor"
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
                              + (ch_menu.bind_obj?qsTr("（暂无）"):"")
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

    function get_widget_ctx() {
        var ctx = {
            'path': path,
            'ctx': {
                '.': {
                    'ctx'           : get_ctx(),
                    'reverse_logic' : reverse_logic,
                    'threshold'     : threshold,
                },
                "argument_menu" : {  'ctx': argument_menu.get_ctx()  },
                "ch_menu"       : {  'ctx': ch_menu.get_ctx()       },
                "cmd_menu"      : {  'ctx': cmd_menu.get_ctx()       },
                "name_menu"     : {  'ctx': name_menu.get_ctx()      },
                'theme'         : {  "ctx": theme.get_ctx()          },
            }
        }

        return ctx;
    }

    function set_widget_ctx(ctx) {
        __set_ctx__(root, ctx.ctx, ref);
    }
}
