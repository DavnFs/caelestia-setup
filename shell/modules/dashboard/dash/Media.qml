pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Components
import Caelestia.Config
import Caelestia.I18n
import Caelestia.Services
import qs.components
import qs.components.controls
import qs.components.widgets
import qs.services
import qs.utils

Item {
    id: root

    property real playerProgress: {
        const active = Players.active;
        return active?.length ? (active.position % active.length) / active.length : 0;
    }

    function fmt(secs: real): string {
        const t = Math.max(0, Math.floor(secs));
        return `${Math.floor(t / 60)}:${String(t % 60).padStart(2, "0")}`;
    }

    anchors.fill: parent
    anchors.margins: Tokens.padding.large
    implicitWidth: Tokens.sizes.dashboard.mediaWidth

    Behavior on playerProgress {
        Anim {
            type: Anim.StandardLarge
        }
    }

    Timer {
        running: Players.active?.isPlaying ?? false
        interval: GlobalConfig.dashboard.mediaUpdateInterval
        triggeredOnStart: true
        repeat: true
        onTriggered: Players.active?.positionChanged()
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Tokens.spacing.medium

        // Album Art
        Item {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: parent.width - Tokens.padding.small * 2
            Layout.preferredHeight: Layout.preferredWidth

            CoverArt {
                anchors.fill: parent
            }
        }

        // Track Info
        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            spacing: 2

            StyledText {
                Layout.fillWidth: true
                animate: true
                horizontalAlignment: Text.AlignHCenter
                text: (Players.active?.trackTitle ?? Tr.tr("No media")) || Tr.tr("Unknown title")
                color: Colours.palette.m3onSurface
                font: Tokens.font.title.small
                elide: Text.ElideRight
            }

            StyledText {
                Layout.fillWidth: true
                animate: true
                horizontalAlignment: Text.AlignHCenter
                text: Players.active?.trackArtist ?? ""
                color: Colours.palette.m3onSurfaceVariant
                font: Tokens.font.body.small
                elide: Text.ElideRight
                visible: text.length > 0
            }

            StyledText {
                Layout.fillWidth: true
                animate: true
                horizontalAlignment: Text.AlignHCenter
                text: Players.active?.trackAlbum ?? ""
                color: Colours.palette.m3outline
                font: Tokens.font.label.small
                elide: Text.ElideRight
                visible: text.length > 0 && text !== Players.active?.trackTitle
            }
        }

        // Progress Bar
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            Item {
                Layout.fillWidth: true
                implicitHeight: 4

                Rectangle {
                    anchors.fill: parent
                    radius: height / 2
                    color: Colours.palette.m3surfaceContainerHighest
                }

                Rectangle {
                    width: parent.width * root.playerProgress
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

            RowLayout {
                Layout.fillWidth: true

                StyledText {
                    text: root.fmt(Players.active?.position ?? 0)
                    color: Colours.palette.m3outline
                    font: Tokens.font.label.small
                }

                Item {
                    Layout.fillWidth: true
                }

                StyledText {
                    text: root.fmt(Players.active?.length ?? 0)
                    color: Colours.palette.m3outline
                    font: Tokens.font.label.small
                }
            }
        }

        // Playback Controls
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: Tokens.spacing.large

            IconButton {
                type: IconButton.Tonal
                icon: "skip_previous"
                isRound: true
                disabled: !Players.active?.canGoPrevious
                onClicked: Players.active?.previous()
            }

            StyledRect {
                implicitWidth: 48
                implicitHeight: 48
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
                    text: Players.active?.isPlaying ? "pause" : "play_arrow"
                    color: Colours.palette.m3onPrimaryContainer
                    fill: 1
                    fontStyle: Tokens.font.icon.large
                }

                MouseArea {
                    id: playMouse

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    enabled: Players.active?.canTogglePlaying ?? false
                    onClicked: Players.active?.togglePlaying()
                }
            }

            IconButton {
                type: IconButton.Tonal
                icon: "skip_next"
                isRound: true
                disabled: !Players.active?.canGoNext
                onClicked: Players.active?.next()
            }
        }
    }
}
