/*
 *  SDDM World Map Interactive Theme (Qt 6 / Plasma 6 compatible)
 *  ─────────────────────────────────────────────────────────────
 *  An interactive zoomable world map login screen with
 *  country quick-navigation, smooth animations, and offline tile cache.
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
    color: (typeof config !== "undefined" && config.backgroundColor) ? config.backgroundColor : "#0a0e17"

    // ═══════════════════════════════════════════
    //  THEME PROPERTIES
    // ═══════════════════════════════════════════

    readonly property color accentColor:   (typeof config !== "undefined" && config.accentColor)   ? config.accentColor   : "#00d4ff"
    readonly property color cardColor:     (typeof config !== "undefined" && config.cardColor)     ? config.cardColor     : "#1a1e2e"
    readonly property color textColor:     (typeof config !== "undefined" && config.textColor)     ? config.textColor     : "#e8e8e8"
    readonly property color errorColor:    (typeof config !== "undefined" && config.errorColor)    ? config.errorColor    : "#ff4757"
    readonly property color successColor:  (typeof config !== "undefined" && config.successColor)  ? config.successColor  : "#2ed573"
    readonly property real  cardOpacity:   (typeof config !== "undefined" && config.cardOpacity)   ? parseFloat(config.cardOpacity)   : 0.88
    readonly property int   cardWidth:     (typeof config !== "undefined" && config.cardWidth)     ? parseInt(config.cardWidth)       : 400
    readonly property int   cardRadius:    (typeof config !== "undefined" && config.cardRadius)    ? parseInt(config.cardRadius)      : 16
    readonly property bool  animEnabled:   (typeof config !== "undefined" && config.animationsEnabled === "false") ? false : true
    readonly property int   animDuration:  (typeof config !== "undefined" && config.animationDuration) ? parseInt(config.animationDuration) : 1200
    readonly property real  mapDarken:     (typeof config !== "undefined" && config.mapDarken)     ? parseFloat(config.mapDarken)     : 0.25
    readonly property bool  showCountryNav: (typeof config !== "undefined" && config.showCountryNav === "false") ? false : true
    readonly property int   countryNavW:   (typeof config !== "undefined" && config.countryNavWidth) ? parseInt(config.countryNavWidth) : 220
    readonly property string navPosition:  (typeof config !== "undefined" && config.countryNavPosition) ? config.countryNavPosition : "left"
    readonly property bool  showClock:     (typeof config !== "undefined" && config.showClock === "false") ? false : true
    readonly property string clockFormat:  (typeof config !== "undefined" && config.clockFormat)  ? config.clockFormat  : "hh:mm"
    readonly property string dateFormat:   (typeof config !== "undefined" && config.dateFormat)   ? config.dateFormat   : "dddd, MMMM d, yyyy"
    readonly property int   clockFontSize: (typeof config !== "undefined" && config.clockFontSize) ? parseInt(config.clockFontSize) : 48
    readonly property int   fontSize:      (typeof config !== "undefined" && config.fontSize)      ? parseInt(config.fontSize)      : 14
    readonly property string fontFamily:   (typeof config !== "undefined" && config.fontFamily)   ? config.fontFamily : "sans-serif"
    readonly property real  defaultLat:    (typeof config !== "undefined" && config.defaultLatitude)  ? parseFloat(config.defaultLatitude)  : 20.0
    readonly property real  defaultLon:    (typeof config !== "undefined" && config.defaultLongitude) ? parseFloat(config.defaultLongitude) : 0.0
    readonly property real  defaultZoom:   (typeof config !== "undefined" && config.defaultZoom)      ? parseFloat(config.defaultZoom)      : 2.5

    property string loginError: ""

    // ═══════════════════════════════════════════
    //  COUNTRY DATA MODEL
    // ═══════════════════════════════════════════

    ListModel {
        id: countriesModel

        // ── World Overview ──
        ListElement { name: "🌍 World";        lat: 20.0;    lon: 0.0;      zoom: 2.5; region: "overview" }

        // ── Asia ──
        ListElement { name: "🇮🇳 India";        lat: 20.5937; lon: 78.9629;  zoom: 5.0; region: "asia" }
        ListElement { name: "🇨🇳 China";        lat: 35.8617; lon: 104.1954; zoom: 4.0; region: "asia" }
        ListElement { name: "🇯🇵 Japan";        lat: 36.2048; lon: 138.2529; zoom: 5.5; region: "asia" }
        ListElement { name: "🇰🇷 South Korea";  lat: 35.9078; lon: 127.7669; zoom: 7.0; region: "asia" }
        ListElement { name: "🇮🇩 Indonesia";    lat: -0.7893; lon: 113.9213; zoom: 4.5; region: "asia" }
        ListElement { name: "🇸🇬 Singapore";    lat: 1.3521;  lon: 103.8198; zoom: 11.0; region: "asia" }

        // ── Europe ──
        ListElement { name: "🇬🇧 United Kingdom"; lat: 55.3781; lon: -3.4360;  zoom: 5.5; region: "europe" }
        ListElement { name: "🇫🇷 France";       lat: 46.6034; lon: 1.8883;   zoom: 6.0; region: "europe" }
        ListElement { name: "🇩🇪 Germany";      lat: 51.1657; lon: 10.4515;  zoom: 6.0; region: "europe" }
        ListElement { name: "🇮🇹 Italy";        lat: 41.8719; lon: 12.5674;  zoom: 6.0; region: "europe" }
        ListElement { name: "🇪🇸 Spain";        lat: 40.4637; lon: -3.7492;  zoom: 6.0; region: "europe" }
        ListElement { name: "🇳🇱 Netherlands";  lat: 52.1326; lon: 5.2913;   zoom: 7.0; region: "europe" }
        ListElement { name: "🇷🇺 Russia";       lat: 61.5240; lon: 105.3188; zoom: 3.0; region: "europe" }

        // ── Americas ──
        ListElement { name: "🇺🇸 United States"; lat: 39.8283; lon: -98.5795; zoom: 4.0; region: "americas" }
        ListElement { name: "🇨🇦 Canada";       lat: 56.1304; lon: -106.3468; zoom: 3.5; region: "americas" }
        ListElement { name: "🇲🇽 Mexico";       lat: 23.6345; lon: -102.5528; zoom: 5.0; region: "americas" }
        ListElement { name: "🇧🇷 Brazil";       lat: -14.2350; lon: -51.9253; zoom: 4.0; region: "americas" }
        ListElement { name: "🇦🇷 Argentina";    lat: -38.4161; lon: -63.6167; zoom: 4.5; region: "americas" }

        // ── Middle East & Africa ──
        ListElement { name: "🇦🇪 UAE";          lat: 23.4241; lon: 53.8478;  zoom: 7.0; region: "mideast" }
        ListElement { name: "🇸🇦 Saudi Arabia"; lat: 23.8859; lon: 45.0792;  zoom: 5.5; region: "mideast" }
        ListElement { name: "🇪🇬 Egypt";        lat: 26.8206; lon: 30.8025;  zoom: 6.0; region: "africa" }
        ListElement { name: "🇿🇦 South Africa"; lat: -30.5595; lon: 22.9375; zoom: 5.5; region: "africa" }
        ListElement { name: "🇳🇬 Nigeria";      lat: 9.0820;  lon: 8.6753;   zoom: 6.0; region: "africa" }

        // ── Oceania ──
        ListElement { name: "🇦🇺 Australia";    lat: -25.2744; lon: 133.7751; zoom: 4.0; region: "oceania" }
        ListElement { name: "🇳🇿 New Zealand";  lat: -40.9006; lon: 174.8860; zoom: 5.5; region: "oceania" }
    }

    // ═══════════════════════════════════════════
    //  MAP NAVIGATION FUNCTIONS
    // ═══════════════════════════════════════════

    function zoomToCountry(lat, lon, zoom) {
        worldMap.center = QtPositioning.coordinate(lat, lon)
        worldMap.zoomLevel = zoom
    }

    function resetView() {
        worldMap.center = QtPositioning.coordinate(defaultLat, defaultLon)
        worldMap.zoomLevel = defaultZoom
    }

    // ═══════════════════════════════════════════
    //  INTERACTIVE WORLD MAP (Background)
    // ═══════════════════════════════════════════

    Plugin {
        id: mapPlugin
        name: "osm"
        PluginParameter {
            name: "osm.mapping.cache.directory"
            value: (typeof config !== "undefined" && config.tileCacheDir) ? config.tileCacheDir : "/var/cache/sddm-worldmap-tiles"
        }
        PluginParameter {
            name: "osm.mapping.cache.disk.size"
            value: "500000000"   // 500 MB cache
        }
        PluginParameter {
            name: "osm.mapping.offline.directory"
            value: Qt.resolvedUrl("tiles/").toString().replace("file://", "")
        }
    }

    Map {
        id: worldMap
        anchors.fill: parent
        plugin: mapPlugin
        center: QtPositioning.coordinate(root.defaultLat, root.defaultLon)
        zoomLevel: root.defaultZoom
        copyrightsVisible: false

        // ── Smooth animations on center/zoom change ──
        Behavior on center {
            enabled: root.animEnabled
            CoordinateAnimation {
                duration: root.animDuration
                easing.type: Easing.InOutCubic
            }
        }
        Behavior on zoomLevel {
            enabled: root.animEnabled
            NumberAnimation {
                duration: root.animDuration * 0.7
                easing.type: Easing.InOutQuad
            }
        }

        // ── Pan and Zoom Interaction via Mouse / Drag ──
        MouseArea {
            id: mapMouseArea
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
                var zoomDelta = wheel.angleDelta.y > 0 ? 0.8 : -0.8
                var maxZ = (typeof config !== "undefined" && config.maxZoom) ? parseFloat(config.maxZoom) : 12
                var minZ = (typeof config !== "undefined" && config.minZoom) ? parseFloat(config.minZoom) : 1
                worldMap.zoomLevel = Math.max(minZ, Math.min(maxZ, worldMap.zoomLevel + zoomDelta))
                wheel.accepted = true
            }
        }

        // ── Map coordinate display (bottom-left) ──
        Text {
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.margins: 12
            text: "📍 " + worldMap.center.latitude.toFixed(2) + "°, " +
                  worldMap.center.longitude.toFixed(2) + "°  ×" +
                  worldMap.zoomLevel.toFixed(1)
            color: Qt.rgba(1, 1, 1, 0.5)
            font.pixelSize: 11
            font.family: "monospace"
            z: 10
        }
    }

    // ── Map darkening overlay (transparent to mouse) ──
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, root.mapDarken)
        enabled: false
        z: 1
    }

    // ═══════════════════════════════════════════
    //  CLOCK / DATE DISPLAY (Top Center)
    // ═══════════════════════════════════════════

    Column {
        id: clockDisplay
        visible: root.showClock
        anchors.top: parent.top
        anchors.topMargin: 40
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 4
        z: 10

        Text {
            id: clockText
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: root.clockFontSize
            font.family: "monospace"
            font.weight: Font.Light
            color: root.textColor
            style: Text.Raised
            styleColor: Qt.rgba(0, 0, 0, 0.6)

            Timer {
                interval: 1000
                running: true
                repeat: true
                triggeredOnStart: true
                onTriggered: {
                    var now = new Date()
                    clockText.text = Qt.formatTime(now, root.clockFormat)
                    dateText.text = Qt.formatDate(now, root.dateFormat)
                }
            }
        }

        Text {
            id: dateText
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: root.fontSize + 2
            font.family: root.fontFamily
            font.weight: Font.Normal
            color: Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.7)
            style: Text.Raised
            styleColor: Qt.rgba(0, 0, 0, 0.4)
        }
    }

    // ═══════════════════════════════════════════
    //  COUNTRY NAVIGATION PANEL (Left/Right Side)
    // ═══════════════════════════════════════════

    Rectangle {
        id: countryNavPanel
        visible: root.showCountryNav
        width: root.countryNavW
        height: parent.height - 100
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: root.navPosition === "left" ? parent.left : undefined
        anchors.right: root.navPosition === "right" ? parent.right : undefined
        anchors.leftMargin: root.navPosition === "left" ? 20 : 0
        anchors.rightMargin: root.navPosition === "right" ? 20 : 0
        radius: root.cardRadius
        color: Qt.rgba(root.cardColor.r, root.cardColor.g, root.cardColor.b, root.cardOpacity * 0.9)
        border.color: Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.15)
        border.width: 1
        z: 10

        Column {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8

            // ── Panel Title ──
            Text {
                text: "🌐 Navigate"
                font.pixelSize: root.fontSize + 4
                font.family: root.fontFamily
                font.weight: Font.Bold
                color: root.accentColor
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
            }

            // ── Search / Filter ──
            Rectangle {
                width: parent.width
                height: 32
                radius: 6
                color: Qt.rgba(0, 0, 0, 0.3)
                border.color: Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.3)
                border.width: 1

                TextInput {
                    id: searchInput
                    anchors.fill: parent
                    anchors.margins: 6
                    color: root.textColor
                    font.pixelSize: root.fontSize - 1
                    font.family: root.fontFamily
                    clip: true
                    selectByMouse: true

                    Text {
                        anchors.fill: parent
                        text: "🔍 Search country..."
                        color: Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.35)
                        font: parent.font
                        visible: !parent.text && !parent.activeFocus
                    }
                }
            }

            // ── Separator ──
            Rectangle { width: parent.width; height: 1; color: Qt.rgba(1, 1, 1, 0.08) }

            // ── Country List (Scrollable) ──
            ListView {
                id: countryList
                width: parent.width
                height: parent.height - 80
                clip: true
                model: countriesModel
                spacing: 3
                currentIndex: -1

                flickableDirection: Flickable.VerticalFlick
                boundsBehavior: Flickable.StopAtBounds

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                    width: 4
                    contentItem: Rectangle {
                        radius: 2
                        color: Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.4)
                    }
                }

                delegate: Rectangle {
                    id: countryDelegate
                    width: countryList.width
                    radius: 8
                    visible: {
                        if (!searchInput.text) return true
                        return model.name.toLowerCase().indexOf(searchInput.text.toLowerCase()) !== -1
                    }
                    height: visible ? 38 : 0
                    Behavior on height { NumberAnimation { duration: 150 } }

                    color: {
                        if (countryList.currentIndex === index)
                            return Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.25)
                        if (countryHover.containsMouse)
                            return Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.12)
                        return "transparent"
                    }

                    border.color: countryList.currentIndex === index
                        ? Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.5)
                        : "transparent"
                    border.width: 1

                    Behavior on color { ColorAnimation { duration: 200 } }

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        text: model.name
                        color: countryList.currentIndex === index ? root.accentColor : root.textColor
                        font.pixelSize: root.fontSize
                        font.family: root.fontFamily
                        font.weight: countryList.currentIndex === index ? Font.Bold : Font.Normal
                        elide: Text.ElideRight
                        width: parent.width - 20
                    }

                    MouseArea {
                        id: countryHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            countryList.currentIndex = index
                            root.zoomToCountry(model.lat, model.lon, model.zoom)
                        }
                    }
                }

                // ── Keyboard navigation ──
                Keys.onUpPressed:   decrementCurrentIndex()
                Keys.onDownPressed: incrementCurrentIndex()
                Keys.onReturnPressed: {
                    if (currentIndex >= 0) {
                        var item = countriesModel.get(currentIndex)
                        root.zoomToCountry(item.lat, item.lon, item.zoom)
                    }
                }
            }
        }
    }

    // ═══════════════════════════════════════════
    //  LOGIN CARD (Center-Right)
    // ═══════════════════════════════════════════

    Rectangle {
        id: loginCard
        width: root.cardWidth
        height: loginColumn.implicitHeight + 60
        anchors.right: parent.right
        anchors.rightMargin: root.showCountryNav && root.navPosition === "right"
            ? root.countryNavW + 60 : 80
        anchors.verticalCenter: parent.verticalCenter
        radius: root.cardRadius
        color: Qt.rgba(root.cardColor.r, root.cardColor.g, root.cardColor.b, root.cardOpacity)
        border.color: Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.2)
        border.width: 1
        z: 20

        // ── Subtle glow effect ──
        Rectangle {
            anchors.fill: parent
            anchors.margins: -1
            radius: parent.radius + 1
            color: "transparent"
            border.color: Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.08)
            border.width: 2
            z: -1
        }

        Column {
            id: loginColumn
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 30
            spacing: 16

            // ── Avatar / Welcome ──
            Item {
                width: parent.width
                height: 80

                Rectangle {
                    id: avatarCircle
                    width: 56
                    height: 56
                    radius: 28
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    color: Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.15)
                    border.color: root.accentColor
                    border.width: 2

                    Text {
                        anchors.centerIn: parent
                        text: "👤"
                        font.pixelSize: 24
                    }
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    text: "Welcome Back"
                    color: root.textColor
                    font.pixelSize: root.fontSize + 8
                    font.family: root.fontFamily
                    font.weight: Font.DemiBold
                }
            }

            // ── Username Field ──
            Column {
                width: parent.width
                spacing: 6

                Text {
                    text: "Username"
                    color: Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.6)
                    font.pixelSize: root.fontSize - 2
                    font.family: root.fontFamily
                    font.weight: Font.Medium
                }

                Rectangle {
                    id: userFieldBg
                    width: parent.width
                    height: 44
                    radius: 8
                    color: Qt.rgba(0, 0, 0, 0.35)
                    border.color: userField.activeFocus
                        ? root.accentColor
                        : Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.15)
                    border.width: userField.activeFocus ? 2 : 1

                    Behavior on border.color { ColorAnimation { duration: 200 } }

                    TextInput {
                        id: userField
                        anchors.fill: parent
                        anchors.margins: 12
                        color: root.textColor
                        font.pixelSize: root.fontSize
                        font.family: root.fontFamily
                        clip: true
                        selectByMouse: true
                        text: (typeof userModel !== "undefined" && userModel) ? (userModel.lastUser || "") : ""

                        KeyNavigation.tab: passField
                        Keys.onReturnPressed: passField.forceActiveFocus()

                        Text {
                            anchors.fill: parent
                            text: "Enter username"
                            color: Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.3)
                            font: parent.font
                            visible: !parent.text && !parent.activeFocus
                        }
                    }
                }
            }

            // ── Password Field ──
            Column {
                width: parent.width
                spacing: 6

                Text {
                    text: "Password"
                    color: Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.6)
                    font.pixelSize: root.fontSize - 2
                    font.family: root.fontFamily
                    font.weight: Font.Medium
                }

                Rectangle {
                    id: passFieldBg
                    width: parent.width
                    height: 44
                    radius: 8
                    color: Qt.rgba(0, 0, 0, 0.35)
                    border.color: passField.activeFocus
                        ? root.accentColor
                        : Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.15)
                    border.width: passField.activeFocus ? 2 : 1

                    Behavior on border.color { ColorAnimation { duration: 200 } }

                    TextInput {
                        id: passField
                        anchors.fill: parent
                        anchors.margins: 12
                        color: root.textColor
                        font.pixelSize: root.fontSize
                        font.family: root.fontFamily
                        echoMode: showPassBtn.checked ? TextInput.Normal : TextInput.Password
                        clip: true
                        selectByMouse: true

                        KeyNavigation.tab: loginBtn
                        Keys.onReturnPressed: root.tryLogin()

                        Text {
                            anchors.fill: parent
                            text: "Enter password"
                            color: Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.3)
                            font: parent.font
                            visible: !parent.text && !parent.activeFocus
                        }
                    }

                    // Show/hide password toggle
                    Rectangle {
                        id: showPassBtn
                        property bool checked: false
                        anchors.right: parent.right
                        anchors.rightMargin: 6
                        anchors.verticalCenter: parent.verticalCenter
                        width: 30
                        height: 30
                        radius: 6
                        color: checked
                            ? Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.2)
                            : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: parent.checked ? "👁️" : "🔒"
                            font.pixelSize: 14
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: parent.checked = !parent.checked
                        }
                    }
                }
            }

            // ── Caps Lock Warning ──
            Text {
                id: capsWarning
                width: parent.width
                text: "⚠️ Caps Lock is ON"
                color: root.errorColor
                font.pixelSize: root.fontSize - 2
                font.family: root.fontFamily
                font.weight: Font.Medium
                visible: (typeof keyboard !== "undefined" && keyboard && keyboard.capsLock) ? true : false
                horizontalAlignment: Text.AlignHCenter
                height: visible ? implicitHeight : 0
            }

            // ── Error Message ──
            Text {
                id: errorMsg
                width: parent.width
                text: root.loginError
                color: root.errorColor
                font.pixelSize: root.fontSize - 1
                font.family: root.fontFamily
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                visible: text !== ""
                height: visible ? implicitHeight : 0

                Behavior on opacity { NumberAnimation { duration: 300 } }
            }

            // ── Login Button ──
            Rectangle {
                id: loginBtn
                width: parent.width
                height: 46
                radius: 8
                color: loginBtnMouse.containsMouse
                    ? Qt.lighter(root.accentColor, 1.15)
                    : root.accentColor

                Behavior on color { ColorAnimation { duration: 200 } }

                property bool isLoading: false

                Text {
                    anchors.centerIn: parent
                    text: loginBtn.isLoading ? "⏳ Logging in..." : "🔓  Log In"
                    color: "#000000"
                    font.pixelSize: root.fontSize + 1
                    font.family: root.fontFamily
                    font.weight: Font.Bold
                }

                MouseArea {
                    id: loginBtnMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.tryLogin()
                }

                focus: true
                Keys.onReturnPressed: root.tryLogin()
                KeyNavigation.tab: sessionSelector
            }

            // ── Session Selector ──
            Row {
                width: parent.width
                spacing: 8
                visible: (typeof config !== "undefined" && config.showSessionSelector === "false") ? false : true

                Text {
                    text: "Session:"
                    color: Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.5)
                    font.pixelSize: root.fontSize - 1
                    font.family: root.fontFamily
                    anchors.verticalCenter: parent.verticalCenter
                }

                ComboBox {
                    id: sessionSelector
                    width: parent.width - 70
                    height: 36
                    model: (typeof sessionModel !== "undefined") ? sessionModel : null
                    currentIndex: (typeof sessionModel !== "undefined" && sessionModel) ? sessionModel.lastIndex : 0
                    textRole: "name"
                    font.pixelSize: root.fontSize - 1

                    background: Rectangle {
                        radius: 6
                        color: Qt.rgba(0, 0, 0, 0.3)
                        border.color: Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.2)
                        border.width: 1
                    }

                    contentItem: Text {
                        text: sessionSelector.displayText
                        color: root.textColor
                        font: sessionSelector.font
                        leftPadding: 10
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }
                }
            }

            // ── Power Buttons ──
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 20
                topPadding: 8

                // Shutdown
                Rectangle {
                    width: 42; height: 42; radius: 21
                    color: shutdownMouse.containsMouse
                        ? Qt.rgba(root.errorColor.r, root.errorColor.g, root.errorColor.b, 0.25)
                        : Qt.rgba(1, 1, 1, 0.06)
                    border.color: shutdownMouse.containsMouse ? root.errorColor : Qt.rgba(1, 1, 1, 0.1)
                    border.width: 1
                    Behavior on color { ColorAnimation { duration: 200 } }

                    Text {
                        anchors.centerIn: parent
                        text: "⏻"
                        font.pixelSize: 18
                        color: shutdownMouse.containsMouse ? root.errorColor : root.textColor
                    }
                    MouseArea {
                        id: shutdownMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (typeof sddm !== "undefined" && sddm) sddm.powerOff()
                        }
                    }
                    ToolTip {
                        visible: shutdownMouse.containsMouse
                        text: "Shutdown"
                        delay: 600
                    }
                }

                // Restart
                Rectangle {
                    width: 42; height: 42; radius: 21
                    color: restartMouse.containsMouse
                        ? Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.25)
                        : Qt.rgba(1, 1, 1, 0.06)
                    border.color: restartMouse.containsMouse ? root.accentColor : Qt.rgba(1, 1, 1, 0.1)
                    border.width: 1
                    Behavior on color { ColorAnimation { duration: 200 } }

                    Text {
                        anchors.centerIn: parent
                        text: "⟳"
                        font.pixelSize: 20
                        color: restartMouse.containsMouse ? root.accentColor : root.textColor
                    }
                    MouseArea {
                        id: restartMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (typeof sddm !== "undefined" && sddm) sddm.reboot()
                        }
                    }
                    ToolTip {
                        visible: restartMouse.containsMouse
                        text: "Restart"
                        delay: 600
                    }
                }

                // Suspend
                Rectangle {
                    width: 42; height: 42; radius: 21
                    color: suspendMouse.containsMouse
                        ? Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.25)
                        : Qt.rgba(1, 1, 1, 0.06)
                    border.color: suspendMouse.containsMouse ? root.accentColor : Qt.rgba(1, 1, 1, 0.1)
                    border.width: 1
                    Behavior on color { ColorAnimation { duration: 200 } }

                    Text {
                        anchors.centerIn: parent
                        text: "⏾"
                        font.pixelSize: 18
                        color: suspendMouse.containsMouse ? root.accentColor : root.textColor
                    }
                    MouseArea {
                        id: suspendMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (typeof sddm !== "undefined" && sddm) sddm.suspend()
                        }
                    }
                    ToolTip {
                        visible: suspendMouse.containsMouse
                        text: "Suspend"
                        delay: 600
                    }
                }
            }
        }
    }

    // ═══════════════════════════════════════════
    //  ZOOM CONTROLS (Bottom-Right)
    // ═══════════════════════════════════════════

    Column {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: 20
        anchors.bottomMargin: 20
        spacing: 6
        z: 10

        // Zoom In
        Rectangle {
            width: 36; height: 36; radius: 8
            color: zoomInMouse.containsMouse ? Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.3) : Qt.rgba(0, 0, 0, 0.5)
            border.color: Qt.rgba(1, 1, 1, 0.15)
            border.width: 1
            Text { anchors.centerIn: parent; text: "+"; color: "white"; font.pixelSize: 20; font.weight: Font.Bold }
            MouseArea {
                id: zoomInMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    var maxZ = (typeof config !== "undefined" && config.maxZoom) ? parseFloat(config.maxZoom) : 12
                    worldMap.zoomLevel = Math.min(maxZ, worldMap.zoomLevel + 1)
                }
            }
        }

        // Zoom Out
        Rectangle {
            width: 36; height: 36; radius: 8
            color: zoomOutMouse.containsMouse ? Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.3) : Qt.rgba(0, 0, 0, 0.5)
            border.color: Qt.rgba(1, 1, 1, 0.15)
            border.width: 1
            Text { anchors.centerIn: parent; text: "−"; color: "white"; font.pixelSize: 20; font.weight: Font.Bold }
            MouseArea {
                id: zoomOutMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    var minZ = (typeof config !== "undefined" && config.minZoom) ? parseFloat(config.minZoom) : 1
                    worldMap.zoomLevel = Math.max(minZ, worldMap.zoomLevel - 1)
                }
            }
        }

        // Reset View
        Rectangle {
            width: 36; height: 36; radius: 8
            color: resetMouse.containsMouse ? Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.3) : Qt.rgba(0, 0, 0, 0.5)
            border.color: Qt.rgba(1, 1, 1, 0.15)
            border.width: 1
            Text { anchors.centerIn: parent; text: "🌍"; font.pixelSize: 16 }
            MouseArea {
                id: resetMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.resetView()
            }
        }
    }

    // ═══════════════════════════════════════════
    //  LOGIN LOGIC
    // ═══════════════════════════════════════════

    function tryLogin() {
        root.loginError = ""
        loginBtn.isLoading = true

        if (!userField.text) {
            root.loginError = "Please enter your username"
            loginBtn.isLoading = false
            userField.forceActiveFocus()
            return
        }
        if (!passField.text) {
            root.loginError = "Please enter your password"
            loginBtn.isLoading = false
            passField.forceActiveFocus()
            return
        }

        if (typeof sddm !== "undefined" && sddm) {
            sddm.login(userField.text, passField.text, sessionSelector.currentIndex)
        }
    }

    // ── Handle login signals from SDDM ──
    Connections {
        target: (typeof sddm !== "undefined") ? sddm : null
        function onLoginFailed() {
            loginBtn.isLoading = false
            root.loginError = "❌ Login failed. Check your credentials."
            passField.text = ""
            passField.forceActiveFocus()

            // Shake animation on error
            shakeAnim.start()
        }
        function onLoginSucceeded() {
            loginBtn.isLoading = false
        }
    }

    // ── Shake animation for login card on error ──
    SequentialAnimation {
        id: shakeAnim
        PropertyAnimation { target: loginCard; property: "x"; to: loginCard.x - 12; duration: 50 }
        PropertyAnimation { target: loginCard; property: "x"; to: loginCard.x + 12; duration: 50 }
        PropertyAnimation { target: loginCard; property: "x"; to: loginCard.x - 8;  duration: 50 }
        PropertyAnimation { target: loginCard; property: "x"; to: loginCard.x + 8;  duration: 50 }
        PropertyAnimation { target: loginCard; property: "x"; to: loginCard.x;       duration: 50 }
    }

    // ═══════════════════════════════════════════
    //  KEYBOARD SHORTCUTS
    // ═══════════════════════════════════════════

    focus: true
    Keys.onPressed: function(event) {
        if (event.key === Qt.Key_Escape) {
            resetView()
            event.accepted = true
        }
    }

    // ── Auto-focus password field on load ──
    Component.onCompleted: {
        if (userField.text) {
            passField.forceActiveFocus()
        } else {
            userField.forceActiveFocus()
        }
    }
}
