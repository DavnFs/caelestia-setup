pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.services
import qs.utils

// Login screen (SDDM) settings, managed from Nexus and synced to /var/tmp/caelestia-sddm
Singleton {
    id: root

    // "wallpaper", "image" or "video"
    property string background: "wallpaper"
    property string imagePath: ""
    property string videoPath: ""
    property bool showPowerButtons: true
    property bool twelveHour: false

    readonly property list<string> keys: ["background", "imagePath", "videoPath", "showPowerButtons", "twelveHour"]
    readonly property list<string> videoExtensions: ["mp4", "webm", "mkv", "mov", "m4v"]

    function set(key: string, value: var): void {
        root[key] = value;
        saveTimer.restart();
    }

    function syncAssets(): void {
        let src = "";
        let isVid = false;
        if (root.background === "wallpaper") {
            src = Wallpapers.current || "";
        } else if (root.background === "image") {
            src = root.imagePath;
        } else if (root.background === "video") {
            src = root.videoPath;
            isVid = true;
        }

        const script = `
            mkdir -p /var/tmp/caelestia-sddm
            chmod 777 /var/tmp/caelestia-sddm
            rm -f /var/tmp/caelestia-sddm/background* /var/tmp/caelestia-sddm/login.json
            cat << 'EOF' > /var/tmp/caelestia-sddm/login.json
${JSON.stringify({
    background: root.background,
    imagePath: root.imagePath,
    videoPath: root.videoPath,
    showPowerButtons: root.showPowerButtons,
    twelveHour: root.twelveHour,
    colours: {
        primary: Colours.palette.m3primary.toString(),
        secondary: Colours.palette.m3secondary.toString(),
        tertiary: Colours.palette.m3tertiary.toString(),
        primaryFixed: Colours.palette.m3primaryFixed.toString(),
        secondaryFixed: Colours.palette.m3secondaryFixed.toString(),
        tertiaryFixed: Colours.palette.m3tertiaryFixed.toString(),
        onSurface: Colours.palette.m3onSurface.toString(),
        surface: Colours.palette.m3surface.toString(),
        surfaceContainer: Colours.palette.m3surfaceContainer.toString(),
        outline: Colours.palette.m3outline.toString(),
        shadow: Colours.palette.m3shadow.toString(),
        light: Colours.light
    }
}, null, 4)}
EOF
            chmod 666 /var/tmp/caelestia-sddm/login.json
            if [ -n "${src}" ] && [ -f "${src}" ]; then
                if [ "${isVid}" = "true" ]; then
                    cp "${src}" /var/tmp/caelestia-sddm/background.mp4
                    chmod 666 /var/tmp/caelestia-sddm/background.mp4
                else
                    cp "${src}" /var/tmp/caelestia-sddm/background
                    chmod 666 /var/tmp/caelestia-sddm/background
                fi
            fi
        `;
        Quickshell.execDetached(["sh", "-c", script]);
    }

    Component.onCompleted: {
        root.syncAssets();
    }

    Connections {
        target: Colours
        function onSchemeChanged(): void {
            root.syncAssets();
        }
    }

    Timer {
        id: saveTimer

        interval: 300
        onTriggered: {
            const data = {};
            for (const k of root.keys)
                data[k] = root[k];
            storage.setText(JSON.stringify(data, null, 4));
            root.syncAssets();
        }
    }

    FileView {
        id: storage

        path: `${Paths.config}/login.json`
        printErrors: false
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            try {
                const data = JSON.parse(text());
                for (const k of root.keys)
                    if (data[k] !== undefined)
                        root[k] = data[k];
            } catch (e) {
                console.warn("login.json is not valid JSON, using defaults:", e);
            }
            root.syncAssets();
        }
    }
}
