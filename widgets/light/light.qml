import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Extras 1.4
import QtQml 2.13
import MyModules 1.0

ResizableRectangle {
    id: root
    property string path:  "light"
    height_width_ratio: 1
    border.width: ((hovered||ligth_mouse.containsMouse))?
                      g_settings.applyHScale(1):0
    property Item ref: Loader {
        active: false
        sourceComponent: Component {
            Item {
                property var ref_argument_menu :   argument_menu
                property var ref_cmd_menu      :   cmd_menu
                property var ref_ch_menu       :   ch_menu
                property var ref_value_menu    :   value_menu
                property var ref_name_menu     :   name_menu
            }
        }
    }

    height: g_settings.applyHScale(40)
    width: g_settings.applyHScale(40)
    minimumWidth: g_settings.applyHScale(40)
    minimumHeight: g_settings.applyHScale(40)
//    full_parent_enabled: false
    radius: g_settings.applyHScale(5)
    color: "transparent"
    border {
        color: "#D0D0D0"
        width: hovered?g_settings.applyHScale(1):0
    }

    property real bottom_value: -1
    property real top_value: 1
    property var command: null
    property bool fix_size: true

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
                             ch_menu.bind_obj.value.toFixed(value_menu.attr.decimal):
                             "0"
    property var threshold_model_ctx

    Connections {
        target: mouse
        onClicked: {
            if (mouse.button === Qt.RightButton)
                menu.popup();
        }
    }

    onThreshold_model_ctxChanged: {
        set_threshold_model_ctx();
    }

    MyStatusIndicator {
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
            margins: g_settings.applyHScale(5)
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

        MyMouseArea {
            id: ligth_mouse
            anchors.centerIn: parent
            width: Math.min(parent.width, parent.height)*2/3
            height: width
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
                sys_manager.send_command(name_menu.attr.name,
                                         cmd_menu.bind_obj,
                                         press_argument,
                                         argument_menu.hex_on
                                         );
            }
        }
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
                  ch_menu.bind_obj.value.toFixed(value_menu.attr.decimal):
                  "0"
        visible: value_menu.attr.visible
        font.family: g_settings.fontFamilyNumber
        font.pixelSize: value_menu.attr.font_size
        color: value_menu.attr.color
    }

    MyText {
        id: name_text
        editable: name_menu.attr.editable
        tips_text: name_menu.attr.tips_text
        anchors {
            top: parent.bottom
            horizontalCenter: parent.horizontalCenter
        }
        text: name_menu.attr.name
        visible: name_menu.attr.visible
        font.pixelSize: name_menu.attr.font_size
        color: name_menu.attr.color
        onText_inputed: name_menu.set_name(text);
    }

    MyIconMenu {
        id: menu
        text_center: false

        DeleteMenuItem {
            target: root
        }

        FillParentMenu {
            target: root
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
            text_center: false
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
                    hex_value: "00 00 80 3f"
                    enabled: true
                    changable: true
                }
                ListElement {
                    name: qsTr("三色模式 颜色1时点击")
                    float_value: 1
                    hex_value: "00 00 80 3f"
                    enabled: true
                    changable: true
                }
                ListElement {
                    name: qsTr("三色模式 颜色2时点击")
                    float_value: 2
                    hex_value: "00 00 00 40"
                    enabled: true
                    changable: true
                }
                ListElement {
                    name: qsTr("三色模式 颜色3时点击")
                    float_value: 3
                    hex_value: "00 00 40 40"
                    enabled: true
                    changable: true
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
        SettingsMenu {
            id: light_menu
            text_center: false
            title: qsTr("模式配置")
//            tips_text: ((light_color_menuitem.binded&&
//                         !three_color_mode)?
//                           qsTr("颜色<C>由已绑定频道决定"):"")
            MyMenuItem {
                text_center: true
                text: qsTr("模式:") + (three_color_mode?qsTr("三色"):qsTr("亮灭"))
                tips_text: three_color_mode?
                               qsTr("点击可切换为亮灭模式"):
                               qsTr("点击可切换为三色模式")
                onTriggered: three_color_mode = !three_color_mode
            }
            MyMenuSeparator {

            }
            MyMenuItem {
                visible: !three_color_mode
                text: qsTr("逻辑:") + ((reverse_logic?"<":">") +
                          qsTr("阈值时,灯亮"))
                tips_text: qsTr("点击可切换逻辑")
                onTriggered: reverse_logic = !reverse_logic
            }
            Instantiator {
                model: three_color_mode?three_color_model:on_off_model
                onObjectAdded: light_menu.insertItem(object.index+3, object)
                onObjectRemoved: light_menu.removeItem(object)
                delegate: MyMenuItem {
                    id: ch_menu_item
                    text_center: true
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
            MyMenuSeparator {

            }
            MyMenuItem {
                id: light_color_menuitem
                text_center: true
                visible: !three_color_mode
                text: qsTr("自定义颜色")
                tips_text: checked?
                               qsTr("已选中，再点击可修改颜色"):
                               qsTr("点击可选中自定义颜色，再点击可修改颜色")
                indicator_color: light_color
                color_mark_on: true
                checked: !light_color_link_ch
                onTriggered: {
                    if (checked)
                        sys_manager.open_color_dialog(
                                    root,
                                    "light_color",
                                    light_color
                                    );
                    light_color_link_ch = false;
                }
            }
            MyMenuItem {
                text_center: true
                visible: !three_color_mode
                text: qsTr("颜色跟随已绑定频道")
                checked: light_color_link_ch
                color_mark_on: true
                indicator_color: ch_menu.bind_obj?
                                     ch_menu.bind_obj.color:
                                     "white"
                onTriggered: light_color_link_ch = !light_color_link_ch
            }
            MyMenuItem {
                text_center: true
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
                text_center: true
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
                text_center: true
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

    function get_widget_ctx() {
        var ctx = {
            'path': path,
            'ctx': {
                '.': {
                    'ctx'                   :   get_ctx()                ,
                    'top_value'             :   top_value                ,
                    'bottom_value'          :   bottom_value             ,
                    'three_color_mode'      :   three_color_mode         ,
                    'light_color_link_ch'   :   light_color_link_ch      ,
                    'light_color'           :   light_color              ,
                    'reverse_logic'         :   reverse_logic            ,
                    'threshold_model_ctx'   :   get_threshold_model_ctx(),
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
                }
            }
        }

        return ctx;
    }

    function set_widget_ctx(ctx) {
        __set_ctx__(root, ctx.ctx, ref);
    }

    // called by sys_manager
    function set_color(parameter, color) {
        root[parameter] = "" + color;
    }

}
