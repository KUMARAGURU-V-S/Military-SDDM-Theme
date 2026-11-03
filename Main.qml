/*
 *  NATIONAL INVESTIGATION AGENCY (NIA) - TACTICAL DEFENSE SDDM GREETER
 *  ──────────────────────────────────────────────────────────────────
 *  Aesthetic: Authentic military command console & tactical terminal
 *  State Machine:
 *    - CASE_1: Tactical command authentication screen with centered NIA SVG emblem
 *    - CASE_2: Tactical OpenStreetMap satellite & laser targeting sequence
 */

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    width: Screen.width
    height: Screen.height
    color: (typeof config !== "undefined" && config.backgroundColor) ? config.backgroundColor : "#080a08"

    // ═══════════════════════════════════════════
    //  MILITARY TACTICAL CONFIGURATION
    // ═══════════════════════════════════════════
    readonly property color militaryOlive:      (typeof config !== "undefined" && config.militaryOlive)      ? config.militaryOlive      : "#283523"
    readonly property color militaryOliveHover: (typeof config !== "undefined" && config.militaryOliveHover) ? config.militaryOliveHover : "#384a32"
    readonly property color militaryBorder:     (typeof config !== "undefined" && config.buttonBorderColor)  ? config.buttonBorderColor  : "#4e6547"
    readonly property color hudGreen:           (typeof config !== "undefined" && config.highlightColor)     ? config.highlightColor     : "#4ef289"
    readonly property color textColor:          (typeof config !== "undefined" && config.textColor)          ? config.textColor          : "#d8e0d5"
    readonly property color mutedTextColor:     (typeof config !== "undefined" && config.mutedTextColor)     ? config.mutedTextColor     : "#687a65"
    readonly property color inputBgColor:       (typeof config !== "undefined" && config.inputBgColor)       ? config.inputBgColor       : "#0b0f0c"
    readonly property color inputBorderColor:   (typeof config !== "undefined" && config.inputBorderColor)   ? config.inputBorderColor   : "#202a22"
    readonly property color errorColor:         (typeof config !== "undefined" && config.errorColor)         ? config.errorColor         : "#d9383a"
    readonly property color alertRedColor:      (typeof config !== "undefined" && config.alertRedColor)      ? config.alertRedColor      : "#ff0033"
    readonly property int   fontSize:           (typeof config !== "undefined" && config.fontSize)          ? parseInt(config.fontSize) : 13
    readonly property string fontFamily:        "monospace"
    readonly property int   logoSize:               (typeof config !== "undefined" && config.logoSize)               ? parseInt(config.logoSize) : 250
    readonly property string loginButtonText:       (typeof config !== "undefined" && config.loginButtonText)       ? config.loginButtonText    : "[ AUTHENTICATE ]"
    readonly property string loginButtonLoadingText:(typeof config !== "undefined" && config.loginButtonLoadingText)? config.loginButtonLoadingText : "AUTHENTICATING..."

    // ── State flags ──
    property bool funMode: false
    property string errorMessage: ""
    property color currentErrorColor: root.errorColor
    property bool isBlinking: false

    // State machine: "CASE_1" (Initial tactical login), "CASE_2" (Tactical map sequence)
    state: "CASE_1"
    signal triggerCase2()

    onTriggerCase2: {
        console.log("[TACTICAL SDDM] Triggering CASE 2: Tactical satellite and laser sequence");
    }

    // ═══════════════════════════════════════════
    //  CASE 1: TACTICAL MILITARY LOGIN SCREEN
    // ═══════════════════════════════════════════
    Item {
        id: case1Container
        anchors.fill: parent
        visible: root.state === "CASE_1"

        // Tactical Corner Crosshair Reticles
        Text { anchors.left: parent.left; anchors.top: parent.top; anchors.margins: 18; text: "┌──[ NIA // SEC-OPS ]"; color: root.mutedTextColor; font.family: root.fontFamily; font.pixelSize: 11; font.letterSpacing: 1 }
        Text { anchors.right: parent.right; anchors.top: parent.top; anchors.margins: 18; text: "[ NODE-01 // ACTIVE ]──┐"; color: root.mutedTextColor; font.family: root.fontFamily; font.pixelSize: 11; font.letterSpacing: 1 }
        Text { anchors.left: parent.left; anchors.bottom: parent.bottom; anchors.margins: 18; text: "└──[ CLASSIFICATION: TOP SECRET ]"; color: root.mutedTextColor; font.family: root.fontFamily; font.pixelSize: 11; font.letterSpacing: 1 }

        // Center Panel: Centerpiece NIA SVG Logo + Inputs directly below
        Column {
            id: centerColumn
            anchors.centerIn: parent
            spacing: 20
            width: 420

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

            // Tactical Military Classification Header
            Column {
                width: parent.width
                spacing: 3

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "NATIONAL INVESTIGATION AGENCY"
                    color: root.textColor
                    font.family: root.fontFamily
                    font.pixelSize: 13
                    font.letterSpacing: 2
                    font.weight: Font.Bold
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "CENTRAL COMMAND AUTHENTICATION TERMINAL"
                    color: root.mutedTextColor
                    font.family: root.fontFamily
                    font.pixelSize: 10
                    font.letterSpacing: 1.5
                }
            }

            // ── Login Prompts directly below the logo ──
            Column {
                width: parent.width
                spacing: 12

                // Username Input Field
                Rectangle {
                    id: userFieldBg
                    width: parent.width
                    height: 44
                    radius: 2
                    color: root.inputBgColor
                    border.color: userField.activeFocus ? root.hudGreen : root.inputBorderColor
                    border.width: 1

                    Behavior on border.color { ColorAnimation { duration: 150 } }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 8

                        Text {
                            text: "OPERATOR //:"
                            font.family: root.fontFamily
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            color: userField.activeFocus ? root.hudGreen : root.mutedTextColor
                        }

                        TextInput {
                            id: userField
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            verticalAlignment: TextInput.AlignVCenter
                            color: root.textColor
                            font.family: root.fontFamily
                            font.pixelSize: root.fontSize
                            clip: true
                            selectByMouse: true
                            text: (typeof userModel !== "undefined" && userModel) ? (userModel.lastUser || "") : ""

                            KeyNavigation.tab: passField
                            Keys.onReturnPressed: passField.forceActiveFocus()

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: "ENTER CALLSIGN / ID"
                                color: Qt.rgba(root.mutedTextColor.r, root.mutedTextColor.g, root.mutedTextColor.b, 0.4)
                                font: parent.font
                                visible: !parent.text && !parent.activeFocus
                            }
                        }
                    }
                }

                // Password Input Field
                Rectangle {
                    id: passFieldBg
                    width: parent.width
                    height: 44
                    radius: 2
                    color: root.inputBgColor
                    border.color: passField.activeFocus ? root.hudGreen : root.inputBorderColor
                    border.width: 1

                    Behavior on border.color { ColorAnimation { duration: 150 } }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 8
                        spacing: 8

                        Text {
                            text: "PASSCODE //:"
                            font.family: root.fontFamily
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            color: passField.activeFocus ? root.hudGreen : root.mutedTextColor
                        }

                        TextInput {
                            id: passField
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            verticalAlignment: TextInput.AlignVCenter
                            color: root.textColor
                            font.family: root.fontFamily
                            font.pixelSize: root.fontSize
                            echoMode: showPassBtn.showPassword ? TextInput.Normal : TextInput.Password
                            clip: true
                            selectByMouse: true

                            KeyNavigation.tab: loginBtn
                            Keys.onReturnPressed: root.tryLogin()

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: "ENTER SECURITY KEY"
                                color: Qt.rgba(root.mutedTextColor.r, root.mutedTextColor.g, root.mutedTextColor.b, 0.4)
                                font: parent.font
                                visible: !parent.text && !parent.activeFocus
                            }
                        }

                        // Low-visibility show/hide toggle
                        Rectangle {
                            id: showPassBtn
                            property bool showPassword: false
                            Layout.preferredWidth: 26
                            Layout.preferredHeight: 26
                            radius: 2
                            color: showPassMouse.containsMouse ? Qt.rgba(255, 255, 255, 0.08) : "transparent"

                            Text {
                                anchors.centerIn: parent
                                text: parent.showPassword ? "👁" : "•"
                                font.family: root.fontFamily
                                font.pixelSize: 13
                                color: root.mutedTextColor
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
                        font.family: root.fontFamily
                        font.pixelSize: 12
                        font.weight: Font.Bold
                        font.letterSpacing: 1.2
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap

                        // Glowing outline when in Fun Mode alert
                        style: root.funMode ? Text.Outline : Text.Normal
                        styleColor: root.funMode ? Qt.rgba(1.0, 0.0, 0.1, 0.7) : "transparent"
                    }
                }

                // ── Military Tactical Button ──
                Rectangle {
                    id: loginBtn
                    width: parent.width
                    height: 44
                    radius: 2
                    color: loginBtnMouse.containsMouse ? root.militaryOliveHover : root.militaryOlive
                    border.color: loginBtnMouse.containsMouse ? Qt.lighter(root.militaryBorder, 1.3) : root.militaryBorder
                    border.width: 1

                    Behavior on color { ColorAnimation { duration: 150 } }
                    Behavior on border.color { ColorAnimation { duration: 150 } }

                    property bool isLoading: false

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 8

                        Text {
                            text: loginBtn.isLoading ? root.loginButtonLoadingText : root.loginButtonText
                            color: loginBtnMouse.containsMouse ? "#ffffff" : root.textColor
                            font.family: root.fontFamily
                            font.pixelSize: 12
                            font.weight: Font.Bold
                            font.letterSpacing: 1.8
                        }
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
            anchors.margins: 18
            width: funToggleLayout.implicitWidth + 20
            height: 32
            radius: 2

            color: funToggleMouse.containsMouse
                ? (root.funMode ? Qt.rgba(255, 59, 48, 0.15) : Qt.rgba(255, 255, 255, 0.08))
                : (root.funMode ? Qt.rgba(255, 59, 48, 0.08) : "#0d130e")
            border.color: root.funMode ? "#ff3b30" : root.inputBorderColor
            border.width: 1

            Behavior on color { ColorAnimation { duration: 150 } }
            Behavior on border.color { ColorAnimation { duration: 150 } }

            RowLayout {
                id: funToggleLayout
                anchors.centerIn: parent
                spacing: 8

                // Arming beacon pip
                Rectangle {
                    width: 6
                    height: 6
                    radius: 1
                    color: root.funMode ? "#ff3b30" : root.mutedTextColor
                    Behavior on color { ColorAnimation { duration: 180 } }
                }

                Text {
                    text: root.funMode ? "[ FUN MODE: ARMED ]" : "Turn on Fun Mode"
                    color: root.funMode ? "#ff4d4d" : root.mutedTextColor
                    font.family: root.fontFamily
                    font.pixelSize: 11
                    font.weight: root.funMode ? Font.Bold : Font.Normal
                    font.letterSpacing: 0.8
                }
            }

            MouseArea {
                id: funToggleMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    root.funMode = !root.funMode
                    console.log("[TACTICAL SDDM] Fun Mode status:", root.funMode)
                }
            }

            ToolTip {
                visible: funToggleMouse.containsMouse
                text: root.funMode ? "Fun Mode is ARMED: Failure triggers tactical sequence" : "Click to arm Fun Mode sequence"
                delay: 300
            }
        }
    }

    // ═══════════════════════════════════════════
    //  CASE 2: TACTICAL STANDBY VIEW (Awaiting Case 2 update)
    // ═══════════════════════════════════════════
    Item {
        id: case2Container
        anchors.fill: parent
        visible: root.state === "CASE_2"

        Rectangle {
            anchors.fill: parent
            color: "#050705"

            Column {
                anchors.centerIn: parent
                spacing: 16

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "🛰️ CASE 2 ACTIVATED"
                    color: root.hudGreen
                    font.family: root.fontFamily
                    font.pixelSize: 20
                    font.weight: Font.Bold
                    font.letterSpacing: 2
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Tactical Satellite & Laser Grid Sequence Initializing..."
                    color: root.mutedTextColor
                    font.family: root.fontFamily
                    font.pixelSize: 13
                    font.letterSpacing: 1
                }

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 180
                    height: 36
                    radius: 2
                    color: root.militaryOlive
                    border.color: root.militaryBorder
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "[ RETURN TO BASE ]"
                        color: root.textColor
                        font.family: root.fontFamily
                        font.pixelSize: 11
                        font.weight: Font.Bold
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.errorMessage = ""
                            root.state = "CASE_1"
                        }
                    }
                }
            }
        }
    }

    // ═══════════════════════════════════════════
    //  FAILURE SEQUENCE: RAPID 3-CYCLE BLINK ANIMATION
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

        // Immediately after 3rd blink -> Trigger Case 2
        onFinished: {
            root.isBlinking = false
            console.log("[TACTICAL SDDM] 3rd blink complete. Triggering Case 2.")
            root.state = "CASE_2"
            root.triggerCase2()
        }
    }

    // ═══════════════════════════════════════════
    //  LOGIN LOGIC & STATE MACHINE
    // ═══════════════════════════════════════════
    function tryLogin() {
        if (root.isBlinking) return
        root.errorMessage = ""
        loginBtn.isLoading = true

        if (!userField.text) {
            handleLoginFailure("OPERATOR ID REQUIRED")
            userField.forceActiveFocus()
            return
        }
        if (!passField.text) {
            handleLoginFailure("SECURITY PASSCODE REQUIRED")
            passField.forceActiveFocus()
            return
        }

        if (typeof sddm !== "undefined" && sddm) {
            sddm.login(userField.text, passField.text, 0)
        } else {
            // Standalone test/preview fallback
            testTimer.start()
        }
    }

    Timer {
        id: testTimer
        interval: 350
        repeat: false
        onTriggered: {
            handleLoginFailure("SECURITY CLEARANCE REJECTED")
        }
    }

    function handleLoginFailure(defaultMsg) {
        loginBtn.isLoading = false

        if (root.funMode) {
            // ── Fun Mode Failure Sequence ──
            // 1. Text changes to "Login Attempt Failed"
            root.errorMessage = "Login Attempt Failed"
            // 2. Color immediately turns glowing RED
            root.currentErrorColor = root.alertRedColor
            errorText.opacity = 1.0
            // 3. Quick opacity animation causes the red text to blink rapidly exactly 3 times
            // 4. Immediately after 3rd blink -> triggers Case 2
            rapidBlinkAnim.restart()
        } else {
            // ── Default Mode (Fun Mode OFF) ──
            // Standard failure message, normal error color, no extra animation
            root.currentErrorColor = root.errorColor
            root.errorMessage = defaultMsg ? defaultMsg : "ACCESS DENIED: INVALID CREDENTIALS"
            errorText.opacity = 1.0
        }
    }

    // SDDM Signal Listeners
    Connections {
        target: (typeof sddm !== "undefined") ? sddm : null
        function onLoginFailed() {
            handleLoginFailure("ACCESS DENIED: INVALID CREDENTIALS")
            passField.text = ""
            passField.forceActiveFocus()
        }
        function onLoginSucceeded() {
            loginBtn.isLoading = false
        }
    }

    Component.onCompleted: {
        if (userField.text) {
            passField.forceActiveFocus()
        } else {
            userField.forceActiveFocus()
        }
    }
}
