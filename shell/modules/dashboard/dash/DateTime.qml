pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import Caelestia.I18n
import qs.components
import qs.services

Item {
    id: root

    anchors.top: parent.top
    anchors.bottom: parent.bottom
    implicitWidth: Tokens.sizes.dashboard.dateTimeWidth

    ColumnLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: 2

        StyledText {
            Layout.alignment: Qt.AlignHCenter
            text: Units.twelveHourClock ? Time.format("h") : Time.hourStr
            color: Colours.palette.m3primary
            font: Tokens.font.headline.builders.large.scale(1.2).weight(Font.Medium).build()
        }

        StyledRect {
            Layout.alignment: Qt.AlignHCenter
            implicitWidth: 16
            implicitHeight: 2
            radius: Tokens.rounding.full
            color: Colours.palette.m3outlineVariant
        }

        StyledText {
            Layout.alignment: Qt.AlignHCenter
            text: Time.minuteStr
            color: Colours.palette.m3secondary
            font: Tokens.font.headline.builders.large.scale(1.2).weight(Font.Medium).build()
        }

        Loader {
            asynchronous: true
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 4

            active: Units.twelveHourClock
            visible: active

            sourceComponent: StyledText {
                text: Time.amPmStr
                color: Colours.palette.m3tertiary
                font: Tokens.font.label.small
            }
        }
    }
}
