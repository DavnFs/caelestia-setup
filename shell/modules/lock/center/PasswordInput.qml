pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.services

StyledRect {
    id: root

    required property real centerScale
    required property int centerWidth
    required property var lock

    implicitWidth: {
        const w = centerWidth * 0.8;
        return lock.pam.buffer ? w : Math.min(w, inputField.placeholderWidth + iconWrapper.implicitWidth + enterButton.implicitWidth + input.spacing * 2 + Tokens.padding.medium * 2);
    }
    implicitHeight: input.implicitHeight + Tokens.padding.small

    color: Colours.palette.m3surfaceContainer
    radius: Tokens.rounding.large
    border.width: 1
    border.color: Colours.palette.m3outlineVariant

    layer.enabled: true
    layer.effect: MultiEffect {
        shadowEnabled: true
        blurMax: 16
        shadowColor: Qt.alpha(Colours.palette.m3shadow, 0.4)
        shadowVerticalOffset: 3
    }

    focus: true
    onActiveFocusChanged: {
        if (!activeFocus)
            forceActiveFocus();
    }

    Keys.onPressed: event => {
        if (root.lock.unlocking)
            return;

        if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return)
            inputField.placeholder.animate = false;

        root.lock.pam.handleKey(event);
    }

    Behavior on implicitWidth {
        Anim {}
    }

    StateLayer {
        hoverEnabled: false
        cursorShape: Qt.IBeamCursor
        onClicked: parent.forceActiveFocus()
    }

    RowLayout {
        id: input

        anchors.fill: parent
        anchors.margins: Tokens.padding.extraSmall
        spacing: Tokens.spacing.medium

        Item {
            id: iconWrapper

            Layout.fillHeight: true
            implicitWidth: height

            AnimLoader {
                anchors.centerIn: parent
                anchors.verticalCenterOffset: sourceComponent === iconComp ? 1 : 0
                sourceComp: root.lock.pam.passwd.active || root.lock.pam.howdy.active ? loadingComp : iconComp
            }

            Component {
                id: iconComp

                MaterialIcon {
                    animate: true
                    text: {
                        if (inputField.showPassword)
                            return "visibility";
                        if (root.lock.pam.fprint.tries >= GlobalConfig.lock.maxFprintTries) {
                            if (root.lock.pam.howdy.canAttempt)
                                return "face";
                            return "fingerprint_off";
                        }
                        if (root.lock.pam.fprint.active)
                            return "fingerprint";
                        if (root.lock.pam.howdy.canAttempt)
                            return "face";
                        return "lock";
                    }
                    color: !root.lock.pam.howdy.canAttempt && root.lock.pam.fprint.tries >= GlobalConfig.lock.maxFprintTries ? Colours.palette.m3error : Colours.palette.m3onSurfaceVariant
                    fontStyle: Tokens.font.icon.builders.medium.scale(root.centerScale).build()
                    fill: text === "face" || text === "visibility"

                    StateLayer {
                        anchors.fill: undefined
                        anchors.centerIn: parent
                        implicitWidth: {
                            const w = parent.implicitHeight + Tokens.padding.small * 2;
                            return w + (w % 2);
                        }
                        implicitHeight: implicitWidth
                        radius: Tokens.rounding.full

                        onClicked: {
                            parent.animate = false;
                            inputField.showPassword = !inputField.showPassword;
                            parent.animate = true;
                        }
                    }
                }
            }

            Component {
                id: loadingComp

                LoadingIndicator {
                    implicitSize: iconWrapper.height - Tokens.padding.small * 2
                }
            }
        }

        InputField {
            id: inputField

            Layout.fillWidth: true
            Layout.fillHeight: true

            centerScale: root.centerScale
            pam: root.lock.pam
        }

        StyledRect {
            id: enterButton

            implicitWidth: 32 * root.centerScale
            implicitHeight: 32 * root.centerScale
            radius: Tokens.rounding.medium
            color: root.lock.pam.buffer ? Colours.palette.m3primary : Qt.alpha(Colours.palette.m3surfaceContainerHighest, 0.5)
            border.width: 1
            border.color: root.lock.pam.buffer ? Colours.palette.m3primary : Colours.palette.m3outlineVariant

            scale: mouse.pressed ? 0.92 : (mouse.containsMouse && root.lock.pam.buffer) ? 1.05 : 1.0

            Behavior on scale {
                Anim {
                    type: Anim.FastSpatial
                }
            }

            Behavior on color {
                CAnim {}
            }

            MouseArea {
                id: mouse

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: root.lock.pam.buffer ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: root.lock.pam.buffer && root.lock.pam.passwd.start()
            }

            MaterialIcon {
                id: enterIcon

                anchors.centerIn: parent
                text: "arrow_forward"
                color: root.lock.pam.buffer ? Colours.palette.m3onPrimary : Colours.palette.m3onSurfaceVariant
                fontStyle: Tokens.font.icon.builders.small.scale(root.centerScale).build()
            }
        }
    }
}
