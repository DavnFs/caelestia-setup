pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Templates
import Quickshell
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.services

Item {
    id: root

    required property real nonAnimWidth
    required property ScreenState screenState
    required property var tabs

    readonly property alias count: bar.count

    implicitHeight: bar.implicitHeight

    TabBar {
        id: bar

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top

        currentIndex: root.screenState.dashboardTab
        onCurrentIndexChanged: root.screenState.dashboardTab = currentIndex

        implicitHeight: contentHeight
        background: null
        contentItem: RowLayout {
            spacing: 8

            Repeater {
                model: bar.contentModel
            }
        }

        Repeater {
            model: ScriptModel {
                values: root.tabs
            }

            delegate: Tab {
                required property var modelData

                iconName: modelData.iconName
                text: modelData.text
            }
        }
    }

    component Tab: TabButton {
        id: tab

        required property string iconName
        readonly property bool current: TabBar.tabBar.currentItem === this

        Layout.fillWidth: true
        Layout.preferredWidth: 1 // Uniform width across all tabs
        implicitHeight: 40
        background: null

        contentItem: StyledRect {
            id: chip

            radius: Tokens.rounding.full
            color: tab.current
                ? Colours.palette.m3primary
                : (mouse.containsMouse ? Colours.palette.m3surfaceContainerHighest : Colours.palette.m3surfaceContainerHigh)

            Behavior on color {
                ColorAnimation {
                    duration: Tokens.anim.durations.short
                }
            }

            CustomMouseArea {
                id: mouse

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                function onWheel(event: WheelEvent): void {
                    if (event.angleDelta.y < 0)
                        root.screenState.dashboardTab = Math.min(root.screenState.dashboardTab + 1, bar.count - 1);
                    else if (event.angleDelta.y > 0)
                        root.screenState.dashboardTab = Math.max(root.screenState.dashboardTab - 1, 0);
                }

                onPressed: root.screenState.dashboardTab = tab.TabBar.index

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 8

                    MaterialIcon {
                        text: tab.iconName
                        color: tab.current
                            ? Colours.palette.m3onPrimary
                            : (mouse.containsMouse ? Colours.palette.m3onSurface : Colours.palette.m3onSurfaceVariant)
                        fill: tab.current ? 1 : 0
                        fontStyle: Tokens.font.icon.medium

                        Behavior on fill {
                            Anim {
                                type: Anim.DefaultEffects
                            }
                        }
                    }

                    StyledText {
                        text: tab.text
                        font.weight: tab.current ? Font.DemiBold : Font.Normal
                        color: tab.current
                            ? Colours.palette.m3onPrimary
                            : (mouse.containsMouse ? Colours.palette.m3onSurface : Colours.palette.m3onSurfaceVariant)
                    }
                }
            }
        }
    }
}
