import QtQuick 2.13
//import QtCanvas3D 1.0
import Qt3D.Core 2.12
import Qt3D.Render 2.12
import QtQuick.Scene3D 2.12
import Qt3D.Extras 2.12
import QtQuick.Controls 2.12
import "file:///____widgets_path____/common"
import "file:///____source_path____/"

ResizableRectangle {
    id: root
    tips_text: qsTr("双击可全屏，右键可弹出设置菜单")
    property var id_map: {
        "angle_offset":     angle_offset,
        "position_offset":  position_offset,
        "center_point":     center_point,
        "obj_length":       obj_length,
        "obj_world_length": obj_world_length,
        "root_transform":   root_transform,
        "scalar_menu":       scalar_menu,
        "x_menu":           x_menu,
        "y_menu":           y_menu,
        "z_menu":           z_menu,
        "pos_offset_menu":  pos_offset_menu
    }

    border {
        width: sys_manager.lock?0:1
        color: "#d0d0d0"
    }
    color: "transparent"

    width: 226
    height: 226
    height_width_ratio: 1
    property string path: "cube"
    property bool not_support_change_window_: true
    property int default_width: width
    property int default_height: height
    property bool quaternion_mode: false
    property string cube_color: "#0080ff"
    property real scale: 1
    property string model_path: ""
    property bool is_auto_center: true
    property bool is_show_obj_axis: true
    property bool is_show_world_axis: true
    property bool angle_or_radian: false
    property color light_color: "#333333"
    property color ambient_color: "#CCCCCC"
    property quaternion pos: Qt.quaternion(
                                 (scalar_menu.bind_obj)?scalar_menu.bind_obj.value:0,
                                 (x_menu.bind_obj)?x_menu.bind_obj.value:0,
                                 (y_menu.bind_obj)?y_menu.bind_obj.value:0,
                                 (z_menu.bind_obj)?z_menu.bind_obj.value:0
                                 )
    property vector3d obj_length: Qt.vector3d(
                                      100,
                                      100,
                                      100)
    property vector3d obj_world_length: Qt.vector3d(
                                            100,
                                            100,
                                            100)
    property vector3d position_offset: Qt.vector3d(
                                           0,
                                           0,
                                           0)
    property vector3d angle_offset: Qt.vector3d(
                                        0,
                                        0,
                                        0)

    property vector3d center_point: Qt.vector3d(
                                        0,
                                        0,
                                        0)
    property var parent_container

    onModel_pathChanged: {
        cube_entity.update_model();
    }

    onAngle_offsetChanged: {
        update_mesh_world_length();
    }

    onPosition_offsetChanged: {
        update_mesh_world_length();
    }

    onScaleChanged: {
        update_mesh_world_length();
    }

    Scene3D {
        id: scene3d
        anchors {
            fill: parent
            margins: appTheme.applyHScale(12)
        }
        aspects: "input"
        visible: (height > 0 && width > 0)

        Entity {
            //            components: [ root_transform ]
            components: [
                RenderSettings {
                    activeFrameGraph: ForwardRenderer {
                        clearColor: Qt.rgba(0, 0.5, 1, 0)
                        camera: camera
                    }
                },
                DirectionalLight {
                    id: light
                    worldDirection: camera.position.times(-1).normalized();
                    color: light_color
                    intensity: 1.0
                }
                // Event Source will be set by the Qt3DQuickWindow
                //            InputSettings { }
            ]
            Camera {
                id: camera
                projectionType: CameraLens.PerspectiveProjection
                fieldOfView: 50
                aspectRatio: root.width/root.height
                nearPlane : 1
                farPlane : 2000.0
                position: Qt.vector3d( 0.0, 0.0, 360 )
                upVector: Qt.vector3d( 0.0, 1.0, 0.0 )
                viewCenter: Qt.vector3d( 0.0, 0.0, 0.0 )
            }


            Entity {
                id: sceneRoot
                components: [ root_transform ]

                Transform {
                    id: root_transform
                    scale: 1
                    rotationX: 20
                    rotationY: -45
                    rotationZ: -20
                }

                Arrow {
                    id: world_axis_x
                    dir: Qt.vector3d(1, 0, 0)
                    color: "#ff0000"
                    ambient_color: root.ambient_color
                    length: ((obj_axis_x.length < 120)?140:obj_axis_x.length+20)
                    width: 0.5
                    enabled: root.is_show_world_axis
                }
                Arrow {
                    id: world_axis_y
                    dir: Qt.vector3d(0, 1, 0)
                    color: "#00ff00"
                    ambient_color: root.ambient_color
                    length: ((obj_axis_y.length < 120)?140:obj_axis_y.length+20)
                    width: 0.5
                    enabled: root.is_show_world_axis
                }
                Arrow {
                    id: world_axis_z
                    dir: Qt.vector3d(0, 0, 1)
                    color: "#0000ff"
                    ambient_color: root.ambient_color
                    length: ((obj_axis_z.length < 120)?140:obj_axis_z.length+20)
                    width: 0.5
                    enabled: root.is_show_world_axis
                }

                PhongMaterial {
                    id: material
                    ambient: root.ambient_color
                    diffuse: cube_color
                    shininess: 1.0
                    //                alpha: 0.5
                }

                Entity {
                    id: obj_entity
                    components: [obj_transform]
                    Transform {
                        id: obj_transform
                        scale: 1
                    }

                    Arrow {
                        id: obj_axis_x
                        dir: Qt.vector3d(1, 0, 0)
                        color: "#ff0000"
                        ambient_color: root.ambient_color
                        length: (obj_world_length.x/2 + 20)
                        width: 0.5
                        enabled: !angle_offset_rect.visible && root.is_show_obj_axis
                    }
                    Arrow {
                        id: obj_axis_y
                        dir: Qt.vector3d(0, 1, 0)
                        color: "#00ff00"
                        ambient_color: root.ambient_color
                        length: (obj_world_length.y/2  + 20)
                        width: 0.5
                        enabled: !angle_offset_rect.visible && root.is_show_obj_axis
                    }
                    Arrow {
                        id: obj_axis_z
                        dir: Qt.vector3d(0, 0, 1)
                        color: "#0000ff"
                        ambient_color: root.ambient_color
                        length: (obj_world_length.z/2 + 20)
                        width: 0.5
                        enabled: !angle_offset_rect.visible && root.is_show_obj_axis
                    }
                    Entity {
                        Transform {
                            id: cube_rotation_offset_transform
                            scale: 1
                            rotationX: angle_offset.x
                            rotationY: angle_offset.y
                            rotationZ: angle_offset.z
                        }

                        components: [
                            cube_rotation_offset_transform
                        ]
                        Arrow {
                            dir: Qt.vector3d(1, 0, 0)
                            color: "#ff0000"
                            ambient_color: root.ambient_color
                            length: ((obj_length.x * root.scale)/2 + 20)
                            width: 0.5
                            enabled: angle_offset_rect.visible
                            origin: position_offset
                        }
                        Arrow {
                            dir: Qt.vector3d(0, 1, 0)
                            color: "#00ff00"
                            ambient_color: root.ambient_color
                            length: ((obj_length.y * root.scale)/2  + 20)
                            width: 0.5
                            enabled: angle_offset_rect.visible
                            origin: position_offset
                        }
                        Arrow {
                            dir: Qt.vector3d(0, 0, 1)
                            color: "#0000ff"
                            ambient_color: root.ambient_color
                            length: ((obj_length.z * root.scale)/2 + 20)
                            width: 0.5
                            enabled: angle_offset_rect.visible
                            origin: position_offset
                        }

                        Entity {
                            id: cube_entity
                            property Mesh obj_mesh
                            property bool first_run: true
                            components: [ ]
                            Component.onCompleted: {
                                update_model();
                            }

                            Connections {
                                target: cube_entity.obj_mesh
                                onStatusChanged: {
                                    if (cube_entity.first_run) {
                                        cube_entity.first_run = false;
                                    } else if (is_auto_center)
                                        root.center_mesh();
                                }
                            }
                            Transform {
                                id: cube_transform
                                scale: root.scale
                                rotation: fromAxisAndAngle(Qt.vector3d(1, 0, 0), 0)
                                //                                translation: center_point.times(-1).plus(
                                //                                                        position_offset)
                                translation: center_point.times(-root.scale).plus(
                                                 position_offset)

                            }

                            function update_model() {
                                cube_entity.components = [];
                                var component = Qt.createComponent("file:///____source_path____/Mesh.qml");
                                var new_mesh  = component.createObject(cube_entity);

                                sys_manager.file_reader.source = sys_manager.config_path + "/" + model_path;
                                if (model_path.length > 0 && sys_manager.file_reader.exist()) {
                                    new_mesh.source = "file:///" + sys_manager.file_reader.source;
                                } else {
                                    new_mesh.source = "file:///____source_path____/cube.stl";
                                }
                                var tmp_mesh = obj_mesh;
                                obj_mesh = new_mesh;
                                if (tmp_mesh)
                                    tmp_mesh.destroy();
                                cube_entity.components =
                                        [ obj_mesh, material, cube_transform ];
                            }
                        }
                    }
                }
            }

        }
    }

    function reset_mesh() {
        obj_world_length.x = 100;
        obj_world_length.y = 100;
        obj_world_length.z = 100;
        obj_length.x = 100;
        obj_length.y = 100;
        obj_length.z = 100;
        root.scale = 1;
        center_point = Qt.vector3d(0, 0, 0);
        position_offset = Qt.vector3d(0, 0, 0);
        angle_offset = Qt.vector3d(0, 0, 0);
    }

    function update_mesh_world_length() {
        var quaternion = cube_rotation_offset_transform.rotation;

        var list = sys_manager.three_tools.bounding_positioin(cube_entity.obj_mesh,
                                                              Qt.vector4d(quaternion.x,
                                                                          quaternion.y,
                                                                          quaternion.z,
                                                                          quaternion.scalar
                                                                          ),
                                                              position_offset,
                                                              root.scale
                                                              );
        if (list.lenght === 0)
            return;
        obj_world_length.x = list[6];
        obj_world_length.y = list[7];
        obj_world_length.z = list[8];
    }

    function center_mesh() {
        var quaternion = cube_rotation_offset_transform.rotation;

        var list = sys_manager.three_tools.bounding_positioin(cube_entity.obj_mesh,
                                                              Qt.vector4d(quaternion.x,
                                                                          quaternion.y,
                                                                          quaternion.z,
                                                                          quaternion.scalar
                                                                          ),
                                                              Qt.vector3d(0, 0, 0),
                                                              root.scale
                                                              );
        if (list.lenght === 0)
            return;

        obj_length.x = list[3];
        obj_length.y = list[4];
        obj_length.z = list[5];
        obj_world_length.x = list[6];
        obj_world_length.y = list[7];
        obj_world_length.z = list[8];

        var max_length = Math.max(obj_length.x,
                                  obj_length.y,
                                  obj_length.z);

        root.scale = 150/max_length;
        position_offset = Qt.vector3d(0, 0, 0);
        center_point = Qt.vector3d(list[0], list[1], list[2]);
    }

    function cross_product(q1, q2) {
        var result = Qt.quaternion(
                    q1.scalar*q2.scalar - q1.x*q2.x      - q1.y*q2.y - q1.z*q2.z,
                    q1.scalar*q2.x      + q1.x*q2.scalar + q1.y*q2.z - q1.z*q2.y,
                    q1.scalar*q2.y      + q1.y*q2.scalar + q1.z*q2.x - q1.x*q2.z,
                    q1.scalar*q2.z      + q1.z*q2.scalar + q1.x*q2.y - q1.y*q2.x
                    );

        return result;

    }

    // called by sys_manager
    function set_color(color) {
        cube_color = "" + color;
    }

    onXChanged: {
        if (!enabled)
            return;

        if (!is_fill_parent)
            x = (x - x%4);
    }
    onYChanged: {
        if (!enabled)
            return;

        if (!is_fill_parent)
            y = (y - y%4);
    }

    function update_cube_rotate() {
        if (!quaternion_mode) {
            if (angle_or_radian) {
                obj_transform.rotationX = pos.x;
                obj_transform.rotationY = pos.y;
                obj_transform.rotationZ = pos.z;
            } else {
                obj_transform.rotationX = pos.x*180/Math.PI;
                obj_transform.rotationY = pos.y*180/Math.PI;
                obj_transform.rotationZ = pos.z*180/Math.PI;
            }
        } else {
            obj_transform.rotation = Qt.quaternion(pos.scalar,
                                                   pos.x,
                                                   pos.y,
                                                   pos.z);
        }
    }

    onPosChanged: {
        update_cube_rotate();
    }

    MouseArea {
        anchors.fill: scene3d
        property int start_x: -999
        property int start_y: -999
        property quaternion start_rotation
        acceptedButtons: Qt.RightButton | Qt.LeftButton
        //        enabled: !sys_manager.lock
        onClicked: {
            if (mouse.button === Qt.RightButton) {
                main_menu.popup();
            }
        }

        onDoubleClicked: {
            if (mouse.button === Qt.LeftButton) {
                pos_offset_menu.checked = !pos_offset_menu.checked;
            }
        }

        onWheel: {
            var scale = root.scale;
            if (wheel.angleDelta.y > 0) {
                scale *= 1.1;
            }
            else {
                scale *= 0.9;
            }

            root.scale = scale;
        }
        onPressed: {
            start_x = mouseX;
            start_y = mouseY;

            start_rotation = root_transform.rotation;
            sys_manager.increase_to_top(root);
        }

        onPositionChanged: {
            var y_gap = start_y - mouseY;
            var effect_size = Math.min(parent.height, parent.width);
            var xangle = -360 * y_gap / effect_size;

            var x_gap = start_x - mouseX;
            var yangle = -360 * x_gap / effect_size;

            var start_rotation_ = Qt.quaternion(
                        start_rotation.scalar,
                        -start_rotation.x,
                        -start_rotation.y,
                        -start_rotation.z,
                        );
            var axis_x = Qt.quaternion(0, 1, 0, 0);
            var axis_y = Qt.quaternion(0, 0, 1, 0);

            axis_x = cross_product(start_rotation_, cross_product(axis_x, start_rotation));
            axis_y = cross_product(start_rotation_, cross_product(axis_y, start_rotation));

            axis_x = Qt.vector3d(axis_x.x, axis_x.y, axis_x.z);
            axis_y = Qt.vector3d(axis_y.x, axis_y.y, axis_y.z);

            var q = root_transform.fromAxesAndAngles(axis_x, xangle, axis_y, yangle);
            root_transform.rotation = cross_product(start_rotation, q);
            //            root_transform.rotation = cross_product(start_rotation, q1);
            start_x = mouseX;
            start_y = mouseY;
            start_rotation = root_transform.rotation;
        }
    }



    ListView {
        id: angle_offset_rect
        visible: pos_offset_menu.checked
        width: appTheme.applyHScale(180)
        anchors {
            bottom: position_offset_rect.top
            horizontalCenter: parent.horizontalCenter
        }
        orientation: ListView.Horizontal
        contentWidth: angle_offset_rect.width/3
        model:ListModel {
            ListElement {
                border_color: "#ff0000"
            }
            ListElement {
                border_color: "#00ff00"
            }
            ListElement {
                border_color: "#0000ff"
            }
        }
        onCountChanged: height = itemAtIndex(0).height;

        delegate: MyTextInput {
            id: angle_input
            width: angle_offset_rect.width/3
            anchors.verticalCenter: parent.verticalCenter
            verticalAlignment: TextInput.AlignVCenter
            horizontalAlignment: TextInput.AlignHCenter
            color: border_color
            tips_text: qsTr("角度偏置 ") +
                       ((model.index === 0)?
                            "X":(model.index===1)?
                                "Y":"Z") + "\n" +
                       qsTr("直接输入或鼠标滚轮设置")
            text: {
                switch (model.index) {
                case 0:
                    angle_offset.x
                    break;
                case 1:
                    angle_offset.y
                    break;
                case 2:
                    angle_offset.z
                    break;
                }
            }
            onTextChanged: {
                var value = ((text.length<=0)?0:parseFloat(text));
                if (isNaN(value))
                    value = 0;
                switch (model.index) {
                case 0:
                    angle_offset.x = value;
                    break;
                case 1:
                    angle_offset.y = value;
                    break;
                case 2:
                    angle_offset.z = value;
                    break;
                }
            }

            onWheel: {
                var sign = (value < 0)?-1:1;
                switch (model.index) {
                case 0:
                    angle_offset.x =
                            (angle_offset.x + sign * 15)%360;
                    break;
                case 1:
                    angle_offset.y =
                            (angle_offset.y + sign * 15)%360;
                    break;
                case 2:
                    angle_offset.z =
                            (angle_offset.z + sign * 15)%360;
                    break;
                }
            }
        }
    }

    ListView {
        id: position_offset_rect
        visible: pos_offset_menu.checked
        width: appTheme.applyHScale(180)
        anchors {
            bottom: parent.bottom
            bottomMargin: appTheme.applyVScale(2)
            horizontalCenter: parent.horizontalCenter
        }
        orientation: ListView.Horizontal
        contentWidth: position_offset_rect.width/3
        onCountChanged: height = itemAtIndex(0).height;
        model:ListModel {
            ListElement {
                border_color: "#ff0000"
            }
            ListElement {
                border_color: "#00ff00"
            }
            ListElement {
                border_color: "#0000ff"
            }
        }

        delegate: MyTextInput {
            id: position_input
            width: position_offset_rect.width/3
            anchors.verticalCenter: parent.verticalCenter
            verticalAlignment: TextInput.AlignVCenter
            horizontalAlignment: TextInput.AlignHCenter
            color: border_color
            tips_text: qsTr("位置偏置 ") +
                       ((model.index === 0)?
                            "X":(model.index===1)?
                                "Y":"Z") + "\n" +
                       qsTr("直接输入或鼠标滚轮设置")
            text:{
                switch (model.index) {
                case 0:
                    position_offset.x
                    break;
                case 1:
                    position_offset.y
                    break;
                case 2:
                    position_offset.z
                    break;
                }
            }
            onTextChanged: {
                var value = ((text.length<=0)?0:parseFloat(text));
                if (isNaN(value))
                    value = 0;
                switch (model.index) {
                case 0:
                    position_offset.x = value;
                    break;
                case 1:
                    position_offset.y = value;
                    break;
                case 2:
                    position_offset.z = value;
                    break;
                }
            }

            onWheel: {
                var sign = (value < 0)?-1:1;
                switch (model.index) {
                case 0:
                    position_offset.x = position_offset.x + sign * 1;
                    break;
                case 1:
                    position_offset.y = position_offset.y + sign * 1;
                    break;
                case 2:
                    position_offset.z = position_offset.z + sign * 1;
                    break;
                }
            }
        }

    }

    DropArea {
        anchors.fill: parent
        onDropped: {
            var path = sys_manager.config_path;
            if(drop.hasUrls){
                reset_mesh();
                for(var i = 0; i < drop.urls.length; i++){
                    var url = drop.urls[i];
                    var source = url.substring(url.indexOf('///') + 3);
                    var file_name = url.substring(url.lastIndexOf('/') + 1);
                    var target = sys_manager.config_path
                            + url.substring(url.lastIndexOf('/'));
                    sys_manager.file_reader.source = source;
                    sys_manager.file_reader.copy_to(target);
                    root.model_path = file_name;
                }
            }
        }
    }

    function onBind() {
    }

    function onUnbind() {
    }

    MyMenu { // 右键菜单
        id: main_menu
        visible: false
        //            height: (count - 1)*30
        //            background_color: ""
        DeleteMenuItem {
            target: root
        }

        MyMenuItem {
            id: mode_menu
            text: quaternion_mode?qsTr("四元数模式"):qsTr("欧拉角模式")
            tips_text: (qsTr("点击可切换为") +
                        (quaternion_mode?qsTr("欧拉角模式"):qsTr("四元数模式")))
            onTriggered: {
                quaternion_mode = !quaternion_mode;
                update_cube_rotate();
            }
        }
        MyMenuItem {
            id: unit_menu
            visible: !quaternion_mode
            text: angle_or_radian?qsTr("单位:角度"):qsTr("单位:弧度")
            tips_text: (qsTr("点击可切换单位为") +
                        (angle_or_radian?qsTr("弧度"):qsTr("角度")))
            onTriggered: {
                angle_or_radian = !angle_or_radian;
                update_cube_rotate();
            }
        }
        ChMenu {
            id: scalar_menu
            checked: bind_obj
            indicator_color: bind_obj?bind_obj.color:"orange"
            color: "orange"
            title: "scalar" + (bind_obj?(" → "+bind_obj.name):"")
            onParentChanged: {
                parent.visible = Qt.binding(function(){
                    return quaternion_mode;
                });
            }
        }

        ChMenu {
            id: x_menu
            checked: bind_obj
            indicator_color: bind_obj?bind_obj.color:"#ff0000"
            color: "#ff0000"
            title: "X" + (bind_obj?(" → "+bind_obj.name):"")
        }

        ChMenu {
            id: y_menu
            checked: bind_obj
            indicator_color: bind_obj?bind_obj.color:"#00ff00"
            color: "#00ff00"
            title: "Y" + (bind_obj?(" → "+bind_obj.name):"")
        }

        ChMenu {
            id: z_menu
            checked: bind_obj
            indicator_color: bind_obj?bind_obj.color:"#0000ff"
            color: "#0000ff"
            title: "Z" + (bind_obj?(" → "+bind_obj.name):"")
        }


        MyMenu {
            title: qsTr("模型视图")
            MyMenu {
                id: view_menu
                title: qsTr("正视图")
                MyMenuItem {
                    text: qsTr("前")
                    onTriggered: {
                        view_menu.set_rotation(0, 0, 0);
                    }
                }
                MyMenuItem {
                    text: qsTr("后")
                    onTriggered: {
                        view_menu.set_rotation(0, 180, 0);
                    }
                }
                MyMenuItem {
                    text: qsTr("左")
                    onTriggered: {
                        view_menu.set_rotation(0, 90, 0);
                    }
                }
                MyMenuItem {
                    text: qsTr("右")
                    onTriggered: {
                        view_menu.set_rotation(0, -90, 0);
                    }
                }
                MyMenuItem {
                    text: qsTr("上")
                    onTriggered: {
                        view_menu.set_rotation(90, 0, 0);
                    }
                }
                MyMenuItem {
                    text: qsTr("下")
                    onTriggered: {
                        view_menu.set_rotation(-90, 0, 0);
                    }
                }

                function set_rotation(x, y, z) {
                    rotationX_animation.stop();
                    rotationY_animation.stop();
                    rotationZ_animation.stop();

                    rotationX_animation.from = root_transform.rotationX;
                    rotationX_animation.to = x;
                    rotationY_animation.from = root_transform.rotationY;
                    rotationY_animation.to = y;
                    rotationZ_animation.from = root_transform.rotationZ;
                    rotationZ_animation.to = z;
                    rotationX_animation.start();
                    rotationY_animation.start();
                    rotationZ_animation.start();
                }

                NumberAnimation {
                    id: rotationX_animation
                    target: root_transform
                    properties: "rotationX"
                    duration: Math.abs(to - from)*200/90
                }
                NumberAnimation {
                    id: rotationY_animation
                    target: root_transform
                    properties: "rotationY"
                    duration: Math.abs(to - from)*200/90
                }
                NumberAnimation {
                    id: rotationZ_animation
                    target: root_transform
                    properties: "rotationZ"
                    duration: Math.abs(to - from)*200/90
                }

            }
            MyMenu {
                title: qsTr("斜视图")
                MyMenuItem {
                    text: qsTr("左前上")
                    onTriggered: {
                        view_menu.set_rotation(20, 45, 20);
                    }
                }
                MyMenuItem {
                    text: qsTr("右前上")
                    onTriggered: {
                        view_menu.set_rotation(20, -45, -20);
                    }
                }

                MyMenuItem {
                    text: qsTr("左前下")
                    onTriggered: {
                        view_menu.set_rotation(-20, 45, -20);
                    }
                }
                MyMenuItem {
                    text: qsTr("右前下")
                    onTriggered: {
                        view_menu.set_rotation(-20, -45, 20);
                    }
                }
                MyMenuItem {
                    text: qsTr("右后上")
                    onTriggered: {
                        view_menu.set_rotation(-20, 225, -20);
                    }
                }
                MyMenuItem {
                    text: qsTr("左后上")
                    onTriggered: {
                        view_menu.set_rotation(-20, 135, 20);
                    }
                }

                MyMenuItem {
                    text: qsTr("右后下")
                    onTriggered: {
                        view_menu.set_rotation(20, 225, 20);
                    }
                }
                MyMenuItem {
                    text: qsTr("左后下")
                    onTriggered: {
                        view_menu.set_rotation(20, 135, -20);
                    }
                }
            }
            MyMenuItem {
                id: center_menu
                text: qsTr("居中模型")
                tips_text: qsTr("自动计算模型的偏置和比例")
                onTriggered: {
                    center_mesh();
                }
            }
            MyMenuItem {
                id: reset_menu
                text: qsTr("恢复原始位姿")
                tips_text: qsTr("模型将按照原始文件的位姿放置")
                onTriggered: {
                    reset_mesh();
                }
            }
            MyMenuItem {
                text: qsTr("恢复默认模型")
                tips_text: qsTr("将使用默认的立方体作为模型")
                onTriggered: {
                    reset_mesh();
                    root.model_path = "";
                }
            }
            MyMenuItem {
                id: is_auto_center_menu
                text: qsTr("拖入时自动居中")
                checked: is_auto_center
                onTriggered: {
                    is_auto_center = !is_auto_center;
                }
            }
            MyMenuItem {
                id: is_show_obj_axis_menu
                text: qsTr("显示模型坐标轴")
                checked: is_show_obj_axis
                onTriggered: {
                    is_show_obj_axis = !is_show_obj_axis;
                }
            }
            MyMenuItem {
                id: is_show_world_axis_menu
                text: qsTr("显示世界坐标轴")
                checked: is_show_world_axis
                onTriggered: {
                    is_show_world_axis = !is_show_world_axis;
                }
            }
        }

        MyMenuItem {
            text: qsTr("模型颜色")
            color_mark_on: true
            indicator_color: root.cube_color
            onTriggered: {
                sys_manager.open_color_dialog(
                            root,
                            null,
                            cube_color
                            );
                main_menu.visible = false;
            }
        }

        MyMenuItem {
            id: pos_offset_menu
            text: angle_offset_rect.visible?
                      qsTr("位姿偏置设置窗口"):
                      qsTr("位姿偏置设置窗口")
            tips_text: qsTr("直接在控件中间双击") + "\n" +
                       qsTr("也可以显示/隐藏位姿偏置设置窗口")
            checked: false
            onTriggered: checked = !checked;
        }
    }

    function widget_ctx() {
        var ctx = {
            "path": path,
            "ctx": [
                { T:'scalar_menu',        P:'ctx',                   V: scalar_menu.get_ctx()    },
                { T:'x_menu',             P:'ctx',                   V: x_menu.get_ctx()         },
                { T:'y_menu',             P:'ctx',                   V: y_menu.get_ctx()         },
                { T:'z_menu',             P:'ctx',                   V: z_menu.get_ctx()         },
                { T:'pos_offset_menu',    P:'checked',               V: pos_offset_menu.checked  },
                {                         P:'scale',                 V: root.scale               },
                {                         P:'quaternion_mode',       V: root.quaternion_mode     },
                {                         P:'angle_or_radian',       V: root.angle_or_radian     },
                { T:'angle_offset',       P:'x',                     V: root.angle_offset.x      },
                { T:'angle_offset',       P:'y',                     V: root.angle_offset.y      },
                { T:'angle_offset',       P:'z',                     V: root.angle_offset.z      },
                { T:'position_offset',    P:'x',                     V: root.position_offset.x   },
                { T:'position_offset',    P:'y',                     V: root.position_offset.y   },
                { T:'position_offset',    P:'z',                     V: root.position_offset.z   },
                { T:'center_point',       P:'x',                     V: root.center_point.x      },
                { T:'center_point',       P:'y',                     V: root.center_point.y      },
                { T:'center_point',       P:'z',                     V: root.center_point.z      },
                { T:'root_transform',     P:'rotationX',             V: root_transform.rotationX },
                { T:'root_transform',     P:'rotationY',             V: root_transform.rotationY },
                { T:'root_transform',     P:'rotationZ',             V: root_transform.rotationZ },
                { T:'obj_length',         P:'x',                     V: root.obj_length.x        },
                { T:'obj_length',         P:'y',                     V: root.obj_length.y        },
                { T:'obj_length',         P:'z',                     V: root.obj_length.z        },
                { T:'obj_world_length',   P:'x',                     V: root.obj_world_length.x  },
                { T:'obj_world_length',   P:'y',                     V: root.obj_world_length.y  },
                { T:'obj_world_length',   P:'z',                     V: root.obj_world_length.z  },
                {                         P:'is_auto_center',        V: root.is_auto_center      },
                {                         P:'is_show_obj_axis',      V: root.is_show_obj_axis    },
                {                         P:'is_show_world_axis',    V: root.is_show_world_axis  },
                {                         P:'model_path',            V: root.model_path          },
                {                         P:'cube_color',            V: root.cube_color          },
                {                         P:'ctx',                   V: get_ctx()                },
            ]};
        return ctx;
    }

    function apply_widget_ctx(ctx) {
        __set_ctx__(root, ctx.ctx);
        //        scene3d.enabled = true;
    }
}
