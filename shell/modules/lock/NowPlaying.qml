pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell.Widgets
import Caelestia.Config
import qs.components
import qs.services

// Material 3 Now Playing card
StyledRect {
    id: root

    required property real s

    readonly property var player: Players.active
    readonly property real progress: player?.length ? Math.min(1, player.position / player.length) : 0

    function fmt(secs: real): string {
        const t = Math.max(0, Math.floor(secs));
        return `${Math.floor(t / 60)}:${String(t % 60).padStart(2, "0")}`;
    }

    implicitWidth: 320 * s
    implicitHeight: content.implicitHeight + 28 * s

    radius: Tokens.rounding.large
    color: Colours.palette.m3surfaceContainer
    border.width: 1
    border.color: Colours.palette.m3outlineVariant

    layer.enabled: true
    layer.effect: MultiEffect {
        shadowEnabled: true
        blurMax: 16
        shadowColor: Qt.alpha(Colours.palette.m3shadow, 0.35)
        shadowVerticalOffset: 2
    }

    Timer {
        running: root.visible && (root.player?.isPlaying ?? false)
        interval: 1000
        repeat: true
        triggeredOnStart: true
        onTriggered: root.player?.positionChanged()
    }

    ColumnLayout {
        id: content

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.margins: 14 * root.s
        spacing: 10 * root.s

        RowLayout {
            spacing: 12 * root.s

            ClippingRectangle {
                implicitWidth: 52 * root.s
                implicitHeight: implicitWidth
                radius: Tokens.rounding.medium
                color: Colours.palette.m3surfaceContainerHighest

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
                spacing: 2

                StyledText {
                    Layout.fillWidth: true
                    text: root.player?.trackTitle ?? ""
                    color: Colours.palette.m3onSurface
                    elide: Text.ElideRight
                    font: Tokens.font.body.builders.medium.weight(Font.Medium).build()
                }

                StyledText {
                    Layout.fillWidth: true
                    text: root.player?.trackArtist ?? ""
                    color: Colours.palette.m3onSurfaceVariant
                    elide: Text.ElideRight
                    font: Tokens.font.body.small
                }
            }

            MaterialIcon {
                text: "graphic_eq"
                color: root.player?.isPlaying ? Colours.palette.m3primary : Colours.palette.m3onSurfaceVariant
            }
        }

        RowLayout {
            spacing: 8 * root.s

            StyledText {
                text: root.fmt(root.player?.position ?? 0)
                color: Colours.palette.m3onSurfaceVariant
                font: Tokens.font.label.small
            }

            Item {
                Layout.fillWidth: true
                implicitHeight: 4

                Rectangle {
                    anchors.fill: parent
                    radius: height / 2
                    color: Colours.palette.m3surfaceContainerHighest
                }

                Rectangle {
                    width: parent.width * root.progress
                    height: parent.height
                    radius: height / 2
                    color: Colours.palette.m3primary

                    Behavior on width {
                        Anim {
                            type: Anim.StandardLarge
                        }
                    }
                }
            }

            StyledText {
                text: root.fmt(root.player?.length ?? 0)
                color: Colours.palette.m3onSurfaceVariant
                font: Tokens.font.label.small
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 24 * root.s

            ControlIcon {
                icon: "skip_previous"
                enabled: root.player?.canGoPrevious ?? false
                onClicked: root.player?.previous()
            }

            StyledRect {
                implicitWidth: 42 * root.s
                implicitHeight: 42 * root.s
                radius: Tokens.rounding.full
                color: Colours.palette.m3primaryContainer

                scale: playMouse.pressed ? 0.92 : (playMouse.containsMouse ? 1.05 : 1.0)
                Behavior on scale {
                    Anim {
                        type: Anim.FastSpatial
                    }
                }

                MaterialIcon {
                    anchors.centerIn: parent
                    text: root.player?.isPlaying ? "pause" : "play_arrow"
                    color: Colours.palette.m3onPrimaryContainer
                    fill: 1
                    fontStyle: Tokens.font.icon.builders.medium.scale(1.2 * root.s).build()
                }

                MouseArea {
                    id: playMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    enabled: root.player?.canTogglePlaying ?? false
                    onClicked: root.player?.togglePlaying()
                }
            }

            ControlIcon {
                icon: "skip_next"
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
        color: Colours.palette.m3onSurface
        opacity: enabled ? (mouse.pressed ? 0.5 : (mouse.containsMouse ? 0.8 : 1)) : 0.38
        fontStyle: Tokens.font.icon.builders.large.scale(size * root.s).build()

        MouseArea {
            id: mouse

            anchors.fill: parent
            anchors.margins: -8
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: ctrl.clicked()
        }
    }
}
