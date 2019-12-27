import QtQuick 2.12

import "file:///____source_path____/effects"

ResizableRectangle {
    id: root
    tips_text: qsTr("双击可全屏，右键可弹出设置菜单")
    width: appTheme.applyHScale(226)
    height: appTheme.applyHScale(226)
    border.width: (is_hide_border?0:1)
    border.color: "#D0D0D0"
    property string path:  "image"
    property string title: "image"
    property int img_index: -1
    property int default_width: 300
    property int default_height: 300
    property bool is_hide_name: false
    property bool is_hide_border: false
    property bool is_show_effect_setting: true
    property string effect_file: effect_loader.file_name
    property var parameters: []
    property var parent_container

    onClicked: {
        if (mouse.button === Qt.RightButton)
            menu.popup();
    }

    Component {
        id: tips_component
        MyToolTip {

        }
    }

    Connections {
        id: connections
        target: null
        onDataChanged: {
            var parameters = [];
            for (var i = 0; i < target.count; i++) {
                parameters[i] = target.get(i).value;
            }
            root.parameters = parameters;
        }
    }


    Item {
        id: image_rect
        anchors {
            fill: parent
            margins: appTheme.applyVScale(12)
        }

        ShaderEffectSource {
            id: theSource
            smooth: true
            hideSource: true
            sourceItem: image
        }

        Image {
            id: image
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                bottom: title_input.bottom
                bottomMargin: is_hide_name?0:title_input.height
            }
            cache: false
            source: "image://data/" + img_index
            fillMode: Image.PreserveAspectFit
        }

        MyText {
            id: title_input
            text: root.title
            editable: true
            tips_text: qsTr("点击此处可修改图片标题")
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            color: "black"
            visible: !is_hide_name
            horizontalAlignment: Text.AlignHCenter
            onText_inputed: {
                root.title = text;
            }
        }
    }

    Loader {
        id: effect_loader
        property string file_name: root.effect_file
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
            item.is_show_setting = Qt.binding(function() { return is_show_effect_setting_menu.checked; } );
            if (root.parameters.length > 0) {
                first_load = false;
                if (item.parameters.count === 0)
                    return;
                for (var i = 0; i < parameters.length; i++) {
                    item.parameters.setProperty(i, "value", parameters[i]);
                }
                root.parameters = [];
            }
            ;
            if (item.parameters.count === 0)
                return;
            connections.target = item.parameters;
            item.appTheme = appTheme;
            item.tips_component = tips_component;
        }
    }

    MyMenu { // 右键菜单
        id: menu
        visible: false
        DeleteMenuItem {
            target: root
        }

        MyMenu {
            id: ch_menu
            title: qsTr("指定图片")
        }
        MyMenu {
            id: effect_menu
            title: qsTr("特效")
            MyMenuItem {
                font_point_size: theme_font_point_size
                property string file_name: "EffectPassThrough.qml.default"
                checked: root.effect_file === file_name
                text: qsTr("None")
                onTriggered: {
                    root.effect_file = file_name;
                }
            }
        }
        MyMenuItem {
            id: is_show_effect_setting_menu
            text: qsTr("显示特效参数")
            checked: root.is_show_effect_setting
            onTriggered: {
                root.is_show_effect_setting =
                        !root.is_show_effect_setting;
            }
        }
        MyMenuItem {
            id: is_hide_name_menu
            text: qsTr("隐藏标题")
            checked: root.is_hide_name
            onTriggered: {
                root.is_hide_name =
                        !root.is_hide_name;
            }
        }
        MyMenuItem {
            id: is_hide_border_menu
            text: qsTr("隐藏外框")
            checked: root.is_hide_border
            onTriggered: {
                root.is_hide_border =
                        !root.is_hide_border;
            }
        }

        Component {
            id: effect_menu_component
            MyMenuItem {
                id: effect_menu_item
                font_point_size: theme_font_point_size
                property string file_name
                checked: root.effect_file === file_name
                onTriggered: {
                    if (!checked)
                        root.effect_file = file_name;
                    else
                        root.effect_file = "";
                }
            }
        }
        Component {
            id: ch_menu_component
            MyMenuItem {
                id: ch_menu_item
                property int index
                checked: (img_index === index)
                font_point_size: theme_font_point_size

                onTriggered: {
                    if (img_index !== index)
                        img_index = index;
                    else
                        img_index = -1;

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
                ch_menu.addItem(ch_menu_component.createObject(ch_menu.contentItem));
            }
            var start = 0;
            var items = ch_menu.contentData;
            for (var i = start; i < items.length; i++) {
                items[i].text = "img" + i;
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
                    var item = effect_menu_component.createObject(effect_menu.contentItem);
                    effect_menu.addItem(item);
                    item.text = name;
                    item.file_name = file_name;
                    text_max_length = Math.max(item.text.length, text_max_length);
                }
            }
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

    Component.onCompleted: {
        menu.update_ch_menu();
        menu.update_effect_menu();
        if (is_fill_parent) {
            sys_manager.fill_parent(root);
        }
    }

    function refresh() {
        image.source = "";
        //        if (img_index >= 0)
        image.source = "image://data/" + img_index;
    }


    function onBind() {

    }


    function onUnbind() {

    }

    function widget_ctx() {
        root.parameters = effect_loader.item.parameters?
                    effect_loader.item.parameters:[];
        var ctx = {
            "path": path,
            "ctx": [
                {P:'ctx',                    V: get_ctx()                   },
                {P:'title',                  V: root.title                  },
                {P:'img_index',              V: root.img_index              },
                {P:'is_hide_name',           V: root.is_hide_name           },
                {P:'is_hide_border',         V: root.is_hide_border         },
                {P:'is_show_effect_setting', V: root.is_show_effect_setting },
                {P:'parameters',             V: root.parameters             },
                {P:'effect_file',            V: root.effect_file            },
            ]};
        return ctx;
    }

    function apply_widget_ctx(ctx) {
        effect_loader.first_load = true;
        __set_ctx__(root, ctx.ctx);
    }
}
