import QtQuick 2.0
import QtQuick.Controls 2.5
import MyModules 1.0
import "."

Slider {
    id: root
    snapMode: Slider.SnapAlways
    touchDragThreshold: g_settings.applyHScale(100)
    hoverEnabled: true
    height: g_settings.applyHScale(16)
    width: g_settings.applyHScale(120)
    pressed: slider_mouse.pressed /*|| keys_pressed*/
    property color color1: appTheme.lineColor
    property color color2: appTheme.mainColor
    property real mouseValue:
    {
        return Math.max(from,
                        Math.min(to,
                                 (root.from + root.stepSize
                                  * mytools.math_trunc(
                                      step_count * (slider_mouse.mouseX - root.leftPadding) /
                                      (root.width - root.leftPadding -root.rightPadding)
                                      )
                                  ).toFixed(step_decimals)
                                 )
                        )
    }
    property int step_decimals:{
        var stepSize_str = "" + stepSize;
        (stepSize_str.indexOf(".")<0?
             0:(stepSize_str.length -
                stepSize_str.indexOf(".") - 1))
    }
    property int step_count: mytools.math_trunc((root.to - root.from) / root.stepSize);
    leftPadding: handle.width/2
    rightPadding: handle.width/2
    topPadding: 0
    bottomPadding: 0
    background: Rectangle {
        x: root.leftPadding
        y: root.topPadding + root.height / 2 - height / 2
        width: root.width - root.leftPadding -root.rightPadding
        height: root.height/4
        radius: height/2
        color: color1

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: handle.x + handle.width/2
            height: parent.height*1.5 + border.width
            color: color2
            radius: height/2
            //            border.width: g_settings.applyVScale(1)
            //            border.color: appTheme.bgColor
        }
    }

    handle: Item {
        x: root.leftPadding + root.visualPosition * (root.width - root.leftPadding -root.rightPadding)
           - width/2
        y: root.topPadding + root.height / 2 - height / 2
        width: root.height
        height: root.height

        MyRipple {
            pressed: slider_mouse.pressed
            active: slider_mouse.pressed || slider_mouse.containsMouse
        }

        Rectangle {
            id: circle
            anchors.fill: parent
            color: (slider_mouse.pressed||slider_mouse.containsMouse)?color2:color1
            radius: width/2
            scale: slider_mouse.pressed ? 1.3 : 1

            Behavior on scale {
                NumberAnimation {
                    duration: 250
                }
            }
            layer.effect: MyDropShadow {
            }

            layer.enabled: !(slider_mouse.pressed || slider_mouse.containsMouse)
        }

    }
    MyMouseArea {
        id: slider_mouse
        hoverEnabled: true
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onPositionChanged: {
            if (pressed) {
                root.value = mouseValue
            }
        }
        onWheel: {
            if (wheel.angleDelta.y > 0)
                increase();
            else
                decrease();
        }
        onContainsMouseChanged: {
            if (containsMouse) {
                focus_on(root);
            }
        }
    }

    onPressedChanged: {
        if (pressed) {
            root.value = mouseValue;
        }
    }

    Keys.onPressed: {
        switch (event.key) {
        case Qt.Key_Left:
            decrease();
            break;
        case Qt.Key_Right:
            increase();
            break;
        }
        event.accepted = true;
    }
}

