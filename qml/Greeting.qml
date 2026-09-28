import QtQuick
import MainQML

Item {
    id: greetingItem
    anchors.fill: parent

    opacity: 0

    NumberAnimation {
        id: fadeOut
        target: greetingItem
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
        target: greetingItem
        property: "opacity"
        from: 0
        to: 1
        duration: 500
        easing.type: Easing.InOutSine
    }

    Timer {
        id: reveal
        interval: 3500
        running: false
        repeat: false
        
        onTriggered: {
            fadeIn.start()
        }
    }

    Component.onCompleted: {
        reveal.start()
    }
    
    Text {
        id: greeting
        color: Colors.foreground
        anchors.centerIn: parent
        anchors.verticalCenterOffset: parent.height * -0.16
        horizontalAlignment: Text.AlignHCenter

        text: getGreeting()
        font {
            family: "JetBrainsMono Nerd Font Mono"
            pixelSize: 0.03 * screenScale
            bold: true
        }
    }

    function getGreeting() {
        let hour = new Date().getHours()

        if (hour < 12 && hour > 6)
            return "Good morning"

        if (hour < 18 && hour > 12)
            return "Good afternoon"

        return "Good evening"
    }
}