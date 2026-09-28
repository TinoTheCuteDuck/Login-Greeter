import QtQuick
import MainQML
import QtMultimedia

Window {
    id: root
    width: 1920
    height: 1080
    visible: true
    visibility: Window.FullScreen
    title: qsTr("LoginGreeter")
    color: "black"
    opacity: 0

    property real screenScale: Math.sqrt(width * width + height * height)
    property bool shuttingOff: false

    signal shuttingOffTriggered()

    Timer {
        id: fadeAllOut
        interval: 1000
        running: false
        repeat: false

        onTriggered: {
            fadeInOut.play()
            shuttingOffTriggered()
        }
    }
    
    onShuttingOffChanged: {
        if (shuttingOff) {
            Backend.startSession()
            fadeAllOut.start()
        }
    }

    MediaPlayer {
        id: backgroundMusic
        source: "qrc:/qt/qml/MainQML/assets/background-ambient.wav"
        audioOutput: AudioOutput {
            volume: 0.04
        }
        loops: MediaPlayer.Infinite
    }

    SoundEffect {
        id: typeSound
        source: "qrc:/qt/qml/MainQML/assets/typing.wav"
        volume: 0.15
    }

    SoundEffect {
        id: fadeInOut
        source: "qrc:/qt/qml/MainQML/assets/fadeInOut.wav"
        volume: 0.4
    }

    SoundEffect {
        id: errorSound
        source: "qrc:/qt/qml/MainQML/assets/error.wav"
        volume: 0.6
    }

    SoundEffect {
        id: successSound
        source: "qrc:/qt/qml/MainQML/assets/success.wav"
        volume: 0.2
    }

    SoundEffect {
        id: clickSound
        source: "qrc:/qt/qml/MainQML/assets/click.wav"
        volume: 0.1
    }

    Component.onCompleted: {
        backgroundMusic.play()
    }

    Background{}
    MiddleSection{}
    Lights{}
    Clock{}
    Greeting{}
    LoginForm{}
    PowerButtons{}
}