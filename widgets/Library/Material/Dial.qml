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

import QtQuick 2.12
import QtQuick.Templates 2.12 as T
import QtQuick.Controls.Private 1.0
//import QtQuick.Controls.Material 2.12
//import QtQuick.Controls.Material.impl 2.12
import MyModules 1.0

T.Dial {
    id: control
    property color color: appTheme.mainColor
    property color handleColor: appTheme.mainColor
    property real customScale: 1
    property real mouseValue: mouseRange.value.toFixed(stepDecimals)
    property int stepDecimals:{
        var stepSize_str = "" + stepSize;
        (stepSize_str.indexOf(".")<0?
             0:(stepSize_str.length -
                stepSize_str.indexOf(".") - 1))
    }

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    RangeModel {
        id: mouseRange
        minimumValue: control.from
        maximumValue: control.to
        stepSize: control.stepSize
        value: control.value
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

    handle: SliderHandle {
        x: control.background.x + control.background.width / 2 - control.handle.width / 2
        y: control.background.y + control.background.height / 2 - control.handle.height / 2
        transform: [
            Translate {
                y: -control.background.height * 0.4 + control.handle.height / 2
            },
            Rotation {
                angle: control.angle
                origin.x: control.handle.width / 2
                origin.y: control.handle.height / 2
            }
        ]
//        implicitWidth: g_settings.applyHScale(10)
//        implicitHeight: g_settings.applyVScale(10)

        value: control.value
        handleHasFocus: control.visualFocus
        handlePressed: control.pressed
        handleHovered: control.hovered
    }

    MyMouseArea {
        id: mouseArea
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        parent: control.background.parent
        anchors.fill: parent

        onPositionChanged: {
            mouseRange.value = valueFromPoint(mouseX, mouseY);
        }
        onPressed: {
            mouse.accepted = false;
        }

    }

    onPositionChanged: {
        var range = control.to - control.from;
        var value;
        value = control.from + range * position;

        mouseRange.value = bound(value)
    }

    function bound(val) { return Math.max(root.from, Math.min(root.to, val)); }

    function valueFromPoint(x, y)
    {
        var yy = height / 2.0 - y;
        var xx = x - width / 2.0;
        var angle = (xx || yy) ? Math.atan2(yy, xx) : 0;

        if (angle < Math.PI/ -2)
            angle = angle + Math.PI * 2;

        var range = control.to - control.from;
        var value;
        value = (control.from + range * (Math.PI * 4 / 3 - angle) / (Math.PI * 10 / 6));

        return bound(value)
    }

}
