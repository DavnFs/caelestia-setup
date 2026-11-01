import "center"
import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtMultimedia
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
    readonly property real s: Math.max(0.6, (lock.screen?.height ?? 1080) / 1080)
    readonly property color fg: Colours.palette.m3onSurface
    readonly property color clockPrimary: Colours.light ? Colours.palette.m3primaryFixed : Colours.palette.m3primary
    readonly property color clockSecondary: Colours.light ? Colours.palette.m3secondaryFixed : Colours.palette.m3secondary
    readonly property color clockTertiary: Colours.light ? Colours.palette.m3tertiaryFixed : Colours.palette.m3tertiary
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

        // Chosen in Settings → Lock screen. The desktop wallpaper stays underneath as a fallback
        Item {
            anchors.fill: parent

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

            CachingImage {
                anchors.fill: parent
                path: LockSettings.background === "image" && LockSettings.imagePath ? LockSettings.imagePath : Wallpapers.current
            }

            Loader {
                anchors.fill: parent
                active: LockSettings.background === "video" && !!LockSettings.videoPath

                sourceComponent: Video {
                    readonly property bool holdFrame: LockSettings.videoOnlyWhenCharging && UPower.onBattery

                    source: `file://${LockSettings.videoPath}`
                    fillMode: VideoOutput.PreserveAspectCrop
                    loops: MediaPlayer.Infinite
                    muted: true
                    // Show a still frame instead of playing on battery, if chosen
                    onHoldFrameChanged: holdFrame ? pause() : play()
                    Component.onCompleted: holdFrame ? pause() : play()
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

        // Status in the top-right corner, matching floating status bar design
        StyledRect {
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: 16
            radius: Tokens.rounding.large
            color: Colours.palette.m3surfaceContainer
            border.width: 1
            border.color: Colours.palette.m3outlineVariant
            implicitWidth: batteryLayout.implicitWidth + Tokens.padding.medium * 2
            implicitHeight: batteryLayout.implicitHeight + Tokens.padding.small * 2
            visible: UPower.displayDevice.isLaptopBattery

            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                blurMax: 12
                shadowColor: Qt.alpha(Colours.palette.m3shadow, 0.3)
                shadowVerticalOffset: 2
            }

            RowLayout {
                id: batteryLayout

                anchors.centerIn: parent
                spacing: Tokens.spacing.small

                StyledText {
                    text: `${Math.round(UPower.displayDevice.percentage * 100)}%`
                    color: Colours.palette.m3onSurface
                    font: Tokens.font.label.builders.small.weight(Font.Medium).build()
                }

                MaterialIcon {
                    text: Icons.getBatteryIcon(UPower.displayDevice.percentage, !UPower.onBattery)
                    color: Colours.palette.m3onSurface
                    fill: 1
                }
            }
        }

        ColumnLayout {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 80 * root.s
            spacing: 8 * root.s

            StyledText {
                Layout.alignment: Qt.AlignHCenter
                text: Time.format("ddd, d MMM")
                color: root.clockTertiary
                font: Tokens.font.title.builders.large.scale(root.s).weight(Font.DemiBold).build()

                layer.enabled: true
                layer.effect: MultiEffect {
                    shadowEnabled: true
                    blurMax: 16
                    shadowColor: Qt.alpha(Colours.palette.m3shadow, 0.5)
                    shadowVerticalOffset: 2
                }
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 2 * root.s

                StyledText {
                    text: Units.twelveHourClock ? Time.format("h") : Time.hourStr
                    color: root.clockPrimary
                    font: Tokens.font.headline.builders.large.scale(3.4 * root.s).weight(Font.Medium).build()

                    layer.enabled: true
                    layer.effect: MultiEffect {
                        shadowEnabled: true
                        blurMax: 20
                        shadowColor: Qt.alpha(Colours.palette.m3shadow, 0.5)
                        shadowVerticalOffset: 3
                    }
                }

                StyledText {
                    text: ":"
                    color: Qt.alpha(Colours.palette.m3outline, 0.75)
                    font: Tokens.font.headline.builders.large.scale(3.4 * root.s).weight(Font.Medium).build()
                    Layout.topMargin: -4 * root.s

                    layer.enabled: true
                    layer.effect: MultiEffect {
                        shadowEnabled: true
                        blurMax: 20
                        shadowColor: Qt.alpha(Colours.palette.m3shadow, 0.5)
                        shadowVerticalOffset: 3
                    }
                }

                StyledText {
                    text: Time.minuteStr
                    color: root.clockSecondary
                    font: Tokens.font.headline.builders.large.scale(3.4 * root.s).weight(Font.Medium).build()

                    layer.enabled: true
                    layer.effect: MultiEffect {
                        shadowEnabled: true
                        blurMax: 20
                        shadowColor: Qt.alpha(Colours.palette.m3shadow, 0.5)
                        shadowVerticalOffset: 3
                    }
                }
            }
        }

        NowPlaying {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: passwordArea.top
            anchors.bottomMargin: 40 * root.s
            s: root.s
            visible: opacity > 0
            opacity: root.music && LockSettings.showMedia ? 1 : 0

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

            PasswordInput {
                id: passwordInput

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                centerScale: Math.max(0.8, root.s)
                centerWidth: 380 * root.s
                lock: root.lock
                implicitWidth: 300 * root.s
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
