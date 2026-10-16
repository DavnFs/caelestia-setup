import "center"
import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.UPower
import Caelestia.Config
import Caelestia.I18n
import qs.components
import qs.components.images
import qs.services
import qs.utils

// macOS-style lock: date and big clock on top, a glass now-playing widget and a quiet password hint at the bottom
Item {
    id: root

    // Needs pam, screen and unlocking (the lock surface, or a stand-in for previews)
    required property var lock
    readonly property real s: Math.min(1, (lock.screen?.height ?? 1080) / 1080)
    readonly property color fg: "white"
    readonly property alias background: background
    readonly property alias foreground: foreground
    // Shown while a player has a track loaded (playing or paused)
    readonly property bool music: !!Players.active?.trackTitle
    // The password field only appears once you start typing, like macOS
    readonly property bool typing: !!lock.pam.buffer || !!lock.pam.passwd.active

    // Wallpaper stays sharp until you start typing, then softly blurs
    Item {
        id: background

        anchors.fill: parent

        CachingImage {
            anchors.fill: parent
            path: Wallpapers.current

            layer.enabled: true
            layer.effect: MultiEffect {
                autoPaddingEnabled: false
                blurEnabled: true
                blurMax: 48
                blur: root.typing ? 1 : 0

                Behavior on blur {
                    Anim {
                        type: Anim.StandardLarge
                    }
                }
            }
        }

        // Darken top and bottom so white text reads on any wallpaper
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

    Item {
        id: foreground

        anchors.fill: parent

        // Status in the top-right corner, like the macOS menu bar
        RowLayout {
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: Tokens.padding.extraLarge
            spacing: Tokens.spacing.small
            visible: UPower.displayDevice.isLaptopBattery

            StyledText {
                text: `${Math.round(UPower.displayDevice.percentage * 100)}%`
                color: root.fg
                font: Tokens.font.label.builders.small.weight(Font.Medium).build()
            }

            MaterialIcon {
                text: Icons.getBatteryIcon(UPower.displayDevice.percentage, !UPower.onBattery)
                color: root.fg
                fill: 1
            }
        }

        ColumnLayout {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 90 * root.s
            spacing: 0

            StyledText {
                Layout.alignment: Qt.AlignHCenter
                text: Time.format("ddd d MMM")
                color: root.fg
                opacity: 0.9
                font: Tokens.font.title.builders.medium.weight(Font.DemiBold).scale(1.15 * root.s).build()
            }

            StyledText {
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: -Tokens.spacing.small
                // Qt only gives 12-hour "h" with an AM/PM marker; drop the marker like macOS does
                text: Units.twelveHourClock ? Time.format("h:mm AP").split(" ")[0] : Time.format("HH:mm")
                color: root.fg
                opacity: 0.92
                font: Tokens.font.headline.builders.large.scale(4.2 * root.s).weight(Font.DemiBold).build()
            }
        }

        NowPlaying {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: passwordArea.top
            anchors.bottomMargin: 40 * root.s
            s: root.s
            blurSource: background
            visible: opacity > 0
            opacity: root.music ? 1 : 0

            Behavior on opacity {
                Anim {
                    type: Anim.DefaultEffects
                }
            }
        }

        // Fixed-height area so the widget above doesn't jump when the field appears
        Item {
            id: passwordArea

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 50 * root.s
            implicitWidth: 420 * root.s
            implicitHeight: passwordInput.implicitHeight + stateMessage.implicitHeight + Tokens.spacing.small

            StyledText {
                anchors.centerIn: passwordInput
                text: Tr.tr("Enter Password")
                color: Qt.rgba(1, 1, 1, 0.75)
                font: Tokens.font.label.builders.medium.weight(Font.Medium).build()
                opacity: root.typing ? 0 : 1

                Behavior on opacity {
                    Anim {
                        type: Anim.DefaultEffects
                    }
                }
            }

            PasswordInput {
                id: passwordInput

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                centerScale: Math.max(0.8, root.s)
                centerWidth: 380 * root.s
                lock: root.lock
                color: Qt.rgba(1, 1, 1, 0.18)
                // Fixed like macOS; the built-in width measures the placeholder too narrow
                implicitWidth: 300 * root.s
                // Still focused and receiving keys while hidden
                opacity: root.typing ? 1 : 0

                Behavior on opacity {
                    Anim {
                        type: Anim.DefaultEffects
                    }
                }
            }

            StateMessage {
                id: stateMessage

                anchors.top: passwordInput.bottom
                anchors.topMargin: Tokens.spacing.small
                anchors.left: parent.left
                anchors.right: parent.right
                pam: root.lock.pam
            }
        }
    }
}
