import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Styles 1.4
import QtQuick.Extras 1.4
import QtQml 2.13
import MyModules 1.0
import QtGraphicalEffects 1.14

ResizableRectangle {
    id: root
    color: "transparent"
    // path属性是每个控件都需要指定的，务必保证它们与你的控件目录名字一致
    property string path:  "circular_gauge"

    property Item ref: Loader {
        active: false
        sourceComponent: Component {
            Item {
                // ref_<对象id>：对象id
                property var ref_ch_menu: ch_menu
                property var ref_name_menu: name_menu
                property var ref_value_menu    :   value_menu
            }
        }
    }
    property real from: -1
    property real to: 1
    property real danger_ratio: 0.9
    property bool danger_on: true
    property bool danger_reverse: false
    property int decimal: 1
    property real font_scale: 1
    property real label_inset: 0.25
    readonly property real scale: (Math.min(gauge.width, gauge.height)/(g_settings.applyHScale(190)))
    readonly property real danger: parseFloat((root.from + (root.to - root.from)*danger_ratio).toFixed(fix_decimal))
    readonly property int fix_decimal: Math.max(6, decimal)
    //    border.width: g_settings.applyHScale(1)

    border.width: (((theme.hideBorder
                     &&!hovered
                     &&!main_mouse.containsMouse))?
                       0:g_settings.applyHScale(1))

    // 这里界定它们的最小宽、高均为100像素
    minimumWidth: g_settings.applyHScale(200)
    minimumHeight: g_settings.applyVScale(200)
    width: minimumWidth
    height: minimumHeight

    Item {
        id: theme
        property bool hideBorder: false
        property color bgColor: "white"
        property bool bgColorFollow: true
        property real bgOpacity: 1.0
        property var ctx
        function get_ctx() {
            var ctx = {
                '.': {
                    "hideBorder"         : hideBorder        ,
                    "bgColor"            : ""+bgColor        ,
                    "bgColorFollow"      : ""+bgColorFollow  ,
                    "bgOpacity"          : bgOpacity         ,
                }
            }

            return ctx;
        }
        function apply_ctx(ctx) {
            if (ctx)
                __set_ctx__(theme, ctx);
        }

        onCtxChanged: {
            if (ctx) {
                apply_ctx(ctx);
                ctx = undefined;
            }
        }
    }

    Rectangle {
        z: -1
        anchors.fill: parent
        color: theme.bgColorFollow?appTheme.bgColor:theme.bgColor
    }


    Item {
        id: gauge_actual_border
        height: Math.min(gauge.width, gauge.height)
        width: height
        anchors.centerIn: gauge

        Item {
            id: danger_ratio_item
            opacity: 0.7
            rotation: -145 + danger_ratio*290
            height: parent.height
            width: g_settings.applyVScale(2) * root.scale
            anchors.centerIn: parent
            Rectangle {
                id: danger_ratio_rect
                visible: root.danger_on
                height: parent.height/3
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                }
                color: {
                    if (gauge.value >= root.danger)
                        return appTheme.badColor
                    else
                        return appTheme.lineColor
                }
                layer.effect: MyDropShadow{}
                layer.enabled: true
            }
            Rectangle {
                id: base_handle
                visible: ratio_rect_mouse.containsMouse || ratio_rect_mouse.pressed
                anchors.bottom: danger_ratio_rect.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                width: g_settings.applyHScale(12) * root.scale
                height: width
                radius: width/2
                color: appTheme.lineColor
                layer.enabled: true
                layer.effect: MyDropShadow {}

            }
            MyText {
                rotation: -danger_ratio_item.rotation
                z: 20
                visible: ratio_rect_mouse.containsMouse || ratio_rect_mouse.pressed
                font.pixelSize: g_settings.fontPixelSizeSmall
                                * root.scale
                                * root.font_scale
                font.family: g_settings.fontFamilyAxis
                anchors.centerIn: base_handle
                text: "" + root.danger
            }

            MyMouseArea {
                id: ratio_rect_mouse
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                property var status
                anchors.horizontalCenter: danger_ratio_rect.horizontalCenter
                width: base_handle.width

                y: danger_ratio_rect.y
                height: danger_ratio_rect.height

                states: [
                    State {
                        when: ratio_rect_mouse.pressed
                        PropertyChanges {
                            explicit: true
                            target: ratio_rect_mouse
                            y: y
                        }
                    }
                ]
                onPressed: {
                    status = {
                        mouseY: mouseY,
                        ratio: root.danger_ratio
                    }
                }

                onPositionChanged: {
                    if (!pressed)
                        return;
                    var mouse_point = mapToItem(gauge_actual_border, mouseX, mouseY);
                    var center_point = [ gauge_actual_border.width/2, gauge_actual_border.height/2 ]

                    var mouse_vector = [ mouse_point.x - center_point[0], center_point[1] - mouse_point.y ]

                    var len_mouse_vector = Math.sqrt(Math.pow(mouse_point.x - center_point[0], 2)
                                                     + Math.pow(center_point[1] - mouse_point.y, 2))


                    var cos_angle = mouse_vector[0]/len_mouse_vector;
                    var angle = 180*Math.acos(cos_angle)/Math.PI;

                    if (center_point[1] < mouse_point.y) {
                        angle = 360 - angle;
                    }

                    angle = (360-angle) - 125;

                    if (angle < 0)
                        angle = 360+angle;

                    if (angle > 290) {
                        if (angle < (290 + 35))
                            angle = 290;
                        else
                            angle = 0;
                    }

                    var target_danger_ratio = angle/290;
                    fix_danger(target_danger_ratio);
                }
            }
        }
    }


    CircularGauge {
        id: gauge
        anchors {
            top: parent.top
            bottom: {
                if (value_text.visible) {
                    value_text.top
                } else {
                    parent.bottom
                }
            }
            left: parent.left
            right: parent.right
            leftMargin: root.width*0.025
            rightMargin: root.width*0.025
            topMargin: root.height*0.025
            bottomMargin: -root.height/6 * 0.3
        }

        minimumValue : root.from
        maximumValue : root.to
        stepSize : 0
        tickmarksVisible :true
        value: ch_menu.bind_obj?
                   ch_menu.bind_obj.value:
                   0
        Behavior on value {
            enabled: !sys_manager.connected
            NumberAnimation {
                duration: 200
            }
        }
        style: CircularGaugeStyle {
            id: circular_gauge_style
            labelInset: outerRadius * label_inset
            tickmarkLabel: Label {
                text: "" + styleData.value.toFixed(root.decimal)
                font.pixelSize: g_settings.fontPixelSizeSmall
                                * root.scale
                                * root.font_scale

                font.family: g_settings.fontFamilyAxis
                color: {
                    if (!root.danger_on)
                        return appTheme.fontColor;

                    if (root.danger_reverse) {
                        return (styleData.value.toFixed(root.fix_decimal) <= root.danger)?
                                    appTheme.badColor:
                                    appTheme.fontColor
                    } else {
                        return (styleData.value.toFixed(root.fix_decimal) >= root.danger)?
                                    appTheme.badColor:
                                    appTheme.fontColor
                    }
                }
            }
            labelStepSize: (root.to-root.from)/10
            tickmarkStepSize : (root.to-root.from)/10

            tickmark: Rectangle {
                radius: implicitWidth/2
                implicitWidth: outerRadius * 0.025
                antialiasing: true
                implicitHeight: outerRadius * 0.05
                color: {
                    if (!root.danger_on)
                        return appTheme.fontColor;

                    if (root.danger_reverse) {

                        return (styleData.value.toFixed(root.fix_decimal) <= root.danger)?
                                    appTheme.badColor:
                                    appTheme.fontColor
                    } else {
                        return (styleData.value.toFixed(root.fix_decimal) >= root.danger)?
                                    appTheme.badColor:
                                    appTheme.fontColor
                    }
                }
            }
            minorTickmark: Rectangle {
                radius: implicitWidth/2
                implicitWidth: outerRadius * 0.025
                antialiasing: true
                implicitHeight: outerRadius * 0.04
                color: {
                    if (!root.danger_on)
                        return appTheme.fontColorTips;
                    if (styleData.index.toFixed(root.fix_decimal) === 5)
                        console.log("styleData.value", styleData.value)

                    if (root.danger_reverse) {
                        (styleData.value.toFixed(root.fix_decimal) <= root.danger)?
                                    appTheme.badColor:
                                    appTheme.fontColorTips
                    } else {
                        (styleData.value.toFixed(root.fix_decimal) >= root.danger)?
                                    appTheme.badColor:
                                    appTheme.fontColorTips
                    }
                }
            }
            needle: Item {
                implicitWidth: __protectedScope.toPixels(0.08)
                implicitHeight: 0.9 * outerRadius

                Image {
                    id: img
                    visible: false
                    anchors.fill: parent
                    source: "./images/needle.svg"
                }
                ColorOverlay {
                    antialiasing: false
                    smooth: false
                    x: img.x
                    y: img.y
                    width: img.width
                    height: img.height
                    //                    parent: root
                    source: img
                    color: value_menu.attr.color
                }
                layer.enabled: true
                layer.effect: MyDropShadow {
                }
            }
            foreground: Item {
                Rectangle {
                    width: outerRadius * 0.2
                    height: width
                    radius: width / 2
                    color: appTheme.lineColor
                    anchors.centerIn: parent
                    layer.effect: MyDropShadow {

                    }
                    layer.enabled: true
                }
            }
        }
    }


    MyText {
        id: value_text
        anchors {
            bottom: parent.bottom
            bottomMargin: root.height*0.025
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
            topMargin: root.height*0.025
            horizontalCenter: parent.horizontalCenter
        }
        text: name_menu.attr.name
        visible: name_menu.attr.visible
        font.pixelSize: name_menu.attr.font_size
        color: name_menu.attr.color
        onText_inputed: name_menu.set_name(text);
    }

    Connections {
        // root.mouse：ResizableRectangle开放出来的MouseArea对象
        target: root.mouse
        onClicked: {
            if (mouse.button === Qt.RightButton) {
                menu.popup();
            }
        }
    }
    MyIconMenu {
        id: menu
        DeleteMenuItem {
            target: root
        }

        ScreenshotMenuItem {
            target: root
        }

        FillParentMenu {
            target: root
        }

        MyMenuSeparator {

        }

        SettingsMenu {
            MyMenuItem {
                text_center: true
                text: qsTr("重置")
                onTriggered: {
                    root.from = -1;
                    root.to = 1;
                    root.danger = 0.8;
                    root.danger_on = false;
                    root.danger_reverse = false;
                    root.decimal = 1;
                    root.font_scale = 0.9;
                    root.label_inset = 0.2;

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
                    root.from = root.from + 1;
                }
                onMinus_triggered: {
                    root.from = root.from - 1;
                }
                onValue_inputed: {
                    var value = parseFloat(text);
                    if (!value)
                        value = 0;
                    root.from = value;
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
                    root.to = root.to - 1;
                }
                onValue_inputed: {
                    var value = parseFloat(text);
                    if (!value)
                        value = 0;
                    root.to = value;
                }
            }
            MyMenuSeparator {
                margins: g_settings.applyHScale(10)
            }
            MyMenu {
                text_center: true
                title: qsTr("警告线")
                MyMenuItem {
                    text_center: true
                    text: qsTr("相对位置") + ":"
                    plus_minus_on: true
                    value_text: "" + root.danger_ratio
                    value_editable: true
                    onPlus_triggered: {
                        fix_danger(root.danger_ratio + 0.02);
                    }
                    onMinus_triggered: {
                        fix_danger(root.danger_ratio - 0.02);
                    }
                    onValue_inputed: {
                        var value = parseFloat(text);
                        if (isNaN(value))
                            value = 0;
                        fix_danger(value);
                    }
                }

                MyMenuItem {
                    text_center: true
                    text: qsTr("对应数值") + ":"
                    plus_minus_on: true
                    value_text: "" + root.danger
                    value_editable: true
                    onPlus_triggered: {
                        var step = (root.to - root.from)/50;
                        var tmp_value = (root.danger + step);
                        var tmp_ratio = (tmp_value - root.from) / (root.to - root.from);
                        fix_danger(tmp_ratio, true)
                    }
                    onMinus_triggered: {
                        var step = (root.to - root.from)/50;
                        var tmp_value = (root.danger - step);
                        var tmp_ratio = (tmp_value - root.from) / (root.to - root.from);

                        fix_danger(tmp_ratio, true)
                    }
                    onValue_inputed: {
                        var value = parseFloat(text);
                        if (isNaN(value))
                            value = root.from;
                        var tmp_value = value;
                        var tmp_ratio = (tmp_value - root.from) / (root.to - root.from);
                        fix_danger(tmp_ratio, false)
                    }
                }
            }

            MyMenuItem {
                text_center: true
                text: qsTr("开启警告")
                checked: root.danger_on
                onTriggered: {
                    root.danger_on = !root.danger_on;
                }
            }

            MyMenuItem {
                text_center: true
                text: qsTr("警告反向")
                checked: root.danger_reverse
                onTriggered: {
                    root.danger_reverse = !root.danger_reverse;
                }
            }

            MyMenuSeparator {
                margins: g_settings.applyHScale(10)
            }

            MyMenuItem {
                text_center: true
                text: qsTr("刻度小数位数") + ":"
                plus_minus_on: true
                value_text: "" + root.decimal
                value_editable: true
                onPlus_triggered: {
                    root.decimal = root.decimal + 1;
                }
                onMinus_triggered: {
                    root.decimal = Math.max(0,
                                            root.decimal - 1);
                }
                onValue_inputed: {
                    var value = parseInt(text);
                    if (isNaN(value) || value < 0)
                        value = 0;
                    root.decimal = value;
                }
            }
            MyMenuItem {
                text_center: true
                text: qsTr("刻度数字缩放") + ":"
                plus_minus_on: true
                value_text: "" + root.font_scale
                value_editable: true
                onPlus_triggered: {
                    root.font_scale = (root.font_scale + 0.01).toFixed(2);
                }
                onMinus_triggered: {
                    root.font_scale = Math.max(0.1,
                                               root.font_scale - 0.01).toFixed(2);
                }
                onValue_inputed: {
                    var value = parseFloat(text);
                    if (isNaN(value) || value <= 0)
                        value = 0.1;
                    root.font_scale = value;
                }
            }
            MyMenuItem {
                text_center: true
                text: qsTr("刻度数字位置") + ":"
                plus_minus_on: true
                value_text: "" + root.label_inset
                value_editable: true
                onPlus_triggered: {
                    root.label_inset = (root.label_inset + 0.01).toFixed(2);
                }
                onMinus_triggered: {
                    root.label_inset = (root.label_inset - 0.01).toFixed(2);
                }
                onValue_inputed: {
                    var value = parseFloat(text).toFixed(2);
                    if (!value)
                        value = 0;
                    root.label_inset = value;
                }
            }
        }

        MyMenuSeparator {

        }

        ChMenu {
            id: ch_menu
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
        NameMenu {
            id: name_menu
            ch_menu: ch_menu
        }
        ValueMenu {
            id: value_menu
            ch_menu: ch_menu
        }

        ThemeMenu {
            id: theme_menu

            MyMenuItem {
                text: qsTr("隐藏外框")
                checked: theme.hideBorder
                onTriggered: {
                    theme.hideBorder =
                            !theme.hideBorder;
                }
            }
            MyMenu {
                title: qsTr("背景颜色")
                MyMenuItem {
                    color_mark_on: true
                    indicator_color: appTheme.bgColor
                    text: qsTr("跟随") + g_settings.colorName["bgColor"]
                    checked: theme.bgColorFollow
                    onTriggered: {
                        theme.bgColorFollow = true;
                    }
                }
                MyColorMenuItem {
                    checked: !theme.bgColorFollow
                    text: qsTr("自定义颜色...")
                    target_obj: theme
                    target_name: "bgColor"
                    onTriggered: {
                        theme.bgColorFollow = false;
                    }
                }
            }

            MyMenuItem {
                text: qsTr("背景不透明度：")
                value_text: theme.bgOpacity.toFixed(2)
                plus_minus_on: true
                value_editable: true
                onPlus_triggered: {
                    theme.bgOpacity =
                            Math.min(1, theme.bgOpacity + 0.1).toFixed(2);
                }
                onMinus_triggered: {
                    theme.bgOpacity =
                            Math.max(0, theme.bgOpacity - 0.1).toFixed(2);
                }
                onValue_inputed: {
                    var tmp = parseFloat(text);
                    tmp = Math.max(0, tmp);
                    tmp = Math.min(1, tmp);
                    theme.bgOpacity = tmp.toFixed(2);
                }
            }
        }
    }


    function fix_danger(target_danger_ratio, stick_to_mark=true) {
        var target_danger = parseFloat((root.from + (root.to - root.from) * target_danger_ratio).toFixed(Math.max(6,root.decimal)));
        target_danger_ratio = (target_danger - root.from)/(root.to - root.from)
        target_danger_ratio = Math.min(1, Math.max(0, target_danger_ratio));
        if (stick_to_mark) {
            var count = Math.round(target_danger_ratio/0.02)
            target_danger_ratio = 0.02 * count;
        }

        root.danger_ratio = target_danger_ratio.toFixed(6);
    }

    //数据保存恢复
    function get_widget_ctx() {
        var ctx = {
            'path': path,
            'ctx': {
                '.': {  'ctx': get_ctx()   ,
                    'from'          : from          ,
                    'to'            : to            ,
                    'danger_ratio'  : danger_ratio  ,
                    'danger_on'     : danger_on     ,
                    'danger_reverse': danger_reverse,
                    'decimal'       : decimal       ,
                    'font_scale'    : font_scale    ,
                    'label_inset'   : label_inset   ,
                },
                'ch_menu': {
                    'ctx': ch_menu.get_ctx()
                },
                'name_menu': {
                    'ctx': name_menu.get_ctx()
                },
                'value_menu': {
                    'ctx': value_menu.get_ctx()
                },
                'theme': {
                    'ctx': theme.get_ctx()
                },
            }
        }

        return ctx;
    }

    function set_widget_ctx(ctx) {
        __set_ctx__(root, ctx.ctx, ref);
    }
}
