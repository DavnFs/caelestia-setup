import QtQuick
import Caelestia.Config
import qs.components
import qs.services
import qs.modules.sidebar as Sidebar

// The sidebar's notification list, reused as a dashboard tab
StyledRect {
    id: root

    required property ScreenState screenState

    implicitWidth: 620
    implicitHeight: 460

    radius: Tokens.rounding.large
    color: Colours.tPalette.m3surfaceContainerLow

    Sidebar.NotifDock {
        props: Sidebar.Props {
            reloadableId: "dashboardNotifs"
        }
        screenState: root.screenState
    }
}
