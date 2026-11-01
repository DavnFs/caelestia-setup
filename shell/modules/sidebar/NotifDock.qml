pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Caelestia.Config
import Caelestia.I18n
import qs.components
import qs.components.containers
import qs.components.controls
import qs.components.effects
import qs.services
import qs.utils

Item {
    id: root

    required property Props props
    required property ScreenState screenState
    readonly property int notifCount: Notifs.list.reduce((acc, n) => n.closed ? acc : acc + 1, 0)

    anchors.fill: parent
    anchors.margins: Tokens.padding.medium

    Component.onCompleted: Notifs.list.forEach(n => n.popup = false)

    RowLayout {
        id: title

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: Tokens.padding.extraSmall

        spacing: Tokens.spacing.small

        RowLayout {
            spacing: Tokens.spacing.small
            Layout.alignment: Qt.AlignVCenter

            StyledText {
                text: Tr.tr("Notifications")
                color: Colours.palette.m3onSurface
                font: Tokens.font.title.small
            }

            StyledRect {
                visible: root.notifCount > 0
                radius: Tokens.rounding.full
                color: Colours.palette.m3primaryContainer
                implicitWidth: Math.max(badgeText.implicitWidth + Tokens.padding.small * 1.5, implicitHeight)
                implicitHeight: badgeText.implicitHeight + Tokens.padding.extraSmall

                StyledText {
                    id: badgeText
                    anchors.centerIn: parent
                    text: root.notifCount
                    color: Colours.palette.m3onPrimaryContainer
                    font: Tokens.font.label.small
                }
            }
        }

        Item {
            Layout.fillWidth: true
        }

        IconTextButton {
            id: clearBtn
            visible: root.notifCount > 0
            icon: "clear_all"
            text: Tr.tr("Clear all")
            type: ButtonBase.Tonal
            horizontalPadding: Tokens.padding.small
            verticalPadding: Tokens.padding.extraSmall
            radius: Tokens.rounding.full
            font: Tokens.font.label.medium
            onClicked: clearTimer.start()
        }
    }

    ClippingRectangle {
        id: clipRect

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: title.bottom
        anchors.bottom: parent.bottom
        anchors.topMargin: Tokens.spacing.medium

        radius: Tokens.rounding.medium
        color: "transparent"

        Loader {
            asynchronous: true
            anchors.centerIn: parent
            active: opacity > 0
            opacity: root.notifCount > 0 ? 0 : 1

            sourceComponent: ColumnLayout {
                spacing: Tokens.spacing.extraLarge

                Image {
                    asynchronous: true
                    source: Paths.absolutePath(Config.paths.noNotifsPic)
                    fillMode: Image.PreserveAspectFit
                    sourceSize.width: clipRect.width * 0.8 * ((QsWindow.window as QsWindow)?.devicePixelRatio ?? 1)

                    layer.enabled: true
                    layer.effect: Colouriser {
                        colorizationColor: Colours.palette.m3outlineVariant
                        brightness: 1
                    }
                }

                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    text: Tr.tr("All up to date!")
                    color: Colours.palette.m3outlineVariant
                    font: Tokens.font.headline.builders.small.width(90).build()
                }
            }

            Behavior on opacity {
                Anim {
                    type: Anim.StandardExtraLarge
                }
            }
        }

        StyledFlickable {
            id: view

            anchors.fill: parent

            flickableDirection: Flickable.VerticalFlick
            contentWidth: width
            contentHeight: notifList.implicitHeight

            StyledScrollBar.vertical: StyledScrollBar {
                flickable: view
            }

            NotifDockList {
                id: notifList

                props: root.props
                screenState: root.screenState
                container: view
            }
        }
    }

    Timer {
        id: clearTimer

        repeat: true
        triggeredOnStart: true
        interval: Math.max(15, Math.min(80, 69.8 - 12.3 * Math.log(Notifs.notClosed.length)))
        onTriggered: {
            const first = Notifs.notClosed[0];
            if (!first) {
                stop();
                return;
            }

            const appName = first.appName;
            let cleared = 0;
            for (const n of Notifs.notClosed.filter(n => n.appName === appName)) {
                n.close();
                cleared++;
                if (cleared > 30) {
                    interval = 5;
                    return;
                }
            }
        }
    }


}
