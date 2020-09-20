import QtQuick 2.12
import Qt3D.Core 2.12
import Qt3D.Render 2.12
import QtQuick.Scene3D 2.12
import Qt3D.Extras 2.12

Entity {
    id: root
    property color color: "#ff0000"
    property color ambient_color: "#cccccc"
    property real length: 140
    property real width: 1
    property real headLength: width*10
    property real headWidth: width*10
    property vector3d dir: Qt.vector3d(0, 0, 1)
    property vector3d origin: Qt.vector3d(0, 0, 0)

    components: [ cylinderMesh, material, transform_cylinder ]

    Component.onCompleted: {
        update_dir();
    }

    onOriginChanged: {
        update_dir();
    }

    onDirChanged: {
        update_dir();
    }

    onWidthChanged: {
        update_dir();
    }

    onLengthChanged: {
        update_dir();
    }

    function update_dir() {
        transform_cylinder.rotation = transform_cylinder.fromAxisAndAngle(Qt.vector3d(0, 1, 0), 0);
        var up_dir = Qt.vector3d(0, 1, 0);
        var rotate_axis = up_dir.crossProduct(dir);
        var sin_angle = rotate_axis.length() / (up_dir.length() * root.dir.length());
        var angle = Math.asin(sin_angle);
        transform_cylinder.rotation = transform_cylinder.fromAxisAndAngle(rotate_axis, angle*180/Math.PI);
        transform_cylinder.translation = root.dir.normalized().times(root.length/2).plus(root.origin);
    }

    PhongMaterial {
        id: material
        ambient: ambient_color
        diffuse: color
        shininess: 1.0
    }

    CylinderMesh {
        id: cylinderMesh
        length: root.length
        radius: root.width
        rings: 100
        slices: 10
    }

    Transform {
        id: transform_cylinder
        scale3D: Qt.vector3d(1, 1, 1)
//        rotation: fromAxisAndAngle(Qt.vector3d(1, 0, 0), 0)
//        translation: Qt.vector3d(cylinderMesh.length/2, 0, 0)
        translation: Qt.vector3d(0, cylinderMesh.length/2, 0)
//        translation: Qt.vector3d(0, 0, cylinderMesh.length/2)
    }

    Entity {
        components: [ cylinderMesh, material, transform_cone_minus ]
        Transform {
            id: transform_cone_minus
            scale3D: Qt.vector3d(1, 1, 1)
            translation: Qt.vector3d(0, -root.length, 0)
            rotation: fromAxisAndAngle(Qt.vector3d(1, 0, 0), 0)
        }
    }

    Entity {
        components: [ coneMesh, material, transform_cone ]
        ConeMesh {
            id: coneMesh
            bottomRadius: headWidth/2
            length: headLength
        }
        Transform {
            id: transform_cone
            scale3D: Qt.vector3d(1, 1, 1)
            translation: Qt.vector3d(0, root.length /2, 0)
            rotation: fromAxisAndAngle(Qt.vector3d(1, 0, 0), 0)
        }
    }

}
