import QtQuick 2.0

import "file:///____source_path____/effects"

Item {
    id: root
    x: ____x____
    y: ____y____
    property string path:  "image"
    property string title: title_input.text
    property int image_index: ____image_index____
    property int default_width: ____width____
    property int default_height: ____height____
    property bool is_hide_name: is_hide_name_menu.notify_on
    property bool is_hide_border: is_hide_border_menu.notify_on
    property bool is_show_effect_setting: is_show_effect_setting_menu.notify_on
    property string effect_file: effect_loader.file_name
    property var parameters: []
    property bool is_fill_parent: ____is_fill_parent____
    property int ctx_width: ____ctx_width____
    property int ctx_height: ____ctx_height____
    property int ctx_x: ____ctx_x____
    property int ctx_y: ____ctx_y____

    onXChanged: {
        if (!is_fill_parent)
            x = (x - x%4);
    }
    onYChanged: {
        if (!is_fill_parent)
            y = (y - y%4);
    }
    onWidthChanged: {
        right_bottom_rect.x = width - right_bottom_rect.width;
    }
    onHeightChanged: {
        right_bottom_rect.y = height - right_bottom_rect.height;
    }

    Connections {
        id: connections
        onDataChanged: {
            var parameters = [];
            for (var i = 0; i < target.count; i++) {
                parameters[i] = target.get(i).value;
            }
            root.parameters = parameters;
        }
    }

    Loader {
        id: effect_loader
        property string file_name: "____effect_file____"
        property bool first_load: true
        source: "file:///____source_path____/effects/" + ((file_name.length>0)?file_name:"EffectPassThrough.qml.default")
        onSourceChanged: {
            item.targetWidth = image.width;
            item.targetHeight = image.height;
            item.fragmentShaderFilename = "____source_path____/shaders/" + item.fragmentShaderFilename;
            item.vertexShaderFilename = "____source_path____/shaders/" + item.vertexShaderFilename;
            item.parent = image_rect;
            item.anchors.fill = image;
//            item.anchors.topMargin = (image.height - image.paintedHeight)/2;
//            item.anchors.leftMargin = (iamge.width - image.paintedWidth)/2;
            item.source = theSource;
            item.dividerValue = 1;
            item.is_show_setting = Qt.binding(function() { return is_show_effect_setting_menu.notify_on; } );
            if (first_load && file_name === "____effect_file____") {
                var parameters = [____parameters____];
                first_load = false;
                for (var i = 0; i < parameters.length; i++) {
                    item.parameters.setProperty(i, "value", parameters[i]);
                }
            }
            connections.target = item.parameters;
        }
    }

    Rectangle {
        id: image_rect
        anchors.fill: parent
        border.width: (is_hide_border?0:1)
        border.color: "#D0D0D0"

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.SizeAllCursor
            onPressed: {
                sys_manager.increase_to_top(root);
            }
        }
        ShaderEffectSource {
            id: theSource
            smooth: true
            hideSource: true
            sourceItem: image
        }

        Image {
            id: image
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: is_hide_border?0:12
            anchors.leftMargin: is_hide_border?0:12
            anchors.rightMargin: is_hide_border?0:12
            anchors.bottom: title_input_rect.top
            anchors.bottomMargin: !is_hide_name?0:anchors.topMargin
            cache: false
            source: "image://data/" + image_index
            fillMode: Image.PreserveAspectFit
        }


        Rectangle {
            id: title_input_rect
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            height: !is_hide_name?24:0
            TextInput {
                id: title_input
                text: "____title____"
                font.family: theme_font
                font.pixelSize: 15
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                color: "black"
                visible: !is_hide_name
                selectByMouse: true
                onAccepted: {
                    focus = false;
                }
                onFocusChanged: {
                    if (focus)
                        selectAll();
                    else if (text.length === 0)
                        text = "image";

                }
            }
        }
    }



    Rectangle {
        id: drag_rect
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        height: 10 + border.width*2
        width: 30 + border.width*2
        color: theme_color
        visible: !sys_manager.lock
        border.width: is_hide_border?2:0
        border.color: "white"
        MouseArea {
            id: drag_mouse
            anchors.fill: parent
            drag.target: is_fill_parent?null:root
            drag.minimumX: -parent.parent.width/2
            drag.minimumY: 0
            drag.threshold: 0
            property real ctx_mouse_x
            property real ctx_mouse_y

            onPressed: {
                parent.color = "blue";
                sys_manager.increase_to_top(root);
                ctx_mouse_x = mouseX;
                ctx_mouse_y = mouseY;
            }
            onReleased: {
                parent.color = theme_color;
            }
            onDoubleClicked: {
                is_fill_parent = !is_fill_parent;
                if (is_fill_parent) {
                    root.ctx_width = root.width;
                    root.ctx_height = root.height;
                    root.ctx_x = root.x;
                    root.ctx_y = root.y;
                    sys_manager.fill_parent(root);
                } else {
                    root.width = root.ctx_width;
                    root.height = root.ctx_height;
                    root.x = root.ctx_x;
                    root.y = root.ctx_y;
                }
            }

            function unfill() {
                if (is_fill_parent) {
                    var gap_width = root.width - root.ctx_width;
                    var gap_height = root.height - root.ctx_height;
                    root.x = root.x + gap_width/2 + mouseX - drag_rect.width/2;
                    root.y = root.y + mouseY;
                    root.width = root.ctx_width;
                    root.height = root.ctx_height;
                    is_fill_parent = false;
                }
            }

            onMouseXChanged: {
                if (Math.abs((mouseX - ctx_mouse_x)) > 10)
                    unfill();
            }

            onMouseYChanged: {
                if (Math.abs((mouseX - ctx_mouse_x)) > 10)
                    unfill();
            }
        }
    }
    Rectangle {
        id: right_bottom_rect
        width: 10 + border.width*2
        height: 10 + border.width*2
        color: theme_color
        x: default_width - width
        y: default_height - height
        visible: !sys_manager.lock && !root.is_fill_parent
        border.width: is_hide_border?2:0
        border.color: "white"
        MouseArea {
            id: right_bottom_mouse
            anchors.fill: parent
            drag.target: parent
            drag.threshold: 0

            onPressed: {
                parent.color = "blue";
                sys_manager.increase_to_top(root);
            }
            onReleased: {
                parent.color = theme_color;
            }
        }
        onXChanged: {
            if (is_fill_parent)
                return;
            x = (x - x%4);
            root.width = right_bottom_rect.x + right_bottom_rect.width;
        }
        onYChanged: {
            if (is_fill_parent)
                return;
            y = (y - y%4);
            root.height = right_bottom_rect.y + right_bottom_rect.height;
        }

    }

    MyMenu { // 右键菜单
        id: menu
        visible: false
        //            height: (count - 1)*30
        //            background_color: ""
        width: 120
        MyMenuItem {
            id: menu_delete
            width: parent.width
            show_text: qsTr("删除")
            color: "red"
            custom_triggered_action: true
            onCustom_triggered: {
                root.destroy();
            }
        }
        MyMenu {
            id: ch_menu
            width: 80
            //                height: count*30

            title: qsTr("指定图片")
            //                background_color: chart_menu.background_color
            //                visible: true
        }
        MyMenu {
            id: effect_menu
            title: qsTr("特效")
            width: 80
            MyMenuItem {
                font_point_size: theme_font_point_size
                custom_triggered_action: true
                width: parent.width
                property string file_name: "EffectPassThrough.qml.default"
                notify_on: effect_loader.file_name === file_name
                show_text: qsTr("None")
                onCustom_triggered: {
                    effect_loader.file_name = file_name;
                }
            }
        }
        MyMenuItem {
            id: is_show_effect_setting_menu
            show_text: qsTr("显示特效参数")
            width: parent.width
            custom_triggered_action: true
            notify_on: ____is_show_effect_setting____
            onCustom_triggered: {
                notify_on = !notify_on;
            }
        }

        MyMenu {
            id: settings_menu
            title: qsTr("设置")
            width: 80
            MyMenuItem {
                id: is_hide_name_menu
                width: parent.width
                show_text: qsTr("隐藏标题")
                notify_on: ____is_hide_name____
                custom_triggered_action: true
                onCustom_triggered: {
                    notify_on = !notify_on;
                }
            }
            MyMenuItem {
                id: is_hide_border_menu
                width: parent.width
                show_text: qsTr("隐藏外框")
                notify_on: ____is_hide_border____
                custom_triggered_action: true
                onCustom_triggered: {
                    notify_on = !notify_on;
                }
            }
        }


        Component {
            id: effect_menu_component
            MyMenuItem {
                id: effect_menu_item
                font_point_size: theme_font_point_size
                custom_triggered_action: true
                width: parent.width
                property string file_name
                notify_on: effect_loader.file_name === file_name
                onCustom_triggered: {
                    if (!notify_on)
                        effect_loader.file_name = file_name;
                    else
                        effect_loader.file_name = "";
                }
            }
        }
        Component {
            id: ch_menu_component
            MyMenuItem {
                id: ch_menu_item
                property int index
                notify_on: (image_index === index)
                width: (parent?parent.width:80)
                font_point_size: theme_font_point_size
                notify_color: "red"
                custom_triggered_action: true

                onCustom_triggered: {
                    if (image_index !== index)
                        image_index = index;
                    else
                        image_index = -1;

                    refresh();
                }
            }
        }

        function update_ch_menu() {
            while ((ch_menu.count) > sys_manager.image_count) {
                ch_menu.removeItem(
                            ch_menu.itemAt(ch_menu.count-1)
                            );
            }
            while ((ch_menu.count) < sys_manager.image_count) {
                ch_menu.addItem(ch_menu_component.createObject(ch_menu));
            }
            var start = 0;
            var items = ch_menu.contentData;
            for (var i = start; i < items.length; i++) {
                items[i].show_text = "img" + i;
                items[i].index = i - start;
            }
        }
        function update_effect_menu() {
            var file_list = sys_manager.file_reader.filesInDirectory("____source_path____/effects");
            var text_max_length=0;
            for (var i = 0; i < file_list.length; i++) {
                var file_name = file_list[i];
                if (file_name !== "Effect.qml" &&
                        file_name.substring(0, 6) === "Effect" &&
                        file_name.substring(file_name.length-4, file_name.length) === ".qml") {
                    var name = file_name.substring(6, file_name.length-4);
                    var item = effect_menu_component.createObject(effect_menu);
                    effect_menu.addItem(item);
                    item.show_text = name;
                    item.file_name = file_name;
                    text_max_length = Math.max(item.show_text.length, text_max_length);
                }
            }
            effect_menu.width = Math.max(80, 32 + text_max_length * 10);
        }
    }

    Connections {
        target: sys_manager
        onImage_countChanged: {
            menu.update_ch_menu();
        }
        onNeed_update: {
            refresh();
        }
    }
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton
        onClicked: {
            menu.popup();
        }
    }

    Component.onCompleted: {
        menu.update_ch_menu();
        menu.update_effect_menu();
        if (is_fill_parent) {
            sys_manager.fill_parent(root);
        }
    }

    function refresh() {
        image.source = "";
        //        if (image_index >= 0)
        image.source = "image://data/" + image_index;
    }


    function onBind() {

    }


    function onUnbind() {

    }
}
