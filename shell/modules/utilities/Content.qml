pragma ComponentBehavior: Bound

import "cards"
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Caelestia.Config
import qs.components
import qs.services
import qs.modules.bar.popouts as BarPopouts

Item {
    id: root

    required property var props
    required property ScreenState screenState
    required property BarPopouts.Wrapper popouts
    required property matrix4x4 deformMatrix

    readonly property int enabledCards: (idleInhibit.active ? 1 : 0) + (record.active ? 1 : 0) + (toggles.active ? 1 : 0)
    readonly property real nonAnimHeight: ((idleInhibit.item as IdleInhibit)?.nonAnimHeight ?? 0) + ((record.item as Record)?.nonAnimHeight ?? 0) + ((toggles.item as Toggles)?.implicitHeight ?? 0) + layout.spacing * Math.max(0, enabledCards - 1) + layout.anchors.margins * 2

    implicitWidth: layout.implicitWidth + layout.anchors.margins * 2
    implicitHeight: layout.implicitHeight + layout.anchors.margins * 2

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

    ColumnLayout {
        id: layout

        anchors.fill: parent
        anchors.margins: Tokens.padding.medium
        spacing: Tokens.spacing.small

        Loader {
            id: idleInhibit

            Layout.fillWidth: true
            active: Config.utilities.cards.keepAwake
            visible: active

            sourceComponent: IdleInhibit {
                objectName: "utilitiesKeepAwake"
            }
        }

        Loader {
            id: record

            Layout.fillWidth: true
            active: Config.utilities.cards.recorder
            visible: active
            z: 1

            sourceComponent: Record {
                objectName: "utilitiesScreenRecorder"

                props: root.props
                screenState: root.screenState
            }
        }

        Loader {
            id: toggles

            Layout.fillWidth: true
            active: Config.utilities.cards.quickToggles
            visible: active

            sourceComponent: Toggles {
                objectName: "utilitiesQuickToggles"

                screenState: root.screenState
                popouts: root.popouts
            }
        }
    }

    RecordingDeleteModal {
        props: root.props
        deformMatrix: root.deformMatrix
    }
}
