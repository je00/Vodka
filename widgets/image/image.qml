import QtQuick 2.12
import MyModules 1.0

import "./effects"

ResizableRectangle {
    id: root
    width: g_settings.applyHScale(226)
    height: g_settings.applyHScale(226)
    border.width: ((is_hide_border&&!hovered)?0:g_settings.applyHScale(1))
    property string path:  "image"
    property string title: "image"
    property string current_directory: ""   // set by system
    property int img_index: -1
    property bool is_hide_name: false
    property bool is_hide_border: true
    property bool is_show_effect_setting: true
    property string effect_file: effect_loader.file_name
    property var parameters: []
    property var parent_container
//    property int image_tick: 0
    color: "transparent"

    Connections {
        target: mouse
        onClicked: {
            if (mouse.button === Qt.RightButton)
                menu.popup();
        }
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
            margins: g_settings.applyVScale(12)
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
            color: appTheme.fontColor
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
        source: "./effects/" + ((file_name.length>0)?file_name:"EffectPassThrough.qml.default")
        onSourceChanged: {
            item.targetWidth = image.width;
            item.targetHeight = image.height;
            item.fragmentShaderFilename = current_directory + "/shaders/" + item.fragmentShaderFilename;
            item.vertexShaderFilename = current_directory + "/shaders/" + item.vertexShaderFilename;
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

    MyIconMenu { // 右键菜单
        id: menu
        visible: false
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
        MyMenu {
            id: ch_menu
            title: qsTr("指定图片")
        }
        MyMenu {
            id: effect_menu
            title: qsTr("特效")
            MyMenuItem {
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

                onTriggered: {
                    if (img_index !== index)
                        img_index = index;
                    else
                        img_index = -1;

                    refresh(true);
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
            var file_list = sys_manager.file_reader.filesInDirectory(current_directory + "/effects");
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
    }

    onCurrent_directoryChanged: menu.update_effect_menu();


    function refresh(force=false) {
        if (force) {
            image.source = "";
            image.source = "image://data/" + img_index;
            return;
        }

        if (img_index < 0)
            return;

//        console.log(image_tick, sys_manager.image_tick);
//        if (image_tick !== sys_manager.image_tick) {
//            image_tick = sys_manager.image_tick;
            image.source = "";
            image.source = "image://data/" + img_index;
//        }
    }


    function onBind() {

    }


    function onUnbind() {

    }

    function get_widget_ctx() {
        var ctx = {
            'path': path,
            'ctx': {
                '.': {
                    'ctx'                    : get_ctx()                   ,
                    'title'                  : root.title                  ,
                    'img_index'              : root.img_index              ,
                    'is_hide_name'           : root.is_hide_name           ,
                    'is_hide_border'         : root.is_hide_border         ,
                    'is_show_effect_setting' : root.is_show_effect_setting ,
                    'parameters'             : root.parameters             ,
                    'effect_file'            : root.effect_file            ,
                }
            }
        }

        return ctx;
    }

    function set_widget_ctx(ctx) {
        effect_loader.first_load = true;
        __set_ctx__(root, ctx.ctx);

        for (var i = 0; i < root.parameters.length; i++) {
            effect_loader.item.parameters.get(i).value = root.parameters[i];
        }
    }
}
