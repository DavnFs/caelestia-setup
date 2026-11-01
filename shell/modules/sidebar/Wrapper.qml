pragma ComponentBehavior: Bound

import QtQuick
import Caelestia
import Caelestia.Config
import qs.components

Item {
    id: root

    property var bar: null
    required property ScreenState screenState
    required property bool mirrored
    readonly property Props props: Props {}

    readonly property int floatMargin: bar?.isFloating ? 10 : 0
    readonly property real slideOffset: (implicitWidth + floatMargin + 15) * offsetScale
    readonly property bool shouldBeActive: screenState.sidebar && Config.sidebar.enabled
    property real offsetScale: shouldBeActive ? 0 : 1

    visible: offsetScale < 1

    implicitWidth: Tokens.sizes.sidebar.width
    scale: 1 - 0.04 * offsetScale
    opacity: 1 - offsetScale

    Behavior on offsetScale {
        Anim {}
    }

    Loader {
        id: content

        anchors.fill: parent

        active: root.shouldBeActive || root.visible

        sourceComponent: Content {
            props: root.props
            screenState: root.screenState
        }
    }
}
