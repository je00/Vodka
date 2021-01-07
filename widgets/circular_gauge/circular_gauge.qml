import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Styles 1.4
import QtQuick.Extras 1.4
import QtQml 2.13
import MyModules 1.0

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
        opacity: theme.bgOpacity
    }

    CircularGauge{
        id:gauge
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
            bottomMargin: 0
        }

        minimumValue : root.from
        maximumValue : root.to
        stepSize : 0
        tickmarksVisible :true
        value: 0
        Behavior on value {
            NumberAnimation {
                duration: 200
            }
        }
        style: CircularGaugeStyle {
            labelInset: outerRadius * 0.2
            tickmarkLabel: Label{
                text:""+styleData.value.toFixed(1)
                font.pixelSize: g_settings.fontPixelSizeSmall *
                                (Math.min(gauge.width, gauge.height)/(g_settings.applyHScale(200)*0.95))
                font.family: g_settings.fontFamilyNumber
                color: appTheme.fontColor
            }
            labelStepSize: (root.to-root.from)/10
            tickmarkStepSize : (root.to-root.from)/10

            tickmark: Rectangle {
                implicitWidth: outerRadius * 0.02
                antialiasing: true
                implicitHeight: outerRadius * 0.06
                color: appTheme.fontColor
            }
            minorTickmark: Rectangle {
                implicitWidth: outerRadius * 0.02
                antialiasing: true
                implicitHeight: outerRadius * 0.03
                color: appTheme.fontColorTips
            }
            needle: Item {
                antialiasing: true
                y: outerRadius*0.15
                implicitWidth: outerRadius * 0.05
                implicitHeight: outerRadius * 0.95
                property color paintColor: value_menu.attr.color
                onPaintColorChanged: {
                    needle_canvas.requestPaint();
                }

                Canvas{
                    id: needle_canvas
                    antialiasing: true
                    anchors.fill:parent
                    onPaint:{
                        var context = getContext("2d");
                        context.beginPath();
                        context.moveTo(width*0.65, 0);
                        context.lineTo(width*0.35, 0);
                        context.lineTo(0, height);
                        context.lineTo(width, height);
                        context.closePath();
                        context.fillStyle = "" + value_menu.attr.color;
                        context.fill();
                    }
                    layer.effect: MyDropShadow {

                    }
                    layer.enabled: true
                }
            }
            foreground: Item {
                Rectangle {
                    width: outerRadius * 0.2
                    height: width
                    radius: width / 2
                    color: appTheme.barColor
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
        target: sys_manager
        onNeed_update: {
            gauge.value=ch_menu.bind_obj?
                        ch_menu.bind_obj.value:
                        0
        }
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
    MyMenu {
        id: menu
        DeleteMenuItem {
            target: root
        }
        ScreenshotMenuItem {
            target: root
        }
        MyMenuSeparator {

        }
        ChMenu {
            id: ch_menu
        }
        NameMenu {
            id: name_menu
            ch_menu: ch_menu
        }
        ValueMenu {
            id: value_menu
            ch_menu: ch_menu
        }
        MyMenuItem {
            text_center: true
            text: "from:"
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
            text: "to:"
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
        MyMenu {
            id: theme_menu
            title: qsTr("主题")

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

    //数据保存恢复
    function get_widget_ctx() {
        var ctx = {
            'path': path,
            'ctx': {
                '.': {  'ctx': get_ctx()   ,
                    'from'      : from     ,
                    'to'        : to       ,
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
