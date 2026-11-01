import QtQuick
import Caelestia.Config
import qs.components
import qs.components.effects
import qs.services
import qs.utils

StyledRect {
    id: root

    implicitWidth: Tokens.sizes.bar.innerWidth
    implicitHeight: Tokens.sizes.bar.innerWidth

    color: stateLayer.containsMouse ? Colours.tPalette.m3surfaceContainerHigh : "transparent"
    radius: Tokens.rounding.full
    border.width: 0

    Behavior on color {
        CAnim {}
    }

    StateLayer {
        id: stateLayer
        anchors.fill: parent
        radius: Tokens.rounding.full
        color: Colours.palette.m3tertiary
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            const screenState = ShellState.forActive();
            screenState.launcher = !screenState.launcher;
        }
    }

    Loader {
        asynchronous: true
        anchors.centerIn: parent
        sourceComponent: SysInfo.isDefaultLogo ? caelestiaLogo : distroIcon
    }

    Component {
        id: caelestiaLogo

        Logo {
            implicitWidth: Math.round(Tokens.font.body.large.pointSize * 1.3)
            implicitHeight: Math.round(Tokens.font.body.large.pointSize * 1.3)
        }
    }

    Component {
        id: distroIcon

        ColouredIcon {
            source: SysInfo.osLogo
            implicitSize: Math.round(Tokens.font.body.large.pointSize * 1.2)
            colour: Colours.palette.m3tertiary
        }
    }
}
