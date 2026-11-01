pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.components
import qs.utils
import qs.modules.bar.popouts

Item {
    id: root

    property var bar: null
    required property ShellScreen screen
    required property real borderThickness
    required property string position

    readonly property bool isHorizontal: BarPosition.isHorizontal(position)

    readonly property alias content: content
    property real offsetScale: content.isDetached || content.hasCurrent ? 0 : 1

    visible: width > 0 && height > 0 && (content.hasCurrent || content.isDetached || offsetScale < 1)
    clip: !bar?.isFloating

    implicitWidth: bar?.isFloating ? content.implicitWidth : (isHorizontal ? content.implicitWidth : (content.implicitWidth * (1 - offsetScale)))
    implicitHeight: bar?.isFloating ? content.implicitHeight : (isHorizontal ? (content.implicitHeight * (1 - offsetScale)) : content.implicitHeight)

    x: {
        if (content.isDetached)
            return (parent.width - content.nonAnimWidth) / 2;
        if (!isHorizontal) {
            const gap = bar?.isFloating ? (bar.floatMarginH + 10) : 0;
            return BarPosition.isRight(position) ? (parent.width - width - gap) : gap;
        }

        const margin = bar?.isFloating ? 10 : 0;
        const off = content.currentCenter - borderThickness - content.nonAnimWidth / 2;
        const diff = (parent.width - margin) - Math.floor(off + content.nonAnimWidth);
        if (diff < 0)
            return off + diff;
        return Math.max(off, margin);
    }

    y: {
        if (content.isDetached)
            return (parent.height - content.nonAnimHeight) / 2;
        if (isHorizontal) {
            const gap = bar?.isFloating ? (bar.floatMarginV + 10) : 0;
            return BarPosition.isBottom(position) ? (parent.height - height - gap) : gap;
        }

        const margin = bar?.isFloating ? 10 : 0;
        const off = content.currentCenter - borderThickness - content.nonAnimHeight / 2;
        const diff = (parent.height - margin) - Math.floor(off + content.nonAnimHeight);
        if (diff < 0)
            return off + diff;
        return Math.max(off, margin);
    }

    Behavior on offsetScale {
        Anim {}
    }

    Behavior on x {
        enabled: (root.isHorizontal && !BarPosition.isRight(root.position)) || content.isDetached

        Anim {
            duration: content.animLength
            easing: content.animCurve
        }
    }

    Behavior on y {
        enabled: (!root.isHorizontal && !BarPosition.isBottom(root.position)) || content.isDetached

        Anim {
            duration: content.animLength
            easing: content.animCurve
        }
    }

    Wrapper {
        id: content

        screen: root.screen
        offsetScale: root.offsetScale

        scale: bar?.isFloating ? (1 - 0.04 * root.offsetScale) : 1
        opacity: 1 - root.offsetScale

        x: {
            if (root.isHorizontal)
                return (parent.width - width) / 2;
            if (bar?.isFloating) {
                const slide = 8 * root.offsetScale;
                return BarPosition.isRight(root.position) ? slide : -slide;
            }
            const slide = (-implicitWidth - 5) * root.offsetScale;
            return BarPosition.isRight(root.position) ? parent.width - width - slide : slide;
        }
        y: {
            if (!root.isHorizontal)
                return (parent.height - height) / 2;
            if (bar?.isFloating) {
                const slide = 8 * root.offsetScale;
                return BarPosition.isBottom(root.position) ? slide : -slide;
            }
            const slide = (-implicitHeight - 15) * root.offsetScale;
            return BarPosition.isBottom(root.position) ? parent.height - height - slide : slide;
        }
    }
}
