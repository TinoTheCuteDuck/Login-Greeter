import QtQuick
import MainQML

Rectangle {
    id: middle
    anchors.centerIn: parent
    height: parent.height
    width: 0.4 * parent.width
    border {
        width: 2
        color: Colors.border
    }

    opacity: 0

    NumberAnimation {
        id: fadeOut
        target: middle
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
        target: middle
        property: "opacity"
        from: 0
        to: 1
        duration: 500
        easing.type: Easing.InOutSine
    }

    Timer {
        id: reveal
        interval: 2500
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

    gradient: Gradient {
        GradientStop {
            position: 0
            color: Qt.rgba(
                Colors.tertiary.r,
                Colors.tertiary.g,
                Colors.tertiary.b,
                0.8
            )
        }

        GradientStop {
            position: 0.8
            color: Qt.rgba(
                Colors.background_main.r,
                Colors.background_main.g,
                Colors.background_main.b,
                0.4
            )
        }
    }
}