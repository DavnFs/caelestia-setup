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

    title: Tr.tr("Login screen")

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
            last: LoginSettings.background === "wallpaper"
            label: Tr.tr("Background")
            subtext: Tr.tr("What shows behind the login card")
            menuItems: root.backgroundItems
            active: root.backgroundItems.find(i => i.value === LoginSettings.background) ?? null
            onSelected: item => LoginSettings.set("background", item.value)
        }

        RowButton {
            visible: LoginSettings.background === "image"
            last: true
            icon: "image"
            text: Tr.tr("Choose image")
            subtext: root.fileName(LoginSettings.imagePath)
            onClicked: imageDialog.open()

            FileDialog {
                id: imageDialog

                title: Tr.tr("Select an image")
                filterLabel: Tr.tr("Image files")
                filters: Images.validImageExtensions
                onAccepted: path => LoginSettings.set("imagePath", path)
            }
        }

        RowButton {
            visible: LoginSettings.background === "video"
            last: true
            icon: "movie"
            text: Tr.tr("Choose video")
            subtext: root.fileName(LoginSettings.videoPath)
            onClicked: videoDialog.open()

            FileDialog {
                id: videoDialog

                title: Tr.tr("Select a video")
                filterLabel: Tr.tr("Video files")
                filters: LoginSettings.videoExtensions
                onAccepted: path => LoginSettings.set("videoPath", path)
            }
        }

        SectionHeader {
            text: Tr.tr("Widgets")
        }

        ToggleRow {
            first: true
            text: Tr.tr("Power buttons")
            subtext: Tr.tr("Show restart and shutdown buttons")
            checked: LoginSettings.showPowerButtons
            onToggled: LoginSettings.set("showPowerButtons", checked)
        }

        ToggleRow {
            last: true
            text: Tr.tr("24-hour clock")
            subtext: Tr.tr("Display time in 24-hour format")
            checked: !LoginSettings.twelveHour
            onToggled: LoginSettings.set("twelveHour", !checked)
        }
    }
}
