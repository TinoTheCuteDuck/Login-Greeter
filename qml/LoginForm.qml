import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import MainQML

Item {
    id: loginForm
    anchors.fill: parent
    focus: true

    Keys.onUpPressed: {
        username.focus = true
        password.focus = false
    }

    Keys.onDownPressed: {
        password.focus = true
        username.focus = false
    }

    NumberAnimation {
        id: fadeOut
        target: loginForm
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

    MouseArea {
        anchors.fill: parent
        z: -1

        onClicked: {
            username.focus = false
            password.focus = false
            loginForm.focus = true
        }
    }

    Text {
        id: loginText
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: parent.height * 0.6
        color: Colors.foreground
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        width: 0.35 * parent.width
        opacity: 0

        property string pendingText: ""
        property bool pendingSuccess: false

        font {
            family: "JetBrainsMono Nerd Font Mono"
            pixelSize: 0.015 * screenScale
            bold: true
        }

        Behavior on opacity {
            NumberAnimation{duration: 200}
        }
    }

    Timer {
        id: updateTextTimer
        interval: 200
        running: false
        repeat: false
        
        onTriggered: {
            if (loginText.pendingSuccess) {
                successSound.play()
                loginText.color = Colors.cyan
                root.shuttingOff = true                
            } else {
                loginText.color = Colors.magenta
                errorSound.play()
            }
            loginText.text = loginText.pendingText
            loginText.opacity = 1
        }
    }

    Connections {
        target: Backend
        function onLoginFinished(text) {
            loginText.pendingText = text
            loginText.pendingSuccess = text.includes("Success")
            loginText.opacity = 0
            updateTextTimer.start()
            userInput.locked = false
            passwordInput.locked = false
        }
    }

    Rectangle {
        id: userInput
        width: parent.width * 0.18
        height: parent.height * 0.05
        anchors.centerIn: parent
        color: Colors.background_main
        opacity: locked ? 0.5 : 0.8
        radius: screenScale * 0.007

        NumberAnimation {
            id: fadeInUserInput
            target: userInput
            property: "opacity"
            from: 0
            to: 0.8
            duration: 500
            easing.type: Easing.InOutSine

            onFinished: {
                userInput.opacity = Qt.binding(function() { 
                    return userInput.locked ? 0.5 : 0.8 
                })
            }
        }

        Timer {
            id: revealUserInput
            interval: 4500
            running: false
            repeat: false
            
            onTriggered: {
                fadeInUserInput.start()
            }
        }

        Component.onCompleted: {
            usernameOpacityBehavior.enabled = false
            opacity = 0
            revealUserInput.start()
            usernameOpacityBehavior.enabled = true
        }

        property bool hovered: false
        property bool locked: false

        scale: username.activeFocus && !locked || hovered && !password.activeFocus && !locked ? 1.05 : 1

        border {
            color: username.activeFocus && !userInput.locked|| hovered && !password.activeFocus && !userInput.locked ? Colors.accent : Colors.border
            width: 3
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: userInput.hovered = true
            onExited: userInput.hovered = false
        }

        TextField {
            id: username
            anchors.fill: parent
            leftPadding: parent.width * 0.04
            rightPadding: parent.width * 0.04
            placeholderText: "Username"
            placeholderTextColor: Colors.foreground
            color: Colors.foreground
            background: null
            hoverEnabled: false
            readOnly: userInput.locked ? true : false
            focus: false

            property string previousUser: Backend.getLastUser()
            property bool previousUserEntered: false
            
            Component.onCompleted: {
                if (previousUser.length > 0) {
                    username.previousUserEntered = true
                    username.text = previousUser
                    password.focus = true
                    username.previousUserEntered = false
                } else {
                    username.focus = true
                }
            }

            Timer {
                id: userBlinkDelayTimer
                interval: 500
                running: false

                onTriggered: {
                    userCursorVisual.shouldBlink = true
                }
            }

            onTextChanged: {
                if (!username.previousUserEntered) {
                    typeSound.play()
                }
                userBlinkDelayTimer.restart()
                userCursorVisual.shouldBlink = false
                userCursorVisual.opacity = 1
            }

            Rectangle {
                id: userCursorVisual
                width: 2
                height: username.font.pixelSize
                anchors.verticalCenter: parent.verticalCenter
                color: Colors.foreground

                property bool shouldBlink: false

                Behavior on x {
                    NumberAnimation { duration: 100 }
                }

                Behavior on opacity {
                    NumberAnimation { duration: 200 }
                }

                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    running: username.activeFocus && userCursorVisual.shouldBlink

                    NumberAnimation { duration: 1000; from: 1; to: 0; easing.type: Easing.InOutQuad; }
                    NumberAnimation { duration: 1000; from: 0; to: 1; easing.type: Easing.InOutQuad; }
                }

                Connections {
                    target: username
                    function onActiveFocusChanged() {
                        if (username.activeFocus) {
                            userCursorVisual.opacity = 1
                            userCursorVisual.shouldBlink = true
                        } else {
                            userCursorVisual.opacity = 0
                            userCursorVisual.shouldBlink = false
                        }
                    }
                }

                Component.onCompleted: {
                    x = username.leftPadding
                    opacity = username.activeFocus ? 1 : 0
                    shouldBlink = username.activeFocus ? true : false
                }
            }

            cursorDelegate: Item {
                onXChanged: {
                    userCursorVisual.x = x
                }
            }

            Keys.onReturnPressed: {
                clickSound.play()
                focus = false
                password.focus = true
            }

            font {
                family: "JetBrainsMono Nerd Font Mono"
                pixelSize: 0.013 * screenScale
                bold: true
            }
        }


        Behavior on border.color {
            ColorAnimation {duration: 200}
        }

        Behavior on opacity {
            id: usernameOpacityBehavior
            NumberAnimation {duration: 200}
        }

        Behavior on scale {
            NumberAnimation {duration: 200}
        }
    }

    Rectangle {
        id: passwordInput
        width: parent.width * 0.18
        height: parent.height * 0.05
        anchors.centerIn: parent
        anchors.verticalCenterOffset: parent.height * 0.06
        color: Colors.background_main
        opacity: locked ? 0.5 : 0.8
        radius: screenScale * 0.007

        NumberAnimation {
            id: fadeInPasswordInput
            target: passwordInput
            property: "opacity"
            from: 0
            to: 0.8
            duration: 500
            easing.type: Easing.InOutSine

            onFinished: {
                passwordInput.opacity = Qt.binding(function() { 
                    return passwordInput.locked ? 0.5 : 0.8 
                })
            }
        }

        Timer {
            id: revealPasswordInput
            interval: 5000
            running: false
            repeat: false
            
            onTriggered: {
                fadeInPasswordInput.start()
            }
        }

        Component.onCompleted: {
            passwordOpacityBehavior.enabled = false
            opacity = 0
            revealPasswordInput.start()
            passwordOpacityBehavior.enabled = true
        }

        property bool hovered: false
        property bool locked: false

        scale: password.activeFocus && !locked|| hovered && !username.activeFocus && !locked ? 1.05 : 1

        border {
            color: password.activeFocus && !passwordInput.locked || hovered && !username.activeFocus && !passwordInput.locked ? Colors.accent : Colors.border
            width: 3
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: passwordInput.hovered = true
            onExited: passwordInput.hovered = false
        }

        TextField {
            id: password
            anchors.fill: parent
            leftPadding: parent.width * 0.04
            rightPadding: parent.width * 0.04
            placeholderText: "Password"
            placeholderTextColor: Colors.foreground
            color: Colors.foreground
            background: null
            hoverEnabled: false
            echoMode: TextInput.Password
            readOnly: passwordInput.locked ? true : false
            passwordCharacter: "⦁"

            Keys.onReturnPressed: {
                clickSound.play()
                if (passwordInput.locked == true) {
                    return;
                }
                loginText.opacity = 0
                focus = false
                Backend.login(username.text, password.text)
                Backend.saveLastUser(username.text)
                userInput.locked = true
                passwordInput.locked = true
                loginForm.focus = true
            }

            Timer {
                id: passwordBlinkDelayTimer
                interval: 500
                running: false

                onTriggered: {
                    passwordCursorVisual.shouldBlink = true
                }
            }

            onTextChanged: {
                typeSound.play()
                passwordBlinkDelayTimer.restart()
                passwordCursorVisual.shouldBlink = false
                passwordCursorVisual.opacity = 1
            }

            Rectangle {
                id: passwordCursorVisual
                width: 2
                height: password.font.pixelSize
                anchors.verticalCenter: parent.verticalCenter
                color: Colors.foreground

                property bool shouldBlink: false

                Behavior on x {
                    NumberAnimation { duration: 100 }
                }

                Behavior on opacity {
                    NumberAnimation { duration: 200 }
                }

                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    running: password.activeFocus && passwordCursorVisual.shouldBlink

                    NumberAnimation { duration: 1000; from: 1; to: 0; easing.type: Easing.InOutQuad; }
                    NumberAnimation { duration: 1000; from: 0; to: 1; easing.type: Easing.InOutQuad; }
                }

                Connections {
                    target: password
                    function onActiveFocusChanged() {
                        if (password.activeFocus) {
                            passwordCursorVisual.opacity = 1
                            passwordCursorVisual.shouldBlink = true
                        } else {
                            passwordCursorVisual.opacity = 0
                            passwordCursorVisual.shouldBlink = false
                        }
                    }
                }

                Component.onCompleted: { 
                    x = password.leftPadding
                    opacity = password.activeFocus ? 1 : 0
                    shouldBlink = password.activeFocus ? true : false
                }
            }

            cursorDelegate: Item {
                onXChanged: {
                    passwordCursorVisual.x = x
                }
            }
            
            font {
                family: "JetBrainsMono Nerd Font Mono"
                pixelSize: 0.013 * screenScale
                bold: true
            }
        }

        Behavior on border.color {
            ColorAnimation {duration: 200}
        }

        Behavior on opacity {
            id: passwordOpacityBehavior
            NumberAnimation {duration: 200}
        }

        Behavior on scale {
            NumberAnimation {duration: 200}
        }
    }

    Item {
        id: greetMaskContainer

        width: greetingName.width
        height: greetingName.height
        visible: false
    }

    Component {
        id: greetRectComponent
        Rectangle {
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#ffffffff" }
                GradientStop { position: 1.0; color: "#ffffffff" }
            }
            opacity: 1
        }
    }

    Text {
        id: greetingName
        color: Colors.magenta
        anchors.centerIn: parent
        anchors.verticalCenterOffset: parent.height * -0.09
        horizontalAlignment: Text.AlignHCenter

        NumberAnimation {
            id: fadeInGreetingName
            target: greetingName
            property: "opacity"
            from: 0
            to: 1
            duration: 500
            easing.type: Easing.InOutSine
        }

        Timer {
            id: revealGreetingName
            interval: 4000
            running: false
            repeat: false
            
            onTriggered: {
                fadeInGreetingName.start()
            }
        }

        Component.onCompleted: {
            opacity = 0
            revealGreetingName.start()
        }

        Connections {
            target: username
            function onTextChanged() {
                let greetingLength = greetingName.text.length
                let usernameLength = username.text.length
                let charLength = greetingName.font.pixelSize * 0.6

                if (greetingLength < usernameLength) {
                    greetingName.text = username.text

                    for (let i = greetingLength; i < usernameLength; i++) {
                        let rect = greetRectComponent.createObject(greetMaskContainer, {
                            x: i * charLength,
                            width: charLength,
                            height: greetingName.contentHeight
                        })

                        let anim = Qt.createQmlObject(`
                            import QtQuick

                            NumberAnimation {
                                property: "opacity"
                                from: 1
                                to: 0
                                duration: 200
                            }
                        `, rect)
                        anim.target = rect

                        anim.finished.connect(function() {
                            rect.destroy()
                            anim.destroy()
                        })
                        
                        anim.start()
                    }
                } else if (greetingLength > usernameLength) {
                    for (let i = greetingLength - 1; i >= usernameLength; i--) {
                        let rect = greetRectComponent.createObject(greetMaskContainer, {
                            x: i * charLength,
                            width: charLength,
                            height: greetingName.contentHeight,
                            opacity: 0
                        })

                        let anim = Qt.createQmlObject(`
                            import QtQuick

                            NumberAnimation {
                                property: "opacity"
                                from: 0
                                to: 1
                                duration: 200
                            }
                        `, rect)
                        anim.target = rect

                        anim.finished.connect(function() {
                            rect.destroy()
                            anim.destroy()
                            greetingName.text = username.text
                        })
                        
                        anim.start()
                    }
                } else {
                    greetingName.text = username.text
                }
            }
        }
        font {
            family: "JetBrainsMono Nerd Font Mono"
            pixelSize: 0.03 * screenScale
            bold: true
        }

        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: greetMaskContainer
            invert: true
        }
    }    
}