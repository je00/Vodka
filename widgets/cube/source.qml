import QtQuick 2.11
import QtCanvas3D 1.0

import "file:///____widgets_path____/3rdparty/three.js" as THREEJS

Rectangle {
    id: root
    property string path: "cube"
    border.width: sys_manager.lock?0:1
    width: right_bototm_rect.x + right_bototm_rect.width
    height: right_bototm_rect.y + right_bototm_rect.width
    color: "transparent"
    x: ____x____
    y: ____y____
    property int default_width: ____width____
    property int default_height: ____height____
    property real r_rect_y: color_r_rect.y
    property real g_rect_y: color_g_rect.y
    property real b_rect_y: color_b_rect.y
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
    property int cube_color: (color_r_rect.value * 0x10000 + color_g_rect.value * 0x100 + color_b_rect.value)

    onCube_colorChanged: {
        if (gl_code.cube)
            gl_code.cube.material.color.setHex(cube_color);
    }

    function update_cube_rotate() {
        if (!bind)
            return;
        var q;
        if (!quaternion_mode) {
            var euler = new THREEJS.THREE.Euler(q0_value, q1_value, q2_value, "XYZ");
            q = new THREEJS.THREE.Quaternion();
            q.setFromEuler(euler);
        } else {
            q = new THREEJS.THREE.Quaternion(q0_value, q1_value, q2_value, q3_value);
        }
        gl_code.cube_meta.quaternion.copy(q);
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

    MouseArea {
        anchors.fill: parent
        property int start_x: -999
        property int start_y: -999
        property real rotation_x: 0
        property real rotation_y: 0
        property real start_rotation_x: 0
        property real start_rotation_y: 0
        enabled: !sys_manager.lock

        onWheel: {
            var scale = gl_code.cube.scale.x;
            if (wheel.angleDelta.y > 0) {
                scale -= 0.1;
            }
            else {
                scale += 0.1;
            }
            gl_code.cube.scale.x = scale;
            gl_code.cube.scale.y = scale;
            gl_code.cube.scale.z = scale;

        }
        onPressed: {
            start_x = mouseX;
            start_y = mouseY;

            start_rotation_x = rotation_x;
            start_rotation_y = rotation_y;
        }

        onPositionChanged: {
            var y_gap = start_y - mouseY;
            var xangle = Math.PI * y_gap / parent.height;
            rotation_x = start_rotation_x + xangle;
            gl_code.camera_rack.rotation.x = rotation_x;

            var x_gap = start_x - mouseX;
            var yangle = Math.PI * x_gap / parent.width;
            rotation_y = start_rotation_y + yangle;
            gl_code.camera_rack.rotation.y = rotation_y;
        }
    }

    Item {
        id: gl_code
        property var camera_rack
        property var camera
        property var scene
        property var renderer
        property var cube
        property var cube_meta
        property var directionalLight
        //        var camera, scene, renderer;
        //        var cube;
        //        var pointLight;


        function initializeGL(canvas) {
            scene = new THREEJS.THREE.Scene();

            camera = new THREEJS.THREE.PerspectiveCamera(50, canvas.width / canvas.height, 1, 2000);
            camera.position.x = -140;
            camera.position.z = 300;
            camera.position.y = 140;
            camera_rack = new THREEJS.THREE.Object3D();
            camera_rack.add(camera);
            scene.add(camera_rack);


            var geometry = new THREEJS.THREE.BoxGeometry(100, 100, 100);
            var faceMaterial = new THREEJS.THREE.MeshLambertMaterial({color: cube_color});

            cube_meta = new THREEJS.THREE.Object3D();
            cube = new THREEJS.THREE.Mesh(geometry, faceMaterial);
            cube_meta.add(cube);
            scene.add(cube_meta);
            camera.lookAt(cube.position);

            scene.add(new THREEJS.THREE.AmbientLight(0xcccccc));
            directionalLight = new THREEJS.THREE.DirectionalLight(0x333333, 1.0);
            directionalLight.position.copy(camera.position);
            directionalLight.quaternion.copy(camera.quaternion);
            camera_rack.add(directionalLight);
            //            scene.add(directionalLight);

            var arrowHelperx = new THREEJS.THREE.ArrowHelper(new THREEJS.THREE.Vector3(1, 0, 0), new THREEJS.THREE.Vector3(0, 0, 0), 140, 0xff0000,10,10);
            var arrowHelpery = new THREEJS.THREE.ArrowHelper(new THREEJS.THREE.Vector3(0, 1, 0), new THREEJS.THREE.Vector3(0, 0, 0), 140, 0x00ff00,10,10);
            var arrowHelperz = new THREEJS.THREE.ArrowHelper(new THREEJS.THREE.Vector3(0, 0, 1), new THREEJS.THREE.Vector3(0, 0, 0), 140, 0x0000ff,10,10);
            scene.add(arrowHelperx);
            scene.add(arrowHelpery);
            scene.add(arrowHelperz);

            arrowHelperx = new THREEJS.THREE.ArrowHelper(new THREEJS.THREE.Vector3(1, 0, 0), new THREEJS.THREE.Vector3(0, 0, 0), 100, 0xff0000,10,10);
            arrowHelpery = new THREEJS.THREE.ArrowHelper(new THREEJS.THREE.Vector3(0, 1, 0), new THREEJS.THREE.Vector3(0, 0, 0), 100, 0x00ff00,10,10);
            arrowHelperz = new THREEJS.THREE.ArrowHelper(new THREEJS.THREE.Vector3(0, 0, 1), new THREEJS.THREE.Vector3(0, 0, 0), 100, 0x0000ff,10,10);
            cube_meta.add(arrowHelperx);
            cube_meta.add(arrowHelpery);
            cube_meta.add(arrowHelperz);

            renderer = new THREEJS.THREE.Canvas3DRenderer(
                        { canvas: canvas, antialias: true, devicePixelRatio: canvas.devicePixelRatio,alpha:true });
            renderer.setPixelRatio(canvas.devicePixelRatio);
            renderer.setSize(canvas.width, canvas.height);
            setBackgroundColor(canvas.backgroundColor);
        }

        function setBackgroundColor(backgroundColor) {
            var str = ""+backgroundColor;
            var color = parseInt(str.substring(1), 16);
            //    if (renderer)
            //        renderer.setClearColor(0x00ff00);
        }

        function resizeGL(canvas) {
            if (camera === undefined) return;

            camera.aspect = canvas.width / canvas.height;
            camera.updateProjectionMatrix();

            renderer.setPixelRatio(canvas.devicePixelRatio);
            renderer.setSize(canvas.width, canvas.height);
        }

        //! [5]
        function paintGL(canvas) {
            //            cube.rotation.x = canvas.xRotation * Math.PI / 180;
            //            cube.rotation.y = canvas.yRotation * Math.PI / 180;
            //            cube.rotation.z = canvas.zRotation * Math.PI / 180;
            renderer.render(scene, camera);
        }
        //! [5]
    }

    Canvas3D {
        id: my_cube
        //! [0]
        state: "image6"
        property color backgroundColor: theme_color
        property real angleOffset: -180 / 8.0
        property string image1: ""
        //! [0]
        property string image2: ""
        property string image3: ""
        property string image4: ""
        property string image5: ""
        property string image6: ""
        property real xRotation: 0
        property real yRotation: 0
        property real zRotation: 0
        anchors.fill: parent

        onBackgroundColorChanged: { gl_code.setBackgroundColor(my_cube.backgroundColor); }

        //! [2]

        //! [3]
        onInitializeGL: {
            gl_code.initializeGL(my_cube);
        }

        onPaintGL: {
            update_cube_rotate();
            gl_code.paintGL(my_cube);
        }

        onResizeGL: {
            gl_code.resizeGL(my_cube);
        }
        //! [3]
    }

    Rectangle {
        id: right_bototm_rect
        width: 10
        height: 10
        color: theme_color
        x: default_width - width
        y: default_height - height
        visible: !sys_manager.lock
        MouseArea {
            anchors.fill: parent
            drag.target: parent
        }
    }


    Rectangle {
        height: 10
        width: 30
        color: theme_color
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        visible: !sys_manager.lock
        MouseArea {
            anchors.fill: parent
            drag.target: parent.parent
            drag.minimumX: -parent.parent.width/2
            drag.minimumY: 0
        }
    }

    Text {
        text: qsTr("[ - ]")
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.topMargin: 10
        font.family: theme_font
        font.pixelSize: 15
        font.bold: theme_font_bold
        color: "blue"
        visible: !sys_manager.lock
        MouseArea {
            anchors.fill: parent
            onClicked: {
                root.destroy();
            }
        }
    }

    Text {
        text: bind?"[★]":"[☆]"
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.topMargin: 10
        font.family: theme_font
        font.pixelSize: 15
        font.bold: theme_font_bold
        color: "blue"
        visible: !sys_manager.lock
        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (root.bind == false)
                    root.onBind();
                else
                    root.onUnbind();
            }
        }
    }

    Text {
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.verticalCenter: q_rect.verticalCenter
        text: q0.visible?"[←]":"[→]"
        font.family: theme_font
        font.pixelSize: 15
        font.underline: true
        font.bold: true
        color: "blue"
        visible: !bind && !sys_manager.lock
        MouseArea {
            anchors.fill: parent
            onClicked: {
                q_rect.visible = !q_rect.visible;
            }
        }
    }
    Rectangle {
        id: q_rect
        width: 149
        height: 105

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        visible: !bind && !sys_manager.lock
        color: "transparent"
        Component.onCompleted: {
            visible = false;
        }

        Rectangle {
            id: q0
            anchors.top: parent.top
            anchors.left: parent.left

            border.width: 1
            height: 50
            width: 72
            visible: !bind && !sys_manager.lock
            Text {
                id: q0_say
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 5
                font.family: theme_font
                font.pixelSize: 15
                font.bold: theme_font_bold
                text: "Pitch|Q0"
            }
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: q0_say.bottom
                anchors.topMargin: 5
                border.width: 1
                border.color: "blue"
                width: 60
                height: 20
                TextInput {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.right: parent.right
                    verticalAlignment: TextInput.AlignVCenter
                    horizontalAlignment: TextInput.AlignHCenter
                    id: q0_input
                    selectByMouse: true
                    color: "black"
                    text: "____q0_name____"
                    enabled: !bind
                    font.family: theme_font
                    font.pixelSize: 15
                    font.bold: theme_font_bold
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
            width: 72
            visible: !bind && !sys_manager.lock
            Text {
                id: q1_say
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 5
                font.family: theme_font
                font.pixelSize: 15
                font.bold: theme_font_bold
                text: "Yaw|Q1"
            }
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: q1_say.bottom
                anchors.topMargin: 5
                border.width: 1
                border.color: "blue"
                width: 60
                height: 20
                TextInput {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.right: parent.right
                    verticalAlignment: TextInput.AlignVCenter
                    horizontalAlignment: TextInput.AlignHCenter
                    id: q1_input
                    selectByMouse: true
                    color: "black"
                    text: "____q1_name____"
                    enabled: !bind
                    font.family: theme_font
                    font.pixelSize: 15
                    font.bold: theme_font_bold
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
            width: 72
            visible: !bind && !sys_manager.lock
            Text {
                id: q2_say
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 5
                font.family: theme_font
                font.pixelSize: 15
                font.bold: theme_font_bold
                text: "ROLL|Q2"
            }
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: q2_say.bottom
                anchors.topMargin: 5
                border.width: 1
                border.color: "blue"
                width: 60
                height: 20
                TextInput {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.right: parent.right
                    verticalAlignment: TextInput.AlignVCenter
                    horizontalAlignment: TextInput.AlignHCenter
                    id: q2_input
                    selectByMouse: true
                    color: "black"
                    text: "____q2_name____"
                    enabled: !bind
                    font.family: theme_font
                    font.pixelSize: 15
                    font.bold: theme_font_bold
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
            width: 72
            visible: !bind && !sys_manager.lock
            Text {
                id: q3_say
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 5
                font.family: theme_font
                font.pixelSize: 15
                font.bold: theme_font_bold
                text: "Q3"
            }
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: q3_say.bottom
                anchors.topMargin: 5
                border.width: 1
                border.color: "blue"
                width: 60
                height: 20
                TextInput {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.right: parent.right
                    verticalAlignment: TextInput.AlignVCenter
                    horizontalAlignment: TextInput.AlignHCenter
                    id: q3_input
                    selectByMouse: true
                    color: "black"
                    text: "____q3_name____"
                    enabled: !bind
                    font.family: theme_font
                    font.pixelSize: 15
                    font.bold: theme_font_bold
                }
            }
        }
    }
    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 1
        //        anchors.leftMargin: -width/2
        color: "black"
        visible: !sys_manager.lock
        property int origin_height: 0
        Component.onCompleted: {
            origin_height = height;
            color_r_rect.y = ____r_rect_y____;
            color_g_rect.y = ____g_rect_y____;
            color_b_rect.y = ____b_rect_y____;
        }
        onHeightChanged: {
            color_r_rect.y = (height - color_r_rect.height)  * color_r_rect.value/255;
            color_g_rect.y = (height - color_g_rect.height)  * color_g_rect.value/255;
            color_b_rect.y = (height - color_b_rect.height)  * color_b_rect.value/255;
            origin_height = height;
        }

        Rectangle {
            id: color_r_rect
            width: 5
            height: 5
            anchors.horizontalCenter: parent.horizontalCenter
            property int value: (y/(parent.origin_height - height) * 255).toFixed(0)
            color: "red"
            MouseArea {
                id: color_r_rect_mouse
                anchors.fill: parent
                drag.target: parent
                drag.axis: Drag.YAxis
                drag.threshold: 0
                drag.minimumY: 0
                drag.maximumY: parent.parent.height - parent.width

            }
            Text {
                anchors.left: parent.right
                font.family: theme_font
                font.pixelSize: 15
                font.bold: true
                visible: color_r_rect_mouse.pressed
                anchors.verticalCenter: parent.verticalCenter
                color: "red"
                text: "" + parent.value
            }
        }
        Rectangle {
            id: color_g_rect
            width: 5
            height: 5
            anchors.horizontalCenter: parent.horizontalCenter
            property int value: (y/(parent.origin_height - height) * 255).toFixed(0)
            color: "green"

            MouseArea {
                id: color_g_rect_mouse
                anchors.fill: parent
                drag.target: parent
                drag.axis: Drag.YAxis
                drag.threshold: 0
                drag.minimumY: 0
                drag.maximumY: parent.parent.height - parent.width

            }
            Text {
                anchors.left: parent.right
                font.family: theme_font
                font.pixelSize: 15
                font.bold: true
                visible: color_g_rect_mouse.pressed
                anchors.verticalCenter: parent.verticalCenter
                color: "green"
                text: "" + parent.value
            }
        }
        Rectangle {
            id: color_b_rect
            width: 5
            height: 5
            anchors.horizontalCenter: parent.horizontalCenter
            property int value: (y/(parent.origin_height - height) * 255).toFixed(0)
            color: "blue"

            MouseArea {
                id: color_b_rect_mouse
                anchors.fill: parent
                drag.target: parent
                drag.axis: Drag.YAxis
                drag.threshold: 0
                drag.minimumY: 0
                drag.maximumY: parent.parent.height - parent.width
            }
            Text {
                anchors.left: parent.right
                font.family: theme_font
                font.pixelSize: 15
                font.bold: true
                visible: color_b_rect_mouse.pressed
                anchors.verticalCenter: parent.verticalCenter
                color: "blue"
                text: "" + parent.value
            }
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
    }
}
