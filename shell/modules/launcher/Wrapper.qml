pragma ComponentBehavior: Bound

import QtQuick
import Caelestia.Config
import qs.components
import qs.modules.launcher.services

Item {
    id: root

    property var bar: null
    required property ScreenState screenState
    required property var panels

    readonly property bool shouldBeActive: screenState.launcher && Config.launcher.enabled

    readonly property real maxHeight: {
        let max = parent.height + Tokens.padding.extraLarge;
        if (screenState.dashboard)
            max -= panels.dashboard.nonAnimHeight;
        return max;
    }

    readonly property int openMargin: bar?.isFloating ? 10 : 0
    readonly property real slideOffset: (-implicitHeight - openMargin - 15) * offsetScale
    property real offsetScale: shouldBeActive ? 0 : 1

    onShouldBeActiveChanged: {
        if (shouldBeActive)
            implicitHeight = Qt.binding(() => content.implicitHeight);
        else
            implicitHeight = implicitHeight; // Break binding during close anim
    }

    visible: offsetScale < 1
    anchors.bottomMargin: openMargin + slideOffset
    implicitHeight: content.implicitHeight
    implicitWidth: content.implicitWidth || 630 // Hard coded fallback for first open
    scale: 1 - 0.04 * offsetScale
    opacity: 1 - offsetScale

    Component.onCompleted: Qt.callLater(() => Apps) // Load apps on init

    Behavior on offsetScale {
        Anim {}
    }

    Loader {
        id: content

        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter

        active: root.shouldBeActive || root.visible

        sourceComponent: Content {
            screenState: root.screenState
            panels: root.panels
            maxHeight: root.maxHeight
        }
    }
}
