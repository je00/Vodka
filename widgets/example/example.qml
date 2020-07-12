import QtQuick 2.12;
import MyModules 1.0

ResizableRectangle {
    id: root

    // path属性是每个控件都需要指定的，务必保证它们与你的控件目录名字一致
    property string path:  "example"

    property Item ref: Loader {
        active: false
        sourceComponent: Component {
            Item {
                // ref_<对象id>：对象id
                property var ref_ch_menu: ch_menu
                property var ref_cmd_menu: cmd_menu
                property var ref_argument_menu: argument_menu
            }
        }
    }

    color: "white"
    border.width: 1


    // 控件宽、高均为100像素
    width: appTheme.applyHScale(100)
    height: appTheme.applyVScale(100)

    // ResizableRectangle是可用鼠标改变尺寸的
    // 这里界定它们的最小宽、高均为100像素
    minimumWidth: appTheme.applyHScale(100)
    minimumHeight: appTheme.applyVScale(100)

    MyMenu {
        id: menu
        DeleteMenuItem {
            target: root
        }
        ChMenu {
            id: ch_menu
        }
        CmdMenu {
            id: cmd_menu
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
    }

    Connections {
        // root.mouse：ResizableRectangle开放出来的MouseArea对象
        target: root.mouse
        onClicked: {
            if (mouse.button === Qt.RightButton) {
                menu.popup();
            }
        }

        onPressed: send_command(0)
        onReleased: send_command(1)
        function send_command(argment_index) {
            var press_argument = argument_model.get(argment_index);
            sys_manager.send_command("example",
                                     cmd_menu.bind_obj,
                                     press_argument,
                                     argument_menu.hex_on
                                     );
        }

    }


    MyText {
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        color: ch_menu.bind_obj?
                   ch_menu.bind_obj.color:
                   "#0080ff"
        text: ch_menu.bind_obj?
                  (ch_menu.bind_obj.name + ":" + ch_menu.bind_obj.value.toFixed(5)):
                  "unbinded"
    }

    function get_widget_ctx() {
        var ctx = {
            'path': path,
            'ctx': {
                '.': {  'ctx': get_ctx() },
                'ch_menu': {
                    'ctx': ch_menu.get_ctx()
                },
                'argument_menu': {
                    'ctx': argument_menu.get_ctx()
                }
            }
        }

        return ctx;
    }

    function set_widget_ctx(ctx) {
        __set_ctx__(root, ctx.ctx, ref);
    }
}
