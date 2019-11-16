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

import QtQuick 2.12
import QtQuick.Controls 1.4

ShaderEffect {
    id: root
    property variant source
    property ListModel parameters: ListModel { }
    property bool divider: true
    property real dividerValue: 1
    property real targetWidth: 0
    property real targetHeight: 0
    property string fragmentShaderFilename
    property string vertexShaderFilename
    property bool is_show_setting: true

    QtObject {
        id: d
        property string fragmentShaderCommon: "
            #ifdef GL_ES
                precision mediump float;
            #else
            #   define lowp
            #   define mediump
            #   define highp
            #endif // GL_ES
        "
    }

    // The following is a workaround for the fact that ShaderEffect
    // doesn't provide a way for shader programs to be read from a file,
    // rather than being inline in the QML filef

    onFragmentShaderFilenameChanged: {
        sys_manager.file_reader.setSource(fragmentShaderFilename);
        var shader = sys_manager.file_reader.read();
        if (shader.length > 0)
            fragmentShader = d.fragmentShaderCommon + sys_manager.file_reader.read();
    }
    onVertexShaderFilenameChanged: {
        sys_manager.file_reader.setSource(vertexShaderFilename);
        var shader = sys_manager.file_reader.read();
        if (shader.length > 0)
            vertexShader = shader;

    }

    Rectangle {
        id: parameters_rect
        anchors.margins: 1
        color: "transparent"
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: parameters_listview.count * 30

        ListView {
            id: parameters_listview
            anchors.fill: parent
            visible: is_show_setting
            model: parameters
            //        contentHeight: 50
            //        contentWidth: 200
            verticalLayoutDirection: ListView.BottomToTop
            delegate: Rectangle{
                height: 30
                anchors.left: parent.left
                anchors.right: parent.right
                color: "transparent"

                Rectangle {
                    anchors.fill: parent
                    color: "white"
                    opacity: 0.6
                }

                Text {
                    id: parameter_name
                    anchors.left: parent.left
                    font.pixelSize: 15
                    font.family: theme_font
                    text: name
                    anchors.verticalCenter: parent.verticalCenter
//                    width: 70
                }


                Slider {
                    value: model.value
                    anchors.left: parameter_name.right
                    anchors.leftMargin: 2
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    onValueChanged: {
                        parameters.setProperty(index, "value", value);
                    }
                }
            }
        }
    }

}
