import QtQuick 2.12

Text {
    id: root
    text: qsTr("clickable")
    font.family: theme_font
    font.pointSize: theme_font_point_size
//    font.bold: mouse
    color: mouse.pressed?"purple":"blue"
    visible: !sys_manager.lock
    signal clicked()
    MouseArea {
        id: mouse
        hoverEnabled: true
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            root.clicked();
        }
        onEntered: {
            root.font.bold = true;
        }
        onExited: {
            root.font.bold = false;
        }
    }
}
