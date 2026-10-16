import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell.Widgets
import Caelestia.Config
import qs.components
import qs.services

// macOS-style now playing widget: small frosted-glass card with artwork, track info, progress and controls
Item {
    id: root

    required property real s
    // What the glass blurs (the lock background)
    required property Item blurSource

    readonly property var player: Players.active
    readonly property real progress: player?.length ? Math.min(1, player.position / player.length) : 0

    function fmt(secs: real): string {
        const t = Math.max(0, Math.floor(secs));
        return `${Math.floor(t / 60)}:${String(t % 60).padStart(2, "0")}`;
    }

    implicitWidth: 300 * s
    implicitHeight: content.implicitHeight + 28 * s

    // Position is only pushed on demand
    Timer {
        running: root.visible && (root.player?.isPlaying ?? false)
        interval: 1000
        repeat: true
        triggeredOnStart: true
        onTriggered: root.player?.positionChanged()
    }

    // Frosted glass: blurred copy of the background behind the card, plus a light tint and edge
    ClippingRectangle {
        id: glass

        anchors.fill: parent
        radius: 22 * root.s
        color: "transparent"

        ShaderEffectSource {
            id: behind

            anchors.fill: parent
            sourceItem: root.blurSource
            sourceRect: {
                root.x; root.y; root.width; root.height; // Re-map when the card moves or resizes
                const p = root.mapToItem(root.blurSource, 0, 0);
                return Qt.rect(p.x, p.y, root.width, root.height);
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
            radius: glass.radius
            color: Qt.rgba(1, 1, 1, 0.14)
            border.width: 1
            border.color: Qt.rgba(1, 1, 1, 0.28)
        }
    }

    ColumnLayout {
        id: content

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.margins: 14 * root.s
        spacing: 10 * root.s

        RowLayout {
            spacing: 10 * root.s

            ClippingRectangle {
                implicitWidth: 52 * root.s
                implicitHeight: implicitWidth
                radius: 8 * root.s
                color: Qt.rgba(1, 1, 1, 0.1)

                Image {
                    anchors.fill: parent
                    source: Players.getArtUrl(root.player)
                    sourceSize.width: 128
                    sourceSize.height: 128
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                StyledText {
                    Layout.fillWidth: true
                    text: root.player?.trackTitle ?? ""
                    color: "white"
                    elide: Text.ElideRight
                    font: Tokens.font.body.builders.small.weight(Font.DemiBold).build()
                }

                StyledText {
                    Layout.fillWidth: true
                    text: (root.player?.trackArtist ?? "").toUpperCase()
                    color: Qt.rgba(1, 1, 1, 0.65)
                    elide: Text.ElideRight
                    font: Tokens.font.label.small
                }
            }

            MaterialIcon {
                text: "graphic_eq"
                color: Qt.rgba(1, 1, 1, root.player?.isPlaying ? 0.85 : 0.4)
            }
        }

        RowLayout {
            spacing: 8 * root.s

            StyledText {
                text: root.fmt(root.player?.position ?? 0)
                color: Qt.rgba(1, 1, 1, 0.65)
                font: Tokens.font.label.small
            }

            Item {
                Layout.fillWidth: true
                implicitHeight: 4

                Rectangle {
                    anchors.fill: parent
                    radius: height / 2
                    color: Qt.rgba(1, 1, 1, 0.25)
                }

                Rectangle {
                    width: parent.width * root.progress
                    height: parent.height
                    radius: height / 2
                    color: Qt.rgba(1, 1, 1, 0.9)

                    Behavior on width {
                        Anim {
                            type: Anim.StandardLarge
                        }
                    }
                }
            }

            StyledText {
                text: root.fmt(root.player?.length ?? 0)
                color: Qt.rgba(1, 1, 1, 0.65)
                font: Tokens.font.label.small
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 32 * root.s

            ControlIcon {
                icon: "fast_rewind"
                enabled: root.player?.canGoPrevious ?? false
                onClicked: root.player?.previous()
            }

            ControlIcon {
                icon: root.player?.isPlaying ? "pause" : "play_arrow"
                size: 1.5
                enabled: root.player?.canTogglePlaying ?? false
                onClicked: root.player?.togglePlaying()
            }

            ControlIcon {
                icon: "fast_forward"
                enabled: root.player?.canGoNext ?? false
                onClicked: root.player?.next()
            }
        }
    }

    component ControlIcon: MaterialIcon {
        id: ctrl

        property string icon
        property real size: 1.2
        signal clicked

        text: icon
        fill: 1
        color: "white"
        opacity: enabled ? (mouse.pressed ? 0.5 : 1) : 0.35
        fontStyle: Tokens.font.icon.builders.large.scale(size * root.s).build()

        MouseArea {
            id: mouse

            anchors.fill: parent
            anchors.margins: -8
            cursorShape: Qt.PointingHandCursor
            onClicked: ctrl.clicked()
        }
    }
}
