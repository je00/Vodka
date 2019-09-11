import QtQuick 2.12
//import QtCanvas3D 1.0
import Qt3D.Core 2.0
import Qt3D.Render 2.0
import QtQuick.Scene3D 2.0
import Qt3D.Extras 2.12
import QtQuick.Controls 2.5
import "file:///____widgets_path____/common"
import "file:///____source_path____/"

Rectangle {
    id: root
    property string path: "cube"
    border.width: sys_manager.lock?0:1
    border.color: "#d0d0d0"
    color: "transparent"
    x: ____x____
    y: ____y____
    property int default_width: ____width____
    property int default_height: ____height____
    property bool bind: false
    property string q0_name: q0_input.text
    property string q1_name: q1_input.text
    property string q2_name: q2_input.text
    property string q3_name: q3_input.text
    property real q0_value: 0
    property real q1_value: 0
    property real q2_value: 0
    property real q3_value: 1
    property bool quaternion_mode: true
    property string cube_color: "____cube_color____"
    property bool is_fill_parent: ____is_fill_parent____
    property int ctx_width: ____ctx_width____
    property int ctx_height: ____ctx_height____
    property int ctx_x: ____ctx_x____
    property int ctx_y: ____ctx_y____
    property real angle_offset_x: ____angle_offset_x____
    property real angle_offset_y: ____angle_offset_y____
    property real angle_offset_z: ____angle_offset_z____
    property real position_offset_x: position_offset.x.toFixed(2)
    property real position_offset_y: position_offset.y.toFixed(2)
    property real position_offset_z: position_offset.z.toFixed(2)
    property real center_point_x: center_point.x.toFixed(2)
    property real center_point_y: center_point.y.toFixed(2)
    property real center_point_z: center_point.z.toFixed(2)
    property real angle_x: ____angle_x____
    property real angle_y: ____angle_y____
    property real angle_z: ____angle_z____
    property real scale: ____scale____
    property real x_length: ____x_length____
    property real y_length: ____y_length____
    property real z_length: ____z_length____
    property real x_length_world: ____x_length_world____
    property real y_length_world: ____y_length_world____
    property real z_length_world: ____z_length_world____
    property string model_path: "____model_path____"
    property bool is_auto_center: is_auto_center_menu.notify_on
    property bool is_show_obj_axis: is_show_obj_axis_menu.notify_on
    property bool is_show_world_axis: is_show_world_axis_menu.notify_on
    property bool true_angle_else_radian: ____true_angle_else_radian____
    property color light_color: "#333333"
    property color ambient_color: "#CCCCCC"
    property vector3d position_offset: Qt.vector3d(
                                           ____position_offset_x____,
                                           ____position_offset_y____,
                                           ____position_offset_z____)
    //                                source: "file:///____source_path____/cube.stl"
    property vector3d center_point: Qt.vector3d(
                                        ____center_point_x____,
                                        ____center_point_y____,
                                        ____center_point_z____)

    Component.onCompleted: {
        if (is_fill_parent) {
            sys_manager.fill_parent(root);
        }
    }

    onModel_pathChanged: {
        cube_entity.update_model();
    }

    function reset_mesh() {
        x_length_world = 100;
        y_length_world = 100;
        z_length_world = 100;
        x_length = 100;
        y_length = 100;
        z_length = 100;
        cube_transform.scale = 1;
        center_point = Qt.vector3d(0, 0, 0);
        position_offset = Qt.vector3d(0, 0, 0);
        cube_rotation_offset_transform.rotation = Qt.quaternion(1, 0, 0, 0);
        cube_transform.translation = Qt.vector3d(0, 0, 0);
    }

    function update_mesh_world_length() {
        var quaternion = cube_rotation_offset_transform.rotation;

        var list = sys_manager.three_tools.bounding_positioin(cube_entity.obj_mesh,
                                                              Qt.vector4d(quaternion.x,
                                                                          quaternion.y,
                                                                          quaternion.z,
                                                                          quaternion.scalar
                                                                          ),
                                                              position_offset
                                                              );
        if (list.lenght === 0)
            return;
        x_length_world = list[6];
        y_length_world = list[7];
        z_length_world = list[8];
    }

    function center_mesh() {
        var quaternion = cube_rotation_offset_transform.rotation;

        var list = sys_manager.three_tools.bounding_positioin(cube_entity.obj_mesh,
                                                              Qt.vector4d(quaternion.x,
                                                                          quaternion.y,
                                                                          quaternion.z,
                                                                          quaternion.scalar
                                                                          ),
                                                              Qt.vector3d(0, 0, 0)
                                                              );
        if (list.lenght === 0)
            return;

        x_length = list[3];
        y_length = list[4];
        z_length = list[5];
        x_length_world = list[6];
        y_length_world = list[7];
        z_length_world = list[8];

        var max_length = Math.max(x_length,
                                  y_length,
                                  z_length);

        cube_transform.scale = 150/max_length;
        position_offset = Qt.vector3d(0, 0, 0);
        center_point = Qt.vector3d(list[0], list[1], list[2]);
        cube_transform.translation = center_point.times(-1).plus(
                    position_offset).times(cube_transform.scale);

    }

    //    function update_model() {

    //    }

    function cross_product(q1, q2) {
        var result = Qt.quaternion(
                    q1.scalar*q2.scalar - q1.x*q2.x      - q1.y*q2.y - q1.z*q2.z,
                    q1.scalar*q2.x      + q1.x*q2.scalar + q1.y*q2.z - q1.z*q2.y,
                    q1.scalar*q2.y      + q1.y*q2.scalar + q1.z*q2.x - q1.x*q2.z,
                    q1.scalar*q2.z      + q1.z*q2.scalar + q1.x*q2.y - q1.y*q2.x
                    );

        return result;

    }

    // called by color_dialog
    function set_color(color) {
        cube_color = "" + color;
    }

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

    function update_cube_rotate() {
        if (!bind)
            return;
        if (!quaternion_mode) {
            if (true_angle_else_radian) {
                obj_transform.rotationX = q0_value;
                obj_transform.rotationY = q1_value;
                obj_transform.rotationZ = q2_value;
            } else {
                obj_transform.rotationX = q0_value*180/Math.PI;
                obj_transform.rotationY = q1_value*180/Math.PI;
                obj_transform.rotationZ = q2_value*180/Math.PI;
            }
        } else {
            obj_transform.rotation = Qt.quaternion(q0_value, q1_value, q2_value, q3_value);
        }
    }

    onQ0_valueChanged: {
        update_cube_rotate();
    }
    onQ1_valueChanged: {
        update_cube_rotate();
    }
    onQ2_valueChanged: {
        update_cube_rotate();
    }
    onQ3_valueChanged: {
        update_cube_rotate();
    }


    Scene3D {
        id: scene3d
        anchors.fill: parent
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
                    //                    rotation: fromAxisAndAngle(Qt.vector3d(1, 0, 0), 0)
                    rotationX: ____angle_x____
                    rotationY: ____angle_y____
                    rotationZ: ____angle_z____
                    onRotationXChanged: {
                        root.angle_x = rotationX;
                    }
                    onRotationYChanged: {
                        root.angle_y = rotationY;
                    }
                    onRotationZChanged: {
                        root.angle_z = rotationZ;
                    }

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
                        length: (((x_length_world) * cube_transform.scale)/2 + 20)
                        width: 0.5
                        enabled: !angle_offset_rect.visible && root.is_show_obj_axis

                    }
                    Arrow {
                        id: obj_axis_y
                        dir: Qt.vector3d(0, 1, 0)
                        color: "#00ff00"
                        ambient_color: root.ambient_color
                        length: (((y_length_world) * cube_transform.scale)/2  + 20)
                        width: 0.5
                        enabled: !angle_offset_rect.visible && root.is_show_obj_axis
                    }
                    Arrow {
                        id: obj_axis_z
                        dir: Qt.vector3d(0, 0, 1)
                        color: "#0000ff"
                        ambient_color: root.ambient_color
                        length: (((z_length_world) * cube_transform.scale)/2 + 20)
                        width: 0.5
                        enabled: !angle_offset_rect.visible && root.is_show_obj_axis
                    }
                    Entity {
                        Arrow {
                            dir: Qt.vector3d(1, 0, 0)
                            color: "#ff0000"
                            ambient_color: root.ambient_color
                            length: ((x_length * cube_transform.scale)/2 + 20)
                            width: 0.5
                            enabled: angle_offset_rect.visible
                            origin: position_offset.times(scale)
                            //                            origin: Qt.vector3d(0, 0, 0)
                        }
                        Arrow {
                            dir: Qt.vector3d(0, 1, 0)
                            color: "#00ff00"
                            ambient_color: root.ambient_color
                            length: ((y_length * cube_transform.scale)/2  + 20)
                            width: 0.5
                            enabled: angle_offset_rect.visible
                            origin: position_offset.times(scale)
                            //                            origin: Qt.vector3d(0, 0, 0)
                        }
                        Arrow {
                            dir: Qt.vector3d(0, 0, 1)
                            color: "#0000ff"
                            ambient_color: root.ambient_color
                            length: ((z_length * cube_transform.scale)/2 + 20)
                            width: 0.5
                            enabled: angle_offset_rect.visible
                            origin: position_offset.times(scale)
                            //                            origin: Qt.vector3d(0, 0, 0)
                        }
                        Transform {
                            id: cube_rotation_offset_transform
                            scale: 1
                            rotationX: ____angle_offset_x____
                            rotationY: ____angle_offset_y____
                            rotationZ: ____angle_offset_z____
                            onRotationXChanged: {
                                root.angle_offset_x = rotationX;
                            }
                            onRotationYChanged: {
                                root.angle_offset_y = rotationY;
                            }
                            onRotationZChanged: {
                                root.angle_offset_z = rotationZ;
                            }
                        }

                        components: [
                            cube_rotation_offset_transform
                        ]
                        Entity {
                            id: cube_entity
                            property Mesh obj_mesh
                            property bool first_run: true
                            components: [ ]
                            //                    CuboidMesh {
                            //                        id: cube_mesh
                            //                        xExtent: 100
                            //                        yExtent: 100
                            //                        zExtent: 100
                            //                    }
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

                            //                            Mesh {
                            //                                id: cube_mesh

                            //                                onStatusChanged: {
                            ////                                    if (status === 2)
                            ////                                        center_mesh(true);
                            //                                }
                            //                                Component.onCompleted: {
                            //                                    update_model();
                            //                                }

                            //                            }

                            Transform {
                                id: cube_transform
                                scale: ____scale____
                                rotation: fromAxisAndAngle(Qt.vector3d(1, 0, 0), 0)

                                onScaleChanged: {
                                    root.scale = scale;
                                }
                            }
                        }
                    }
                }
            }

        }
    }

    MouseArea {
        anchors.fill: parent
        property int start_x: -999
        property int start_y: -999
        property real rotation_x: 0
        property real rotation_y: 0
        property real start_rotation_x: 0
        property real start_rotation_y: 0
        property quaternion start_rotation
        acceptedButtons: Qt.RightButton | Qt.LeftButton
        //        enabled: !sys_manager.lock
        onClicked: {
            if (mouse.button === Qt.RightButton) {
                menu.popup();
            }
        }

        onWheel: {

            var scale = cube_transform.scale;
            if (wheel.angleDelta.y > 0) {
                scale *= 1.1;
            }
            else {
                scale *= 0.9;
            }

            cube_transform.scale = scale;
            cube_transform.translation = center_point.times(-1).plus(
                        position_offset).times(cube_transform.scale);
        }
        onPressed: {
            start_x = mouseX;
            start_y = mouseY;

            start_rotation_x = rotation_x;
            start_rotation_y = rotation_y;
            start_rotation = root_transform.rotation;

            sys_manager.increase_to_top(root);
            angle_offset_rect.unfocus();
            position_offset_rect.unfocus();
        }

        onPositionChanged: {
            var y_gap = start_y - mouseY;
            var effect_size = Math.min(parent.height, parent.width);
            var xangle = -360 * y_gap / effect_size;
            //            rotation_x = start_rotation_x + xangle;
            //            root_transform.rotationX = rotation_x;

            var x_gap = start_x - mouseX;
            var yangle = -360 * x_gap / effect_size;
            //            rotation_y = start_rotation_y + yangle;
            //            root_transform.rotationY = rotation_y;

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

            //            axis_x = Qt.vector3d(1, 0, 0);
            //            axis_y = Qt.vector3d(0, 1, 0);
            var q = root_transform.fromAxesAndAngles(axis_x, xangle, axis_y, yangle);
            //            var q1 = root_transform.fromAxisAndAngle(
            //                        axis_x, xangle);
            //            var q2 = root_transform.fromAxisAndAngle(
            //                        axis_y, yangle);
            root_transform.rotation = cross_product(start_rotation, q);
            //            root_transform.rotation = cross_product(start_rotation, q1);
            start_x = mouseX;
            start_y = mouseY;
            start_rotation = root_transform.rotation;
        }
    }

    Rectangle {
        id: right_bottom_rect
        width: 10
        height: 10
        color: theme_color
        x: default_width - width
        y: default_height - height
        visible: !sys_manager.lock && !root.is_fill_parent
        MouseArea {
            anchors.fill: parent
            drag.target: parent
            drag.threshold: 0
            onPressed: {
                parent.color = "blue";
                sys_manager.increase_to_top(root);
            }
            onReleased: {
                parent.color = Qt.binding(function() { return theme_color });
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


    Rectangle {
        id: drag_rect
        height: 10
        width: 30
        color: theme_color
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        visible: !sys_manager.lock
        MouseArea {
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

            function unfill(trigger_by_double_click) {
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
                if (Math.abs(mouseX - ctx_mouse_x) > 10)
                    unfill();
            }

            onMouseYChanged: {
                if (Math.abs(mouseY - ctx_mouse_y) > 10)
                    unfill();
            }
        }
    }

    ClickableText {
        text: qsTr("[ x ]")
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.topMargin: 10
        font.family: theme_font
        visible: !sys_manager.lock
        onClicked: {
            root.destroy();
        }
    }

    ClickableText {
        id: bind_text
        text: bind?"[★]":"[☆]"
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.topMargin: 10
        visible: !sys_manager.lock
        onClicked: {
            if (root.bind == false)
                root.onBind();
            else
                root.onUnbind();
        }
    }

    Rectangle {
        id: circle_rigion
        anchors.horizontalCenter: bind_text.horizontalCenter
        anchors.top: bind_text.bottom
        anchors.topMargin: 10
        width: 12
        height: width
        color: cube_color
        radius: width/2
        visible: !sys_manager.lock
        MouseArea {
            anchors.fill: parent
            propagateComposedEvents: true
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true
            onPressed:{
                color_dialog.color = cube_color;
                color_dialog.target_obj = root;
                color_dialog.parameter = null;
                color_dialog.open();
            }
        }
    }

    ClickableText {
        id: set_para_name_text
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.verticalCenter: q_rect.verticalCenter
        text: q0.visible?"[←]":"[→]"
        visible: !bind && !sys_manager.lock
        onClicked: {
            q_rect.change_visible();
        }
    }

    ClickableText {
        id: set_angle_text
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
        text: angle_offset_rect.visible_?"[←]":"[offsets]"
        visible: !bind && !sys_manager.lock
        onClicked: {
            angle_offset_rect.change_visible();
            position_offset_rect.change_visible();
        }
    }
    ClickableText {
        id: set_menu_text
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
        text: "menu"
        visible: !bind && !sys_manager.lock
        onClicked: {
            menu.popup();
        }
    }

    Rectangle {
        id: angle_offset_rect
        property bool visible_: false
        height: 20
        width: 180
        border.width: 1
        anchors.top: bind_text.bottom
        anchors.topMargin: 2
        anchors.horizontalCenter: parent.horizontalCenter
        color: "transparent"
        visible: !bind && !sys_manager.lock && visible_
        signal unfocus()

        function change_visible() {
            visible_ = !visible_;
        }

        MyText {
            anchors.bottom: parent.top
            anchors.bottomMargin: 5
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Rotation"
        }

        ListView {
            anchors.fill: parent
            orientation: ListView.Horizontal
            contentHeight: 20
            contentWidth: angle_offset_rect.width/3
            model:ListModel {
                ListElement {
                    border_color: "#ff0000"
                    action_id: 0
                    value: ____angle_offset_x____
                }
                ListElement {
                    border_color: "#00ff00"
                    action_id: 1
                    value: ____angle_offset_y____
                }
                ListElement {
                    border_color: "#0000ff"
                    action_id: 2
                    value: ____angle_offset_z____
                }
            }

            delegate: Rectangle {
                border.width: 1
                //                border.color: border_color
                width: angle_offset_rect.width/3
                height: 20
                color: "transparent"
                CustomTextInput {
                    id: angle_input
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.right: parent.right
                    verticalAlignment: TextInput.AlignVCenter
                    horizontalAlignment: TextInput.AlignHCenter
                    color: border_color
                    text: "" + value
                    enabled: !bind
                    Connections {
                        target: angle_offset_rect
                        onUnfocus: {
                            angle_input.focus = false;
                        }
                    }
                    Connections {
                        target: cube_rotation_offset_transform
                        onRotationXChanged: {
                            if (action_id === 0)
                                angle_input.text = cube_rotation_offset_transform.rotationX;
                        }
                        onRotationYChanged: {
                            if (action_id === 1)
                                angle_input.text = cube_rotation_offset_transform.rotationY;
                        }
                        onRotationZChanged: {
                            if (action_id === 2)
                                angle_input.text = cube_rotation_offset_transform.rotationZ;
                        }

                    }

                    onWheel: {
                        var sign = (value < 0)?-1:1;
                        switch (action_id) {
                        case 0:
                            cube_rotation_offset_transform.rotationX =
                                    (cube_rotation_offset_transform.rotationX + sign * 15)%360;
                            angle_input.text = cube_rotation_offset_transform.rotationX;
                            break;
                        case 1:
                            cube_rotation_offset_transform.rotationY =
                                    (cube_rotation_offset_transform.rotationY + sign * 15)%360;
                            angle_input.text = cube_rotation_offset_transform.rotationY;
                            break;
                        case 2:
                            cube_rotation_offset_transform.rotationZ =
                                    (cube_rotation_offset_transform.rotationZ + sign * 15)%360;
                            angle_input.text = cube_rotation_offset_transform.rotationZ;
                            break;
                        }
                    }

                    onAccepted: {
                        focus = false;
                        angle_offset_rect.focus = false;
                    }
                    onFocusChanged: {
                        if (focus === false) {
                            if (text.length == 0)
                                text = "0";
                            switch (action_id) {
                            case 0:
                                cube_rotation_offset_transform.rotationX = parseFloat(text);
                                break;
                            case 1:
                                cube_rotation_offset_transform.rotationY = parseFloat(text);
                                break;
                            case 2:
                                cube_rotation_offset_transform.rotationZ = parseFloat(text);
                                break;
                            }
                            update_mesh_world_length();
                        } else {
                            selectAll();
                        }
                    }
                }
            }

        }

    }
    Rectangle {
        id: position_offset_rect
        property bool visible_: false

        height: 20
        width: 180
        anchors.bottom: set_angle_text.top
        anchors.bottomMargin: 2

        border.width: 1
        anchors.horizontalCenter: parent.horizontalCenter
        color: "transparent"
        visible: !bind && !sys_manager.lock && visible_
        signal unfocus()

        function change_visible() {
            visible_ = !visible_;
        }

        MyText {
            anchors.top: parent.bottom
            anchors.topMargin: 5
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Position"
        }

        ListView {
            anchors.fill: parent
            orientation: ListView.Horizontal
            contentHeight: 20
            contentWidth: position_offset_rect.width/3
            model:ListModel {
                ListElement {
                    border_color: "#ff0000"
                    action_id: 0
                    value: ____position_offset_x____
                }
                ListElement {
                    border_color: "#00ff00"
                    action_id: 1
                    value: ____position_offset_y____
                }
                ListElement {
                    border_color: "#0000ff"
                    action_id: 2
                    value: ____position_offset_z____
                }
            }

            delegate: Rectangle {
                border.width: 1
                //                border.color: border_color
                width: position_offset_rect.width/3
                height: 20
                color: "transparent"
                CustomTextInput {
                    id: position_input
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.right: parent.right
                    verticalAlignment: TextInput.AlignVCenter
                    horizontalAlignment: TextInput.AlignHCenter
                    color: border_color
                    text: "" + value
                    enabled: !bind
                    function update_position() {
                        switch (action_id) {
                        case 0:
                            position_offset.x = parseFloat(text);
                            break;
                        case 1:
                            position_offset.y = parseFloat(text);
                            break;
                        case 2:
                            position_offset.z = parseFloat(text);
                            break;
                        }
                        cube_transform.translation = center_point.times(-1).plus(
                                    position_offset).times(cube_transform.scale);

                    }
                    Component.onCompleted: {
                        update_position();
                    }

                    Connections {
                        target: position_offset_rect
                        onUnfocus: {
                            position_input.focus = false;
                        }
                    }
                    Connections {
                        target: root
                        onPosition_offsetChanged: {
                            switch (action_id) {
                            case 0:
                                position_input.text = position_offset.x.toFixed(2);
                                break;
                            case 1:
                                position_input.text = position_offset.y.toFixed(2);
                                break;
                            case 2:
                                position_input.text = position_offset.z.toFixed(2);
                                break;
                            }
                        }
                    }

                    onAccepted: {
                        focus = false;
                        position_offset_rect.focus = false;
                    }

                    onWheel: {
                        var sign = (value < 0)?-1:1;
                        switch (action_id) {
                        case 0:
                            position_input.text = position_offset.x + sign * 1;
                            break;
                        case 1:
                            position_input.text = position_offset.y + sign * 1;
                            break;
                        case 2:
                            position_input.text = position_offset.z + sign * 1;
                            break;
                        }
                        update_position();
                        update_mesh_world_length();
                    }

                    onFocusChanged: {
                        if (focus === false) {
                            if (text.length == 0)
                                text = "0";
                            update_position();
                            update_mesh_world_length();
                        } else {
                            selectAll();
                            //                            angle_offset_rect.focus = true;
                        }
                    }

                }
            }

        }

    }


    Rectangle {
        id: q_rect
        width: 156
        height: 105

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        color: "transparent"
        visible: !bind && !sys_manager.lock && visible_
        property bool visible_: false
        signal unfocus()

        function change_visible() {
            visible_ = !visible_;
        }

        Rectangle {
            id: q0
            anchors.top: parent.top
            anchors.left: parent.left

            border.width: 1
            height: 50
            width: 76
            visible: !bind && !sys_manager.lock
            Text {
                id: q0_say
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 5
                font.family: theme_font
                font.pixelSize: 15
                font.bold: theme_font_bold
                text: "Pitch|Q.w"
                height: 20
            }
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 5
                border.width: 1
                border.color: "blue"
                width: 60
                height: 20
                CustomTextInput {
                    id: q0_input
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.right: parent.right
                    verticalAlignment: TextInput.AlignVCenter
                    horizontalAlignment: TextInput.AlignHCenter
                    color: "black"
                    text: "____q0_name____"
                    enabled: !bind
                }
            }
        }
        Rectangle {
            id: q1
            anchors.left: q0.right
            anchors.leftMargin: 5
            anchors.top: q0.top
            border.width: 1
            height: 50
            width: 76
            visible: !bind && !sys_manager.lock
            Text {
                id: q1_say
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 5
                font.family: theme_font
                font.pixelSize: 15
                font.bold: theme_font_bold
                text: "Yaw|Q.x"
                height: 20
            }
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 5
                border.width: 1
                border.color: "blue"
                width: 60
                height: 20
                CustomTextInput {
                    id: q1_input
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.right: parent.right
                    verticalAlignment: TextInput.AlignVCenter
                    horizontalAlignment: TextInput.AlignHCenter
                    text: "____q1_name____"
                    enabled: !bind
                }
            }
        }

        Rectangle {
            id: q2
            anchors.left: q0.left
            anchors.top: q0.bottom
            anchors.topMargin: 5
            border.width: 1
            height: 50
            width: 76
            visible: !bind && !sys_manager.lock
            Text {
                id: q2_say
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 5
                font.family: theme_font
                font.pixelSize: 15
                font.bold: theme_font_bold
                text: "ROLL|Q.y"
                height: 20
            }
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 5
                border.width: 1
                border.color: "blue"
                width: 60
                height: 20
                CustomTextInput {
                    id: q2_input
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.right: parent.right
                    verticalAlignment: TextInput.AlignVCenter
                    horizontalAlignment: TextInput.AlignHCenter
                    text: "____q2_name____"
                    enabled: !bind
                }
            }
        }
        Rectangle {
            id: q3
            anchors.left: q1.left
            anchors.top: q0.bottom
            anchors.topMargin: 5
            border.width: 1
            height: 50
            width: 76
            visible: !bind && !sys_manager.lock
            Text {
                id: q3_say
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 5
                font.family: theme_font
                font.pixelSize: 15
                font.bold: theme_font_bold
                text: "Q.z"
                height: 20
            }
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 5
                border.width: 1
                border.color: "blue"
                width: 60
                height: 20
                CustomTextInput {
                    id: q3_input
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.right: parent.right
                    verticalAlignment: TextInput.AlignVCenter
                    horizontalAlignment: TextInput.AlignHCenter
                    selectByMouse: true
                    color: "black"
                    text: "____q3_name____"
                    enabled: !bind
                }
            }
        }

        Rectangle {
            height: 21
            anchors.bottom: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            CheckBox {
                id: angle_check
                text: "angle"
                font.family: theme_font
                font.pointSize: theme_font_point_size
                font.bold: true
                height: parent.height
                indicator.width: 10
                indicator.height: 10
                anchors.left: parent.left
                checked: true_angle_else_radian
                checkable: false
                onClicked: {
                    true_angle_else_radian = true;
                    checked = Qt.binding(function(){ return true_angle_else_radian; });
                }
            }
            CheckBox {
                id: radian_check
                text: "radian"
                font.family: theme_font
                font.pointSize: theme_font_point_size
                font.bold: true
                anchors.left: angle_check.right
                anchors.top: angle_check.top
                height: parent.height
                indicator.width: 10
                indicator.height: 10
                checked: !true_angle_else_radian
                checkable: false
                onClicked: {
                    true_angle_else_radian = false;
                    checked = Qt.binding(function(){ return !true_angle_else_radian; });
                }
            }
        }

    }



    DropArea {
        anchors.fill: parent
        enabled: !bind
        onDropped: {
            //                console.log("onDropped!")
            reset_mesh();
            var path = sys_manager.config_path;
            if(drop.hasUrls){
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

        onEntered: {
            //                console.log("onEntered!");
        }

        onExited: {
            //                console.log("onExited!")
        }

        onPositionChanged: {
            //                console.log("onPositionChanged!");
        }
    }

    function onBind() {
        var rt_value = [];
        rt_value[0] = sys_manager.find_rt_value_obj_by_name(q0_input.text);
        rt_value[1] = sys_manager.find_rt_value_obj_by_name(q1_input.text);
        rt_value[2] = sys_manager.find_rt_value_obj_by_name(q2_input.text);
        rt_value[3] = sys_manager.find_rt_value_obj_by_name(q3_input.text);

        if (rt_value[0] && rt_value[1] && rt_value[2]) {
            q0_value = Qt.binding(function() { return rt_value[0].value } );
            q1_value = Qt.binding(function() { return rt_value[1].value } );
            q2_value = Qt.binding(function() { return rt_value[2].value } );
            bind = true;
        }
        if (rt_value[3]) {
            q3_value = Qt.binding(function() { return rt_value[3].value } );
            quaternion_mode = true;
        } else {
            quaternion_mode = false;
        }
    }
    function onUnbind() {
        bind = false;
        obj_transform.rotationX = 0;
        obj_transform.rotationY = 0;
        obj_transform.rotationZ = 0;
    }
    MyMenu { // 右键菜单
        id: menu
        visible: false
        //            height: (count - 1)*30
        //            background_color: ""
        width: 80

        MyMenu {
            width: 120
            title: qsTr("模型")
            MyMenuItem {
                id: center_menu
                width: parent.width
                show_text: qsTr("居中模型")
                custom_triggered_action: true
                onCustom_triggered: {
                    center_mesh();
                }
            }
            MyMenuItem {
                id: reset_menu
                width: parent.width
                show_text: qsTr("复位模型")
                custom_triggered_action: true
                onCustom_triggered: {
                    reset_mesh();
                }
            }
            MyMenuItem {
                id: is_auto_center_menu
                width: parent.width
                show_text: qsTr("拖入时自动居中")
                notify_on: ____is_auto_center____
                custom_triggered_action: true
                onCustom_triggered: {
                    notify_on = !notify_on;
                }
            }
        }
        MyMenu {
            id: view_menu
            width: 80
            title: qsTr("正视图")
            MyMenuItem {
                width: parent.width
                show_text: qsTr("前")
                custom_triggered_action: true
                onCustom_triggered: {
                    view_menu.set_rotation(0, 0, 0);
                }
            }
            MyMenuItem {
                width: parent.width
                show_text: qsTr("后")
                custom_triggered_action: true
                onCustom_triggered: {
                    view_menu.set_rotation(0, 180, 0);
                }
            }
            MyMenuItem {
                width: parent.width
                show_text: qsTr("左")
                custom_triggered_action: true
                onCustom_triggered: {
                    view_menu.set_rotation(0, 90, 0);
                }
            }
            MyMenuItem {
                width: parent.width
                show_text: qsTr("右")
                custom_triggered_action: true
                onCustom_triggered: {
                    view_menu.set_rotation(0, -90, 0);
                }
            }
            MyMenuItem {
                width: parent.width
                show_text: qsTr("上")
                custom_triggered_action: true
                onCustom_triggered: {
                    view_menu.set_rotation(90, 0, 0);
                }
            }
            MyMenuItem {
                width: parent.width
                show_text: qsTr("下")
                custom_triggered_action: true
                onCustom_triggered: {
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
            width: 80
            title: qsTr("斜视图")
            MyMenuItem {
                width: parent.width
                show_text: qsTr("左前上")
                custom_triggered_action: true
                onCustom_triggered: {
                    view_menu.set_rotation(20, 45, 20);
                }
            }
            MyMenuItem {
                width: parent.width
                show_text: qsTr("右前上")
                custom_triggered_action: true
                onCustom_triggered: {
                    view_menu.set_rotation(20, -45, -20);
                }
            }

            MyMenuItem {
                width: parent.width
                show_text: qsTr("左前下")
                custom_triggered_action: true
                onCustom_triggered: {
                    view_menu.set_rotation(-20, 45, -20);
                }
            }
            MyMenuItem {
                width: parent.width
                show_text: qsTr("右前下")
                custom_triggered_action: true
                onCustom_triggered: {
                    view_menu.set_rotation(-20, -45, 20);
                }
            }
            MyMenuItem {
                width: parent.width
                show_text: qsTr("右后上")
                custom_triggered_action: true
                onCustom_triggered: {
                    view_menu.set_rotation(-20, 225, -20);
                }
            }
            MyMenuItem {
                width: parent.width
                show_text: qsTr("左后上")
                custom_triggered_action: true
                onCustom_triggered: {
                    view_menu.set_rotation(-20, 135, 20);
                }
            }

            MyMenuItem {
                width: parent.width
                show_text: qsTr("右后下")
                custom_triggered_action: true
                onCustom_triggered: {
                    view_menu.set_rotation(20, 225, 20);
                }
            }
            MyMenuItem {
                width: parent.width
                show_text: qsTr("左后下")
                custom_triggered_action: true
                onCustom_triggered: {
                    view_menu.set_rotation(20, 135, -20);
                }
            }
        }
        MyMenu {
            width: 120
            title: qsTr("设置")
            MyMenuItem {
                id: is_show_obj_axis_menu
                width: parent.width
                show_text: qsTr("模型坐标轴")
                notify_on: ____is_show_obj_axis____
                custom_triggered_action: true
                onCustom_triggered: {
                    notify_on = !notify_on;
                }
            }
            MyMenuItem {
                id: is_show_world_axis_menu
                width: parent.width
                show_text: qsTr("世界坐标轴")
                notify_on: ____is_show_world_axis____
                custom_triggered_action: true
                onCustom_triggered: {
                    notify_on = !notify_on;
                }
            }

        }
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
    }

}
