pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import Caelestia.Config
import Caelestia.I18n
import qs.components
import qs.components.controls
import qs.services
import qs.utils
import qs.modules.nexus.common

PageBase {
    id: root

    title: Tr.tr("App volumes")
    isSubPage: true

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.extraSmall / 2

        StyledText {
            Layout.fillWidth: true
            Layout.leftMargin: Tokens.padding.small
            Layout.bottomMargin: Tokens.spacing.medium
            text: Tr.tr("Set each app's volume and the device it uses. Click an app's icon to mute it.")
            color: Colours.palette.m3outline
            font: Tokens.font.body.small
            wrapMode: Text.WordWrap
        }

        SectionHeader {
            first: true
            text: Tr.tr("Playing")
        }

        StreamList {
            streams: Audio.playbackStreams
            devices: Audio.sinks
            placeholderIcon: "music_off"
            placeholderText: Tr.tr("No apps playing audio")
        }

        SectionHeader {
            text: Tr.tr("Recording")
        }

        StreamList {
            streams: Audio.recordingStreams
            devices: Audio.sources
            placeholderIcon: "mic_off"
            placeholderText: Tr.tr("No apps using a microphone")
        }
    }

    component StreamList: ItemList {
        id: streamList

        property list<PwNode> streams
        property list<PwNode> devices

        first: true
        last: true
        showList: true
        color: list.count === 0 ? Colours.tPalette.m3surfaceContainer : "transparent"
        list.spacing: Tokens.spacing.extraSmall / 2

        model: ScriptModel {
            values: [...streamList.streams]
        }

        delegate: ColumnLayout {
            id: stream

            required property PwNode modelData
            required property int index

            readonly property bool muted: !!modelData?.audio?.muted
            readonly property PwNode device: Audio.streamDevice(modelData)

            anchors.left: streamList.list.contentItem.left
            anchors.right: streamList.list.contentItem.right
            spacing: Tokens.spacing.extraSmall / 2

            SliderRow {
                first: stream.index === 0

                icon: Audio.isRecording(stream.modelData) ? Icons.getMicVolumeIcon(stream.modelData?.audio?.volume ?? 0, stream.muted) : Icons.getVolumeIcon(stream.modelData?.audio?.volume ?? 0, stream.muted)
                iconClickable: true
                label: Audio.getStreamName(stream.modelData)
                valueLabel: stream.muted ? Tr.tr("Muted") : Strings.percentOne(value)
                value: stream.modelData?.audio?.volume ?? 0
                onMoved: v => Audio.setStreamVolume(stream.modelData, v)
                onIconClicked: Audio.setStreamMuted(stream.modelData, !stream.muted)
            }

            SelectRow {
                last: stream.index === streamList.list.count - 1

                label: Audio.isRecording(stream.modelData) ? Tr.tr("Input device") : Tr.tr("Output device")
                menuItems: [...deviceItems.instances]
                active: deviceItems.instances.find(i => stream.device && i.value?.id === stream.device.id) ?? null
                fallbackText: Tr.tr("Not connected")
                onSelected: item => Audio.moveStream(stream.modelData, item.value)

                Variants {
                    id: deviceItems

                    model: [...streamList.devices]

                    MenuItem {
                        required property PwNode modelData

                        text: modelData?.description || modelData?.name || ""
                        value: modelData
                    }
                }
            }
        }
    }
}
