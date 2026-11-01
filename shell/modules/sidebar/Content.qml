pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Caelestia.Config
import qs.components
import qs.services

Item {
    id: root

    required property Props props
    required property ScreenState screenState

    StyledRect {
        id: bg

        anchors.fill: parent
        radius: Tokens.rounding.large
        color: Colours.palette.m3surfaceContainerLow
        border.color: Colours.palette.m3outlineVariant
        border.width: 1

        layer.enabled: true
        layer.smooth: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            blurMax: 12
            shadowColor: Qt.alpha(Colours.palette.m3shadow, 0.5)
            shadowVerticalOffset: 3
        }
    }

    NotifDock {
        id: notifDock
        objectName: "sidebarNotifications"

        anchors.fill: parent
        props: root.props
        screenState: root.screenState
    }
}
