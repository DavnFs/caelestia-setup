pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import Caelestia.I18n
import qs.components
import qs.components.controls
import qs.components.filedialog
import qs.services
import qs.utils
import qs.modules.nexus.common

PageBase {
    id: root

    readonly property list<MenuItem> backgroundItems: [
        MenuItem {
            text: Tr.tr("Desktop wallpaper")
            value: "wallpaper"
        },
        MenuItem {
            text: Tr.tr("Image")
            value: "image"
        },
        MenuItem {
            text: Tr.tr("Live wallpaper")
            value: "video"
        }
    ]

    function fileName(path: string): string {
        return path ? path.split("/").pop() : Tr.tr("None chosen");
    }

    title: Tr.tr("Lock screen")

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.extraSmall / 2

        SectionHeader {
            first: true
            text: Tr.tr("Background")
        }

        SelectRow {
            first: true
            last: LockSettings.background === "wallpaper"
            label: Tr.tr("Background")
            subtext: Tr.tr("What shows behind the clock")
            menuItems: root.backgroundItems
            active: root.backgroundItems.find(i => i.value === LockSettings.background) ?? null
            onSelected: item => LockSettings.set("background", item.value)
        }

        RowButton {
            visible: LockSettings.background === "image"
            last: true
            icon: "image"
            text: Tr.tr("Choose image")
            subtext: root.fileName(LockSettings.imagePath)
            onClicked: imageDialog.open()

            FileDialog {
                id: imageDialog

                title: Tr.tr("Select an image")
                filterLabel: Tr.tr("Image files")
                filters: Images.validImageExtensions
                onAccepted: path => LockSettings.set("imagePath", path)
            }
        }

        RowButton {
            visible: LockSettings.background === "video"
            icon: "movie"
            text: Tr.tr("Choose video")
            subtext: root.fileName(LockSettings.videoPath)
            onClicked: videoDialog.open()

            FileDialog {
                id: videoDialog

                title: Tr.tr("Select a video")
                filterLabel: Tr.tr("Video files")
                filters: LockSettings.videoExtensions
                onAccepted: path => LockSettings.set("videoPath", path)
            }
        }

        ToggleRow {
            visible: LockSettings.background === "video"
            last: true
            text: Tr.tr("Play only when charging")
            subtext: Tr.tr("Shows a still frame on battery to save power")
            checked: LockSettings.videoOnlyWhenCharging
            onToggled: LockSettings.set("videoOnlyWhenCharging", checked)
        }

        SectionHeader {
            text: Tr.tr("Widgets")
        }

        ToggleRow {
            first: true
            last: true
            text: Tr.tr("Now playing")
            subtext: Tr.tr("Show music controls while something is playing")
            checked: LockSettings.showMedia
            onToggled: LockSettings.set("showMedia", checked)
        }
    }
}
