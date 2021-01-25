/****************************************************************************
**
** Copyright (C) 2016 The Qt Company Ltd.
** Contact: https://www.qt.io/licensing/
**
** This file is part of the Qt Mobility Components.
**
** $QT_BEGIN_LICENSE:BSD$
** Commercial License Usage
** Licensees holding valid commercial Qt licenses may use this file in
** accordance with the commercial license agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and The Qt Company. For licensing terms
** and conditions see https://www.qt.io/terms-conditions. For further
** information use the contact form at https://www.qt.io/contact-us.
**
** BSD License Usage
** Alternatively, you may use this file under the terms of the BSD license
** as follows:
**
** "Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are
** met:
**   * Redistributions of source code must retain the above copyright
**     notice, this list of conditions and the following disclaimer.
**   * Redistributions in binary form must reproduce the above copyright
**     notice, this list of conditions and the following disclaimer in
**     the documentation and/or other materials provided with the
**     distribution.
**   * Neither the name of The Qt Company Ltd nor the names of its
**     contributors may be used to endorse or promote products derived
**     from this software without specific prior written permission.
**
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
** "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
** A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
** OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
** LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
** DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
** THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
** OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
**
** $QT_END_LICENSE$
**
****************************************************************************/

// Based on http://www.geeks3d.com/20100909/shader-library-gaussian-blur-post-processing-filter-in-glsl/

import QtQuick 2.12
import QtQuick.Controls 2.5
import MyModules 1.0
import "../../Library/Modules"

Item {
    id: root
    property bool divider: true
    property real dividerValue: 1
    property string fragmentShaderFilename: ""
    property string vertexShaderFilename: ""
    property bool is_show_setting: true
    property var tips_component: undefined
    property var appTheme

    property ListModel parameters: ListModel {
        ListElement {
            name: "Radius"
            value: 0.5
        }
        onDataChanged: updateBlurSize()
    }

    function updateBlurSize()
    {
        if ((targetHeight > 0) && (targetWidth > 0))
        {
            verticalBlurSize = 4.0 * parameters.get(0).value / targetHeight;
            horizontalBlurSize = 4.0 * parameters.get(0).value / targetWidth;
        }
    }

    property alias targetWidth: verticalShader.targetWidth
    property alias targetHeight: verticalShader.targetHeight
    property alias source: verticalShader.source
    property alias horizontalBlurSize: horizontalShader.blurSize
    property alias verticalBlurSize: verticalShader.blurSize


    Effect {
        id: verticalShader
        anchors.fill:  parent
        dividerValue: parent.dividerValue
        property real blurSize: 0.0

        onTargetHeightChanged: {
            updateBlurSize()
        }
        onTargetWidthChanged: {
            updateBlurSize()
        }
        fragmentShaderFilename: root.fragmentShaderFilename + "gaussianblur_v.fsh"
    }

    Effect {
        id: horizontalShader
        anchors.fill: parent
        dividerValue: parent.dividerValue
        property real blurSize: 0.0
        fragmentShaderFilename: root.fragmentShaderFilename + "gaussianblur_h.fsh"
        source: horizontalShaderSource

        ShaderEffectSource {
            id: horizontalShaderSource
            sourceItem: verticalShader
            smooth: true
            hideSource: true
        }
    }
    Rectangle {
        id: parameters_rect
        anchors.margins: 1
        anchors.fill: parent
        color: "transparent"

        ListView {
            id: parameters_listview
            anchors.fill: parent
            visible: is_show_setting
            model: parameters
            //        contentHeight: 50
            //        contentWidth: 200
            interactive: false
            verticalLayoutDirection: ListView.BottomToTop
            delegate: Rectangle {
                id: parameter_rect
                height: 30
                anchors.left: parent.left
                anchors.right: parent.right
                color: "transparent"

                Loader {
                    sourceComponent: root.tips_component
                    active: parameter_slider.pressed ||
                            parameter_slider.hovered
                    onLoaded: {
                        item.parent = parameter_rect;
                        item.text = Qt.binding(function(){
                            return model.name + ":" + model.value.toFixed(2);
                        });
                        item.delay = 0;
                        item.visible = true;
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    color: appTheme.bgColor
                    opacity: 0.6
                }

                MySlider {
                    id: parameter_slider
                    stepSize: 0.01
                    value: model.value
                    anchors {
                        left: parent.left
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                    }
                    onValueChanged: {
                        parameters.setProperty(index, "value", value);
                    }
                }
            }
        }
    }

}

