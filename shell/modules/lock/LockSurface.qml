pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Wayland
import Caelestia.Config
import qs.components
import qs.services

WlSessionLockSurface {
    id: root

    required property WlSessionLock lock
    required property Pam pam

    readonly property alias unlocking: unlockAnim.running

    contentItem.Config.screen: screen.name
    contentItem.Tokens.screen: screen.name

    color: "transparent"

    Connections {
        function onUnlock(): void {
            unlockAnim.start();
        }

        target: root.lock
    }

    SequentialAnimation {
        id: unlockAnim

        ParallelAnimation {
            Anim {
                target: content.foreground
                property: "opacity"
                to: 0
                type: Anim.StandardSmall
            }
            Anim {
                target: content.foreground
                property: "scale"
                to: 1.06
            }
            Anim {
                target: content.background
                property: "opacity"
                to: 0
                type: Anim.StandardLarge
            }
        }
        PropertyAction {
            target: root.lock
            property: "locked"
            value: false
        }
    }

    ParallelAnimation {
        running: true

        Anim {
            target: content.background
            property: "opacity"
            to: 1
            type: Anim.StandardLarge
        }
        Anim {
            target: content.foreground
            property: "opacity"
            to: 1
            type: Anim.StandardLarge
        }
        Anim {
            target: content.foreground
            property: "scale"
            to: 1
            type: Anim.StandardLarge
        }
    }

    Minimal {
        id: content

        anchors.fill: parent
        visible: Config.lock.enabled
        lock: root
        background.opacity: 0
        foreground.opacity: 0
        foreground.scale: 0.96
    }
}
