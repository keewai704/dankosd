import QtQuick
import qs.Common
import qs.Widgets

DankOSD {
    id: root

    property var osdState
    property string iconName: "brightness_medium"
    property int levelValue: 0

    readonly property bool useVertical: isVerticalLayout
    readonly property real valueRatio: Math.max(0, Math.min(1, levelValue / 100))

    blurNamespace: "dms:osd"
    osdWidth: useVertical ? (40 + Theme.spacingS * 2) : Math.min(300, screen.width - Theme.spacingM * 2)
    osdHeight: useVertical ? Math.min(300, screen.height - Theme.spacingM * 2) : (40 + Theme.spacingS * 2)
    autoHideInterval: 2200
    enableMouseInteraction: false

    function updateAndShow(value) {
        levelValue = Math.max(0, Math.min(100, Math.round(value)));
        show();
    }

    Connections {
        target: osdState

        function onShowRequested() {
            root.iconName = osdState.iconName;
            root.updateAndShow(osdState.levelValue);
        }
    }

    content: Loader {
        anchors.fill: parent
        sourceComponent: useVertical ? verticalContent : horizontalContent
    }

    Component {
        id: horizontalContent

        Item {
            property int gap: Theme.spacingS

            anchors.centerIn: parent
            width: parent.width - Theme.spacingS * 2
            height: 40

            Rectangle {
                width: Theme.iconSize
                height: Theme.iconSize
                radius: Theme.iconSize / 2
                color: "transparent"
                x: parent.gap
                anchors.verticalCenter: parent.verticalCenter

                DankIcon {
                    anchors.centerIn: parent
                    name: root.iconName
                    size: Theme.iconSize
                    color: Theme.primary
                }
            }

            Item {
                id: barArea

                width: parent.width - Theme.iconSize - parent.gap * 3
                height: 24
                x: parent.gap * 2 + Theme.iconSize
                anchors.verticalCenter: parent.verticalCenter

                Rectangle {
                    id: sliderTrack
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    height: 12
                    radius: Theme.cornerRadius
                    color: Theme.outline
                }

                Rectangle {
                    anchors.verticalCenter: sliderTrack.verticalCenter
                    width: Math.max(0, Math.min(sliderTrack.width, sliderTrack.width * root.valueRatio))
                    height: sliderTrack.height
                    radius: Theme.cornerRadius
                    color: Theme.primary
                }

                Rectangle {
                    width: 8
                    height: 24
                    radius: Theme.cornerRadius
                    x: Math.max(0, Math.min(sliderTrack.width - width, (sliderTrack.width - width) * root.valueRatio))
                    anchors.verticalCenter: sliderTrack.verticalCenter
                    color: Theme.primary
                    border.width: 3
                    border.color: Theme.surfaceContainer
                }
            }
        }
    }

    Component {
        id: verticalContent

        Item {
            anchors.fill: parent
            property int gap: Theme.spacingS

            Rectangle {
                width: Theme.iconSize
                height: Theme.iconSize
                radius: Theme.iconSize / 2
                color: "transparent"
                anchors.horizontalCenter: parent.horizontalCenter
                y: gap

                DankIcon {
                    anchors.centerIn: parent
                    name: root.iconName
                    size: Theme.iconSize
                    color: Theme.primary
                }
            }

            Item {
                id: sliderArea
                width: 12
                height: parent.height - Theme.iconSize - gap * 3
                anchors.horizontalCenter: parent.horizontalCenter
                y: gap * 2 + Theme.iconSize

                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width
                    height: parent.height
                    color: Theme.outline
                    radius: Theme.cornerRadius
                }

                Rectangle {
                    width: parent.width
                    height: parent.height * root.valueRatio
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: Theme.primary
                    radius: Theme.cornerRadius
                }

                Rectangle {
                    width: 24
                    height: 8
                    radius: Theme.cornerRadius
                    y: Math.max(0, Math.min(parent.height - height, (parent.height - height) * (1 - root.valueRatio)))
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: Theme.primary
                    border.width: 3
                    border.color: Theme.surfaceContainer
                }
            }
        }
    }
}
