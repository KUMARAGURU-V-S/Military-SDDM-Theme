/*
 *  National Investigation Agency (NIA) Tactical SDDM Theme
 *  ────────────────────────────────────────────────────────
 *  State Machine:
 *    - CASE_1: Secure initial login terminal with NIA SVG centerpiece
 *    - CASE_2: Tactical interactive satellite & laser sequence (hook ready for update)
 */

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    width: Screen.width
    height: Screen.height
    color: (typeof config !== "undefined" && config.backgroundColor) ? config.backgroundColor : "#0a0a0a"

    // ═══════════════════════════════════════════
    //  THEME CONFIGURATION & PROPERTIES
    // ═══════════════════════════════════════════
    readonly property color accentColor:    (typeof config !== "undefined" && config.accentColor)   ? config.accentColor   : "#00d4ff"
    readonly property color textColor:      (typeof config !== "undefined" && config.textColor)     ? config.textColor     : "#e8e8e8"
    readonly property color errorColor:     (typeof config !== "undefined" && config.errorColor)    ? config.errorColor    : "#ff4757"
    readonly property color alertRedColor:  (typeof config !== "undefined" && config.alertRedColor) ? config.alertRedColor : "#ff0033"
    readonly property color inputBgColor:   (typeof config !== "undefined" && config.inputBgColor)  ? config.inputBgColor  : "#14171c"
    readonly property int   fontSize:       (typeof config !== "undefined" && config.fontSize)      ? parseInt(config.fontSize) : 14
    readonly property string fontFamily:    (typeof config !== "undefined" && config.fontFamily)   ? config.fontFamily    : "sans-serif"
    readonly property int   logoSize:       (typeof config !== "undefined" && config.logoSize)      ? parseInt(config.logoSize) : 190

    // ── State flags ──
    property bool funMode: false
    property string errorMessage: ""
    property color currentErrorColor: root.errorColor
    property bool isBlinking: false

    // State machine: "CASE_1" (Default initial login screen), "CASE_2" (Tactical map sequence)
    state: "CASE_1"
    signal triggerCase2()

    onTriggerCase2: {
        console.log("[SDDM] Triggering CASE 2: Tactical OpenStreetMap satellite & laser sequence");
    }

    // ═══════════════════════════════════════════
    //  CASE 1: INITIAL LOGIN VIEW
    // ═══════════════════════════════════════════
    Item {
        id: case1Container
        anchors.fill: parent
        visible: root.state === "CASE_1"

        // Subtle dark military vignette / grid lines
        Rectangle {
            anchors.fill: parent
            color: "transparent"
            border.color: Qt.rgba(1, 1, 1, 0.03)
            border.width: 1
        }

        // Center Container: Centerpiece NIA Logo + Input Prompts directly below
        Column {
            id: centerColumn
            anchors.centerIn: parent
            spacing: 24
            width: 380

            // ── Centerpiece: NIA Logo (rendered as SVG) ──
            Item {
                width: root.logoSize
                height: root.logoSize
                anchors.horizontalCenter: parent.horizontalCenter

                Image {
                    id: niaLogo
                    anchors.fill: parent
                    source: "assets/NIA-logo.svg"
                    sourceSize.width: root.logoSize * 2
                    sourceSize.height: root.logoSize * 2
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    mipmap: true
                }
            }

            // Agency Sub-header
            Column {
                width: parent.width
                spacing: 4

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "NATIONAL INVESTIGATION AGENCY"
                    color: Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.85)
                    font.family: root.fontFamily
                    font.pixelSize: 13
                    font.letterSpacing: 2.5
                    font.weight: Font.DemiBold
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "CENTRAL AUTHENTICATION TERMINAL"
                    color: Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.45)
                    font.family: root.fontFamily
                    font.pixelSize: 10
                    font.letterSpacing: 1.5
                }
            }

            // ── Login Prompts directly below the logo ──
            Column {
                width: parent.width
                spacing: 14

                // Username Input Box
                Rectangle {
                    id: userFieldBg
                    width: parent.width
                    height: 46
                    radius: 6
                    color: root.inputBgColor
                    border.color: userField.activeFocus
                        ? root.accentColor
                        : Qt.rgba(1, 1, 1, 0.12)
                    border.width: userField.activeFocus ? 2 : 1

                    Behavior on border.color { ColorAnimation { duration: 180 } }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 14
                        spacing: 10

                        Text {
                            text: "👤"
                            font.pixelSize: 14
                            color: Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.5)
                        }

                        TextInput {
                            id: userField
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            verticalAlignment: TextInput.AlignVCenter
                            color: root.textColor
                            font.pixelSize: root.fontSize
                            font.family: root.fontFamily
                            clip: true
                            selectByMouse: true
                            text: (typeof userModel !== "undefined" && userModel) ? (userModel.lastUser || "") : ""

                            KeyNavigation.tab: passField
                            Keys.onReturnPressed: passField.forceActiveFocus()

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: "Enter Username"
                                color: Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.3)
                                font: parent.font
                                visible: !parent.text && !parent.activeFocus
                            }
                        }
                    }
                }

                // Password Input Box
                Rectangle {
                    id: passFieldBg
                    width: parent.width
                    height: 46
                    radius: 6
                    color: root.inputBgColor
                    border.color: passField.activeFocus
                        ? root.accentColor
                        : Qt.rgba(1, 1, 1, 0.12)
                    border.width: passField.activeFocus ? 2 : 1

                    Behavior on border.color { ColorAnimation { duration: 180 } }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 10
                        spacing: 10

                        Text {
                            text: "🔒"
                            font.pixelSize: 14
                            color: Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.5)
                        }

                        TextInput {
                            id: passField
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            verticalAlignment: TextInput.AlignVCenter
                            color: root.textColor
                            font.pixelSize: root.fontSize
                            font.family: root.fontFamily
                            echoMode: showPassBtn.showPassword ? TextInput.Normal : TextInput.Password
                            clip: true
                            selectByMouse: true

                            KeyNavigation.tab: loginBtn
                            Keys.onReturnPressed: root.tryLogin()

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: "Enter Password"
                                color: Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.3)
                                font: parent.font
                                visible: !parent.text && !parent.activeFocus
                            }
                        }

                        // Show/Hide password toggle
                        Rectangle {
                            id: showPassBtn
                            property bool showPassword: false
                            Layout.preferredWidth: 32
                            Layout.preferredHeight: 32
                            radius: 4
                            color: showPassMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : "transparent"

                            Text {
                                anchors.centerIn: parent
                                text: parent.showPassword ? "👁️" : "🔒"
                                font.pixelSize: 13
                                opacity: 0.6
                            }

                            MouseArea {
                                id: showPassMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: showPassBtn.showPassword = !showPassBtn.showPassword
                            }
                        }
                    }
                }

                // ── Error text positioned directly below the password box ──
                Item {
                    id: errorContainer
                    width: parent.width
                    height: errorText.text !== "" ? errorText.implicitHeight + 6 : 0
                    visible: errorText.text !== ""

                    Text {
                        id: errorText
                        width: parent.width
                        anchors.centerIn: parent
                        text: root.errorMessage
                        color: root.currentErrorColor
                        font.pixelSize: root.fontSize - 1
                        font.family: root.fontFamily
                        font.weight: root.funMode ? Font.Bold : Font.Normal
                        font.letterSpacing: root.funMode ? 1.2 : 0.0
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap

                        // Glowing shadow/glow effect when in Fun Mode alert
                        style: root.funMode ? Text.Outline : Text.Normal
                        styleColor: root.funMode ? Qt.rgba(1.0, 0.0, 0.2, 0.6) : "transparent"
                    }
                }

                // Login Action Button
                Rectangle {
                    id: loginBtn
                    width: parent.width
                    height: 44
                    radius: 6
                    color: loginBtnMouse.containsMouse
                        ? Qt.lighter(root.accentColor, 1.15)
                        : root.accentColor

                    Behavior on color { ColorAnimation { duration: 150 } }

                    property bool isLoading: false

                    Text {
                        anchors.centerIn: parent
                        text: loginBtn.isLoading ? "AUTHENTICATING..." : "AUTHORIZE ACCESS"
                        color: "#000000"
                        font.pixelSize: root.fontSize
                        font.family: root.fontFamily
                        font.weight: Font.Bold
                        font.letterSpacing: 1.5
                    }

                    MouseArea {
                        id: loginBtnMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.tryLogin()
                    }
                }
            }
        }

        // ═══════════════════════════════════════════
        //  UI TOGGLE: "Turn on Fun Mode" (Bottom-Right)
        // ═══════════════════════════════════════════
        Rectangle {
            id: funModeToggle
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 20
            width: funToggleLayout.implicitWidth + 24
            height: 36
            radius: 18

            color: funToggleMouse.containsMouse
                ? (root.funMode ? Qt.rgba(0, 212, 255, 0.2) : Qt.rgba(255, 255, 255, 0.1))
                : (root.funMode ? Qt.rgba(0, 212, 255, 0.1) : Qt.rgba(255, 255, 255, 0.04))
            border.color: root.funMode ? root.accentColor : Qt.rgba(255, 255, 255, 0.15)
            border.width: 1

            Behavior on color { ColorAnimation { duration: 180 } }
            Behavior on border.color { ColorAnimation { duration: 180 } }

            RowLayout {
                id: funToggleLayout
                anchors.centerIn: parent
                spacing: 8

                // Indicator pip
                Rectangle {
                    width: 7
                    height: 7
                    radius: 3.5
                    color: root.funMode ? "#00ff88" : Qt.rgba(1, 1, 1, 0.3)
                    Behavior on color { ColorAnimation { duration: 200 } }
                }

                Text {
                    text: root.funMode ? "Fun Mode: Active" : "Turn on Fun Mode"
                    color: root.funMode ? root.accentColor : Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.6)
                    font.pixelSize: 12
                    font.family: root.fontFamily
                    font.weight: root.funMode ? Font.DemiBold : Font.Normal
                }
            }

            MouseArea {
                id: funToggleMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    root.funMode = !root.funMode
                    console.log("[SDDM] Fun Mode is now:", root.funMode)
                }
            }

            ToolTip {
                visible: funToggleMouse.containsMouse
                text: root.funMode ? "Fun Mode is ON: Click to disable" : "Click to activate Fun Mode"
                delay: 400
            }
        }
    }

    // ═══════════════════════════════════════════
    //  CASE 2: PLACEHOLDER CONTAINER (Awaiting update)
    // ═══════════════════════════════════════════
    Item {
        id: case2Container
        anchors.fill: parent
        visible: root.state === "CASE_2"

        Rectangle {
            anchors.fill: parent
            color: "#05070a"

            Column {
                anchors.centerIn: parent
                spacing: 16

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "🛰️ CASE 2 ACTIVATED"
                    color: root.accentColor
                    font.pixelSize: 22
                    font.family: root.fontFamily
                    font.weight: Font.Bold
                    font.letterSpacing: 2
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Tactical OpenStreetMap Satellite & Laser Sequence Initializing..."
                    color: Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.7)
                    font.pixelSize: 14
                    font.family: root.fontFamily
                }

                Button {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Return to Case 1"
                    onClicked: {
                        root.errorMessage = ""
                        root.state = "CASE_1"
                    }
                }
            }
        }
    }

    // ═══════════════════════════════════════════
    //  FAILURE SEQUENCE ANIMATION (RAPID 3 BLINKS)
    // ═══════════════════════════════════════════
    SequentialAnimation {
        id: rapidBlinkAnim

        onStarted: {
            root.isBlinking = true
        }

        // Blink Cycle 1
        NumberAnimation { target: errorText; property: "opacity"; to: 0.0; duration: 90; easing.type: Easing.Linear }
        NumberAnimation { target: errorText; property: "opacity"; to: 1.0; duration: 90; easing.type: Easing.Linear }

        // Blink Cycle 2
        NumberAnimation { target: errorText; property: "opacity"; to: 0.0; duration: 90; easing.type: Easing.Linear }
        NumberAnimation { target: errorText; property: "opacity"; to: 1.0; duration: 90; easing.type: Easing.Linear }

        // Blink Cycle 3
        NumberAnimation { target: errorText; property: "opacity"; to: 0.0; duration: 90; easing.type: Easing.Linear }
        NumberAnimation { target: errorText; property: "opacity"; to: 1.0; duration: 90; easing.type: Easing.Linear }

        // Immediately after the 3rd blink, trigger Case 2
        onFinished: {
            root.isBlinking = false
            console.log("[SDDM] 3rd blink complete. Transitioning to Case 2.")
            root.state = "CASE_2"
            root.triggerCase2()
        }
    }

    // ═══════════════════════════════════════════
    //  LOGIN LOGIC & STATE MACHINE HANDLERS
    // ═══════════════════════════════════════════
    function tryLogin() {
        if (root.isBlinking) return
        root.errorMessage = ""
        loginBtn.isLoading = true

        if (!userField.text) {
            handleLoginFailure("Please enter username")
            userField.forceActiveFocus()
            return
        }
        if (!passField.text) {
            handleLoginFailure("Please enter password")
            passField.forceActiveFocus()
            return
        }

        if (typeof sddm !== "undefined" && sddm) {
            sddm.login(userField.text, passField.text, 0)
        } else {
            // Standalone test / demo environment simulation:
            // Entering wrong password or test credentials triggers failure sequence
            testTimer.start()
        }
    }

    Timer {
        id: testTimer
        interval: 350
        repeat: false
        onTriggered: {
            // In standalone test mode, simulate login failure to test sequence
            handleLoginFailure("Authentication failed: Access Denied")
        }
    }

    function handleLoginFailure(defaultMsg) {
        loginBtn.isLoading = false

        if (root.funMode) {
            // ── Fun Mode Failure Sequence ──
            // 1. Text changes to "Login Attempt Failed"
            root.errorMessage = "Login Attempt Failed"
            // 2. Text color immediately turns glowing RED
            root.currentErrorColor = root.alertRedColor
            errorText.opacity = 1.0
            // 3. Quick opacity animation causes the red text to blink rapidly exactly 3 times
            // 4. Immediately after 3rd blink -> triggers Case 2
            rapidBlinkAnim.restart()
        } else {
            // ── Default Mode (Fun Mode OFF) ──
            // Normal SDDM greeter failure: normal message, standard color, no extra animation
            root.currentErrorColor = root.errorColor
            root.errorMessage = defaultMsg ? defaultMsg : "Login failed. Check your credentials."
            errorText.opacity = 1.0
        }
    }

    // ── Handle login signals from SDDM ──
    Connections {
        target: (typeof sddm !== "undefined") ? sddm : null
        function onLoginFailed() {
            handleLoginFailure("Login failed. Check your credentials.")
            passField.text = ""
            passField.forceActiveFocus()
        }
        function onLoginSucceeded() {
            loginBtn.isLoading = false
        }
    }

    // Auto-focus username/password on load
    Component.onCompleted: {
        if (userField.text) {
            passField.forceActiveFocus()
        } else {
            userField.forceActiveFocus()
        }
    }
}
