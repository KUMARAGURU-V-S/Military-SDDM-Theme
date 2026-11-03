/*
 *  NATIONAL INVESTIGATION AGENCY (NIA) - TACTICAL DEFENSE SDDM GREETER
 *  ──────────────────────────────────────────────────────────────────
 *  Aesthetic: Authentic military command console & tactical C4ISR terminal
 *  State Machine:
 *    - CASE_1: Tactical command authentication screen with centered NIA SVG emblem
 *    - CASE_2: Tactical OpenStreetMap satellite & laser targeting sequence
 */

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtLocation
import QtPositioning

Rectangle {
    id: root
    width: Screen.width
    height: Screen.height
    color: (typeof config !== "undefined" && config.backgroundColor) ? config.backgroundColor : "#080a08"

    // ═══════════════════════════════════════════
    //  MILITARY TACTICAL PALETTE & CONFIG
    // ═══════════════════════════════════════════
    readonly property color militaryOlive:          (typeof config !== "undefined" && config.militaryOlive)          ? config.militaryOlive          : "#283523"
    readonly property color militaryOliveHover:     (typeof config !== "undefined" && config.militaryOliveHover)     ? config.militaryOliveHover     : "#384a32"
    readonly property color militaryBorder:         (typeof config !== "undefined" && config.buttonBorderColor)      ? config.buttonBorderColor      : "#4e6547"
    readonly property color hudGreen:               (typeof config !== "undefined" && config.highlightColor)         ? config.highlightColor         : "#4ef289"
    readonly property color textColor:              (typeof config !== "undefined" && config.textColor)              ? config.textColor              : "#d8e0d5"
    readonly property color mutedTextColor:         (typeof config !== "undefined" && config.mutedTextColor)         ? config.mutedTextColor         : "#687a65"
    readonly property color inputBgColor:           (typeof config !== "undefined" && config.inputBgColor)           ? config.inputBgColor           : "#0b0f0c"
    readonly property color inputBorderColor:       (typeof config !== "undefined" && config.inputBorderColor)       ? config.inputBorderColor       : "#202a22"
    readonly property color errorColor:             (typeof config !== "undefined" && config.errorColor)             ? config.errorColor             : "#d9383a"
    readonly property color alertRedColor:          (typeof config !== "undefined" && config.alertRedColor)          ? config.alertRedColor          : "#ff0033"
    readonly property int   fontSize:               (typeof config !== "undefined" && config.fontSize)              ? parseInt(config.fontSize)     : 13
    readonly property string fontFamily:            "monospace"
    readonly property int   logoSize:               (typeof config !== "undefined" && config.logoSize)               ? parseInt(config.logoSize)     : 250
    readonly property string loginButtonText:       (typeof config !== "undefined" && config.loginButtonText)       ? config.loginButtonText        : "[ AUTHENTICATE ]"
    readonly property string loginButtonLoadingText:(typeof config !== "undefined" && config.loginButtonLoadingText)? config.loginButtonLoadingText : "AUTHENTICATING..."

    // ── Global State flags ──
    property bool funMode: false
    property string errorMessage: ""
    property color currentErrorColor: root.errorColor
    property bool isBlinking: false

    // State machine: "CASE_1" (Login screen), "CASE_2" (Tactical map sequence)
    state: "CASE_1"
    signal triggerCase2()

    onTriggerCase2: {
        root.state = "CASE_2"
        case2Manager.startSequence()
    }

    // ═══════════════════════════════════════════
    //  CASE 1: TACTICAL MILITARY LOGIN SCREEN
    // ═══════════════════════════════════════════
    Item {
        id: case1Container
        anchors.fill: parent
        visible: root.state === "CASE_1"
        opacity: root.state === "CASE_1" ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 300 } }

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
                spacing: 4

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

                // ── Session Selector ──
                RowLayout {
                    width: parent.width
                    visible: (typeof config !== "undefined" && config.showSessionSelector === "false") ? false : true
                    spacing: 8

                    Text {
                        text: "SESSION //:"
                        font.family: root.fontFamily
                        font.pixelSize: 11
                        font.weight: Font.Bold
                        color: root.mutedTextColor
                    }

                    ComboBox {
                        id: sessionSelector
                        Layout.fillWidth: true
                        height: 34
                        model: (typeof sessionModel !== "undefined" && sessionModel) ? sessionModel : ["Plasma (Wayland)", "Plasma (X11)", "Custom Session"]
                        currentIndex: (typeof sessionModel !== "undefined" && sessionModel) ? sessionModel.lastIndex : 0
                        textRole: "name"
                        font.family: root.fontFamily
                        font.pixelSize: 11

                        background: Rectangle {
                            radius: 2
                            color: root.inputBgColor
                            border.color: root.inputBorderColor
                            border.width: 1
                        }

                        contentItem: Text {
                            text: sessionSelector.displayText
                            color: root.textColor
                            font: sessionSelector.font
                            leftPadding: 8
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }
                    }
                }
            }
        }

        // ── Tactical Power Controls (Bottom-Left) ──
        Row {
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.margins: 18
            spacing: 10
            visible: (typeof config !== "undefined" && config.showPowerButtons === "false") ? false : true

            // Power Off
            Rectangle {
                width: powerOffLayout.implicitWidth + 14
                height: 28
                radius: 2
                color: powerOffMouse.containsMouse ? Qt.rgba(217, 56, 58, 0.25) : "#0d130e"
                border.color: powerOffMouse.containsMouse ? root.errorColor : root.inputBorderColor
                border.width: 1

                RowLayout {
                    id: powerOffLayout
                    anchors.centerIn: parent
                    spacing: 4
                    Text { text: "⏻"; color: powerOffMouse.containsMouse ? root.errorColor : root.mutedTextColor; font.pixelSize: 11 }
                    Text { text: "SHUTDOWN"; color: powerOffMouse.containsMouse ? root.errorColor : root.mutedTextColor; font.family: root.fontFamily; font.pixelSize: 10; font.weight: Font.Bold }
                }
                MouseArea {
                    id: powerOffMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: { if (typeof sddm !== "undefined" && sddm) sddm.powerOff() }
                }
            }

            // Reboot
            Rectangle {
                width: rebootLayout.implicitWidth + 14
                height: 28
                radius: 2
                color: rebootMouse.containsMouse ? Qt.rgba(78, 242, 137, 0.15) : "#0d130e"
                border.color: rebootMouse.containsMouse ? root.hudGreen : root.inputBorderColor
                border.width: 1

                RowLayout {
                    id: rebootLayout
                    anchors.centerIn: parent
                    spacing: 4
                    Text { text: "⟳"; color: rebootMouse.containsMouse ? root.hudGreen : root.mutedTextColor; font.pixelSize: 11 }
                    Text { text: "REBOOT"; color: rebootMouse.containsMouse ? root.hudGreen : root.mutedTextColor; font.family: root.fontFamily; font.pixelSize: 10; font.weight: Font.Bold }
                }
                MouseArea {
                    id: rebootMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: { if (typeof sddm !== "undefined" && sddm) sddm.reboot() }
                }
            }

            // Suspend
            Rectangle {
                width: suspendLayout.implicitWidth + 14
                height: 28
                radius: 2
                color: suspendMouse.containsMouse ? Qt.rgba(78, 242, 137, 0.15) : "#0d130e"
                border.color: suspendMouse.containsMouse ? root.hudGreen : root.inputBorderColor
                border.width: 1

                RowLayout {
                    id: suspendLayout
                    anchors.centerIn: parent
                    spacing: 4
                    Text { text: "⏾"; color: suspendMouse.containsMouse ? root.hudGreen : root.mutedTextColor; font.pixelSize: 11 }
                    Text { text: "SLEEP"; color: suspendMouse.containsMouse ? root.hudGreen : root.mutedTextColor; font.family: root.fontFamily; font.pixelSize: 10; font.weight: Font.Bold }
                }
                MouseArea {
                    id: suspendMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: { if (typeof sddm !== "undefined" && sddm) sddm.suspend() }
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
                // Double click can also trigger Case 2 directly
                onDoubleClicked: {
                    root.triggerCase2()
                }
            }

            ToolTip {
                visible: funToggleMouse.containsMouse
                text: root.funMode ? "Fun Mode is ARMED: Failure triggers tactical sequence (Double-click to launch)" : "Click to arm Fun Mode sequence"
                delay: 300
            }
        }
    }

    // ═══════════════════════════════════════════
    //  CASE 2: TACTICAL OPENSTREETMAP SATELLITE & LASER SEQUENCE
    // ═══════════════════════════════════════════
    Item {
        id: case2Container
        anchors.fill: parent
        visible: root.state === "CASE_2"
        opacity: root.state === "CASE_2" ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 400 } }

        // ── Map Plugin (OpenStreetMap with offline tile cache support) ──
        Plugin {
            id: mapPlugin
            name: "osm"
            PluginParameter {
                name: "osm.mapping.cache.directory"
                value: (typeof config !== "undefined" && config.tileCacheDir) ? config.tileCacheDir : "/var/cache/sddm-worldmap-tiles"
            }
            PluginParameter {
                name: "osm.mapping.cache.disk.size"
                value: "500000000"
            }
            PluginParameter {
                name: "osm.mapping.offline.directory"
                value: Qt.resolvedUrl("tiles/").toString().replace("file://", "")
            }
        }

        // ── 1. Interactive Base Map ──
        Map {
            id: worldMap
            anchors.fill: parent
            plugin: mapPlugin
            center: QtPositioning.coordinate(20.0, 0.0)
            zoomLevel: 2.2
            copyrightsVisible: false

            // Coordinates for satellite & target
            property real satLat: 58.0
            property real satLon: 35.0
            property real targetLat: 21.1458   // Central India (Nagpur Command Zone)
            property real targetLon: 79.0882
            property real cursorLat: 21.1458
            property real cursorLon: 79.0882
            property bool laserActive: false
            property bool targetLocked: false

            // Map pan/drag interaction
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                property real lastX: 0
                property real lastY: 0
                property bool isDragging: false

                onPressed: function(mouse) {
                    lastX = mouse.x
                    lastY = mouse.y
                    isDragging = true
                }
                onPositionChanged: function(mouse) {
                    var coord = worldMap.toCoordinate(Qt.point(mouse.x, mouse.y))
                    if (coord && !isNaN(coord.latitude)) {
                        worldMap.cursorLat = coord.latitude
                        worldMap.cursorLon = coord.longitude
                    }
                    if (isDragging) {
                        var dx = mouse.x - lastX
                        var dy = mouse.y - lastY
                        worldMap.pan(-dx, -dy)
                        lastX = mouse.x
                        lastY = mouse.y
                    }
                }
                onReleased: function(mouse) {
                    isDragging = false
                }
                onWheel: function(wheel) {
                    var delta = wheel.angleDelta.y > 0 ? 0.6 : -0.6
                    worldMap.zoomLevel = Math.max(1.5, Math.min(12, worldMap.zoomLevel + delta))
                    wheel.accepted = true
                }
            }

            // ── 4. Laser Targeting Projector (Dual Polyline with Energy Glow) ──
            // Outer Laser Glow
            MapPolyline {
                id: laserGlow
                visible: worldMap.laserActive
                line.width: 12
                line.color: Qt.rgba(1.0, 0.0, 0.15, laserGlowPulse.pulseAlpha)
                path: [
                    QtPositioning.coordinate(worldMap.satLat, worldMap.satLon),
                    QtPositioning.coordinate(worldMap.targetLat, worldMap.targetLon)
                ]
            }

            // Intense Red Laser Beam
            MapPolyline {
                id: laserBeam
                visible: worldMap.laserActive
                line.width: 4
                line.color: "#ff0033"
                path: [
                    QtPositioning.coordinate(worldMap.satLat, worldMap.satLon),
                    QtPositioning.coordinate(worldMap.targetLat, worldMap.targetLon)
                ]
            }

            // White Coherent Core
            MapPolyline {
                id: laserCore
                visible: worldMap.laserActive
                line.width: 1.5
                line.color: "#ffffff"
                path: [
                    QtPositioning.coordinate(worldMap.satLat, worldMap.satLon),
                    QtPositioning.coordinate(worldMap.targetLat, worldMap.targetLon)
                ]
            }

            // Laser energy pulsation timer / property
            Item {
                id: laserGlowPulse
                property real pulseAlpha: 0.4
                SequentialAnimation on pulseAlpha {
                    running: worldMap.laserActive
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.75; duration: 180; easing.type: Easing.InOutQuad }
                    NumberAnimation { to: 0.35; duration: 180; easing.type: Easing.InOutQuad }
                }
            }

            // ── 4. Pulsing Target Reticle in Central India (MapQuickItem) ──
            MapQuickItem {
                id: groundTargetItem
                coordinate: QtPositioning.coordinate(worldMap.targetLat, worldMap.targetLon)
                anchorPoint.x: 45
                anchorPoint.y: 45
                visible: worldMap.targetLocked

                sourceItem: Item {
                    width: 90
                    height: 90

                    // Expanding radar pulse ring
                    Rectangle {
                        id: pulseRing
                        anchors.centerIn: parent
                        width: 70
                        height: 70
                        radius: 35
                        color: "transparent"
                        border.color: "#ff0033"
                        border.width: 2

                        SequentialAnimation on scale {
                            running: worldMap.targetLocked
                            loops: Animation.Infinite
                            NumberAnimation { from: 0.5; to: 1.35; duration: 1200; easing.type: Easing.OutQuad }
                        }
                        SequentialAnimation on opacity {
                            running: worldMap.targetLocked
                            loops: Animation.Infinite
                            NumberAnimation { from: 1.0; to: 0.0; duration: 1200; easing.type: Easing.OutQuad }
                        }
                    }

                    // Concentric locked ring
                    Rectangle {
                        anchors.centerIn: parent
                        width: 48
                        height: 48
                        radius: 24
                        color: Qt.rgba(1.0, 0.0, 0.2, 0.15)
                        border.color: "#ff0033"
                        border.width: 2
                    }

                    // Inner bullseye
                    Rectangle {
                        anchors.centerIn: parent
                        width: 12
                        height: 12
                        radius: 6
                        color: "#ff0033"
                    }

                    // Crosshairs
                    Rectangle { width: 80; height: 1; color: "#ff0033"; anchors.centerIn: parent }
                    Rectangle { width: 1; height: 80; color: "#ff0033"; anchors.centerIn: parent }

                    // Ground target label
                    Text {
                        anchors.top: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.topMargin: 4
                        text: "TGT // 21.1458° N, 79.0882° E"
                        color: "#ff3b30"
                        font.family: root.fontFamily
                        font.pixelSize: 10
                        font.weight: Font.Bold
                        style: Text.Outline
                        styleColor: "#000000"
                    }
                }
            }

            // ── 3. Satellite Graphic (MapQuickItem deployed over Northern India) ──
            MapQuickItem {
                id: satItem
                coordinate: QtPositioning.coordinate(worldMap.satLat, worldMap.satLon)
                anchorPoint.x: 35
                anchorPoint.y: 35

                sourceItem: Item {
                    width: 70
                    height: 70

                    // Orbital strobe beacon
                    Rectangle {
                        width: 8
                        height: 8
                        radius: 4
                        color: "#00ff88"
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top

                        SequentialAnimation on opacity {
                            loops: Animation.Infinite
                            NumberAnimation { to: 0.1; duration: 400 }
                            NumberAnimation { to: 1.0; duration: 400 }
                        }
                    }

                    // Left Solar Array
                    Rectangle {
                        width: 22
                        height: 12
                        radius: 1
                        color: "#1c2b36"
                        border.color: "#4ef289"
                        border.width: 1
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: satBody.left
                        anchors.rightMargin: 3
                    }

                    // Satellite Body
                    Rectangle {
                        id: satBody
                        width: 18
                        height: 24
                        radius: 2
                        color: "#283523"
                        border.color: "#88ff3333"
                        border.width: 1
                        anchors.centerIn: parent

                        // Optical Laser Emitter Aperture
                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: 6
                            height: 6
                            radius: 3
                            color: worldMap.laserActive ? "#ff0033" : "#666666"
                            border.color: "#ffffff"
                            border.width: 1
                        }
                    }

                    // Right Solar Array
                    Rectangle {
                        width: 22
                        height: 12
                        radius: 1
                        color: "#1c2b36"
                        border.color: "#4ef289"
                        border.width: 1
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: satBody.right
                        anchors.leftMargin: 3
                    }

                    // Satellite Callsign
                    Text {
                        anchors.bottom: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottomMargin: 2
                        text: "GSAT-7A // MIL-ORBIT"
                        color: "#4ef289"
                        font.family: root.fontFamily
                        font.pixelSize: 9
                        font.weight: Font.Bold
                        style: Text.Outline
                        styleColor: "#000000"
                    }
                }
            }
        }

        // Tactical Surveillance Grid / Dark Vignette Overlay
        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(0, 0, 0, 0.25)
            enabled: false
        }

        // ═══════════════════════════════════════════
        //  5. TACTICAL HUD OVERLAY (Top-Left Corner)
        // ═══════════════════════════════════════════
        Rectangle {
            id: hudFeedBox
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.margins: 22
            width: 380
            height: hudColumn.implicitHeight + 28
            radius: 2

            // Semi-transparent red military terminal background
            color: Qt.rgba(0.08, 0.015, 0.015, 0.88)
            border.color: "#ff0033"
            border.width: 1

            // Subtle scanline pattern
            Rectangle {
                anchors.fill: parent
                color: "transparent"
                border.color: Qt.rgba(1.0, 0.0, 0.1, 0.15)
                border.width: 1
            }

            Column {
                id: hudColumn
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 14
                spacing: 8

                // Terminal Header
                RowLayout {
                    width: parent.width

                    Text {
                        text: "[ TACTICAL UPLINK FEED ]"
                        color: "#ff3b30"
                        font.family: root.fontFamily
                        font.pixelSize: 12
                        font.weight: Font.Bold
                        font.letterSpacing: 1.5
                    }

                    Item { Layout.fillWidth: true }

                    // Blinking REC Indicator
                    Row {
                        spacing: 4
                        Rectangle {
                            width: 6; height: 6; radius: 3; color: "#ff0033"
                            anchors.verticalCenter: parent.verticalCenter
                            SequentialAnimation on opacity {
                                loops: Animation.Infinite
                                NumberAnimation { to: 0.1; duration: 350 }
                                NumberAnimation { to: 1.0; duration: 350 }
                            }
                        }
                        Text {
                            text: "LIVE"
                            color: "#ff3b30"
                            font.family: root.fontFamily
                            font.pixelSize: 10
                            font.weight: Font.Bold
                        }
                    }
                }

                // Header separator line
                Rectangle {
                    width: parent.width
                    height: 1
                    color: Qt.rgba(1.0, 0.0, 0.2, 0.3)
                }

                // Typewriter / Event Feed lines
                Column {
                    width: parent.width
                    spacing: 4

                    Repeater {
                        model: case2Manager.feedLines
                        delegate: Text {
                            text: modelData
                            color: index === case2Manager.feedLines.length - 1 ? "#ffffff" : Qt.rgba(1.0, 0.8, 0.8, 0.85)
                            font.family: root.fontFamily
                            font.pixelSize: 11
                            font.letterSpacing: 0.8
                            wrapMode: Text.WordWrap
                            width: hudColumn.width
                        }
                    }

                    // Blinking cursor
                    Text {
                        text: case2Manager.isFinished ? " " : "> _"
                        color: "#ff0033"
                        font.family: root.fontFamily
                        font.pixelSize: 11
                        font.weight: Font.Bold
                        SequentialAnimation on opacity {
                            loops: Animation.Infinite
                            NumberAnimation { to: 0.0; duration: 300 }
                            NumberAnimation { to: 1.0; duration: 300 }
                        }
                    }
                }

                // Real-time telemetry coordinates footer
                Rectangle {
                    width: parent.width
                    height: 1
                    color: Qt.rgba(1.0, 0.0, 0.2, 0.2)
                }

                Text {
                    text: "SAT: 34.50° N, 76.50° E | ALT: 35,786 KM\nLOCK: ACTIVE | COHERENT BEAM: 1.21 GW"
                    color: Qt.rgba(1.0, 0.4, 0.4, 0.6)
                    font.family: root.fontFamily
                    font.pixelSize: 9
                    font.letterSpacing: 0.5
                }
            }
        }

        // ── Real-time Interactive GPS Cursor Telemetry (Bottom-Left) ──
        Rectangle {
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.margins: 20
            width: 290
            height: 38
            radius: 2
            color: Qt.rgba(0.05, 0.01, 0.01, 0.85)
            border.color: Qt.rgba(1.0, 0.0, 0.2, 0.4)
            border.width: 1

            RowLayout {
                anchors.centerIn: parent
                spacing: 8
                Text { text: "📍"; font.pixelSize: 11 }
                Text {
                    text: "CURSOR GPS //: " + (worldMap.cursorLat >= 0 ? worldMap.cursorLat.toFixed(3) + "° N" : Math.abs(worldMap.cursorLat).toFixed(3) + "° S") + ", " + (worldMap.cursorLon >= 0 ? worldMap.cursorLon.toFixed(3) + "° E" : Math.abs(worldMap.cursorLon).toFixed(3) + "° W")
                    color: "#ff4d4d"
                    font.family: root.fontFamily
                    font.pixelSize: 10
                    font.weight: Font.Bold
                    font.letterSpacing: 0.5
                }
            }
        }

        // ── Controls: Return to Access Terminal ──
        Rectangle {
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 20
            width: 220
            height: 38
            radius: 2
            color: abortMouse.containsMouse ? "#3d1414" : Qt.rgba(0.1, 0.02, 0.02, 0.85)
            border.color: abortMouse.containsMouse ? "#ff3b30" : Qt.rgba(1.0, 0.0, 0.2, 0.5)
            border.width: 1

            Behavior on color { ColorAnimation { duration: 150 } }

            Text {
                anchors.centerIn: parent
                text: "[ RETURN TO BASE // ESC ]"
                color: abortMouse.containsMouse ? "#ffffff" : "#ff4d4d"
                font.family: root.fontFamily
                font.pixelSize: 11
                font.weight: Font.Bold
                font.letterSpacing: 1.2
            }

            MouseArea {
                id: abortMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    case2Manager.stopSequence()
                    root.errorMessage = ""
                    root.state = "CASE_1"
                }
            }
        }
    }

    // ═══════════════════════════════════════════
    //  CASE 2 SEQUENCE ORCHESTRATION MANAGER
    // ═══════════════════════════════════════════
    QtObject {
        id: case2Manager
        property var feedLines: []
        property bool isFinished: false

        function startSequence() {
            feedLines = []
            isFinished = false
            worldMap.laserActive = false
            worldMap.targetLocked = false

            // Initial zoomed out global view
            worldMap.center = QtPositioning.coordinate(20.0, 0.0)
            worldMap.zoomLevel = 2.2
            worldMap.satLat = 58.0
            worldMap.satLon = 35.0

            step1Timer.restart()
        }

        function stopSequence() {
            panZoomAnim.stop()
            satDeployAnim.stop()
            step1Timer.stop()
            step2Timer.stop()
            step3Timer.stop()
            step4Timer.stop()
            step5Timer.stop()
            step6Timer.stop()
            worldMap.laserActive = false
            worldMap.targetLocked = false
        }
    }

    // ── Step 1: > INITIALIZING ORBITAL TRACKING... ──
    Timer {
        id: step1Timer
        interval: 300
        repeat: false
        onTriggered: {
            case2Manager.feedLines = ["> INITIALIZING ORBITAL TRACKING..."]
            // Begin Geographical Pan & Zoom toward India
            panZoomAnim.restart()
            step2Timer.restart()
        }
    }

    // ── 2. Geographical Pan & Zoom Animation to India ──
    ParallelAnimation {
        id: panZoomAnim
        CoordinateAnimation {
            target: worldMap
            property: "center"
            to: QtPositioning.coordinate(23.5937, 78.9629)
            duration: 2200
            easing.type: Easing.InOutCubic
        }
        NumberAnimation {
            target: worldMap
            property: "zoomLevel"
            to: 5.5
            duration: 2200
            easing.type: Easing.InOutQuad
        }
    }

    // ── Step 2: > SATELLITE UPLINK ESTABLISHED. ──
    Timer {
        id: step2Timer
        interval: 1000
        repeat: false
        onTriggered: {
            var lines = case2Manager.feedLines
            lines.push("> SATELLITE UPLINK ESTABLISHED.")
            case2Manager.feedLines = lines
            step3Timer.restart()
        }
    }

    // ── Step 3: > SECURING ENCRYPTED CHANNELS... ──
    Timer {
        id: step3Timer
        interval: 900
        repeat: false
        onTriggered: {
            var lines = case2Manager.feedLines
            lines.push("> SECURING ENCRYPTED CHANNELS...")
            case2Manager.feedLines = lines
            // Begin Satellite Deployment from offscreen
            satDeployAnim.restart()
            step4Timer.restart()
        }
    }

    // ── 3. Satellite Deployment Animation across real GPS coordinates ──
    ParallelAnimation {
        id: satDeployAnim
        NumberAnimation {
            target: worldMap
            property: "satLat"
            to: 34.5000       // Northern India orbital hover
            duration: 1800
            easing.type: Easing.OutCubic
        }
        NumberAnimation {
            target: worldMap
            property: "satLon"
            to: 76.5000
            duration: 1800
            easing.type: Easing.OutCubic
        }
    }

    // ── Step 4: > ACQUIRING GPS COORDINATES... ──
    Timer {
        id: step4Timer
        interval: 850
        repeat: false
        onTriggered: {
            var lines = case2Manager.feedLines
            lines.push("> ACQUIRING GPS COORDINATES...")
            case2Manager.feedLines = lines
            step5Timer.restart()
        }
    }

    // ── Step 5: > TRIANGULATING TRAJECTORY... ──
    Timer {
        id: step5Timer
        interval: 900
        repeat: false
        onTriggered: {
            var lines = case2Manager.feedLines
            lines.push("> TRIANGULATING TRAJECTORY...")
            case2Manager.feedLines = lines
            step6Timer.restart()
        }
    }

    // ── Step 6: > TARGET LOCKED. (Laser targeting activates!) ──
    Timer {
        id: step6Timer
        interval: 950
        repeat: false
        onTriggered: {
            var lines = case2Manager.feedLines
            lines.push("> TARGET LOCKED.")
            case2Manager.feedLines = lines
            case2Manager.isFinished = true

            // Deploy pulsing target reticle and fire coherent laser beam!
            worldMap.targetLocked = true
            worldMap.laserActive = true
            console.log("[TACTICAL SDDM] Target Locked in Central India. Coherent laser ray engaged.")
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

    // Keyboard Shortcuts
    focus: true
    Keys.onPressed: function(event) {
        if (event.key === Qt.Key_Escape) {
            if (root.state === "CASE_2") {
                case2Manager.stopSequence()
                root.errorMessage = ""
                root.state = "CASE_1"
                event.accepted = true
            }
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
