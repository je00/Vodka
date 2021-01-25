import QtQuick 2.0
import QtQuick.Controls.Material 2.12
import QtQuick.Controls.Material.impl 2.12

Ripple {
    anchors.centerIn: parent
    width: parent.width * 1.5
    height: width
    color: appTheme.lineColor
    opacity: 0.5
}
