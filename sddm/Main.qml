pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Effects
import "components"
import "singletons"

// Boot login screen styled like the Caelestia lock screen: frosted date and clock on top,
// a quiet "Enter Password" hint at the bottom that turns into a password field when you type
Rectangle {
    id: root

    // Settings loaded dynamically from /var/tmp/caelestia-sddm/login.json
    property bool twelveHour: false
    property bool showPowerButtons: true
    property string customBgImage: ""
    property bool videoActive: false
    property string buffer: ""
    property bool authenticating: false
    property string error: ""
    property var now: new Date()
    property color clockPrimary: Theme.mPrimary
    property color clockSecondary: Theme.mSecondary
    property color clockTertiary: Theme.mTertiary
    readonly property bool capsLock: (typeof keyboard !== "undefined") ? keyboard.capsLock : false

    Component.onCompleted: {
        const req = new XMLHttpRequest();
        req.open("GET", "file:///var/tmp/caelestia-sddm/login.json");
        req.onreadystatechange = function() {
            if (req.readyState === XMLHttpRequest.DONE && req.status === 200) {
                try {
                    const cfg = JSON.parse(req.responseText);
                    if (cfg.twelveHour !== undefined) root.twelveHour = cfg.twelveHour;
                    if (cfg.showPowerButtons !== undefined) root.showPowerButtons = cfg.showPowerButtons;
                    if (cfg.background === "video") {
                        root.videoActive = true;
                    } else {
                        root.customBgImage = "file:///var/tmp/caelestia-sddm/background";
                    }
                    if (cfg.colours) {
                        const isLight = !!cfg.colours.light;
                        root.clockPrimary = (isLight && cfg.colours.primaryFixed) ? cfg.colours.primaryFixed : (cfg.colours.primary || Theme.mPrimary);
                        root.clockSecondary = (isLight && cfg.colours.secondaryFixed) ? cfg.colours.secondaryFixed : (cfg.colours.secondary || Theme.mSecondary);
                        root.clockTertiary = (isLight && cfg.colours.tertiaryFixed) ? cfg.colours.tertiaryFixed : (cfg.colours.tertiary || Theme.mTertiary);
                        if (cfg.colours.primary) Theme.mPrimary = cfg.colours.primary;
                        if (cfg.colours.secondary) Theme.mSecondary = cfg.colours.secondary;
                        if (cfg.colours.tertiary) Theme.mTertiary = cfg.colours.tertiary;
                        if (cfg.colours.onSurface) Theme.mOnSurface = cfg.colours.onSurface;
                        if (cfg.colours.surface) Theme.mSurface = cfg.colours.surface;
                        if (cfg.colours.surfaceContainer) Theme.mSurfaceContainer = cfg.colours.surfaceContainer;
                        if (cfg.colours.outline) Theme.mOutline = cfg.colours.outline;
                    }
                } catch (e) {}
            }
        };
        req.send();
    }
    readonly property string userName: {
        if (userModel.count > 0) {
            const idx = (userModel.lastIndex >= 0 && userModel.lastIndex < userModel.count) ? userModel.lastIndex : 0;
            return userModel.data(userModel.index(idx, 0), Qt.UserRole + 1);
        }
        return "";
    }

    function login(): void {
        if (!buffer || authenticating)
            return;
        error = "";
        authenticating = true;
        const sIdx = (sessionModel.lastIndex >= 0 && sessionModel.lastIndex < sessionModel.count) ? sessionModel.lastIndex : 0;
        sddm.login(userName, buffer, sIdx);
        buffer = "";
    }

    width: 1920
    height: 1080
    readonly property real s: Math.max(0.6, root.height / 1080)
    color: "black"

    // Same font as the Caelestia shell; loaded from the theme because the greeter can't read ~/.local/share/fonts
    readonly property string fontFamily: googleSansFlex.name

    FontLoader {
        id: googleSansFlex

        source: "assets/google-sans-flex/GoogleSansFlex.ttf"
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.now = new Date()
    }

    Connections {
        function onLoginFailed(): void {
            root.authenticating = false;
            root.error = "Incorrect password";
            keyHandler.forceActiveFocus();
        }

        target: sddm
    }

    Item {
        id: keyHandler

        focus: true
        Component.onCompleted: forceActiveFocus()
        Keys.onPressed: event => {
            if (root.authenticating)
                return;
            if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
                root.login();
            } else if (event.key === Qt.Key_Escape) {
                root.buffer = "";
            } else if (event.key === Qt.Key_Backspace) {
                root.buffer = (event.modifiers & Qt.ControlModifier) ? "" : root.buffer.slice(0, -1);
            } else if (event.text && /^[^\x00-\x1F\x7F-\x9F]+$/.test(event.text)) {
                root.error = "";
                root.buffer += event.text;
            }
            event.accepted = true;
        }
    }

    // Wallpaper (or video) stays sharp until you type, then softly blurs
    Item {
        id: background

        anchors.fill: parent

        Item {
            anchors.fill: parent

            layer.enabled: true
            layer.effect: MultiEffect {
                autoPaddingEnabled: false
                blurEnabled: true
                blurMax: 48
                blur: root.buffer || root.authenticating ? 1 : 0

                Behavior on blur {
                    NumberAnimation {
                        duration: 400
                        easing.type: Easing.OutCubic
                    }
                }
            }

            AnimatedImage {
                anchors.fill: parent
                source: root.customBgImage || Theme.backgroundSource
                fillMode: Image.PreserveAspectCrop
            }

            Loader {
                anchors.fill: parent
                active: root.videoActive
                source: "components/VideoBackground.qml"
            }
        }

        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop {
                    position: 0
                    color: Qt.rgba(0, 0, 0, 0.3)
                }
                GradientStop {
                    position: 0.45
                    color: Qt.rgba(0, 0, 0, 0.05)
                }
                GradientStop {
                    position: 1
                    color: Qt.rgba(0, 0, 0, 0.35)
                }
            }
        }
    }

    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 80 * root.s
        spacing: 8 * root.s

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDate(root.now, "ddd, d MMM")
            color: root.clockTertiary
            font.family: root.fontFamily
            font.pixelSize: 22 * root.s
            font.weight: Font.DemiBold
            font.variableAxes: ({ "wght": 600 })

            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                blurMax: 16
                shadowColor: Qt.rgba(0, 0, 0, 0.5)
                shadowVerticalOffset: 2
            }
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 2 * root.s

            Text {
                text: root.twelveHour ? Qt.formatTime(root.now, "h") : Qt.formatTime(root.now, "HH")
                color: root.clockPrimary
                font.family: root.fontFamily
                font.pixelSize: 108 * root.s
                font.weight: Font.Medium
                font.variableAxes: ({ "wght": 500 })

                layer.enabled: true
                layer.effect: MultiEffect {
                    shadowEnabled: true
                    blurMax: 20
                    shadowColor: Qt.rgba(0, 0, 0, 0.5)
                    shadowVerticalOffset: 3
                }
            }

            Text {
                text: ":"
                color: Theme.withAlpha(Theme.mOutline, 0.75)
                font.family: root.fontFamily
                font.pixelSize: 108 * root.s
                font.weight: Font.Medium
                font.variableAxes: ({ "wght": 500 })
                topPadding: -4 * root.s

                layer.enabled: true
                layer.effect: MultiEffect {
                    shadowEnabled: true
                    blurMax: 20
                    shadowColor: Qt.rgba(0, 0, 0, 0.5)
                    shadowVerticalOffset: 3
                }
            }

            Text {
                text: Qt.formatTime(root.now, "mm")
                color: root.clockSecondary
                font.family: root.fontFamily
                font.pixelSize: 108 * root.s
                font.weight: Font.Medium
                font.variableAxes: ({ "wght": 500 })

                layer.enabled: true
                layer.effect: MultiEffect {
                    shadowEnabled: true
                    blurMax: 20
                    shadowColor: Qt.rgba(0, 0, 0, 0.5)
                    shadowVerticalOffset: 3
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        z: -1
        onClicked: keyHandler.forceActiveFocus()
    }

    Item {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 50 * root.height / 1080
        width: 300
        height: 44 + 32

        Rectangle {
            id: field

            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            height: 48
            radius: 16
            color: Theme.mSurfaceContainer
            border.width: 1
            border.color: Theme.withAlpha(Theme.mOutline, 0.5)

            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                blurMax: 16
                shadowColor: Qt.rgba(0, 0, 0, 0.35)
                shadowVerticalOffset: 3
            }

            MouseArea {
                anchors.fill: parent
                onClicked: keyHandler.forceActiveFocus()
            }

            Text {
                anchors.centerIn: parent
                text: root.authenticating ? "Logging in…" : "Enter Password"
                color: Theme.mOnSurfaceVariant
                font.family: root.fontFamily
                font.pixelSize: 16
                font.weight: Font.Medium
                visible: !root.buffer
            }

            Text {
                anchors.centerIn: parent
                width: parent.width - 40
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideLeft
                text: "•".repeat(root.buffer.length)
                color: Theme.mOnSurface
                font.pixelSize: 20
                visible: !!root.buffer
            }
        }

        Text {
            anchors.top: field.bottom
            anchors.topMargin: 8
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.error || (root.capsLock ? "Caps Lock is on" : "")
            color: root.error ? Theme.mError : Qt.rgba(1, 1, 1, 0.7)
            font.family: root.fontFamily
            font.pixelSize: 14
        }
    }

    Row {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 16
        spacing: 8
        visible: root.showPowerButtons

        PowerButton {
            width: 44
            height: 44
            iconText: "restart_alt"
            onRestoreFocus: () => keyHandler.forceActiveFocus()
            onClickedAction: () => sddm.reboot()
        }

        PowerButton {
            width: 44
            height: 44
            iconText: "power_settings_new"
            onRestoreFocus: () => keyHandler.forceActiveFocus()
            onClickedAction: () => sddm.powerOff()
        }
    }


}
