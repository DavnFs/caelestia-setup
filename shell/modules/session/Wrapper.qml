pragma ComponentBehavior: Bound

import QtQuick
import Caelestia.Config
import qs.components

Item {
    id: root

    property var bar: null
    required property ScreenState screenState
    required property bool sidebarVisible
    readonly property real nonAnimWidth: content.implicitWidth

    required property bool mirrored
    readonly property int floatMargin: bar?.isFloating ? 10 : 0
    readonly property real slideOffset: (-implicitWidth - floatMargin - 20 - sidebarOffset) * offsetScale
    readonly property bool shouldBeActive: screenState.session && Config.session.enabled
    property real offsetScale: shouldBeActive ? 0 : 1
    property real sidebarOffset: sidebarVisible ? 14 : 0

    visible: offsetScale < 1

    implicitWidth: content.implicitWidth
    implicitHeight: content.implicitHeight || 420
    scale: 1 - 0.04 * offsetScale
    opacity: 1 - offsetScale

    Behavior on offsetScale {
        Anim {}
    }

    Loader {
        id: content

        anchors.verticalCenter: parent.verticalCenter
        anchors.left: root.mirrored ? undefined : parent.left
        anchors.right: root.mirrored ? parent.right : undefined

        active: root.shouldBeActive || root.visible

        sourceComponent: Content {
            screenState: root.screenState
            mirrored: root.mirrored
        }
    }
}
