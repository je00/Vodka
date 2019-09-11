import QtQuick 2.12

TextInput {
    id: root
    font.family: theme_font
    font.pointSize: theme_font_point_size
    font.bold: theme_font_bold
    selectByMouse: true
    signal wheel(real value)

//    onAccepted: {
//        focus = false;
//    }

//    onFocusChanged: {
//        if (focus) {
//            selectAll();
//        }
//    }
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.IBeamCursor
        enabled: true
        propagateComposedEvents: true
        onWheel: {
            root.wheel(wheel.angleDelta.y);
        }
        onClicked: {
            mouse.accepted = false;
        }
        onPressed: {
            mouse.accepted = false;
        }
        onReleased: {
            mouse.accepted = false;
        }
    }
}
