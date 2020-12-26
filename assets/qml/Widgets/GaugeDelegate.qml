/*
 * Copyright (c) 2020 Alex Spataru <https://github.com/alex-spataru>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import QtQuick 2.12
import QtQuick.Controls 2.12

Rectangle {
    id: gauge

    //
    // Custom properties
    //
    property string title: ""
    property int lastNumber: 8
    property int firstNumber: 0
    property real numberSize: 18
    property real currentValue: 0
    property real maximumValue: 0
    property real minimumValue: 0
    property real indicatorWidth: 4
    property bool maximumVisible: true
    property bool minimumVisible: true
    property bool currentVisible: true
    property bool numbersVisible: true
    property bool valueLabelVisible: true

    //
    // Colors
    //
    property color valueColor: Qt.rgba(142/255, 205/255, 157/255, 1)
    property color titleColor: Qt.rgba(81/255, 116/255, 151/255, 1)
    property color numbersColor: Qt.rgba(230/255, 224/255, 178/255, 1)
    property color indicatorColor: Qt.rgba(230/255, 224/255, 178/255, 1)
    property color indicatorMaxColor: Qt.rgba(215/255, 45/255, 96/255, 1)
    property color indicatorMinColor: Qt.rgba(45/255, 96/255, 115/255, 1)

    //
    // Redraw indicators automatically
    //
    onCurrentValueChanged: indicatorCanvas.requestPaint()

    //
    // Animations
    //
    Behavior on minimumValue {NumberAnimation{}}
    Behavior on maximumValue {NumberAnimation{}}
    Behavior on currentValue {NumberAnimation{}}

    //
    // Properties
    //
    border.width: 2
    radius: width / 2
    color: Qt.rgba(18 / 255, 18 / 255, 24 / 255, 1)
    border.color: Qt.rgba(230/255, 224/255, 178/255, 1)

    //
    // Redraw numbers automatically
    //
    onWidthChanged: numbersCanvas.requestPaint()
    onHeightChanged: numbersCanvas.requestPaint()

    //
    // Label
    //
    Label {
        font.pixelSize: 14
        text: gauge.title
        color: gauge.titleColor
        anchors.centerIn: parent
        font.family: app.monoFont
        anchors.verticalCenterOffset: 32
    }

    //
    // Value label
    //
    Label {
        font.pixelSize: 14
        color: gauge.valueColor
        anchors.centerIn: parent
        font.family: app.monoFont
        visible: gauge.valueLabelVisible
        anchors.verticalCenterOffset: 56
        text: gauge.currentValue.toFixed(3)
    }

    //
    // Numbers painter
    //
    Canvas {
        opacity: 0.8
        id: numbersCanvas
        anchors.fill: parent
        Component.onCompleted: requestPaint()
        onPaint: {
            var ctx = getContext('2d')
            ctx.reset()

            if (!gauge.numbersVisible)
                return

            var range = lastNumber - firstNumber
            for (var i = 0; i <= range; ++i) {
                var radius = Math.min(gauge.width, gauge.height) / 2

                var startupTheta = -180
                var theta = (startupTheta + i * 360 / (range + 1)) * (Math.PI / 180)
                var dX = (radius - gauge.numberSize) * Math.cos(theta) + radius - gauge.numberSize / 2
                var dY = (radius - gauge.numberSize) * Math.sin(theta) + radius + gauge.numberSize / 2

                ctx.font = "bold " + gauge.numberSize + "px " + app.monoFont
                ctx.fillStyle = gauge.indicatorColor
                ctx.fillText(i + firstNumber, dX, dY)

                if (i === range) {
                    var x = radius
                    var y = radius
                    var spacing = 10 * Math.PI / 180.0;
                    var startAngle = theta + spacing
                    var finishAngle = Math.PI - spacing

                    ctx.lineWidth = 2
                    ctx.strokeStyle = gauge.indicatorColor

                    ctx.beginPath();
                    ctx.arc(x, y, radius - (gauge.numberSize + 3), startAngle, finishAngle)
                    ctx.stroke()
                    ctx.beginPath();
                    ctx.arc(x, y, radius - (gauge.numberSize - 3), startAngle, finishAngle)
                    ctx.stroke()
                }
            }
        }
    }

    //
    // Indicator painter
    //
    Canvas {
        id: indicatorCanvas
        anchors.fill: parent
        Component.onCompleted: requestPaint()
        onPaint: {
            var ctx = getContext('2d')

            function drawLineWithArrows(x0,y0,x1,y1,aWidth,aLength){
                var dx=x1-x0;
                var dy=y1-y0;
                var angle=Math.atan2(dy,dx);
                var length=Math.sqrt(dx*dx+dy*dy);

                ctx.translate(x0,y0);
                ctx.rotate(angle);
                ctx.beginPath();
                ctx.moveTo(0,0);
                ctx.lineTo(length,0);

                ctx.moveTo(length-aLength,-aWidth);
                ctx.lineTo(length,0);
                ctx.lineTo(length-aLength,aWidth);

                ctx.stroke();
                ctx.setTransform(1,0,0,1,0,0);
            }

            function drawIndicator(value, color, width, lenGain) {
                var deg = ((Math.min(value, gauge.lastNumber) / (gauge.lastNumber + 1)) * 360) - 180
                var rad = deg * (Math.PI / 180)
                var len = Math.min(gauge.width, gauge.height) * lenGain

                var x = gauge.width / 2
                var y = gauge.height / 2
                var x1 = x + Math.cos(rad) * len
                var y1 = y + Math.sin(rad) * len

                ctx.lineWidth = width
                ctx.strokeStyle = color
                drawLineWithArrows(x, y, x1, y1, width, width * 2)
            }

            ctx.reset()

            if (gauge.maximumVisible)
                drawIndicator(gauge.maximumValue, gauge.indicatorMaxColor, gauge.indicatorWidth * 0.8, 0.20)

            if (gauge.minimumVisible)
                drawIndicator(gauge.minimumValue, gauge.indicatorMinColor, gauge.indicatorWidth * 0.8, 0.20)

            if (gauge.currentVisible)
                drawIndicator(gauge.currentValue, gauge.indicatorColor, gauge.indicatorWidth, 0.28)
        }
    }

    //
    // Central gauge
    //
    Rectangle {
        width: 24
        height: 24
        color: "#111"
        radius: width / 2
        anchors.centerIn: parent
        border.color: gauge.indicatorColor
        border.width: gauge.indicatorWidth - 1
    }
}