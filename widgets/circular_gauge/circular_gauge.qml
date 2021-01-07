import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Styles 1.4
import QtQuick.Extras 1.4
import QtQml 2.13
import MyModules 1.0

ResizableRectangle {
    id: root

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

    color: appTheme.bgColor
    border.width: g_settings.applyHScale(1)


    // 这里界定它们的最小宽、高均为100像素
    minimumWidth: g_settings.applyHScale(200)
    minimumHeight: g_settings.applyVScale(200)
    width: minimumWidth
    height: minimumHeight


    CircularGauge{
        id:gauge
        width:parent.width*0.9
        height:parent.height*0.9
        minimumValue : root.from
        maximumValue : root.to
        stepSize : 0
        tickmarksVisible :true
        value: 0
        anchors{
            verticalCenter:parent.verticalCenter
            horizontalCenter:parent.horizontalCenter
        } 
        Behavior on value {
            NumberAnimation {
                duration: 200
            }
        } 
        style: CircularGaugeStyle {
                tickmarkLabel: Label{
                    text:""+styleData.value.toFixed(1)
                    font.pixelSize: 14
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
            }
    }

    
    MyText {
        id: value_text
        anchors {
            bottom: parent.bottom
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
            }
        }

        return ctx;
    }

    function set_widget_ctx(ctx) {
        __set_ctx__(root, ctx.ctx, ref);
    }
}
