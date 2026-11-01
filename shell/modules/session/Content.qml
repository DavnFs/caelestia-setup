pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Caelestia
import Caelestia.Config
import Caelestia.I18n
import Caelestia.Services
import qs.components
import qs.services
import qs.utils

Item {
    id: root

    required property ScreenState screenState
    required property bool mirrored

    implicitWidth: 190
    implicitHeight: cardLayout.implicitHeight + cardLayout.anchors.margins * 2

    StyledRect {
        id: bg

        anchors.fill: parent
        radius: Tokens.rounding.large
        color: Colours.palette.m3surfaceContainer
        border.color: Colours.palette.m3outlineVariant
        border.width: 1

        layer.enabled: true
        layer.smooth: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            blurMax: 15
            shadowColor: Qt.alpha(Colours.palette.m3shadow, 0.4)
            shadowVerticalOffset: 3
        }
    }

    ColumnLayout {
        id: cardLayout

        anchors.fill: parent
        anchors.margins: 8
        spacing: 5

        ActionRow {
            id: lockBtn

            icon: "lock"
            title: Tr.tr("Lock Screen")
            onAction: () => {
                Quickshell.execDetached(["caelestia", "shell", "lock", "lock"]);
            }

            KeyNavigation.down: sleepBtn

            Component.onCompleted: forceActiveFocus()

            Connections {
                function onSessionChanged(): void {
                    if (root.screenState.session)
                        lockBtn.forceActiveFocus();
                }

                target: root.screenState
            }
        }

        ActionRow {
            id: sleepBtn

            icon: Config.session.icons.hibernate || "bedtime"
            command: Config.session.commands.hibernate
            title: Tr.tr("Sleep")

            KeyNavigation.up: lockBtn
            KeyNavigation.down: rebootBtn
        }

        ActionRow {
            id: rebootBtn

            icon: Config.session.icons.reboot || "restart_alt"
            command: Config.session.commands.reboot
            title: Tr.tr("Restart…")

            KeyNavigation.up: sleepBtn
            KeyNavigation.down: shutdownBtn
        }

        ActionRow {
            id: shutdownBtn

            icon: Config.session.icons.shutdown || "power_settings_new"
            command: Config.session.commands.shutdown
            title: Tr.tr("Shut Down…")
            isDanger: true

            KeyNavigation.up: rebootBtn
            KeyNavigation.down: logoutBtn
        }

        StyledRect {
            Layout.fillWidth: true
            Layout.topMargin: 2
            Layout.bottomMargin: 2
            implicitHeight: 1
            color: Colours.palette.m3outlineVariant
            opacity: 0.5
        }

        ActionRow {
            id: logoutBtn

            icon: Config.session.icons.logout || "logout"
            command: Config.session.commands.logout
            title: Tr.tr("Log Out…")

            KeyNavigation.up: shutdownBtn
        }
    }

    component ActionRow: StyledRect {
        id: button

        focus: true
        activeFocusOnTab: true

        required property string icon
        required property string title
        property list<string> command: []
        property bool isDanger: false
        property var onAction: null

        function exec(): void {
            root.screenState.session = false;
            if (onAction) {
                onAction();
            } else if (command.length > 0) {
                if (!SessionManager.exec(command))
                    Quickshell.execDetached(command);
            }
        }

        Layout.fillWidth: true
        implicitHeight: 59
        radius: Tokens.rounding.medium

        color: {
            if (mouseArea.pressed)
                return isDanger ? Qt.alpha(Colours.palette.m3error, 0.2) : Colours.palette.m3secondaryContainer;
            if (activeFocus)
                return isDanger ? Qt.alpha(Colours.palette.m3error, 0.15) : Colours.tPalette.m3secondaryContainer;
            if (mouseArea.containsMouse)
                return isDanger ? Qt.alpha(Colours.palette.m3error, 0.08) : Colours.tPalette.m3surfaceContainerHigh;
            return "transparent";
        }

        Behavior on color {
            CAnim {}
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: button.exec()
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            spacing: 12

            MaterialIcon {
                text: button.icon
                color: button.isDanger
                    ? Colours.palette.m3error
                    : (button.activeFocus ? Colours.palette.m3primary : Colours.palette.m3onSurfaceVariant)
                fontStyle: Tokens.font.icon.builders.small.scale(1.15).build()
            }

            StyledText {
                text: button.title
                font: Tokens.font.body.builders.medium.weight(button.activeFocus ? Font.Medium : Font.Normal).build()
                color: button.isDanger
                    ? Colours.palette.m3error
                    : Colours.palette.m3onSurface
                Layout.fillWidth: true
                elide: Text.ElideRight
            }
        }

        Keys.onEnterPressed: exec()
        Keys.onReturnPressed: exec()
        Keys.onEscapePressed: root.screenState.session = false
        Keys.onPressed: event => {
            if (!Config.session.vimKeybinds)
                return;

            if (event.modifiers & Qt.ControlModifier) {
                if ((event.key === Qt.Key_J || event.key === Qt.Key_N) && KeyNavigation.down) {
                    KeyNavigation.down.focus = true;
                    event.accepted = true;
                } else if ((event.key === Qt.Key_K || event.key === Qt.Key_P) && KeyNavigation.up) {
                    KeyNavigation.up.focus = true;
                    event.accepted = true;
                }
            } else if (event.key === Qt.Key_Tab && KeyNavigation.down) {
                KeyNavigation.down.focus = true;
                event.accepted = true;
            } else if (event.key === Qt.Key_Backtab || (event.key === Qt.Key_Tab && (event.modifiers & Qt.ShiftModifier))) {
                if (KeyNavigation.up) {
                    KeyNavigation.up.focus = true;
                    event.accepted = true;
                }
            }
        }
    }
}
