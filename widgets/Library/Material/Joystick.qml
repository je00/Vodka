/****************************************************************************
**
** Copyright (C) 2017 The Qt Company Ltd.
** Contact: http://www.qt.io/licensing/
**
** This file is part of the Qt Quick Controls 2 module of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:LGPL3$
** Commercial License Usage
** Licensees holding valid commercial Qt licenses may use this file in
** accordance with the commercial license agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and The Qt Company. For licensing terms
** and conditions see http://www.qt.io/terms-conditions. For further
** information use the contact form at http://www.qt.io/contact-us.
**
** GNU Lesser General Public License Usage
** Alternatively, this file may be used under the terms of the GNU Lesser
** General Public License version 3 as published by the Free Software
** Foundation and appearing in the file LICENSE.LGPLv3 included in the
** packaging of this file. Please review the following information to
** ensure the GNU Lesser General Public License version 3 requirements
** will be met: https://www.gnu.org/licenses/lgpl.html.
**
** GNU General Public License Usage
** Alternatively, this file may be used under the terms of the GNU
** General Public License version 2.0 or later as published by the Free
** Software Foundation and appearing in the file LICENSE.GPL included in
** the packaging of this file. Please review the following information to
** ensure the GNU General Public License version 2.0 requirements will be
** met: http://www.gnu.org/licenses/gpl-2.0.html.
**
** $QT_END_LICENSE$
**
****************************************************************************/

import QtQuick 2.14
import QtQuick.Controls.Private 1.0
import QtQuick.Controls 2.14
//import QtQuick.Controls.Material 2.12
//import QtQuick.Controls.Material.impl 2.12
import MyModules 1.0

Control {
    id: control
    property real positionX: 0
    property real positionY: 0
    property alias xValue: xRange.value
    property alias yValue: yRange.value
    property bool pressed: mouseArea.pressed
    property real from: -1
    property real to: 1
    property real stepSize: 0.1
    property color color: appTheme.mainColor
    property color handleColor: appTheme.mainColor
    property real customScale: 1
    property real mouseXValue: mouseXRange.value.toFixed(stepDecimals)
    property real mouseYValue: mouseYRange.value.toFixed(stepDecimals)
    property int stepDecimals:{
        var stepSize_str = "" + stepSize;
        (stepSize_str.indexOf(".")<0?
             0:(stepSize_str.length -
                stepSize_str.indexOf(".") - 1))
    }
    property bool boundEnabled: true
    signal valueChanged();

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    RangeModel {
        id: xRange
        minimumValue: control.from
        maximumValue: control.to
        stepSize: control.stepSize
    }

    RangeModel {
        id: yRange
        minimumValue: control.from
        maximumValue: control.to
        stepSize: control.stepSize
    }

    RangeModel {
        id: mouseXRange
        minimumValue: control.from
        maximumValue: control.to
        stepSize: control.stepSize
    }

    RangeModel {
        id: mouseYRange
        minimumValue: control.from
        maximumValue: control.to
        stepSize: control.stepSize
    }

    background: Rectangle {
        antialiasing: true
        implicitWidth: g_settings.applyHScale(100)
        implicitHeight: g_settings.applyVScale(100)

        x: control.width / 2 - width / 2
        y: control.height / 2 - height / 2
        width: Math.max(g_settings.applyHScale(64), Math.min(control.width, control.height))
        height: width
        color: "transparent"
        radius: width / 2

        opacity: control.enabled?1:0.7
        border.color: control.color
        border.width: g_settings.applyHScale(2)
    }

    property Item handle: SliderHandle {
        handleHasFocus: control.visualFocus
        handlePressed: control.pressed
        handleHovered: control.hovered
        ratio: 0.25
        parent: control
        x: {
            if (mouseArea.pressed || !boundEnabled) {
                control.background.x + control.background.width * control.positionX - control.handle.width / 2
            } else {
                control.background.x + control.background.width / 2 - control.handle.width / 2
            }
        }
        y: {
            if (mouseArea.pressed || !boundEnabled) {
                control.background.y + control.background.height * control.positionY - control.handle.height / 2
            } else {
                control.background.y + control.background.height / 2 - control.handle.height / 2
            }
        }
    }

    MyMouseArea {
        id: mouseArea
        property var mouseXFixed: width * control.positionX
        property var mouseYFixed: height * control.positionY
        acceptedButtons: Qt.LeftButton
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        parent: control.background.parent
        anchors.centerIn: parent
        width: background.width
        height: background.height

        function updateTargetPosition() {
            var angle;
            var mouseXInCoord = mouseX - width/2;
            var mouseYInCoord = height/2 - mouseY;

            var targetX, targetY;
            if (mouseXInCoord === 0) {
                if (mouseYInCoord === 0)
                    angle = 0;
                else if (mouseYInCoord > 0)
                    angle = Math.PI/2;
                else if (mouseYInCoord < 0)
                    angle = -Math.PI/2;
            } else {
                angle = Math.atan(mouseYInCoord/mouseXInCoord);
                if (mouseXInCoord < 0) {
                    angle = Math.PI + angle;
                }
            }
            var cos = Math.cos(angle)*background.width/2;
            var sin = Math.sin(angle)*background.height/2;
            if (cos > 0) {
                targetX = Math.min(mouseX, width/2 + cos);
            } else {
                targetX = Math.max(mouseX, width/2 + cos);
            }

            if (sin > 0) {
                targetY = Math.max(mouseY, height/2 - sin);
            } else {
                targetY = Math.min(mouseY, height/2 - sin);
            }

            var point = valueFromPoint(targetX, targetY);

            if (mouseArea.pressed) {
                var changed = (xRange.value !== point.x || yRange.value !== point.y);
                xRange.value = point.x;
                yRange.value = point.y;
                control.positionX = targetX / width;
                control.positionY = targetY / height;

                if (changed)
                    control.valueChanged();
            }
            mouseXRange.value = point.x;
            mouseYRange.value = point.y;
        }

        onPositionChanged: {
            updateTargetPosition();
        }
        onPressed: {
            updateTargetPosition();
        }

        onReleased: {
            if (boundEnabled) {
                resetCenter();
            }
        }
    }

    onBoundEnabledChanged: {
        resetCenter();
    }

    function resetCenter() {
        var xTarget = root.from + (root.to - root.from)/2;
        var yTarget = xRange.value;
        var changed = (xRange.value !== xTarget || yRange.value !== yTarget);

        control.positionX = 0.5;
        control.positionY = 0.5;
        xRange.value = root.from + (root.to - root.from)/2
        yRange.value = xRange.value;

        if (changed)
            control.valueChanged();
    }

    function bound(val) { return Math.max(root.from, Math.min(root.to, val)); }

    function valueFromPoint(x, y)
    {
        //        var yy = height / 2.0 - y;
        //        var xx = x - width / 2.0;
        //        var angle = (xx || yy) ? Math.atan2(yy, xx) : 0;

        //        if (angle < Math.PI/ -2)
        //            angle = angle + Math.PI * 2;

        //        var range = control.to - control.from;
        //        var value;
        //        value = (control.from + range * (Math.PI * 4 / 3 - angle) / (Math.PI * 10 / 6));

        var yy = background.height - y;
        var xx = x;

        var range = control.to - control.from;
        var xValue = (control.from + range * xx / background.width);
        var yValue = (control.from + range * yy / background.height);

        return Qt.point(bound(xValue), bound(yValue));
    }

}
