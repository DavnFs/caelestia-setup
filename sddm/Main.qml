pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Effects
import "components"
import "singletons"

// Boot login screen styled like the Caelestia lock screen: frosted date and clock on top,
// a quiet "Enter Password" hint at the bottom that turns into a password field when you type
Rectangle {
    id: root

    // shortcut: 12-hour clock is fixed here because SDDM can't read the shell's setting; flip if you switch to 24-hour
    readonly property bool twelveHour: true
    property string buffer: ""
    property bool authenticating: false
    property string error: ""
    property var now: new Date()
    readonly property bool capsLock: (typeof keyboard !== "undefined") ? keyboard.capsLock : false
    readonly property string userName: {
        if (userModel.count > 0 && userModel.lastIndex >= 0)
            return userModel.data(userModel.index(userModel.lastIndex, 0), Qt.UserRole + 1);
        return "";
    }

    function login(): void {
        if (!buffer || authenticating)
            return;
        error = "";
        authenticating = true;
        sddm.login(userName, buffer, sessionModel.lastIndex);
        buffer = "";
    }

    width: 1920
    height: 1080
    color: "black"

    // Same font as the Caelestia lock screen (Rubik, installed system-wide)
    readonly property string fontFamily: "Rubik"

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
                source: Theme.backgroundSource
                fillMode: Image.PreserveAspectCrop
            }

            Loader {
                anchors.fill: parent
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
        anchors.topMargin: 90 * root.height / 1080
        spacing: -10

        GlassText {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDate(root.now, "ddd d MMM")
            font.pixelSize: 30 * root.height / 1080
        }

        GlassText {
            anchors.horizontalCenter: parent.horizontalCenter
            // Qt only gives 12-hour "h" with an AM/PM marker; drop the marker like macOS does
            text: root.twelveHour ? Qt.formatTime(root.now, "h:mm AP").split(" ")[0] : Qt.formatTime(root.now, "HH:mm")
            font.pixelSize: 150 * root.height / 1080
        }
    }

    Item {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 50 * root.height / 1080
        width: 300
        height: 44 + 32

        Text {
            anchors.centerIn: field
            text: root.authenticating ? "Logging in…" : "Enter Password"
            color: Qt.rgba(1, 1, 1, 0.75)
            font.family: root.fontFamily
            font.pixelSize: 16
            font.weight: Font.Medium
            opacity: root.buffer ? 0 : 1

            Behavior on opacity {
                NumberAnimation {
                    duration: 200
                }
            }
        }

        Rectangle {
            id: field

            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            height: 44
            radius: height / 2
            color: Qt.rgba(1, 1, 1, 0.18)
            border.width: 1
            border.color: Qt.rgba(1, 1, 1, 0.28)
            opacity: root.buffer ? 1 : 0

            Behavior on opacity {
                NumberAnimation {
                    duration: 200
                }
            }

            Text {
                anchors.centerIn: parent
                width: parent.width - 40
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideLeft
                text: "•".repeat(root.buffer.length)
                color: "white"
                font.pixelSize: 20
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
        anchors.margins: 24
        spacing: 8

        PowerButton {
            width: 48
            height: 48
            iconText: "restart_alt"
            onRestoreFocus: () => keyHandler.forceActiveFocus()
            onClickedAction: () => sddm.reboot()
        }

        PowerButton {
            width: 48
            height: 48
            iconText: "power_settings_new"
            onRestoreFocus: () => keyHandler.forceActiveFocus()
            onClickedAction: () => sddm.powerOff()
        }
    }

    // Frosted-glass text: blurred background behind the letters, lightly tinted (same recipe as the lock screen)
    component GlassText: Item {
        id: glassText

        property alias text: shape.text
        property alias font: shape.font

        implicitWidth: shape.implicitWidth
        implicitHeight: shape.implicitHeight

        Text {
            id: shape

            anchors.fill: parent
            color: "white"
            font.family: root.fontFamily
            font.weight: Font.DemiBold
            // Rubik is a variable font; Qt only applies the weight through its axis
            font.variableAxes: ({ "wght": 600 })
            visible: false
            layer.enabled: true
        }

        Item {
            id: fill

            anchors.fill: parent
            visible: false
            layer.enabled: true

            ShaderEffectSource {
                id: behind

                anchors.fill: parent
                sourceItem: background
                sourceRect: {
                    glassText.x; glassText.y; glassText.width; glassText.height; // Re-map on layout
                    const p = glassText.mapToItem(background, 0, 0);
                    return Qt.rect(p.x, p.y, glassText.width, glassText.height);
                }
                visible: false
            }

            MultiEffect {
                anchors.fill: parent
                source: behind
                blurEnabled: true
                blurMax: 48
                blur: 1
                saturation: 0.2
            }

            Rectangle {
                anchors.fill: parent
                color: "white"
                opacity: 0.55
            }
        }

        MultiEffect {
            anchors.fill: parent
            source: fill
            maskEnabled: true
            maskSource: shape
            maskThresholdMin: 0.3
            maskSpreadAtMin: 0.3
        }
    }
}
