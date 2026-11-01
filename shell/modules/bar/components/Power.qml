import QtQuick
import Caelestia.Config
import qs.components
import qs.services

StyledRect {
    id: root

    required property ScreenState screenState

    implicitWidth: Tokens.sizes.bar.innerWidth
    implicitHeight: Tokens.sizes.bar.innerWidth

    color: stateLayer.containsMouse ? Qt.alpha(Colours.palette.m3error, 0.15) : "transparent"
    radius: Tokens.rounding.full
    border.width: 0

    Behavior on color {
        CAnim {}
    }

    StateLayer {
        id: stateLayer
        anchors.fill: parent
        radius: Tokens.rounding.full
        color: Colours.palette.m3error
        cursorShape: Qt.PointingHandCursor
        onClicked: root.screenState.session = !root.screenState.session
    }

    MaterialIcon {
        id: icon

        anchors.centerIn: parent

        text: "power_settings_new"
        color: Colours.palette.m3error
        fontStyle: Tokens.font.icon.builders.small.weight(Font.Bold).build()
    }
}
