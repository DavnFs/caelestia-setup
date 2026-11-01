pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import Caelestia.I18n
import qs.components
import qs.components.effects
import qs.components.filedialog
import qs.components.images
import qs.services
import qs.utils

Item {
    id: root

    required property ScreenState screenState
    required property FileDialog facePicker

    anchors.fill: parent
    anchors.margins: Tokens.padding.large

    RowLayout {
        anchors.fill: parent
        spacing: Tokens.spacing.medium

        // Avatar
        Item {
            implicitWidth: parent.height
            implicitHeight: parent.height

            StyledClippingRect {
                id: pfpClip

                anchors.fill: parent
                radius: Tokens.rounding.full
                color: Colours.palette.m3surfaceContainerHighest

                CachingImage {
                    id: pfp

                    anchors.fill: parent
                    path: `${Paths.home}/.face`
                }

                MaterialIcon {
                    anchors.centerIn: parent
                    text: "person"
                    color: Colours.palette.m3onSurfaceVariant
                    fontStyle: Tokens.font.icon.large
                    visible: pfp.status !== Image.Ready
                }

                StyledRect {
                    anchors.fill: parent
                    color: Qt.alpha(Colours.palette.m3scrim, 0.45)
                    opacity: mouse.containsMouse ? 1 : 0

                    Behavior on opacity {
                        Anim {
                            type: Anim.DefaultEffects
                        }
                    }

                    MaterialIcon {
                        anchors.centerIn: parent
                        text: "edit"
                        color: Colours.palette.m3onPrimary
                        fontStyle: Tokens.font.icon.medium
                    }
                }
            }

            MouseArea {
                id: mouse

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    root.screenState.dashboard = false;
                    root.facePicker.open();
                }
            }
        }

        // User info & chips
        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 6

            RowLayout {
                spacing: Tokens.spacing.small

                StyledText {
                    text: SysInfo.user
                    color: Colours.palette.m3onSurface
                    font: Tokens.font.title.medium
                }

                StyledRect {
                    radius: Tokens.rounding.full
                    color: Colours.palette.m3secondaryContainer
                    implicitHeight: wmRow.implicitHeight + 4
                    implicitWidth: wmRow.implicitWidth + 12

                    RowLayout {
                        id: wmRow

                        anchors.centerIn: parent
                        spacing: 4

                        MaterialIcon {
                            text: "desktop_windows"
                            color: Colours.palette.m3onSecondaryContainer
                            fontStyle: Tokens.font.icon.small
                        }

                        StyledText {
                            text: SysInfo.wm
                            color: Colours.palette.m3onSecondaryContainer
                            font: Tokens.font.label.small
                        }
                    }
                }
            }

            RowLayout {
                spacing: Tokens.spacing.small

                // Uptime chip
                StyledRect {
                    radius: Tokens.rounding.full
                    color: Colours.palette.m3tertiaryContainer
                    implicitHeight: uptimeRow.implicitHeight + 4
                    implicitWidth: uptimeRow.implicitWidth + 12

                    RowLayout {
                        id: uptimeRow

                        anchors.centerIn: parent
                        spacing: 4

                        MaterialIcon {
                            text: "schedule"
                            color: Colours.palette.m3onTertiaryContainer
                            fontStyle: Tokens.font.icon.small
                        }

                        StyledText {
                            text: Tr.trCtx("up %1", "system uptime").arg(SysInfo.uptimeShort)
                            color: Colours.palette.m3onTertiaryContainer
                            font: Tokens.font.label.small
                        }
                    }
                }

                // OS / Distro badge
                StyledRect {
                    radius: Tokens.rounding.full
                    color: Colours.palette.m3surfaceContainerHigh
                    implicitHeight: osRow.implicitHeight + 4
                    implicitWidth: osRow.implicitWidth + 12

                    RowLayout {
                        id: osRow

                        anchors.centerIn: parent
                        spacing: 4

                        ColouredIcon {
                            source: SysInfo.osLogo
                            implicitSize: 12
                            colour: Colours.palette.m3onSurfaceVariant
                        }

                        StyledText {
                            text: SysInfo.distro || "Linux"
                            color: Colours.palette.m3onSurfaceVariant
                            font: Tokens.font.label.small
                        }
                    }
                }
            }
        }
    }
}
