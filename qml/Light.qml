import QtQuick
import QtQuick.Shapes
import MainQML

Shape {
    id: glow
    property real lightSize: 100
    property real xPosition: 50
    property real yPosition: 50
    property color lightColor: Colors.cyan
    property real driftRange: lightSize * 1.5
    property real scaleRange: 2
    property real xOffset: 0
    property real yOffset: 0
    property real lightOpacity: 0.8
    property int animationDelay: 5000 + Math.random() * 10000

    width: lightSize
    height: lightSize
    opacity: 0

    x: xPosition + xOffset
    y: yPosition + yOffset

    NumberAnimation {
        id: fadeOut
        target: glow
        property: "opacity"
        from: 1
        to: 0
        duration: 3000
        easing.type: Easing.InOutSine
    }

    Connections {
        target: root
        function onShuttingOffTriggered() {
            if (root.shuttingOff) {
                fadeOut.start()
            }
        }
    }

    NumberAnimation {
        id: fadeIn
        target: glow
        property: "opacity"
        to: 1
        duration: 2000
        easing.type: Easing.InOutSine
    }

    Component.onCompleted: {
        fadeIn.start()
    }

    NumberAnimation {
        id: changeSize
        target: glow
        property: "scale"
        duration: animationDelay
        easing.type: Easing.InOutSine
    }

    NumberAnimation {
        id: moveX
        target: glow
        property: "xOffset"
        duration: animationDelay
        easing.type: Easing.InOutSine
    }

    NumberAnimation {
        id: moveY
        target: glow
        property: "yOffset"
        duration: animationDelay
        easing.type: Easing.InOutSine
    }

    Timer {
        interval: animationDelay
        running: true
        repeat: true

        onTriggered: {
            moveX.to = Math.random() * driftRange * 2 - driftRange
            moveY.to = Math.random() * driftRange * 2 - driftRange
            changeSize.to = 1.0 + (Math.random() * (scaleRange - 1.0))

            moveX.restart()
            moveY.restart()
            changeSize.restart()
        }

        Component.onCompleted: {
            triggered()
        }
    }

    ShapePath {
        fillGradient: RadialGradient {
            centerX: lightSize * 0.5
            centerY: lightSize * 0.5
            centerRadius: lightSize * 0.5
            focalX: centerX
            focalY: centerY

            GradientStop {
                position: 0.0
                color: Qt.rgba(
                    lightColor.r,
                    lightColor.g,
                    lightColor.b,
                    lightOpacity
                )
            }

            GradientStop {
                position: 0.5
                color: Qt.rgba(
                    lightColor.r,
                    lightColor.g,
                    lightColor.b,
                    lightOpacity * 0.64
                )
            }

            GradientStop {
                position: 1.0
                color: "transparent"
            }
        }
        strokeColor: "transparent"

        PathLine {
            x: lightSize
            y: 0
        }

        PathLine {
            x: lightSize
            y: lightSize
        }

        PathLine {
            x: 0
            y: lightSize
        }

        PathLine {
            x: 0
            y: 0
        } 
    }
}