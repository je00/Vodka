import QtQuick 2.9

Rectangle {
    width: 200
    height: 200
    border.width: 1
    x: ____x____
    y: ____y____
    property string path: "my_widget"
    property string my_parameter1: text1.text
    property string my_parameter2: text2.text

    Text {
        id: text1
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: 20
        anchors.leftMargin: 20
        font.family: theme_font
        font.pixelSize: theme_font_pixel_size
        font.bold: theme_font_bold

        text: "____my_parameter1____"
    }

    Text {
        id: text2
        anchors.top: text1.bottom
        anchors.left: text1.left
        anchors.topMargin: 20
        font.family: theme_font
        font.pixelSize: theme_font_pixel_size
        font.bold: theme_font_bold
        text: "____my_parameter2____"
    }
}
