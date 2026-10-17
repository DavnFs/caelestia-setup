pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Caelestia.Config
import Caelestia.I18n
import qs.components
import qs.services
import qs.modules.nexus.common

// Band switcher for single-SSID dual-band Wi-Fi: live link status, gateway latency, band lock and Anti-Lag Mode.
// The work is done by assets/wifi-band.sh through NetworkManager (no root needed).
PageBase {
    id: root

    readonly property string script: Quickshell.shellPath("assets/wifi-band.sh")
    property var status: ({})
    property list<real> pings: []
    property bool busy
    property string message

    readonly property int freq: parseInt(status.freq) || 0
    readonly property bool on5: freq >= 4900
    readonly property int channel: freq ? (on5 ? (freq - 5000) / 5 : (freq - 2407) / 5) : 0
    readonly property real avgPing: pings.length ? pings.reduce((a, b) => a + b, 0) / pings.length : 0
    readonly property real jitter: pings.length ? Math.sqrt(pings.reduce((a, b) => a + (b - avgPing) ** 2, 0) / pings.length) : 0

    function run(args: list<string>): void {
        busy = true;
        message = Tr.tr("Reconnecting…");
        action.command = [script, ...args];
        action.running = true;
    }

    title: Tr.tr("Wi-Fi band")

    // Background work; PageBase only accepts visual children, so it lives in a hidden Item
    Item {
        visible: false

        Process {
            id: statusProc

            command: [root.script, "status"]
            stdout: StdioCollector {
                onStreamFinished: {
                    const s = {};
                    for (const line of text.trim().split("\n")) {
                        const i = line.indexOf("=");
                        if (i > 0)
                            s[line.slice(0, i)] = line.slice(i + 1);
                    }
                    root.status = s;
                }
            }
        }

        Timer {
            interval: 3000
            running: !root.busy
            repeat: true
            triggeredOnStart: true
            onTriggered: statusProc.running = true
        }

        // Live latency to the gateway; keeps the last 20 replies
        Process {
            running: !!root.status.gateway && !root.busy
            command: ["ping", "-n", "-i", "1", root.status.gateway ?? ""]
            stdout: SplitParser {
                onRead: line => {
                    const m = line.match(/time=([\d.]+)/);
                    if (m)
                        root.pings = [...root.pings.slice(-19), parseFloat(m[1])];
                }
            }
        }

        Process {
            id: action

            stdout: StdioCollector {
                onStreamFinished: {
                    const err = text.match(/error=(.*)/);
                    root.message = err ? err[1] : "";
                }
            }
            onExited: {
                root.busy = false;
                root.pings = [];
                statusProc.running = true;
            }
        }
    }

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.extraSmall / 2

        SectionHeader {
            first: true
            text: root.status.connection ?? Tr.tr("Not connected")
        }

        InfoRow {
            first: true
            icon: "network_wifi"
            label: Tr.tr("Band")
            value: root.freq ? `${root.on5 ? "5 GHz" : "2.4 GHz"} · ${Tr.tr("channel")} ${root.channel}` : "—"
        }

        InfoRow {
            icon: "router"
            label: Tr.tr("Access point")
            subtext: root.status.locked ? Tr.tr("Locked (Anti-Lag Mode)") : ""
            value: root.status.bssid ?? "—"
        }

        InfoRow {
            icon: "signal_cellular_alt"
            label: Tr.tr("Signal")
            subtext: {
                const s = parseInt(root.status.signal);
                return s >= -60 ? Tr.tr("Good") : s >= -70 ? Tr.tr("Fair") : s ? Tr.tr("Weak") : "";
            }
            value: root.status.signal ? `${root.status.signal} dBm` : "—"
        }

        InfoRow {
            last: true
            icon: "speed"
            label: Tr.tr("Gateway ping")
            subtext: Tr.tr("Average and jitter over the last %1 pings").arg(root.pings.length)
            value: root.pings.length ? `${root.avgPing.toFixed(0)} ms · ±${root.jitter.toFixed(0)} ms` : "—"
        }

        SectionHeader {
            text: Tr.tr("Band")
        }

        RowButton {
            first: true
            icon: "wifi"
            text: Tr.tr("Force 5 GHz")
            subtext: Tr.tr("Usually steadier on a busy network; shorter range")
            trailingIcon: root.status.band === "a" ? "check" : ""
            disabled: root.busy
            onClicked: root.run(["band", "5"])
        }

        RowButton {
            icon: "wifi_2_bar"
            text: Tr.tr("Force 2.4 GHz")
            subtext: Tr.tr("Longer range and stronger signal; more interference")
            trailingIcon: root.status.band === "bg" ? "check" : ""
            disabled: root.busy
            onClicked: root.run(["band", "2.4"])
        }

        RowButton {
            last: true
            icon: "autorenew"
            text: Tr.tr("Auto / Default")
            subtext: Tr.tr("Let the router choose the band")
            trailingIcon: root.status.band === "" ? "check" : ""
            disabled: root.busy
            onClicked: root.run(["band", "auto"])
        }

        SectionHeader {
            text: Tr.tr("Gaming & calls")
        }

        ToggleRow {
            first: true
            last: true
            text: Tr.tr("Anti-Lag Mode")
            subtext: Tr.tr("Stay on this access point and stop background Wi-Fi scans")
            checked: !!root.status.locked
            enabled: !root.busy
            onToggled: root.run(["antilag", checked ? "on" : "off"])
        }

        StyledText {
            Layout.fillWidth: true
            Layout.topMargin: Tokens.spacing.medium
            Layout.leftMargin: Tokens.padding.small
            visible: !!root.message
            text: root.message
            color: root.busy ? Colours.palette.m3outline : Colours.palette.m3error
            font: Tokens.font.body.small
            wrapMode: Text.WordWrap
        }
    }
}
