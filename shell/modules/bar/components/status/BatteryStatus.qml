import QtQuick
import Quickshell.Services.UPower
import Caelestia.Config
import qs.components
import qs.services
import qs.utils

Row {
    id: root

    required property color colour
    property bool isHorizontal: false

    readonly property var battery: UPower.displayDevice
    readonly property color tint: !UPower.onBattery || battery.percentage > 0.2 ? colour : Colours.palette.m3error

    spacing: Tokens.spacing.small / 2

    MaterialIcon {
        anchors.verticalCenter: parent.verticalCenter
        animate: true
        text: {
            if (!root.battery.isLaptopBattery) {
                if (PowerProfiles.profile === PowerProfile.PowerSaver)
                    return "energy_savings_leaf";
                if (PowerProfiles.profile === PowerProfile.Performance)
                    return "rocket_launch";
                return "balance";
            }
            return Icons.getBatteryIcon(root.battery.percentage, [UPowerDeviceState.Charging, UPowerDeviceState.FullyCharged, UPowerDeviceState.PendingCharge].includes(root.battery.state));
        }
        color: root.tint
        fill: 1
    }

    // Percentage, plus live draw while discharging (no room for text on the vertical bar)
    StyledText {
        anchors.verticalCenter: parent.verticalCenter
        visible: root.isHorizontal && root.battery.isLaptopBattery
        text: {
            const pct = `${Math.round(root.battery.percentage * 100)}%`;
            return UPower.onBattery && root.battery.changeRate > 0 ? `${pct} · ${root.battery.changeRate.toFixed(1)}W` : pct;
        }
        font: Tokens.font.label.builders.small.weight(Font.Medium).build()
        color: root.tint
    }
}
