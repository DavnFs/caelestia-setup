pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.utils

// Lock screen settings, kept in their own file since the main config only accepts its built-in keys
Singleton {
    id: root

    // "wallpaper", "image" or "video"
    property string background: "wallpaper"
    property string imagePath
    property string videoPath
    property bool videoOnlyWhenCharging: false
    property bool showMedia: true

    readonly property list<string> keys: ["background", "imagePath", "videoPath", "videoOnlyWhenCharging", "showMedia"]
    readonly property list<string> videoExtensions: ["mp4", "webm", "mkv", "mov", "m4v"]

    function set(key: string, value: var): void {
        root[key] = value;
        saveTimer.restart();
    }

    Timer {
        id: saveTimer

        interval: 300
        onTriggered: {
            const data = {};
            for (const k of root.keys)
                data[k] = root[k];
            storage.setText(JSON.stringify(data, null, 4));
        }
    }

    FileView {
        id: storage

        path: `${Paths.config}/lock.json`
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
                console.warn("lock.json is not valid JSON, using defaults:", e);
            }
        }
    }
}
