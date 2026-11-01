import QtQuick
import Caelestia.Config
import qs.components
import qs.services
import qs.modules.sidebar as Sidebar

// The sidebar's notification list, reused as a dashboard tab
StyledRect {
    id: root

    required property ScreenState screenState

    implicitWidth: 860
    implicitHeight: 480
    width: implicitWidth
    height: implicitHeight

    radius: Tokens.rounding.extraLarge
    color: Colours.palette.m3surfaceContainer

    Sidebar.NotifDock {
        props: Sidebar.Props {
            reloadableId: "dashboardNotifs"
        }
        screenState: root.screenState
    }
}
