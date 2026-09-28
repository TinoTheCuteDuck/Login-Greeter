import QtQuick
import QtQuick.Effects
import MainQML

Item {
    id: background
    anchors.fill: parent
    opacity: 0

    NumberAnimation {
        id: fadeOut
        target: background
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
        target: background
        property: "opacity"
        from: 0
        to: 1
        duration: 1000
        easing.type: Easing.InOutSine
    }

    Timer {
        id: reveal
        interval: 1500
        running: false
        repeat: false
        
        onTriggered: {
            fadeIn.start()
        }
    }

    Component.onCompleted: {
        reveal.start()
    }
    
    Image {
        id: image
        anchors.fill: parent
        source: "qrc:/qt/qml/MainQML/assets/background.png"
    }

    ShaderEffectSource {
        id: blurMask
        height: parent.height
        width: parent.width
        anchors.centerIn: parent
        sourceItem: image
        sourceRect: Qt.rect(x, y, width, height)
        visible: true
    }

    MultiEffect {
        height: parent.height
        width: parent.width
        anchors.centerIn: parent
        source: blurMask
        blurEnabled: true
        autoPaddingEnabled: false
        blur: 1.0
        blurMax: 48
        visible: true
    }

    Rectangle {
        anchors.fill: parent
        color: Colors.background_dark
        opacity: 0.15
    }
}