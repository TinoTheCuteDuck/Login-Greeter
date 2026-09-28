import QtQuick
import MainQML

Item {
    id: dateNTime
    anchors.fill: parent

    opacity: 0

    NumberAnimation {
        id: fadeOut
        target: dateNTime
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
        target: dateNTime
        property: "opacity"
        from: 0
        to: 1
        duration: 500
        easing.type: Easing.InOutSine
    }

    Timer {
        id: reveal
        interval: 3000
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
        id: clock
        color: Colors.foreground
        anchors.centerIn: parent
        anchors.verticalCenterOffset: parent.height * -0.4

        font {
            family: "JetBrainsMono Nerd Font Mono"
            pixelSize: 0.04 * screenScale
            bold: true
        }
    }
    
    Text {
        id: date
        color: Colors.foreground
        anchors.centerIn: parent
        anchors.verticalCenterOffset: parent.height * -0.33

        font {
            family: "JetBrainsMono Nerd Font Mono"
            pixelSize: 0.02 * screenScale
            bold: false
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true

        onTriggered: {
            updateTime()
        }

        Component.onCompleted: {
            triggered()
        }
    }

    function updateTime() {
        let now = new Date()

        clock.text = Qt.formatDateTime(now, "hh:mm")
        date.text = Qt.formatDateTime(now, "dddd, dd MMMM yyyy")
    }
}