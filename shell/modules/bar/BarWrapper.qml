pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import Quickshell
import Caelestia.Config
import qs.components
import qs.services
import qs.utils
import qs.modules.bar.popouts as BarPopouts

Item {
    id: root

    required property ShellScreen screen
    required property ScreenState screenState
    required property BarPopouts.Wrapper popouts
    required property bool fullscreen
    required property rect dashboardHitRect

    readonly property bool disabled: Strings.testRegexList(Config.bar.excludedScreens, screen.name)
    readonly property string position: BarPosition.resolvedPosition(Config.bar.position)
    readonly property bool isHorizontal: BarPosition.isHorizontal(position)
    readonly property bool isFloating: Config.bar?.floating ?? true
    readonly property int floatMarginH: 10
    readonly property int floatMarginV: 10

    readonly property int padding: Math.max(Tokens.padding.small, Config.border.thickness)
    readonly property int thickness: Tokens.sizes.bar.innerWidth + padding * 2

    readonly property int contentWidth: isHorizontal ? (isFloating ? screen.width - floatMarginH * 2 : screen.width) : thickness
    readonly property int contentHeight: isHorizontal ? thickness : screen.height

    readonly property int clampedWidth: isHorizontal ? contentWidth : Math.max(Config.border.minThickness, implicitWidth)
    readonly property int clampedHeight: isHorizontal ? Math.max(Config.border.minThickness, implicitHeight) : screen.height

    readonly property int exclusiveZone: !disabled && (Config.bar.persistent || screenState.bar) ? (isFloating && isHorizontal ? thickness + floatMarginV : thickness) : Config.border.thickness
    readonly property bool shouldBeVisible: !fullscreen && !disabled && (Config.bar.persistent || screenState.bar || isHovered)
    property bool isHovered
    readonly property Item contentItem: (isHorizontal ? horizontalContent.item : verticalContent.item) as Item

    function closeTray(): void {
        (contentItem as Bar)?.closeTray();
    }

    function hasNonTitleEntryAt(along: real): bool {
        return (contentItem as Bar)?.hasNonTitleEntryAt(along - (isHorizontal && isFloating ? floatMarginH : 0)) ?? false;
    }

    function checkPopout(along: real): void {
        (contentItem as Bar)?.checkPopout(along - (isHorizontal && isFloating ? floatMarginH : 0));
    }

    function handleWheel(along: real, angleDelta: point): void {
        (contentItem as Bar)?.handleWheel(along - (isHorizontal && isFloating ? floatMarginH : 0), angleDelta);
    }

    clip: !isFloating
    visible: (isHorizontal ? height : width) > Config.border.thickness

    width: isHorizontal ? contentWidth : implicitWidth
    height: isHorizontal ? implicitHeight : screen.height

    implicitWidth: fullscreen ? 0 : (isHorizontal ? contentWidth : Config.border.thickness)
    implicitHeight: fullscreen ? 0 : (isHorizontal ? Config.border.thickness : screen.height)

    onIsHorizontalChanged: {
        if (popouts && !popouts.isDetached)
            popouts.hasCurrent = false;
    }

    states: State {
        name: "visible"
        when: root.shouldBeVisible

        PropertyChanges {
            root.implicitWidth: root.contentWidth
            root.implicitHeight: root.contentHeight
        }
    }

    transitions: [
        Transition {
            from: ""
            to: "visible"

            Anim {
                target: root
                properties: "implicitWidth,implicitHeight"
            }
        },
        Transition {
            from: "visible"
            to: ""

            Anim {
                target: root
                properties: "implicitWidth,implicitHeight"
                type: Anim.Emphasized
            }
        }
    ]

    StyledRect {
        id: barBg

        anchors.fill: parent
        radius: 15
        color: Colours.palette.m3surfaceContainer
        border.color: Colours.palette.m3outlineVariant
        border.width: 1
        visible: root.isFloating && root.shouldBeVisible

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            blurMax: 12
            shadowColor: Qt.alpha(Colours.palette.m3shadow, 0.4)
            shadowVerticalOffset: 2
        }
    }

    // Keep separate layout instances so an axis switch starts with fresh geometry.
    Loader {
        id: horizontalContent

        anchors.fill: parent
        active: root.shouldBeVisible && root.isHorizontal
        sourceComponent: barContent
    }

    Loader {
        id: verticalContent

        anchors.fill: parent
        active: root.shouldBeVisible && !root.isHorizontal
        sourceComponent: barContent
    }

    Component {
        id: barContent

        Bar {
            isHorizontal: root.isHorizontal
            width: root.width
            height: root.height
            screen: root.screen
            screenState: root.screenState
            popouts: root.popouts // qmllint disable incompatible-type
            fullscreen: root.fullscreen
            dashboardHitRect: root.dashboardHitRect
        }
    }
}
