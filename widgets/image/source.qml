import QtQuick 2.0

import "file:///____source_path____/effects"

Item {
    id: root
    property string path:  "image"
    property string title: title_input.text
    property int image_index: ____image_index____
    width: right_bototm_rect.x + right_bototm_rect.width
    height: right_bototm_rect.y + right_bototm_rect.width
    property int default_width: ____width____
    property int default_height: ____height____
    property bool is_hide_name: is_hide_name_menu.notify_on
    property bool is_hide_border: is_hide_border_menu.notify_on
    property bool is_show_effect_setting: is_show_effect_setting_menu.notify_on
    property string effect_file: effect_loader.file_name
    property var parameters: []
    x: ____x____
    y: ____y____

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
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        height: 10 + border.width*2
        width: 30 + border.width*2
        color: theme_color
        visible: !sys_manager.lock
        border.width: is_hide_border?2:0
        border.color: "white"
        MouseArea {
            anchors.fill: parent
            drag.target: parent.parent
            drag.minimumX: -parent.parent.width/2
            drag.minimumY: 0

            onPressed: {
                parent.color = "blue";
            }
            onReleased: {
                parent.color = theme_color;
            }
        }
    }
    Rectangle {
        id: right_bototm_rect
        width: 10 + border.width*2
        height: 10 + border.width*2
        color: theme_color
        x: default_width - width
        y: default_height - height
        visible: !sys_manager.lock
        border.width: is_hide_border?2:0
        border.color: "white"
        MouseArea {
            anchors.fill: parent
            drag.target: parent
            onPressed: {
                parent.color = "blue";
            }
            onReleased: {
                parent.color = theme_color;
            }
        }
        onXChanged: {
            x = (x - x%4);
        }
        onYChanged: {
            y = (y - y%4);
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
                font_pixel_size: 15
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
                font_pixel_size: 15
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
                font_pixel_size: 15
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
