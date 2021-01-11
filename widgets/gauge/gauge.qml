import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Styles 1.4
import QtGraphicalEffects 1.12
import QtQuick.Extras 1.4
import QtQml 2.13
import MyModules 1.0

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
    property real from: -1
    property real to: 1
    property real orientation: Qt.Vertical

    //    border.width: g_settings.applyHScale(1)

    border.width: (((theme.hideBorder
                     &&!hovered
                     &&!main_mouse.containsMouse))?
                       0:g_settings.applyHScale(1))

    // 这里界定它们的最小宽、高均为100像素
    minimumWidth: g_settings.applyHScale(root.orientation==Qt.Vertical?80:200)
    minimumHeight: g_settings.applyVScale(root.orientation==Qt.Horizontal?80:200)
    width: g_settings.applyHScale(80)
    height: g_settings.applyVScale(200)

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

    Rectangle {
        color: "transparent"
        width: parent.width*0.95
        height: parent.height*0.95
        anchors {
            verticalCenter:parent.verticalCenter
            horizontalCenter:parent.horizontalCenter
        }
        Gauge {
            id: gauge
            anchors {
                top: parent.top
                bottom:parent.bottom
                left: parent.left
                right: parent.right
            }
            width:parent.width
            height:parent.height
            minimumValue : root.from
            maximumValue : root.to
            value: ch_menu.bind_obj?
                       ch_menu.bind_obj.value:
                       0

            minorTickmarkCount :4
            tickmarkStepSize:(root.to-root.from)/10
            orientation: root.orientation
            tickmarkAlignment :root.orientation==Qt.Vertical?Qt.AlignRight:Qt.AlignBottom
            Behavior on value {
                NumberAnimation {
                    duration: 200
                }
            }
            Rectangle {
                anchors.fill: parent
                color: "transparent"
                border.width: 1
            }

            style: GaugeStyle {
                tickmarkLabel: Rectangle {
                    implicitWidth: label_text.implicitWidth
                    implicitHeight: label_text.implicitHeight
                    color: "transparent"
                    border.width: 1
                    MyText {
                        id: label_text
//                        anchors.bottom: parent.bottom
//                        anchors.right: parent.right
                        font.family: g_settings.fontFamilyNumber
                        font.pixelSize: g_settings.fontPixelSizeSmall
                        text:""+styleData.value.toFixed(1)
                    }
                }

                tickmark: Rectangle {
                    implicitWidth: 10
                    antialiasing: true
                    implicitHeight: 2
                    color: appTheme.fontColor
                }
                minorTickmark: Rectangle {
                    implicitWidth: 5
                    antialiasing: true
                    implicitHeight: 1
                    color: appTheme.fontColorTips
                }
                valueBar: Item {
                    implicitWidth: gauge.width/2
                    Rectangle {
                        id: rectangle
                        anchors.fill: parent
                        color: value_menu.attr.color
                        border.width:1
                        border.color:appTheme.lineColor 
                    }
                    // Glow {
                    //     anchors.fill: rectangle
                    //     radius: 8
                    //     samples: 12
                    //     color: "white"
                    //     source: rectangle
                    // }
                }
            }
        }
    }


    MyText {
        id: value_text
        anchors {
            bottom: parent.top
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
            text: qsTr("方向:")
            plus_minus_on: true
            value_text:  root.orientation==Qt.Vertical?qsTr("垂直"):qsTr("水平")
            value_editable: false
            onPlus_triggered: {
                if(root.orientation==Qt.Vertical){
                    root.orientation =Qt.Horizontal;
                    root.width=root.minimumWidth=g_settings.applyHScale(200)
                    root.height=root.minimumHeight=g_settings.applyVScale(80)
                }else{
                    root.orientation =Qt.Vertical;
                    root.width=root.minimumWidth=g_settings.applyHScale(80)
                    root.height=root.minimumHeight=g_settings.applyVScale(200)
                }
            }
            onMinus_triggered: {
                if(root.orientation==Qt.Vertical){
                    root.orientation =Qt.Horizontal;
                    root.width=root.minimumWidth=g_settings.applyHScale(200)
                    root.height=root.minimumHeight=g_settings.applyVScale(80)
                }else{
                    root.orientation =Qt.Vertical;
                    root.width=root.minimumWidth=g_settings.applyHScale(80)
                    root.height=root.minimumHeight=g_settings.applyVScale(200)
                }
            }
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
                '.': {  'ctx': get_ctx()           ,
                    'from'          : from         ,
                    'to'            : to           ,
                    'orientation'   : orientation  ,
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
