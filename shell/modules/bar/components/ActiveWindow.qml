pragma ComponentBehavior: Bound

import QtQuick
import Caelestia.Config
import Caelestia.I18n
import qs.components
import qs.services
import qs.utils

StyledRect {
    id: root

    required property var bar
    property bool isHorizontal: false
    property color colour: Colours.palette.m3primary
    readonly property int paddingH: Tokens.padding.medium

    readonly property string windowTitle: {
        const title = Hypr.activeToplevel?.title;
        if (!title)
            return Tr.trCtx("Desktop", "shown when no window is focused");
        if (Config.bar.activeWindow.compact) {
            const parts = title.split(/\s+[\-\u2013\u2014]\s+/);
            if (parts.length > 1)
                return parts[parts.length - 1].trim();
        }
        return title;
    }

    readonly property real minimumAlong: (isHorizontal ? icon.implicitWidth : icon.implicitHeight) + Tokens.spacing.small + paddingH * 2
    readonly property real maxAlong: {
        let otherAlong = 0;
        for (const child of bar.children) {
            if (child.entryId && child.item !== this && child.entryId !== "spacer")
                otherAlong += child.item.nonAnimAlong ?? (isHorizontal ? child.item.implicitWidth : child.item.implicitHeight);
        }
        const totalAlong = isHorizontal ? bar.width : bar.height;
        const spacing = isHorizontal ? bar.columnSpacing : bar.rowSpacing;
        return Math.max(0, totalAlong - otherAlong - spacing * Math.max(0, bar.entryCount - 1) - bar.axisPadding * 2);
    }
    property Title current: text1

    clip: true
    implicitWidth: isHorizontal ? Math.max(minimumAlong, Math.min(maxAlong, icon.implicitWidth + current.implicitWidth + (current.text.length > 0 ? Tokens.spacing.small : 0) + paddingH * 2)) : Tokens.sizes.bar.innerWidth
    implicitHeight: Tokens.sizes.bar.innerWidth

    color: stateLayer.containsMouse ? Colours.tPalette.m3surfaceContainerHigh : "transparent"
    radius: Tokens.rounding.medium
    border.width: 0

    Behavior on color {
        CAnim {}
    }

    Behavior on implicitWidth {
        Anim {}
    }

    Behavior on implicitHeight {
        Anim {}
    }

    StateLayer {
        id: stateLayer
        anchors.fill: parent
        radius: Tokens.rounding.medium
        color: Colours.palette.m3primary
        cursorShape: Qt.PointingHandCursor

        onClicked: event => {
            const popouts = root.bar.popouts;
            if (popouts.hasCurrent) {
                popouts.hasCurrent = false;
            } else {
                popouts.currentName = "activewindow";
                popouts.currentCenter = root.bar.activeWindowCenter(root);
                popouts.hasCurrent = true;
            }
        }
    }

    MaterialIcon {
        id: icon

        anchors.horizontalCenter: root.isHorizontal ? undefined : parent.horizontalCenter
        anchors.left: root.isHorizontal ? parent.left : undefined
        anchors.leftMargin: root.isHorizontal ? root.paddingH : 0
        anchors.verticalCenter: root.isHorizontal ? parent.verticalCenter : undefined

        animate: true
        text: Icons.getAppCategoryIcon(Hypr.activeToplevel?.lastIpcObject.class, "desktop_windows")
        color: root.colour
        fontStyle: Tokens.font.icon.small
    }

    Title {
        id: text1
    }

    Title {
        id: text2
    }

    TextMetrics {
        id: metrics

        text: root.windowTitle
        font: root.Tokens.font.label.builders.small.letterSpacing(0.2).build()
        elide: Qt.ElideRight
        elideWidth: Math.max(0, Math.min(root.maxAlong, root.isHorizontal ? root.bar.width / 4 : Infinity) - root.minimumAlong)

        onTextChanged: {
            const next = root.current === text1 ? text2 : text1;
            next.text = elidedText;
            root.current = next;
        }
        onElideWidthChanged: root.current.text = elidedText
    }

    component Title: StyledText {
        id: text

        anchors.horizontalCenter: root.isHorizontal ? undefined : icon.horizontalCenter
        anchors.top: root.isHorizontal ? undefined : icon.bottom
        anchors.topMargin: root.isHorizontal ? 0 : Tokens.spacing.small

        anchors.left: root.isHorizontal ? icon.right : undefined
        anchors.leftMargin: root.isHorizontal ? Tokens.spacing.small : 0
        anchors.verticalCenter: root.isHorizontal ? icon.verticalCenter : undefined

        font: metrics.font
        color: Colours.palette.m3onSurface
        opacity: root.current === this ? 1 : 0
        horizontalAlignment: Text.AlignLeft

        transform: [
            Translate {
                x: root.isHorizontal ? 0 : (root.Config.bar.activeWindow.inverted ? -text.implicitWidth + text.implicitHeight : 0)
            },
            Rotation {
                angle: root.isHorizontal ? 0 : (root.Config.bar.activeWindow.inverted ? 270 : 90)
                origin.x: text.implicitHeight / 2
                origin.y: text.implicitHeight / 2
            }
        ]

        width: root.isHorizontal ? implicitWidth : implicitHeight
        height: root.isHorizontal ? implicitHeight : implicitWidth

        Behavior on opacity {
            Anim {
                type: Anim.DefaultEffects
            }
        }
    }
}
