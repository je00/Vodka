import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Extras 1.4
import QtQml 2.13

ResizableRectangle {
    id: root
    property var id_map: {
        'argument_menu': argument_menu,
        'cmd_menu':      cmd_menu,
        'ch_menu':       ch_menu
    }
    height: 40
    width: 40
    minimumWidth: 40
    minimumHeight: 40
    support_fill_parent: false
    radius: 5
    color: "transparent"
    border {
        color: "#D0D0D0"
        width: hovered?appTheme.applyHScale(1):0
    }
    tips_text: qsTr("右键可弹出菜单")
    height_width_ratio: 1

    property string path:  "light"
    property string name: "light"
    property string name_:  {
        if (name_link_ch && ch_menu.bind_obj)
            ch_menu.bind_obj.name
        else if (name_link_cmd && cmd_menu.bind_obj)
            cmd_menu.bind_obj.name
        else
            name
    }
    property bool value_visable: true
    property bool name_visable: true
    property real bottom_value: -1
    property real top_value: 1
    property var command: null
    property bool fix_size: true
    property int value_font_size: -1
    property int value_font_size_: (value_font_size > 0)?
                                       value_font_size:appTheme.fontPixelSizeNormal
    property string value_color: "black"
    property string value_color_: {
        if (v_color_link_ch && ch_menu.bind_obj)
            ch_menu.bind_obj.color
        else
            value_color
    }
    property int value_decimal: 5
    property bool v_color_link_ch: true

    property int name_font_size: -1
    property int name_font_size_: (name_font_size > 0)?
                                      name_font_size:
                                      appTheme.fontPixelSizeNormal
    property string name_color: "black"
    property string name_color_:  {
        if (n_color_link_ch && ch_menu.bind_obj)
            ch_menu.bind_obj.color
        else
            name_color
    }
    property bool name_link_ch: false
    property bool name_link_cmd: false
    property bool n_color_link_ch: true

    property bool three_color_mode: false
    property bool light_color_link_ch: true
    property string light_color: "#0080ff"
    property color light_color_: {
        if (light_color_link_ch && ch_menu.bind_obj)
            ch_menu.bind_obj.color
        else
            light_color
    }
    property bool reverse_logic: false

    property color light_color1: "red"
    property color light_color2: "yellow"
    property color light_color3: "green"
    property real value: ch_menu.bind_obj?
                             ch_menu.bind_obj.value.toFixed(value_decimal):
                             "0"
    property var threshold_model_ctx

    onThreshold_model_ctxChanged: {
        set_threshold_model_ctx();
    }

    StatusIndicator {
        id: light_bt
        property bool active_: false
        property color color_: light_color1
        active: {
            if (ch_menu.bind_obj) {
                if (three_color_mode)
                    true
                else {
                    if (reverse_logic)
                        root.value < on_off_model.get(0).value
                    else
                        root.value > on_off_model.get(0).value
                }
            } else {
                if (three_color_mode)
                    true
                else
                    active_
            }
        }

        anchors {
            fill: parent
            margins: 5
        }

        color: {
            if (!three_color_mode)
                light_color_
            else if (ch_menu.bind_obj) {
                if (root.value < three_color_model.get(0).value)
                    light_color1
                else if (root.value >= three_color_model.get(0).value &&
                         root.value < three_color_model.get(1).value)
                    light_color2
                else if (root.value > three_color_model.get(1).value)
                    light_color3
            } else {
                color_
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (three_color_mode) {
                    if (light_bt.color === light_color1) {
                        if (!ch_menu.bind_obj)
                            light_bt.color_ = light_color2;
                        send_command(2);
                    } else if (light_bt.color === light_color2) {
                        if (!ch_menu.bind_obj)
                            light_bt.color_ = light_color3;
                        send_command(3);
                    } else if (light_bt.color === light_color3) {
                        if (!ch_menu.bind_obj)
                            light_bt.color_ = light_color1;
                        send_command(4);
                    }
                } else {
                    if (light_bt.active)
                        send_command(1);
                    else
                        send_command(0);
                    if (!ch_menu.bind_obj)
                        light_bt.active_ = !light_bt.active_;
                }
            }
            function send_command(argment_index) {
                var press_argument = argument_model.get(argment_index);
                sys_manager.send_command(root.name,
                                         cmd_menu.bind_obj,
                                         press_argument,
                                         argument_menu.hex_on
                                         );
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

    ListModel {
        id: on_off_model
        ListElement {
            name: qsTr("阈值")
            value: 0
        }
    }

    ListModel {
        id: three_color_model
        ListElement {
            name: qsTr("阈值1")
            value: -0.5
        }
        ListElement {
            name: qsTr("阈值2")
            value: 0.5
        }
    }

    MyText {
        id: value_text
        anchors {
            bottom: parent.top
            horizontalCenter: parent.horizontalCenter
        }
        text: ch_menu.bind_obj?
                  ch_menu.bind_obj.value.toFixed(value_decimal):
                  "0"
        visible: parent.value_visable
        font.pixelSize: value_font_size_
        color: value_color_
    }

    MyText {
        id: name_text
        editable: !(root.name_link_ch || root.name_link_cmd)
        tips_text: {
            if (root.name_link_ch)
                qsTr("名称由已绑定频道决定")
            else if (root.name_link_cmd)
                qsTr("名称由已绑定命令决定")
            else
                qsTr("点击可修改名称。通过右键菜单设置，\n可将名称可与已绑定频道或命令绑定。")
        }
        anchors {
            top: parent.bottom
            horizontalCenter: parent.horizontalCenter
        }
        text: root.name_
        visible: root.name_visable
        font.pixelSize: root.name_font_size_
        color: name_color_
        onText_inputed: root.name = text
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
                    name: qsTr("亮灭模式 灯灭时点击")
                    float_value: 0
                    hex_value: "00 00 00 00"
                    enabled: true
                    changable: true
                }
                ListElement {
                    name: qsTr("亮灭模式 灯亮时点击")
                    float_value: 1
                    hex_value: "3F 80 00 00"
                    enabled: true
                    changable: true
                }
                ListElement {
                    name: qsTr("三色模式 颜色1时点击")
                    float_value: 1
                    hex_value: "3F 80 00 00"
                    enabled: true
                    changable: true
                }
                ListElement {
                    name: qsTr("三色模式 颜色2时点击")
                    float_value: 2
                    hex_value: "40 00 00 00"
                    enabled: true
                    changable: true
                }
                ListElement {
                    name: qsTr("三色模式 颜色3时点击")
                    float_value: 3
                    hex_value: "40 40 00 00"
                    enabled: true
                    changable: true
                }
            }
        }

        MyMenu {
            title: (qsTr("显示数值") + (binded?" <ch>":""))
            property bool binded: value_color_menu.binded
            tips_text: binded?qsTr("颜色由已绑定频道决定"):""
            indicator_color: value_color_
            checked: root.value_visable
            onTriggered: root.value_visable = !root.value_visable
            MyMenuItem {
                text: qsTr("字体大小:")
                plus_minus_on: true
                value_text: "" + value_font_size_
                value_editable: true
                onPlus_triggered: {
                    value_font_size = value_font_size_ + 1;
                }
                onMinus_triggered: {
                    value_font_size = Math.max(
                                appTheme.fontPixelSizeNormal,
                                value_font_size_ - 1
                                );
                }
                onValue_inputed: {
                    var tmp = parseInt(text);
                    if (isNaN(tmp))
                        tmp = -1;
                    value_font_size = tmp;
                }
            }
            MyMenuItem {
                text: qsTr("保留小数点后位数:")
                plus_minus_on: true
                value_text: "" + value_decimal
                value_editable: true
                onPlus_triggered: value_decimal = value_decimal + 1;
                onMinus_triggered: {
                    value_decimal = Math.max(
                                0,
                                value_decimal - 1
                                );
                }
                onValue_inputed: {
                    var tmp = parseInt(text);
                    if (isNaN(tmp))
                        tmp = 0;
                    value_decimal = tmp;
                }
            }

            MyMenuItem {
                id: value_color_menu
                text: (qsTr("颜色") + (binded?" <ch>":""))
                property bool binded: v_color_link_ch &&
                                      ch_menu.bind_obj
                tips_text: (binded?qsTr("颜色由已绑定频道决定"):text)
                           + ":" + color
                indicator_color: value_color_
                color_mark_on: true
                value_editable: true
                onTriggered: {
                    if (binded)
                        return;
                    sys_manager.open_color_dialog(
                                root,
                                "value_color",
                                value_color
                                );
                    menu.visible = false;
                }
            }
            MyMenuItem {
                text: qsTr("允许颜色由已绑定频道决定")
                checked: v_color_link_ch
                onTriggered: v_color_link_ch = !v_color_link_ch;
            }
        }
        MyMenu {
            title: (qsTr("显示名称") +
                    (name_color_menu.binded?" <ch>":"") +
                    ((name_ch_binded ||
                      name_cmd_binded)?" <cmd>":"")
                    )
            property bool binded: name_color_menu.binded ||
                                  name_ch_binded ||
                                  name_cmd_binded
            property bool name_ch_binded: name_link_ch && ch_menu.bind_obj
            property bool name_cmd_binded: name_link_cmd && cmd_menu.bind_obj
            tips_text: ((name_color_menu.binded?
                             qsTr("颜色由已绑定频道决定"):"") +
                        (name_ch_binded?
                             (name_color_menu.binded?"\n":"") +
                             qsTr("名称由已绑定频道决定"):
                             name_cmd_binded?
                                 (name_color_menu.binded?"\n":"") +
                                 qsTr("名称由已绑定命令决定"):
                                 "")
                        )

            indicator_color: name_color_
            checked: root.name_visable
            onTriggered: root.name_visable = !root.name_visable
            MyMenuItem {
                text: qsTr("名称字体大小:")
                plus_minus_on: true
                value_text: "" + name_font_size_
                value_editable: true
                onPlus_triggered: {
                    name_font_size = name_font_size_ + 1;
                }
                onMinus_triggered: {
                    name_font_size = Math.max(
                                appTheme.fontPixelSizeNormal,
                                name_font_size - 1
                                );
                }
            }

            MyMenuItem {
                id: name_color_menu
                text: (qsTr("颜色") + (binded?" <ch>":""))
                tips_text: (binded?qsTr("颜色由已绑定频道决定"):text) +
                           ":" + color
                property bool binded: (n_color_link_ch &&
                                       ch_menu.bind_obj)
                indicator_color: name_color_
                color_mark_on: true
                value_editable: true
                onTriggered: {
                    if (binded)
                        return;
                    sys_manager.open_color_dialog(
                                root,
                                "name_color",
                                name_color_
                                );
                    menu.visible = false;
                }
            }
            MyMenuItem {
                text: qsTr("允许名称由已绑定频道决定")
                checked: name_link_ch
                onTriggered: {
                    name_link_ch = !name_link_ch;
                    if (name_link_ch)
                        name_link_cmd = false;
                }
            }
            MyMenuItem {
                text: qsTr("允许名称由已绑定命令决定")
                checked: name_link_cmd
                onTriggered: {
                    name_link_cmd = !name_link_cmd;
                    if (name_link_cmd)
                        name_link_ch = false;
                }
            }

            MyMenuItem {
                text: qsTr("允许颜色由已绑定频道决定")
                checked: n_color_link_ch
                onTriggered: n_color_link_ch = !n_color_link_ch;
            }
        }
        MyMenu {
            id: light_menu
            title: qsTr("指示灯模式")
            MyMenuItem {
                text: three_color_mode?qsTr("三色模式"):qsTr("亮灭模式")
                tips_text: three_color_mode?
                               qsTr("点击可切换为亮灭模式"):
                               qsTr("点击可切换为三色模式")
                onTriggered: three_color_mode = !three_color_mode
            }
            MyMenuItem {
                visible: !three_color_mode
                text: reverse_logic?
                          qsTr("< 阈值时灯亮"):
                          qsTr("> 阈值时灯亮")
                tips_text: qsTr("点击可切换逻辑")
                onTriggered: reverse_logic = !reverse_logic
            }
            Instantiator {
                model: three_color_mode?three_color_model:on_off_model
                onObjectAdded: light_menu.insertItem(object.index+2, object)
                onObjectRemoved: light_menu.removeItem(object)
                delegate: MyMenuItem {
                    id: ch_menu_item
                    property int index: model.index
                    text: model.name + ":"
                    value_text: model.value
                    value_editable: true
                    plus_minus_on: true
                    onPlus_triggered: model.value += 1
                    onMinus_triggered: model.value -= 1
                    onValue_inputed: {
                        var tmp = parseFloat(text);
                        if (isNaN(tmp))
                            tmp = 0;
                        model.value = tmp;
                    }
                }
            }
            MyMenuItem {
                visible: !three_color_mode
                text: (qsTr("颜色") + (binded?" <ch>":""))
                tips_text: (binded?qsTr("颜色由已绑定频道决定"):text) +
                           ":" + color
                property bool binded: light_color_link_ch &&
                                      ch_menu.bind_obj
                indicator_color: light_color_
                color_mark_on: true
                onTriggered: {
                    if (binded) return;
                    sys_manager.open_color_dialog(
                                root,
                                "light_color",
                                light_color
                                );
                    menu.visible = false;
                }
            }
            MyMenuItem {
                visible: !three_color_mode
                text: qsTr("允许颜色由已绑定频道决定")
                checked: light_color_link_ch
                onTriggered: light_color_link_ch = !light_color_link_ch
            }
            MyMenuItem {
                visible: three_color_mode
                text: qsTr("颜色 ( -∞ ,阈值1)")
                tips_text: text + ":" + color
                indicator_color: light_color1
                color_mark_on: true
                onTriggered: {
                    sys_manager.open_color_dialog(
                                root,
                                "light_color1",
                                light_color1
                                );
                    menu.visible = false;
                }
            }
            MyMenuItem {
                visible: three_color_mode
                text: qsTr("颜色 [阈值1,阈值2)")
                tips_text: text + ":" + color
                indicator_color: light_color2
                color_mark_on: true
                onTriggered: {
                    sys_manager.open_color_dialog(
                                root,
                                "light_color2",
                                light_color2
                                );
                    menu.visible = false;
                }
            }
            MyMenuItem {
                visible: three_color_mode
                text: qsTr("颜色 (阈值2, +∞ )")
                tips_text: text + ":" + color
                indicator_color: light_color3
                color_mark_on: true
                onTriggered: {
                    sys_manager.open_color_dialog(
                                root,
                                "light_color3",
                                light_color3
                                );
                    menu.visible = false;
                }
            }

        }
    }


    function set_threshold_model_ctx() {
        if (!threshold_model_ctx ||
                threshold_model_ctx.length !== 2 ||
                threshold_model_ctx[1].length !== 2)
            return;
        on_off_model.get(0).value = threshold_model_ctx[0];
        for (var i = 0; i < 2; i++) {
            three_color_model.get(i).value =
                    threshold_model_ctx[1][i];
        }
    }

    function get_threshold_model_ctx() {
        var threshold_model = [
                    on_off_model.get(0).value,
                    [three_color_model.get(0).value,
                     three_color_model.get(1).value]
                ];
        return threshold_model;
    }

    function widget_ctx() {
        var ctx = {
            "path": path,
            "ctx": [
                {                    P:'ctx',                   V: get_ctx()                },
                {                    P:'top_value',             V: top_value                },
                {                    P:'bottom_value',          V: bottom_value             },
                {                    P:'value_visable',         V: value_visable            },
                {                    P:'value_color',           V: value_color              },
                {                    P:'value_font_size',       V: value_font_size          },
                {                    P:'value_decimal',         V: value_decimal            },
                {                    P:'v_color_link_ch',       V: v_color_link_ch          },
                {                    P:'name',                  V: name                     },
                {                    P:'name_visable',          V: name_visable             },
                {                    P:'name_color',            V: name_color               },
                {                    P:'name_link_ch',          V: name_link_ch             },
                {                    P:'name_link_cmd',         V: name_link_cmd            },
                {                    P:'n_color_link_ch',       V: n_color_link_ch          },
                {                    P:'three_color_mode',      V: three_color_mode         },
                {                    P:'light_color_link_ch',   V: light_color_link_ch      },
                {                    P:'light_color',           V: light_color              },
                {                    P:'reverse_logic',         V: reverse_logic            },
                {                    P:'threshold_model_ctx',   V: get_threshold_model_ctx()},
                { T:"argument_menu", P:'ctx',                   V: argument_menu.get_ctx()  },
                { T:"cmd_menu",      P:'ctx',                   V: cmd_menu.get_ctx()       },
                { T:"ch_menu",       P:'ctx',                   V: ch_menu.get_ctx()        }

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
