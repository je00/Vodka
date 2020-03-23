import QtQuick 2.12;
import QtQuick.Controls 2.12
import QtQml 2.13
import QtGraphicalEffects 1.0
import MyModules 1.0

ResizableRectangle {
    id: root
    property var id_map: {
        'argument_menu': argument_menu,
        'cmd_menu':      cmd_menu,
        'name_menu':     name_menu,
        'theme':         theme
    }
    full_parent_enabled: true
    width: appTheme.applyHScale(74)
    height: appTheme.applyVScale(54)
    minimumWidth: minimumHeight
    minimumHeight: bt_mouse.anchors.margins * 3
    radius: appTheme.applyHScale(5)
    property string path:  "bound_bt"

    border.color: theme.colorBorder_
    border.width: theme.borderWidth

    Item {
        id: theme
        property bool color1Follow: true
        property bool color2Follow: true
        property bool colorBorderFollow: true

        property color color1: appTheme.bgColor
        property color color2: appTheme.mainColor
        property color colorBorder: appTheme.lineColor
        property int borderWidth: appTheme.applyHScale(1)

        property color color1_: color1Follow?appTheme.bgColor:color1
        property color color2_: color2Follow?appTheme.mainColor:color2
        property color colorBorder_: colorBorderFollow?appTheme.lineColor:colorBorder
        //        property real opacity: 1
        property var ctx
        function get_ctx() {
            var ctx = [
                        { P:'color1',             V: ""+color1          },
                        { P:'color2',             V: ""+color2          },
                        { P:'colorBorder',        V: ""+colorBorder     },
                        { P:'color1Follow',       V: color1Follow       },
                        { P:'color2Follow',       V: color2Follow       },
                        { P:'colorBorderFollow',  V: colorBorderFollow  },
                        { P:'borderWidth',        V: borderWidth        },
                        { P:'opacity',            V: opacity            },
                    ];
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

    Rectangle {
        opacity: theme.opacity *
                 ((bt_mouse.pressed||!root.enabled)?
                      0.7:1)
        anchors.fill: parent
        anchors.margins: theme.borderWidth
        color: ((bt_mouse.pressed||bt_mouse.containsMouse)?
                    theme.color2_:
                    theme.color1_)
        radius: parent.radius
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
        onDoubleClicked: {}
        function send_command(argment_index) {
            var press_argument = argument_model.get(argment_index);
            sys_manager.send_command(name_menu.attr.name,
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
        property real effect_text_ratio1: (parent.width - name_menu.attr.font_size)/bound_bt_name.width
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
        text: name_menu.attr.name
        color: bt_mouse.containsMouse?
                   theme.color1_:
                   theme.color2_
        font.bold: true
        font.pixelSize: name_menu.attr.font_size
        onText_inputed: name_menu.set_name(text);
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
        ArgumentMenu {
            id: argument_menu
            cmd_obj: cmd_menu.bind_obj
            model: ListModel {
                id: argument_model
                ListElement {
                    name: qsTr("按下")
                    float_value: 1
                    hex_value: "00 00 80 3f"
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
        NameMenu {
            id: name_menu
            cmd_menu: cmd_menu
            support_color: false
        }

        MyMenu {
            id: theme_menu
            text_center: true
            title: qsTr("主题")
            MyMenuItem {
                text: qsTr("重置")
                tips_text: qsTr("恢复默认配色")
                onTriggered: {
                    theme.color1Follow = true;
                    theme.color2Follow = true;
                    theme.colorBorderFollow = true;
                }
            }
            MyMenuItem {
                text_center: true
                text: qsTr("边框宽度:")
                plus_minus_on: true
                value_text: theme.borderWidth
                value_editable: true
                onPlus_triggered: {
                    theme.borderWidth += 1;
                }
                onMinus_triggered: {
                    theme.borderWidth = Math.max(
                                0,
                                theme.borderWidth - 1
                                );
                }

                onValue_inputed: {
                    var tmp = parseInt(text);
                    if (isNaN(tmp))
                        tmp = 0;
                    theme.borderWidth = tmp;
                }
            }

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
            MyMenuSeparator {

            }
            Instantiator {
                model: ListModel {
                    ListElement {
                        text: qsTr("颜色1")
                        parameter: "color1"
                        follow: "bgColor"
                    }
                    ListElement {
                        text: qsTr("颜色2")
                        parameter: "color2"
                        follow: "mainColor"
                    }
                    ListElement {
                        text: qsTr("边框")
                        parameter: "colorBorder"
                        follow: "lineColor"
                    }
                }
                onObjectAdded: theme_menu.addMenu(object);
                onObjectRemoved: theme_menu.removeMenu(object)
                delegate: MyMenu {
                    title: model.text
                    color_mark_on: true
                    indicator_color: theme[model.parameter+"_"]
                    MyMenuItem {
                        text: qsTr("自定义")
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
                        text: qsTr("跟随") + appTheme.colorName[model.follow]
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

    onClicked: {
        if (mouse.button === Qt.RightButton)
            menu.popup();
    }


    function onBind() {
    }

    function onUnbind() {
    }

    function widget_ctx() {
        var ctx = {
            "path": path,
            "ctx": [
                {                       P:'ctx',  V: get_ctx()                },
                {   T:"argument_menu",  P:'ctx',  V: argument_menu.get_ctx()  },
                {   T:"cmd_menu",       P:'ctx',  V: cmd_menu.get_ctx()       },
                {   T:"name_menu",      P:'ctx',  V: name_menu.get_ctx()      },
                {   T:'theme',          P:"ctx",  V: theme.get_ctx()          },
            ]};
        return ctx;
    }

    function apply_widget_ctx(ctx) {
        __set_ctx__(root, ctx.ctx);
    }
}
