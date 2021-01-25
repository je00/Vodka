import QtQuick 2.12
import QtQuick.Extras 1.4
import QtQml 2.13
import QtGraphicalEffects 1.14
import QtQuick.Controls 2.12
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls.Material 2.12
import QtQuick.Controls.Material.impl 2.12

import MyModules 1.0
import "../Library/Modules"

ResizableRectangle {
    id: root
    color: "transparent"
    // path属性是每个控件都需要指定的，务必保证它们与你的控件目录名字一致
    property string path:  "gauge"

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


    property real from: -2
    property real to: 2
    property int  decimal: 1
    property real label_scale: 1
    property real base_ratio: 0.5
    property real danger_from_ratio: 0
    property real danger_to_ratio: 1
    property bool danger_on: false
    property bool danger_reverse: false

    readonly property real base:        (root.from + (root.to - root.from)*base_ratio).toFixed(fix_decimal)
    readonly property real danger_from: (root.from + (root.to - root.from)*danger_from_ratio).toFixed(fix_decimal)
    readonly property real danger_to:   (root.from + (root.to - root.from)*danger_to_ratio).toFixed(fix_decimal)
    readonly property int fix_decimal: Math.max(6, decimal)

    readonly property color danger_from_line_color: {
        if (root.danger_on
                && (root.danger_reverse
                    && (gauge.value.toFixed(fix_decimal) >= root.danger_from
                        && gauge.value.toFixed(fix_decimal) <= root.danger_to))
                || (!root.danger_reverse
                    &&(gauge.value.toFixed(fix_decimal) <= root.danger_from))) {
            return appTheme.badColor
        }
        return appTheme.lineColor
    }

    readonly property color danger_to_line_color: {
        if (root.danger_on
                && (root.danger_reverse
                    && (gauge.value.toFixed(fix_decimal) >= root.danger_from
                        && gauge.value.toFixed(fix_decimal) <= root.danger_to))
                || (!root.danger_reverse
                    &&(gauge.value.toFixed(fix_decimal) >= root.danger_to))) {
            return appTheme.badColor
        }
        return appTheme.lineColor
    }

    readonly property color base_line_color: appTheme.lineColor
    //    border.width: g_settings.applyHScale(1)

    border.width: (((theme.hideBorder
                     &&!hovered
                     &&!main_mouse.containsMouse))?
                       0:g_settings.applyHScale(1))

    // 这里界定它们的最小宽、高均为100像素
    minimumWidth: Math.max(
                      gauge.label_offset + g_settings.applyHScale(18) + g_settings.applyHScale(36),
                      value_text.visible?value_text.width:0,
                      name_text.visible?name_text.width:0)
    minimumHeight: g_settings.applyVScale(210)
    width: minimumWidth
    height: minimumHeight

    property real scale: Math.min(root.width/minimumWidth, root.height/minimumHeight)
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
        opacity: theme.bgOpacity
        radius: root.radius
    }

    Item {
        id: root_item

        anchors {
            top: value_menu.attr.visible?value_text.bottom:parent.top
            bottom: name_menu.attr.visible?name_text.top:parent.bottom
            //            bottom: parent.bottom
            left: parent.left
            right: parent.right

            topMargin: value_menu.attr.visible?0:(root.height * 0.02)
            bottomMargin: name_menu.attr.visible?0:(root.height * 0.02)
            //            bottomMargin: anchors.topMargin
            rightMargin: g_settings.applyHScale(6)
        }

        Gauge {
            id: gauge
            anchors.fill: parent
            minimumValue : root.from
            maximumValue : root.to
            value: ch_menu.bind_obj?
                       ch_menu.bind_obj.value:
                       0

            minorTickmarkCount :4
            tickmarkStepSize:(root.to-root.from)/10
            tickmarkAlignment: Qt.AlignLeft
            Behavior on value {
                enabled: !sys_manager.connected
                NumberAnimation {
                    duration: 200
                }
            }
            property int from_label_width
            property int from_label_height
            property int to_label_width
            property int to_label_height
            property int label_offset: Math.max(from_label_width, to_label_width)
            property int label_count: {
                var target_count = gauge.height/from_label_height;
                if (target_count < 10) {
                    if (target_count < 5) {
                        return 2;
                    } else {
                        return 5;
                    }
                } else {
                    return 10
                }
            }

            style: GaugeStyle {
                tickmarkLabel: MyText {
                    id: label_text
                    x: gauge.label_offset
                    text:""+styleData.value.toFixed(decimal)
                    font.pixelSize: label_scale*g_settings.fontPixelSizeSmall
                    font.family: g_settings.fontFamilyAxis
                    color: {
                        if (!root.danger_on)
                            return appTheme.fontColor

                        if ((root.danger_reverse
                             && (styleData.value.toFixed(fix_decimal) >= root.danger_from
                                 && styleData.value.toFixed(fix_decimal) <= root.danger_to))
                                || (!root.danger_reverse
                                    &&(styleData.value.toFixed(fix_decimal) <= root.danger_from
                                       || styleData.value.toFixed(fix_decimal) >= root.danger_to))) {
                            return appTheme.badColor
                        }

                        return appTheme.fontColor
                    }

                    visible: styleData.index % (10/gauge.label_count) === 0
                    Component.onCompleted: {
                        switch (styleData.index) {
                        case 0:
                            gauge.from_label_width = Qt.binding(function(){
                                return label_text.width;
                            });
                            gauge.from_label_height = Qt.binding(function(){
                                return label_text.height;
                            });
                            break;
                        case 9:
                            gauge.to_label_width = Qt.binding(function(){
                                return label_text.width;
                            });
                            gauge.to_label_height = Qt.binding(function(){
                                return label_text.height;
                            });
                            gauge.anchors.topMargin = Qt.binding(function(){
                                return label_text.height/2;
                            })
                            break;
                        }
                    }
                }
                tickmark: Rectangle {
                    x: gauge.label_offset
                    implicitWidth: g_settings.applyHScale(10) * root.scale
                    antialiasing: true
                    implicitHeight: g_settings.applyVScale(2) * root.scale
                    color: {
                        if (!root.danger_on)
                            return appTheme.fontColor

                        if ((root.danger_reverse
                             && (styleData.value.toFixed(fix_decimal) >= root.danger_from
                                 && styleData.value.toFixed(fix_decimal) <= root.danger_to))
                                || (!root.danger_reverse
                                    &&(styleData.value.toFixed(fix_decimal) <= root.danger_from
                                       || styleData.value.toFixed(fix_decimal) >= root.danger_to))) {
                            return appTheme.badColor
                        }

                        return appTheme.fontColor
                    }
                }
                minorTickmark: Rectangle {
                    x: gauge.label_offset
                    implicitWidth: g_settings.applyHScale(5) * root.scale
                    antialiasing: true
                    implicitHeight: g_settings.applyVScale(1) * root.scale
                    color: {
                        if (!root.danger_on)
                            return appTheme.fontColorTips

                        if ((root.danger_reverse
                             && (styleData.value.toFixed(fix_decimal) >= root.danger_from
                                 && styleData.value.toFixed(fix_decimal) <= root.danger_to))
                                || (!root.danger_reverse
                                    &&(styleData.value.toFixed(fix_decimal) <= root.danger_from
                                       || styleData.value.toFixed(fix_decimal) >= root.danger_to))) {
                            return appTheme.badColor
                        }
                        return appTheme.fontColorTips
                    }
                }
                valueBar: Item {
                    x: gauge.label_offset + g_settings.applyHScale(2)
                    implicitWidth: root_item.width - gauge.label_offset
                                   - g_settings.applyHScale(10) * root.scale
                                   - g_settings.applyHScale(6)
                                   - g_settings.applyHScale(2)

                }
                foreground: Item {
                    id: value_bar_container
                    x: gauge.label_offset + g_settings.applyHScale(2)
                    implicitWidth: root_item.width - gauge.label_offset - g_settings.applyHScale(18)

                    Rectangle {
                        anchors {
                            left: parent.left
                            right: parent.right
                        }
                        y: {
                            if (gauge.value.toFixed(root.fix_decimal) > root.base) {
                                parent.height * (root.to - gauge.value.toFixed(root.fix_decimal)) / (root.to - root.from)
                            } else {
                                parent.height * (root.to - root.base) / (root.to - root.from)
                            }
                        }
                        height: {
                            if (gauge.value.toFixed(root.fix_decimal) > root.base) {
                                parent.height * (gauge.value.toFixed(root.fix_decimal) - root.base) / (root.to - root.from)
                            } else {
                                parent.height * (root.base - gauge.value.toFixed(root.fix_decimal)) / (root.to - root.from)
                            }
                        }
                        color: value_menu.attr.color
                    }

                    Instantiator {
                        model: ListModel {
                            ListElement {
                                z: 2
                                ratio: "base_ratio"
                                value: "base"
                                x_pos: 0.5
                                line_color: "base_line_color"
                            }

                            ListElement {
                                z: 1
                                ratio: "danger_from_ratio"
                                value: "danger_from"
                                max: "danger_to_ratio"
                                line_color: "danger_from_line_color"
                                visible: "danger_on"
                                x_pos: 0
                            }

                            ListElement {
                                z: 1
                                ratio: "danger_to_ratio"
                                value: "danger_to"
                                min: "danger_from_ratio"
                                line_color: "danger_to_line_color"
                                visible: "danger_on"
                                x_pos: 1
                            }

                        }

                        delegate: Item {
                            z: ratio_rect_mouse.containsMouse?10:model.z
                            visible: {
                                if (model.visible === undefined)
                                    return true
                                else
                                    root[model.visible]
                            }
                            parent: value_bar_container
                            anchors.fill: parent
                            Rectangle {
                                id: ratio_rect
                                radius: height/2
                                opacity: 0.7
                                z:-1
                                height: g_settings.applyVScale(2) * root.scale
                                anchors {
                                    left: parent.left
                                    right: parent.right
                                }
                                y: (1 - root[model.ratio]) * (parent.height - height)
                                //                                color: appTheme.lineColor
                                color: root[model.line_color]
                                layer.enabled: true
                                layer.effect: Glow {
                                    color: appTheme.bgColor
                                }
                            }

                            MyRipple {
                                anchors.centerIn: base_handle
                                width: base_handle.width * 1.5
                                height: width
                                pressed: ratio_rect_mouse.pressed
                                active: ratio_rect_mouse.pressed || ratio_rect_mouse.containsMouse
                            }

                            Rectangle {
                                id: base_handle
                                x: (parent.width - width) * model.x_pos
                                visible: ratio_rect_mouse.containsMouse || ratio_rect_mouse.pressed
                                //                                         || root.mouse.containsMouse
                                anchors {
                                    verticalCenter: ratio_rect.verticalCenter
                                }
                                width: g_settings.applyHScale(10) * root.scale
                                height: width
                                radius: width/2
                                color: (ratio_rect_mouse.pressed || ratio_rect_mouse.containsMouse)?
                                           value_menu.attr.color:appTheme.lineColor
                                layer.enabled: !(ratio_rect_mouse.pressed || ratio_rect_mouse.containsMouse)
                                layer.effect: MyDropShadow {}
                                MyToolTip {
                                    text: "" + root[model.value]
                                    visible: ratio_rect_mouse.containsMouse || ratio_rect_mouse.pressed
                                }
                                scale: ratio_rect_mouse.pressed ? 1.3 : 1

                                Behavior on scale {
                                    NumberAnimation {
                                        duration: 250
                                    }
                                }
                            }

                            MyMouseArea {
                                id: ratio_rect_mouse
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                property var status
                                x: {
                                    if (model.x_pos === 0.5) {
                                        base_handle.x + base_handle.width/2 - width/2
                                    } else if (model.x_pos < 0.5) {
                                        base_handle.x
                                    } else {
                                        base_handle.x + base_handle.width - width
                                    }
                                }
                                y: base_handle.y
                                width: parent.width - base_handle.width*2
                                height: base_handle.height

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
                                        ratio: root[model.ratio]
                                    }
                                }

                                onPositionChanged: {
                                    if (pressed) {
                                        var tmp_ratio = status.ratio
                                                + ((status.mouseY - mouseY) / value_bar_container.height);
                                        if (model.max !== undefined) {
                                            tmp_ratio = Math.min(root[model.max], tmp_ratio)
                                        } else {
                                            tmp_ratio = Math.min(1, tmp_ratio)
                                        }

                                        if (model.min !== undefined) {
                                            tmp_ratio = Math.max(root[model.min], tmp_ratio)
                                        } else {
                                            tmp_ratio = Math.max(0, tmp_ratio)
                                        }

                                        fix_ratio(model.ratio, tmp_ratio);
                                    }
                                }
                            }
                        }

                    }
                }
            }
        }
    }


    MyText {
        id: value_text
        anchors {
            top: root.top
            topMargin: root.height*0.025
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
            bottom: root.bottom
            bottomMargin: root.height*0.025
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

    Component {
        id: ratio_menu_component
        MyMenu {
            id: ratio_menu
            property string property: "base_ratio"
            property string value_property: "base"
            property real max: 1.0
            property real min: 0.0
            text_center: true
            title: qsTr("基线位置")

            MyMenuItem {
                text_center: true
                text: qsTr("相对位置") + ":"
                plus_minus_on: true
                value_text: "" + root[ratio_menu.property]
                value_editable: true
                onPlus_triggered: {
                    fix_ratio(ratio_menu.property, root[ratio_menu.property] + 0.02, true, ratio_menu.min, ratio_menu.max);
                }
                onMinus_triggered: {
                    fix_ratio(ratio_menu.property, root[ratio_menu.property] - 0.02, true, ratio_menu.min, ratio_menu.max);
                }
                onValue_inputed: {
                    var value = parseFloat(text);
                    if (isNaN(value))
                        value = 0;
                    fix_ratio(ratio_menu.property, value, true, ratio_menu.min, ratio_menu.max);
                }
            }

            MyMenuItem {
                text_center: true
                text: qsTr("对应数值") + ":"
                plus_minus_on: true
                value_text: "" + root[ratio_menu.value_property]
                value_editable: true
                onPlus_triggered: {
                    var step = (root.to - root.from)/50;
                    var tmp_value = (root[ratio_menu.value_property] + step);
                    var tmp_ratio = (tmp_value - root.from) / (root.to - root.from);

                    fix_ratio(ratio_menu.property, tmp_ratio, true, ratio_menu.min, ratio_menu.max);
                }
                onMinus_triggered: {
                    var step = (root.to - root.from)/50;
                    var tmp_value = (root[ratio_menu.value_property] - step);
                    var tmp_ratio = (tmp_value - root.from) / (root.to - root.from);

                    fix_ratio(ratio_menu.property, tmp_ratio, true, ratio_menu.min, ratio_menu.max);
                }
                onValue_inputed: {
                    var value = parseFloat(text);
                    if (isNaN(value))
                        value = root.from;
                    var tmp_value = value;
                    var tmp_ratio = (tmp_value - root.from) / (root.to - root.from);

                    fix_ratio(ratio_menu.property, tmp_ratio, false, ratio_menu.min, ratio_menu.max);
                }
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

        MyMenuSeparator {}

        SettingsMenu {
            id: settings_menu
            MyMenuItem {
                text_center: true
                text: qsTr("重置")
                onTriggered: {
                    root.from = -5;
                    root.to = 5;
                    root.decimal = 1;
                    root.label_scale = 1;
                    root.base_ratio = 0.5;
                    root.danger_from_ratio = 0;
                    root.danger_to_ratio = 1;
                    root.danger_on = false;
                    root.danger_reverse = false;
                }
            }

            MyMenuItem {
                text_center: true
                text: qsTr("上限") + ":"
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
                    if (isNaN(value))
                        value = 0;
                    root.to = Math.max(root.from, value);
                }
            }

            MyMenuItem {
                text_center: true
                text: qsTr("下限") + ":"
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
                    if (isNaN(value))
                        value = 0;
                    root.from = Math.min(root.to, value);
                }
            }

            Loader {
                sourceComponent: ratio_menu_component
                onLoaded: {
                    item.property ="base_ratio"
                    item.value_property ="base"
                    item.title = Qt.binding(function(){
                        return qsTr("基线位置")
                    })
                    settings_menu.insertMenu(3, item);
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
                    root.decimal = root.decimal - 1;
                }
                onValue_inputed: {
                    var value = parseInt(text);
                    if (isNaN(value))
                        value = 0;
                    root.decimal = value;
                }
            }


            MyMenuItem {
                text_center: true
                text: qsTr("刻度数字缩放") + ":"
                plus_minus_on: true
                value_text: "" + root.label_scale
                value_editable: true
                onPlus_triggered: {
                    root.label_scale = (root.label_scale + 0.1).toFixed(2);
                }
                onMinus_triggered: {
                    root.label_scale = (root.label_scale - 0.1).toFixed(2);
                }
                onValue_inputed: {
                    var value = parseFloat(text);
                    if (isNaN(value))
                        value = 0;
                    root.label_scale = value;
                }
            }

            MyMenuSeparator {
                margins: g_settings.applyHScale(10)
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
            Loader {
                sourceComponent: ratio_menu_component
                onLoaded: {
                    item.property ="danger_from_ratio"
                    item.value_property ="danger_from"
                    item.max = Qt.binding(function(){
                        return root.danger_to_ratio;
                    })
                    item.title = Qt.binding(function(){
                        return qsTr("警告下限")
                    })
                    settings_menu.addMenu(item);
                }
            }
            Loader {
                sourceComponent: ratio_menu_component
                onLoaded: {
                    item.property ="danger_to_ratio"
                    item.value_property ="danger_to"
                    item.min = Qt.binding(function(){
                        return root.danger_from_ratio;
                    })
                    item.title = Qt.binding(function(){
                        return qsTr("警告上限")
                    })
                    settings_menu.addMenu(item);
                }
            }
        }

        MyMenuSeparator {}

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


    function fix_ratio(ratio_name, target_ratio, stick_to_mark=true, min=undefined, max=undefined) {
        var target_value = parseFloat((root.from + (root.to - root.from) * target_ratio).toFixed(Math.max(6,root.decimal)));
        target_ratio = (target_value - root.from)/(root.to - root.from)
        if (max === undefined)
            max = 1.0;
        if (min === undefined)
            min = 0.0;
        target_ratio = Math.min(max, Math.max(min, target_ratio));

        if (stick_to_mark) {
            var count = Math.round(target_ratio/0.02)
            target_ratio = 0.02 * count;
        }
        root[ratio_name] = target_ratio.toFixed(6);
    }

    //数据保存恢复
    function get_widget_ctx() {
        var ctx = {
            'path': path,
            'ctx': {
                '.': {  'ctx': get_ctx()                    ,
                    'from'              : from              ,
                    'to'                : to                ,
                    'decimal'           : decimal           ,
                    'base_ratio'        : base_ratio        ,
                    'label_scale'       : label_scale       ,
                    'danger_from_ratio' : danger_from_ratio ,
                    'danger_to_ratio'   : danger_to_ratio   ,
                    'danger_on'         : danger_on         ,
                    'danger_reverse'    : danger_reverse    ,
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
