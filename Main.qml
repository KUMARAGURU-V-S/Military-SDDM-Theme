/*
 *  NATIONAL INVESTIGATION AGENCY (NIA) - TACTICAL DEFENSE SDDM GREETER
 *  ──────────────────────────────────────────────────────────────────
 *  Aesthetic: Authentic military command console & tactical C4ISR terminal
 *  State Machine:
 *    - CASE_1: Tactical command authentication screen with centered NIA SVG emblem
 *    - CASE_2: Tactical OpenStreetMap satellite & laser targeting sequence
 *    - CASE_3: Commander-in-Chief Ground Station, Submarine Strike, & Ballistic Intercept
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
    readonly property color pmoGoldColor:           "#e5a93c"
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

    // State machine: "CASE_1", "CASE_2", "CASE_3"
    state: "CASE_1"
    signal triggerCase2()
    signal triggerCase3()

    onTriggerCase2: {
        root.state = "CASE_2"
        case2Manager.startSequence()
    }

    onTriggerCase3: {
        root.state = "CASE_3"
        case3Manager.startSequence()
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
                        model: (typeof sessionModel !== "undefined") ? sessionModel : ["Plasma (Wayland)", "Plasma (X11)", "Custom Session"]
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
    //  CASE 2 & CASE 3 SHARED TACTICAL MAP CONTAINER
    // ═══════════════════════════════════════════
    Item {
        id: tacticalMapContainer
        anchors.fill: parent
        visible: root.state === "CASE_2" || root.state === "CASE_3"
        opacity: (root.state === "CASE_2" || root.state === "CASE_3") ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 400 } }

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

        // ── Tactical OpenStreetMap ──
        Map {
            id: worldMap
            anchors.fill: parent
            plugin: mapPlugin
            center: QtPositioning.coordinate(20.0, 0.0)
            zoomLevel: 2.2
            copyrightsVisible: false

            // Coordinates for telemetry
            property real satLat: 58.0
            property real satLon: 35.0
            property real targetLat: 21.1458   // Central India (Target Command Node)
            property real targetLon: 79.0882
            property real subLat: 14.5000      // Bay of Bengal Submarine
            property real subLon: 86.2000
            property real carrierLat: 16.0000  // Arabian Sea INS Vikrant
            property real carrierLon: 70.5000
            property real tejasLat: 26.2000    // Secret Airbase (Western Sector)
            property real tejasLon: 72.8000
            property real missileLat: 14.5000
            property real missileLon: 86.2000
            property real missileProgress: 0.0
            onMissileProgressChanged: {
                var t = missileProgress
                var lat0 = subLat, lon0 = subLon
                var lat1 = targetLat, lon1 = targetLon
                missileLat = (1 - t) * lat0 + t * lat1 + 2.8 * Math.sin(Math.PI * t)
                missileLon = (1 - t) * lon0 + t * lon1
            }
            property real cursorLat: 21.1458
            property real cursorLon: 79.0882

            // Operational status flags
            property bool laserActive: false
            property bool targetLocked: false
            property bool assetsVisible: false
            property bool missileInFlight: false
            property bool targetDestroyed: false

            // Map interaction
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

            // ── Case 2: Laser Targeting Polyline ──
            MapPolyline {
                id: laserGlow
                visible: worldMap.laserActive && !worldMap.targetDestroyed
                line.width: 12
                line.color: Qt.rgba(1.0, 0.0, 0.15, laserGlowPulse.pulseAlpha)
                path: [
                    QtPositioning.coordinate(worldMap.satLat, worldMap.satLon),
                    QtPositioning.coordinate(worldMap.targetLat, worldMap.targetLon)
                ]
            }

            MapPolyline {
                id: laserBeam
                visible: worldMap.laserActive && !worldMap.targetDestroyed
                line.width: 4
                line.color: "#ff0033"
                path: [
                    QtPositioning.coordinate(worldMap.satLat, worldMap.satLon),
                    QtPositioning.coordinate(worldMap.targetLat, worldMap.targetLon)
                ]
            }

            MapPolyline {
                id: laserCore
                visible: worldMap.laserActive && !worldMap.targetDestroyed
                line.width: 1.5
                line.color: "#ffffff"
                path: [
                    QtPositioning.coordinate(worldMap.satLat, worldMap.satLon),
                    QtPositioning.coordinate(worldMap.targetLat, worldMap.targetLon)
                ]
            }

            Item {
                id: laserGlowPulse
                property real pulseAlpha: 0.4
                SequentialAnimation on pulseAlpha {
                    running: worldMap.laserActive && !worldMap.targetDestroyed
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.75; duration: 180; easing.type: Easing.InOutQuad }
                    NumberAnimation { to: 0.35; duration: 180; easing.type: Easing.InOutQuad }
                }
            }

            // ── Case 3: Ballistic Missile Trajectory Arc ──
            MapPolyline {
                id: missileTrajectoryGlow
                visible: worldMap.missileInFlight || worldMap.targetDestroyed
                line.width: 7
                line.color: Qt.rgba(1.0, 0.4, 0.0, 0.35)
                path: case3Manager.ballisticPath
            }

            MapPolyline {
                id: missileTrajectoryPath
                visible: worldMap.missileInFlight || worldMap.targetDestroyed
                line.width: 2.5
                line.color: "#ffaa00"
                path: case3Manager.ballisticPath
            }

            // ── Target Reticle / Destruction Graphic (Central India) ──
            MapQuickItem {
                id: groundTargetItem
                coordinate: QtPositioning.coordinate(worldMap.targetLat, worldMap.targetLon)
                anchorPoint.x: 45
                anchorPoint.y: 45
                visible: worldMap.targetLocked

                sourceItem: Item {
                    width: 90
                    height: 90

                    // Pulsing radar ring (pre-destruction)
                    Rectangle {
                        anchors.centerIn: parent
                        width: 70
                        height: 70
                        radius: 35
                        color: "transparent"
                        border.color: worldMap.targetDestroyed ? "#ff3300" : "#ff0033"
                        border.width: 2
                        visible: !worldMap.targetDestroyed

                        SequentialAnimation on scale {
                            running: worldMap.targetLocked && !worldMap.targetDestroyed
                            loops: Animation.Infinite
                            NumberAnimation { from: 0.5; to: 1.35; duration: 1200; easing.type: Easing.OutQuad }
                        }
                        SequentialAnimation on opacity {
                            running: worldMap.targetLocked && !worldMap.targetDestroyed
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
                        color: worldMap.targetDestroyed ? Qt.rgba(1.0, 0.2, 0.0, 0.3) : Qt.rgba(1.0, 0.0, 0.2, 0.15)
                        border.color: worldMap.targetDestroyed ? "#ff3300" : "#ff0033"
                        border.width: 2
                    }

                    Rectangle {
                        anchors.centerIn: parent
                        width: 12
                        height: 12
                        radius: 6
                        color: worldMap.targetDestroyed ? "#ff8800" : "#ff0033"
                    }

                    Rectangle { width: 80; height: 1; color: worldMap.targetDestroyed ? "#ff3300" : "#ff0033"; anchors.centerIn: parent }
                    Rectangle { width: 1; height: 80; color: worldMap.targetDestroyed ? "#ff3300" : "#ff0033"; anchors.centerIn: parent }

                    // Destruction Explosion Shockwaves
                    Rectangle {
                        id: explosionShockwave
                        anchors.centerIn: parent
                        width: 80
                        height: 80
                        radius: 40
                        color: "transparent"
                        border.color: "#ffaa00"
                        border.width: 4
                        visible: worldMap.targetDestroyed

                        SequentialAnimation on scale {
                            running: worldMap.targetDestroyed
                            loops: Animation.Infinite
                            NumberAnimation { from: 0.2; to: 2.2; duration: 900; easing.type: Easing.OutQuad }
                        }
                        SequentialAnimation on opacity {
                            running: worldMap.targetDestroyed
                            loops: Animation.Infinite
                            NumberAnimation { from: 1.0; to: 0.0; duration: 900; easing.type: Easing.OutQuad }
                        }
                    }

                    // Label
                    Text {
                        anchors.top: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.topMargin: 4
                        text: worldMap.targetDestroyed ? "💥 TARGET DESTROYED // 100% NEUTRALIZED" : "TGT // 21.1458° N, 79.0882° E"
                        color: worldMap.targetDestroyed ? "#00ff88" : "#ff3b30"
                        font.family: root.fontFamily
                        font.pixelSize: 10
                        font.weight: Font.Bold
                        style: Text.Outline
                        styleColor: "#000000"
                    }
                }
            }

            // ── Case 2 Satellite (Northern India) ──
            MapQuickItem {
                id: satItem
                coordinate: QtPositioning.coordinate(worldMap.satLat, worldMap.satLon)
                anchorPoint.x: 35
                anchorPoint.y: 35
                visible: root.state === "CASE_2" || root.state === "CASE_3"

                sourceItem: Item {
                    width: 70
                    height: 70

                    Rectangle {
                        width: 8; height: 8; radius: 4; color: "#00ff88"
                        anchors.horizontalCenter: parent.horizontalCenter; anchors.top: parent.top
                        SequentialAnimation on opacity {
                            loops: Animation.Infinite
                            NumberAnimation { to: 0.1; duration: 400 }
                            NumberAnimation { to: 1.0; duration: 400 }
                        }
                    }
                    Rectangle { width: 22; height: 12; radius: 1; color: "#1c2b36"; border.color: "#4ef289"; border.width: 1; anchors.verticalCenter: parent.verticalCenter; anchors.right: satBody.left; anchors.rightMargin: 3 }
                    Rectangle {
                        id: satBody
                        width: 18; height: 24; radius: 2; color: "#283523"; border.color: "#88ff3333"; border.width: 1; anchors.centerIn: parent
                        Rectangle { anchors.bottom: parent.bottom; anchors.horizontalCenter: parent.horizontalCenter; width: 6; height: 6; radius: 3; color: worldMap.laserActive ? "#ff0033" : "#666666"; border.color: "#ffffff"; border.width: 1 }
                    }
                    Rectangle { width: 22; height: 12; radius: 1; color: "#1c2b36"; border.color: "#4ef289"; border.width: 1; anchors.verticalCenter: parent.verticalCenter; anchors.left: satBody.right; anchors.leftMargin: 3 }
                    Text {
                        anchors.bottom: parent.top; anchors.horizontalCenter: parent.horizontalCenter; anchors.bottomMargin: 2
                        text: "GSAT-7A // MIL-ORBIT"; color: "#4ef289"; font.family: root.fontFamily; font.pixelSize: 9; font.weight: Font.Bold; style: Text.Outline; styleColor: "#000000"
                    }
                }
            }

            // ── Case 3 Military Assets: 1. Submarine INS Arihant (Bay of Bengal) ──
            MapQuickItem {
                id: subItem
                coordinate: QtPositioning.coordinate(worldMap.subLat, worldMap.subLon)
                anchorPoint.x: 35
                anchorPoint.y: 35
                visible: worldMap.assetsVisible

                sourceItem: Item {
                    width: 70
                    height: 70

                    // Pulsing Sonar Ping Rings
                    Rectangle {
                        anchors.centerIn: parent
                        width: 50; height: 50; radius: 25
                        color: "transparent"; border.color: "#00ff88"; border.width: 1.5
                        SequentialAnimation on scale {
                            loops: Animation.Infinite
                            NumberAnimation { from: 0.5; to: 1.8; duration: 1500; easing.type: Easing.OutQuad }
                        }
                        SequentialAnimation on opacity {
                            loops: Animation.Infinite
                            NumberAnimation { from: 1.0; to: 0.0; duration: 1500; easing.type: Easing.OutQuad }
                        }
                    }

                    // Submarine Hull Icon
                    Rectangle {
                        id: subHull
                        anchors.centerIn: parent
                        width: 36; height: 12; radius: 6
                        color: "#18261b"; border.color: "#00ff88"; border.width: 1.5
                        // Conning Tower
                        Rectangle { width: 8; height: 7; radius: 1; color: "#00ff88"; anchors.horizontalCenter: parent.horizontalCenter; anchors.bottom: parent.top }
                    }

                    Text {
                        anchors.top: subHull.bottom; anchors.horizontalCenter: parent.horizontalCenter; anchors.topMargin: 4
                        text: "INS ARIHANT (SSBN-80)\n[ BAY OF BENGAL // STRIKE ASSET ]"
                        color: "#00ff88"; font.family: root.fontFamily; font.pixelSize: 9; font.weight: Font.Bold; horizontalAlignment: Text.AlignHCenter; style: Text.Outline; styleColor: "#000000"
                    }
                }
            }

            // ── Case 3 Military Assets: 2. Warship INS Vikrant (Arabian Sea) ──
            MapQuickItem {
                id: carrierItem
                coordinate: QtPositioning.coordinate(worldMap.carrierLat, worldMap.carrierLon)
                anchorPoint.x: 35
                anchorPoint.y: 35
                visible: worldMap.assetsVisible

                sourceItem: Item {
                    width: 70
                    height: 70

                    Rectangle {
                        id: carrierHull
                        anchors.centerIn: parent
                        width: 34; height: 14; radius: 2
                        color: "#1c2226"; border.color: "#4e9af2"; border.width: 1
                        Rectangle { width: 10; height: 4; color: "#4e9af2"; anchors.right: parent.right; anchors.top: parent.top }
                    }

                    Text {
                        anchors.top: carrierHull.bottom; anchors.horizontalCenter: parent.horizontalCenter; anchors.topMargin: 3
                        text: "INS VIKRANT (R11)\n[ ARABIAN SEA CSG ]"
                        color: "#4e9af2"; font.family: root.fontFamily; font.pixelSize: 8; font.weight: Font.Bold; horizontalAlignment: Text.AlignHCenter; style: Text.Outline; styleColor: "#000000"
                    }
                }
            }

            // ── Case 3 Military Assets: 3. Tejas Squadron (Secret Forward Base) ──
            MapQuickItem {
                id: tejasItem
                coordinate: QtPositioning.coordinate(worldMap.tejasLat, worldMap.tejasLon)
                anchorPoint.x: 35
                anchorPoint.y: 35
                visible: worldMap.assetsVisible

                sourceItem: Item {
                    width: 70
                    height: 70

                    Rectangle {
                        id: tejasBody
                        anchors.centerIn: parent
                        width: 18; height: 18; radius: 9
                        color: "#283523"; border.color: "#e5a93c"; border.width: 1
                        Text { anchors.centerIn: parent; text: "✈"; color: "#e5a93c"; font.pixelSize: 12 }
                    }

                    Text {
                        anchors.top: tejasBody.bottom; anchors.horizontalCenter: parent.horizontalCenter; anchors.topMargin: 3
                        text: "IAF TEJAS MK1A\n[ TRISHUL BASE ]"
                        color: "#e5a93c"; font.family: root.fontFamily; font.pixelSize: 8; font.weight: Font.Bold; horizontalAlignment: Text.AlignHCenter; style: Text.Outline; styleColor: "#000000"
                    }
                }
            }

            // ── In-Flight Ballistic Missile (MapQuickItem traveling along trajectory) ──
            MapQuickItem {
                id: flyingMissileItem
                coordinate: QtPositioning.coordinate(worldMap.missileLat, worldMap.missileLon)
                anchorPoint.x: 15
                anchorPoint.y: 15
                visible: worldMap.missileInFlight

                sourceItem: Item {
                    width: 30
                    height: 30

                    // Exhaust flame pulse
                    Rectangle {
                        anchors.centerIn: parent
                        width: 22; height: 22; radius: 11
                        color: Qt.rgba(1.0, 0.4, 0.0, 0.5)
                        SequentialAnimation on scale {
                            loops: Animation.Infinite
                            NumberAnimation { to: 1.4; duration: 80 }
                            NumberAnimation { to: 0.8; duration: 80 }
                        }
                    }

                    // Warhead core
                    Rectangle {
                        anchors.centerIn: parent
                        width: 8; height: 8; radius: 4
                        color: "#ffffff"
                        border.color: "#ff3300"; border.width: 1
                    }

                    Text {
                        anchors.bottom: parent.top; anchors.horizontalCenter: parent.horizontalCenter; anchors.bottomMargin: 2
                        text: "K-4 SLBM // HYPERSONIC"; color: "#ffaa00"; font.family: root.fontFamily; font.pixelSize: 9; font.weight: Font.Bold; style: Text.Outline; styleColor: "#000000"
                    }
                }
            }
        }

        // Surveillance Vignette Overlay
        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(0, 0, 0, 0.22)
            enabled: false
        }

        // ═══════════════════════════════════════════
        //  TOP-LEFT: CASE 2 HUD OR CASE 3 SUBMARINE LAUNCH FLIR CAM
        // ═══════════════════════════════════════════

        // ── Case 2 Red Terminal Box (Disappears in Case 3) ──
        Rectangle {
            id: hudFeedBox
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.margins: 22
            width: 380
            height: hudColumn.implicitHeight + 28
            radius: 2
            visible: root.state === "CASE_2"
            opacity: root.state === "CASE_2" ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 400 } }

            color: Qt.rgba(0.08, 0.015, 0.015, 0.88)
            border.color: "#ff0033"
            border.width: 1

            Column {
                id: hudColumn
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 14
                spacing: 8

                RowLayout {
                    width: parent.width
                    Text { text: "[ TACTICAL UPLINK FEED ]"; color: "#ff3b30"; font.family: root.fontFamily; font.pixelSize: 12; font.weight: Font.Bold; font.letterSpacing: 1.5 }
                    Item { Layout.fillWidth: true }
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
                        Text { text: "LIVE"; color: "#ff3b30"; font.family: root.fontFamily; font.pixelSize: 10; font.weight: Font.Bold }
                    }
                }

                Rectangle { width: parent.width; height: 1; color: Qt.rgba(1.0, 0.0, 0.2, 0.3) }

                Column {
                    width: parent.width
                    spacing: 4
                    Repeater {
                        model: case2Manager.feedLines
                        delegate: Text {
                            text: modelData
                            color: index === case2Manager.feedLines.length - 1 ? "#ffffff" : Qt.rgba(1.0, 0.8, 0.8, 0.85)
                            font.family: root.fontFamily; font.pixelSize: 11; font.letterSpacing: 0.8; wrapMode: Text.WordWrap; width: hudColumn.width
                        }
                    }
                    Text {
                        text: case2Manager.isFinished ? " " : "> _"
                        color: "#ff0033"; font.family: root.fontFamily; font.pixelSize: 11; font.weight: Font.Bold
                        SequentialAnimation on opacity {
                            loops: Animation.Infinite
                            NumberAnimation { to: 0.0; duration: 300 }
                            NumberAnimation { to: 1.0; duration: 300 }
                        }
                    }
                }

                Rectangle { width: parent.width; height: 1; color: Qt.rgba(1.0, 0.0, 0.2, 0.2) }
                Text { text: "SAT: 34.50° N, 76.50° E | ALT: 35,786 KM\nLOCK: ACTIVE | COHERENT BEAM: 1.21 GW"; color: Qt.rgba(1.0, 0.4, 0.4, 0.6); font.family: root.fontFamily; font.pixelSize: 9; font.letterSpacing: 0.5 }
            }
        }

        // ── Case 3 Green Night-Vision Submarine Surfacing & Launch FLIR Cam ──
        Rectangle {
            id: submarineFlirBox
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.margins: 22
            width: 420
            height: 290
            radius: 2
            visible: root.state === "CASE_3"
            opacity: root.state === "CASE_3" ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 500 } }

            // Sonar Night-Vision Green Palette
            color: Qt.rgba(0.02, 0.07, 0.03, 0.92)
            border.color: root.hudGreen
            border.width: 1

            Column {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 8

                // Header & Callsign Captions
                RowLayout {
                    width: parent.width
                    Text { text: "[ OPTICAL FLIR // BAY OF BENGAL ]"; color: root.hudGreen; font.family: root.fontFamily; font.pixelSize: 11; font.weight: Font.Bold; font.letterSpacing: 1.2 }
                    Item { Layout.fillWidth: true }
                    Text { text: "NIGHT-VISION CH-04"; color: root.mutedTextColor; font.family: root.fontFamily; font.pixelSize: 9 }
                }

                // Submarine Credentials & Status Bar
                Rectangle {
                    width: parent.width
                    height: 38
                    radius: 2
                    color: Qt.rgba(0.04, 0.12, 0.05, 0.8)
                    border.color: Qt.rgba(78, 242, 137, 0.25)
                    border.width: 1

                    Column {
                        anchors.centerIn: parent
                        spacing: 2
                        Text {
                            text: "SUB-ID: INS ARIHANT (SSBN-80) // CODE: CHAKRA-IV"
                            color: root.hudGreen; font.family: root.fontFamily; font.pixelSize: 10; font.weight: Font.Bold
                        }
                        Text {
                            text: case3Manager.subStatusText
                            color: "#ffffff"; font.family: root.fontFamily; font.pixelSize: 9; font.weight: Font.DemiBold
                        }
                    }
                }

                // Submarine Surfacing & Launch Animation Viewport
                Rectangle {
                    width: parent.width
                    height: 145
                    radius: 2
                    color: "#040e06"
                    clip: true
                    border.color: Qt.rgba(78, 242, 137, 0.2)
                    border.width: 1

                    // Sonar grid overlay lines
                    Repeater {
                        model: 5
                        Rectangle {
                            width: parent.width; height: 1; y: index * 30 + 10
                            color: Qt.rgba(78, 242, 137, 0.08)
                        }
                    }

                    // Ocean Surface Waterline
                    Rectangle {
                        id: waterLine
                        width: parent.width
                        height: 60
                        anchors.bottom: parent.bottom
                        color: Qt.rgba(0.02, 0.15, 0.08, 0.6)

                        // Surface foam ripples
                        Rectangle { width: parent.width; height: 2; color: root.hudGreen; opacity: 0.5 }
                    }

                    // Surfacing Submarine Hull
                    Item {
                        id: subGraphic
                        width: 180
                        height: 50
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: case3Manager.subHullY   // Animates from 90 (submerged) up to 60 (surfaced)

                        // Submarine Body
                        Rectangle {
                            width: 160
                            height: 26
                            radius: 12
                            anchors.bottom: parent.bottom
                            color: "#0a1f0f"
                            border.color: root.hudGreen
                            border.width: 1.5

                            // Conning Tower / Sail
                            Rectangle {
                                width: 26
                                height: 16
                                radius: 2
                                color: "#0d2613"
                                border.color: root.hudGreen
                                border.width: 1
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.bottom: parent.top

                                // Periscope mast
                                Rectangle { width: 2; height: 8; color: root.hudGreen; anchors.bottom: parent.top; anchors.horizontalCenter: parent.horizontalCenter }
                            }

                            // VLS Missile Silo Hatch (Aft deck)
                            Rectangle {
                                id: siloHatch
                                width: 14
                                height: 4
                                radius: 1
                                color: case3Manager.hatchOpen ? "#ffaa00" : root.hudGreen
                                anchors.right: parent.right
                                anchors.rightMargin: 35
                                anchors.top: parent.top
                                anchors.topMargin: -2

                                // Hatch angle animation when open
                                transform: Rotation {
                                    angle: case3Manager.hatchOpen ? -65 : 0
                                    origin.x: 0; origin.y: 2
                                    Behavior on angle { NumberAnimation { duration: 600 } }
                                }
                            }
                        }

                        // Ejecting Missile Graphic from Hatch
                        Item {
                            id: launchEgressMissile
                            width: 10
                            height: 28
                            anchors.right: parent.right
                            anchors.rightMargin: 37
                            y: case3Manager.missileEgressY   // Animates upward into sky
                            visible: case3Manager.missileEgressing

                            // Missile body
                            Rectangle {
                                width: 8
                                height: 26
                                radius: 2
                                color: "#ffffff"
                                border.color: root.hudGreen
                                border.width: 1
                            }

                            // Rocket booster exhaust plume
                            Rectangle {
                                width: 12
                                height: 20
                                radius: 4
                                anchors.top: parent.bottom
                                anchors.horizontalCenter: parent.horizontalCenter
                                color: Qt.rgba(1.0, 0.5, 0.0, 0.85)

                                SequentialAnimation on height {
                                    loops: Animation.Infinite
                                    NumberAnimation { to: 30; duration: 60 }
                                    NumberAnimation { to: 18; duration: 60 }
                                }
                            }
                        }
                    }

                    // Crosshair Periscope Reticle
                    Rectangle { width: parent.width; height: 1; color: Qt.rgba(78, 242, 137, 0.25); anchors.centerIn: parent }
                    Rectangle { width: 1; height: parent.height; color: Qt.rgba(78, 242, 137, 0.25); anchors.centerIn: parent }
                }

                // Telemetry Footer
                Text {
                    text: "DEPTH: 0.0M (SURFACED) | BALLAST: PURGED | SILO CELL-04: FIRED"
                    color: root.mutedTextColor; font.family: root.fontFamily; font.pixelSize: 9; font.letterSpacing: 0.5
                }
            }
        }

        // ═══════════════════════════════════════════
        //  TOP-RIGHT: COMMANDER-IN-CHIEF GROUND STATION (CASE 3)
        // ═══════════════════════════════════════════
        Rectangle {
            id: pmoCommandBox
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 22
            width: 410
            height: pmoColumn.implicitHeight + 28
            radius: 2
            visible: root.state === "CASE_3"
            opacity: root.state === "CASE_3" ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 400 } }

            // Strategic Forces Command Amber/Military Gold Aesthetic
            color: Qt.rgba(0.08, 0.05, 0.02, 0.92)
            border.color: root.pmoGoldColor
            border.width: 1

            Column {
                id: pmoColumn
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 14
                spacing: 8

                RowLayout {
                    width: parent.width
                    Text { text: "[ COMMANDER-IN-CHIEF // GROUND STATION ]"; color: root.pmoGoldColor; font.family: root.fontFamily; font.pixelSize: 11; font.weight: Font.Bold; font.letterSpacing: 1.2 }
                    Item { Layout.fillWidth: true }
                    Row {
                        spacing: 4
                        Rectangle {
                            width: 6; height: 6; radius: 3; color: root.pmoGoldColor
                            anchors.verticalCenter: parent.verticalCenter
                            SequentialAnimation on opacity {
                                loops: Animation.Infinite
                                NumberAnimation { to: 0.2; duration: 300 }
                                NumberAnimation { to: 1.0; duration: 300 }
                            }
                        }
                        Text { text: "DEFCON 1"; color: root.pmoGoldColor; font.family: root.fontFamily; font.pixelSize: 10; font.weight: Font.Bold }
                    }
                }

                Rectangle { width: parent.width; height: 1; color: Qt.rgba(229, 169, 60, 0.3) }

                Column {
                    width: parent.width
                    spacing: 4
                    Repeater {
                        model: case3Manager.eventLines
                        delegate: Text {
                            text: modelData
                            color: index === case3Manager.eventLines.length - 1 ? "#ffffff" : Qt.rgba(1.0, 0.9, 0.7, 0.85)
                            font.family: root.fontFamily; font.pixelSize: 10; font.letterSpacing: 0.6; wrapMode: Text.WordWrap; width: pmoColumn.width
                        }
                    }
                    Text {
                        text: case3Manager.isFinished ? "[ MISSION COMPLETE // DEFCON 5 ]" : "> _"
                        color: root.pmoGoldColor; font.family: root.fontFamily; font.pixelSize: 11; font.weight: Font.Bold
                        SequentialAnimation on opacity {
                            loops: Animation.Infinite
                            NumberAnimation { to: 0.0; duration: 250 }
                            NumberAnimation { to: 1.0; duration: 250 }
                        }
                    }
                }

                Rectangle { width: parent.width; height: 1; color: Qt.rgba(229, 169, 60, 0.2) }
                Text { text: "AUTH KEY // PMO: #984-ALPHA-CMD | CAPTAIN: #412-KILO-VLS\nCLEARANCE: NCA-PRIME-MINISTER-OFFICIAL"; color: Qt.rgba(229, 169, 60, 0.6); font.family: root.fontFamily; font.pixelSize: 8; font.letterSpacing: 0.5 }
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

        // ── Controls: Escalate to Case 3 or Return to Base ──
        Row {
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 20
            spacing: 12

            // Escalate to Case 3 Button (visible during Case 2)
            Rectangle {
                width: 240
                height: 38
                radius: 2
                visible: root.state === "CASE_2"
                color: case3BtnMouse.containsMouse ? "#3d2d14" : Qt.rgba(0.12, 0.08, 0.02, 0.85)
                border.color: case3BtnMouse.containsMouse ? root.pmoGoldColor : Qt.rgba(229, 169, 60, 0.6)
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: "[ ESCALATE: STRIKE OPS // CASE 3 ]"
                    color: case3BtnMouse.containsMouse ? "#ffffff" : root.pmoGoldColor
                    font.family: root.fontFamily
                    font.pixelSize: 11
                    font.weight: Font.Bold
                    font.letterSpacing: 1.0
                }

                MouseArea {
                    id: case3BtnMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.triggerCase3()
                }
            }

            // Return to Base Button
            Rectangle {
                width: 210
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
                        case3Manager.stopSequence()
                        root.errorMessage = ""
                        root.state = "CASE_1"
                    }
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
            worldMap.assetsVisible = false
            worldMap.missileInFlight = false
            worldMap.targetDestroyed = false

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
            autoCase3Timer.stop()
            worldMap.laserActive = false
            worldMap.targetLocked = false
        }
    }

    Timer {
        id: step1Timer
        interval: 300
        repeat: false
        onTriggered: {
            case2Manager.feedLines = ["> INITIALIZING ORBITAL TRACKING..."]
            panZoomAnim.restart()
            step2Timer.restart()
        }
    }

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

    Timer {
        id: step3Timer
        interval: 900
        repeat: false
        onTriggered: {
            var lines = case2Manager.feedLines
            lines.push("> SECURING ENCRYPTED CHANNELS...")
            case2Manager.feedLines = lines
            satDeployAnim.restart()
            step4Timer.restart()
        }
    }

    ParallelAnimation {
        id: satDeployAnim
        NumberAnimation { target: worldMap; property: "satLat"; to: 34.5000; duration: 1800; easing.type: Easing.OutCubic }
        NumberAnimation { target: worldMap; property: "satLon"; to: 76.5000; duration: 1800; easing.type: Easing.OutCubic }
    }

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

    Timer {
        id: step6Timer
        interval: 950
        repeat: false
        onTriggered: {
            var lines = case2Manager.feedLines
            lines.push("> TARGET LOCKED.")
            case2Manager.feedLines = lines
            case2Manager.isFinished = true

            worldMap.targetLocked = true
            worldMap.laserActive = true
            console.log("[TACTICAL SDDM] Target Locked in Central India. Coherent laser ray engaged.")

            // Automatically transition to Case 3 after 2.5 seconds
            autoCase3Timer.restart()
        }
    }

    Timer {
        id: autoCase3Timer
        interval: 2500
        repeat: false
        onTriggered: {
            console.log("[TACTICAL SDDM] Transitioning automatically from Case 2 to Case 3 Strategic Strike.")
            root.triggerCase3()
        }
    }

    // ═══════════════════════════════════════════
    //  CASE 3 SEQUENCE ORCHESTRATION MANAGER
    // ═══════════════════════════════════════════
    QtObject {
        id: case3Manager
        property var eventLines: []
        property var ballisticPath: []
        property bool isFinished: false
        property real subHullY: 90
        property real missileEgressY: 10
        property bool hatchOpen: false
        property bool missileEgressing: false
        property string subStatusText: "STATUS: SUBMERGED // DEPTH: 80M"

        function startSequence() {
            eventLines = []
            isFinished = false
            subHullY = 90
            missileEgressY = 10
            hatchOpen = false
            missileEgressing = false
            worldMap.laserActive = false
            worldMap.targetDestroyed = false
            worldMap.missileInFlight = false
            worldMap.assetsVisible = true
            subStatusText = "STATUS: RUNNING SILENT // SCANNING ASSETS..."

            // Compute Ballistic Trajectory Coordinates Arc
            var pts = []
            var lat0 = worldMap.subLat, lon0 = worldMap.subLon
            var lat1 = worldMap.targetLat, lon1 = worldMap.targetLon
            for (var i = 0; i <= 25; i++) {
                var t = i / 25.0
                var arcLat = (1 - t) * lat0 + t * lat1 + 2.8 * Math.sin(Math.PI * t)
                var arcLon = (1 - t) * lon0 + t * lon1
                pts.push(QtPositioning.coordinate(arcLat, arcLon))
            }
            ballisticPath = pts

            c3Step1Timer.restart()
        }

        function stopSequence() {
            c3Step1Timer.stop()
            c3Step2Timer.stop()
            c3Step3Timer.stop()
            c3Step4Timer.stop()
            c3Step5Timer.stop()
            c3Step6Timer.stop()
            c3Step7Timer.stop()
            c3Step8Timer.stop()
            missileFlightAnim.stop()
        }
    }

    // C3 Step 1: Commander in Chief Ground Station Alert
    Timer {
        id: c3Step1Timer
        interval: 400
        repeat: false
        onTriggered: {
            case3Manager.eventLines = [
                "> STRATEGIC FORCES COMMAND (SFC) ALERT ACKNOWLEDGED.",
                "> SCANNING THEATRE LAUNCH PLATFORMS..."
            ]
            c3Step2Timer.restart()
        }
    }

    // C3 Step 2: Locating Nearby Launch Vehicles
    Timer {
        id: c3Step2Timer
        interval: 1200
        repeat: false
        onTriggered: {
            var lines = case3Manager.eventLines
            lines.push("  [+] AIR FORCE: TEJAS MK1A // BASE TRISHUL [ARMED]")
            lines.push("  [+] NAVY: INS VIKRANT CSG // ARABIAN SEA [PATROL]")
            lines.push("  [+] STRATEGIC: INS ARIHANT // BAY OF BENGAL [OPTIMAL]")
            lines.push("> SELECTING PRIMARY STRIKE ASSET: INS ARIHANT")
            case3Manager.eventLines = lines

            // Shift focus between Target and Launch Asset (Bay of Bengal)
            c3FocusPanAnim.restart()
            c3Step3Timer.restart()
        }
    }

    // Camera Pans to Focus on Submarine in Bay of Bengal
    ParallelAnimation {
        id: c3FocusPanAnim
        CoordinateAnimation {
            target: worldMap
            property: "center"
            to: QtPositioning.coordinate(15.2, 85.5)
            duration: 2000
            easing.type: Easing.InOutCubic
        }
        NumberAnimation {
            target: worldMap
            property: "zoomLevel"
            to: 6.2
            duration: 2000
            easing.type: Easing.InOutQuad
        }
    }

    // C3 Step 3: Secure Quantum Link Established
    Timer {
        id: c3Step3Timer
        interval: 1800
        repeat: false
        onTriggered: {
            var lines = case3Manager.eventLines
            lines.push("> SECURE QUANTUM LINK ESTABLISHED WITH ASSET.")
            lines.push("> AWAITING DUAL-KEY AUTH FROM PMO & COMMANDER-IN-CHIEF...")
            case3Manager.eventLines = lines
            c3Step4Timer.restart()
        }
    }

    // C3 Step 4: Authorize Code Verification (PM & Captain)
    Timer {
        id: c3Step4Timer
        interval: 1400
        repeat: false
        onTriggered: {
            var lines = case3Manager.eventLines
            lines.push("> VERIFYING DUAL-KEY PROTOCOL:")
            lines.push("  [PMO / COMMANDER-IN-CHIEF]: CODE #984-ALPHA [MATCHED]")
            lines.push("  [SUBMARINE CAPTAIN CODE]: #412-KILO [MATCHED]")
            lines.push("> STRIKE AUTHORIZATION GRANTED BY PRIME MINISTER.")
            case3Manager.eventLines = lines

            // Submarine begins surfacing animation in FLIR cam
            case3Manager.subStatusText = "STATUS: BLOWING MAIN BALLAST // SURFACING..."
            subSurfaceAnim.restart()
            c3Step5Timer.restart()
        }
    }

    // Submarine Surfacing Animation (Hull rises through waterline)
    NumberAnimation {
        id: subSurfaceAnim
        target: case3Manager
        property: "subHullY"
        to: 62
        duration: 1500
        easing.type: Easing.OutQuad
    }

    // C3 Step 5: Silo Hatch Opens & Egress Begins
    Timer {
        id: c3Step5Timer
        interval: 1700
        repeat: false
        onTriggered: {
            var lines = case3Manager.eventLines
            lines.push("> INS ARIHANT SURFACED. OPENING VLS CELL-04 HATCH...")
            case3Manager.eventLines = lines

            case3Manager.hatchOpen = true
            case3Manager.subStatusText = "STATUS: HATCH OPEN // COLD GAS EJECTION ARMED"

            c3Step6Timer.restart()
        }
    }

    // C3 Step 6: Missile Ejection & Rocket Motor Ignition
    Timer {
        id: c3Step6Timer
        interval: 1200
        repeat: false
        onTriggered: {
            var lines = case3Manager.eventLines
            lines.push("> MISSILE EGRESS: K-4 SLBM EJECTED FROM SILO!")
            lines.push("> BOOSTER IGNITION CONFIRMED. CLIMBING TO APOGEE...")
            case3Manager.eventLines = lines

            case3Manager.missileEgressing = true
            case3Manager.subStatusText = "STATUS: LAUNCH COMMENCED // 1ST STAGE IGNITION"

            // Egress upward animation in FLIR cam
            missileFlirEgressAnim.restart()

            // Map camera pans out to theatre overview showing flight from Bay of Bengal to Central India
            c3TheatrePanAnim.restart()

            // Ballistic flight across map begins
            worldMap.missileInFlight = true
            missileFlightAnim.restart()

            c3Step7Timer.restart()
        }
    }

    NumberAnimation {
        id: missileFlirEgressAnim
        target: case3Manager
        property: "missileEgressY"
        to: -50
        duration: 900
        easing.type: Easing.InQuad
    }

    ParallelAnimation {
        id: c3TheatrePanAnim
        CoordinateAnimation {
            target: worldMap
            property: "center"
            to: QtPositioning.coordinate(18.2, 82.5)
            duration: 2200
            easing.type: Easing.InOutCubic
        }
        NumberAnimation {
            target: worldMap
            property: "zoomLevel"
            to: 5.2
            duration: 2200
            easing.type: Easing.InOutQuad
        }
    }

    // Ballistic missile position interpolation along trajectory arc
    NumberAnimation {
        id: missileFlightAnim
        target: worldMap
        property: "missileProgress"
        from: 0.0
        to: 1.0
        duration: 3600
        easing.type: Easing.InOutQuad

        onFinished: {
            // Missile impact on target!
            worldMap.missileInFlight = false
            worldMap.targetDestroyed = true
            c3Step8Timer.restart()
        }
    }

    // C3 Step 7: Hypersonic Terminal Dive
    Timer {
        id: c3Step7Timer
        interval: 2200
        repeat: false
        onTriggered: {
            var lines = case3Manager.eventLines
            lines.push("> APOGEE REACHED (350 KM). TERMINAL DIVE AT MACH 7.5...")
            case3Manager.eventLines = lines
            case3Manager.subStatusText = "STATUS: LAUNCH SUCCESSFUL // RE-SUBMERGING TO 120M"
        }
    }

    // C3 Step 8: Impact & Destruction Confirmed
    Timer {
        id: c3Step8Timer
        interval: 200
        repeat: false
        onTriggered: {
            var lines = case3Manager.eventLines
            lines.push("> KINETIC IMPACT CONFIRMED AT 21.1458° N, 79.0882° E.")
            lines.push("> TARGET ANNIHILATED. BDA ASSESSMENT: 100% NEUTRALIZED.")
            lines.push("> MISSION ACCOMPLISHED. STRATEGIC ORDER EXECUTED.")
            case3Manager.eventLines = lines
            case3Manager.isFinished = true

            // Final camera zoom into destroyed target
            c3ImpactZoomAnim.restart()
        }
    }

    ParallelAnimation {
        id: c3ImpactZoomAnim
        CoordinateAnimation {
            target: worldMap
            property: "center"
            to: QtPositioning.coordinate(worldMap.targetLat, worldMap.targetLon)
            duration: 1200
            easing.type: Easing.OutCubic
        }
        NumberAnimation {
            target: worldMap
            property: "zoomLevel"
            to: 6.4
            duration: 1200
            easing.type: Easing.OutQuad
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

        NumberAnimation { target: errorText; property: "opacity"; to: 0.0; duration: 90; easing.type: Easing.Linear }
        NumberAnimation { target: errorText; property: "opacity"; to: 1.0; duration: 90; easing.type: Easing.Linear }
        NumberAnimation { target: errorText; property: "opacity"; to: 0.0; duration: 90; easing.type: Easing.Linear }
        NumberAnimation { target: errorText; property: "opacity"; to: 1.0; duration: 90; easing.type: Easing.Linear }
        NumberAnimation { target: errorText; property: "opacity"; to: 0.0; duration: 90; easing.type: Easing.Linear }
        NumberAnimation { target: errorText; property: "opacity"; to: 1.0; duration: 90; easing.type: Easing.Linear }

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
            sddm.login(userField.text, passField.text, sessionSelector.currentIndex)
        } else {
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
            root.errorMessage = "Login Attempt Failed"
            root.currentErrorColor = root.alertRedColor
            errorText.opacity = 1.0
            rapidBlinkAnim.restart()
        } else {
            root.currentErrorColor = root.errorColor
            root.errorMessage = defaultMsg ? defaultMsg : "ACCESS DENIED: INVALID CREDENTIALS"
            errorText.opacity = 1.0
        }
    }

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

    focus: true
    Keys.onPressed: function(event) {
        if (event.key === Qt.Key_Escape) {
            if (root.state === "CASE_2" || root.state === "CASE_3") {
                case2Manager.stopSequence()
                case3Manager.stopSequence()
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
