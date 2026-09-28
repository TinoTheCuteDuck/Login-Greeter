import QtQuick

Item {
    id: powerButtons
    anchors.fill: parent

    opacity: 0

    NumberAnimation {
        id: fadeOut
        target: powerButtons
        property: "opacity"
        from: 1
        to: 0
        duration: 500
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
        target: powerButtons
        property: "opacity"
        from: 0
        to: 1
        duration: 500
        easing.type: Easing.InOutSine
    }

    Timer {
        id: reveal
        interval: 5500
        running: false
        repeat: false
        
        onTriggered: {
            fadeInOut.play()
            fadeIn.start()
        }
    }

    Component.onCompleted: {
        reveal.start()
    }

    Rectangle {
        id: powerButton
        anchors.centerIn: parent
        anchors.verticalCenterOffset: parent.height * 0.44
        anchors.horizontalCenterOffset: -parent.width * 0.03
        width: 0.04 * screenScale
        height: 0.04 * screenScale

        color: Colors.background_main
        opacity: 0.8
        radius: 0.007 * screenScale
        scale: hovered ? 1.05 : 1

        property bool hovered: false

        border {
            color: hovered ? Colors.accent : Colors.border
            width: 3
        }

        Text {
            anchors.centerIn: parent
            color: Colors.foreground
            text: "⏻"

            font {
                family: "JetBrainsMono Nerd Font Mono"
                pixelSize: 0.035 * screenScale
                bold: true 
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: powerButton.hovered = true
            onExited: powerButton.hovered = false
            onPressed:  {
                clickSound.play()
                Backend.shutdown()
            }
        }

        Behavior on border.color {
            ColorAnimation {duration: 200}
        }

        Behavior on scale {
            NumberAnimation {duration: 200}
        }
    }

    Rectangle {
        id: restartButton
        anchors.centerIn: parent
        anchors.verticalCenterOffset: parent.height * 0.44
        anchors.horizontalCenterOffset: parent.width * 0.03
        width: 0.04 * screenScale
        height: 0.04 * screenScale

        color: Colors.background_main
        opacity: 0.8
        radius: 0.007 * screenScale
        scale: hovered ? 1.05 : 1

        property bool hovered: false

        border {
            color: hovered ? Colors.accent : Colors.border
            width: 3
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: restartButton.hovered = true
            onExited: restartButton.hovered = false
            onPressed: {
                clickSound.play()
                Backend.restart()
            }
        }

        Text {
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: screenScale * 0.004
            color: Colors.foreground
            rotation: 90
            text: "↻"

            font {
                family: "JetBrainsMono Nerd Font Mono"
                pixelSize: 0.035 * screenScale
                bold: true 
            }
        }

        Behavior on border.color {
            ColorAnimation {duration: 200}
        }

        Behavior on scale {
            NumberAnimation {duration: 200}
        }
    }
}