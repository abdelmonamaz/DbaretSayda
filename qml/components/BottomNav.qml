import QtQuick
import QtQuick.Layouts
import QtQuick.Effects

Item {
    id: bottomNav

    property int currentIndex: 0
    signal tabSelected(int idx)

    implicitHeight: 80   // card 64 + 8 top margin + 8 bottom margin

    Rectangle {
        anchors {
            fill:         parent
            leftMargin:   12
            rightMargin:  12
            topMargin:    8
            bottomMargin: 8
        }

        radius: 22
        color:  Theme.colors.card

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled:          true
            shadowColor:            "#18000000"
            shadowVerticalOffset:   4
            shadowHorizontalOffset: 0
            shadowBlur:             0.4
        }

        RowLayout {
            anchors {
                fill:         parent
                topMargin:    8
                bottomMargin: 8
                leftMargin:   10
                rightMargin:  10
            }
            spacing: 4

            Repeater {
                // Reading I18n.currentLanguage makes this array reactive to language changes
                model: (I18n.currentLanguage, [
                    { label: I18n.t('tabs.planner'),  icon: "calendar-blank", idx: 0 },
                    { label: I18n.t('tabs.dishes'),   icon: "chef-hat",       idx: 1 },
                    { label: I18n.t('tabs.shopping'), icon: "card-checklist", idx: 2 },
                    { label: I18n.t('tabs.settings'), icon: "settings",       idx: 3 }
                ])

                Rectangle {
                    Layout.fillWidth:  true
                    Layout.fillHeight: true

                    readonly property bool active: bottomNav.currentIndex === modelData.idx

                    color:  active ? Theme.colors.harissa.soft : "transparent"
                    radius: 14

                    Column {
                        anchors.centerIn: parent
                        spacing: 4

                        NavIcon {
                            anchors.horizontalCenter: parent.horizontalCenter
                            iconType:  modelData.icon
                            iconColor: parent.parent.active ? Theme.colors.harissa.deep : Theme.colors.ink2
                            sz: 22
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text:           modelData.label
                            font.pixelSize: 10
                            font.family:    Theme.typography.fontUI
                            color: parent.parent.active ? Theme.colors.harissa.deep : Theme.colors.ink2
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked:    bottomNav.tabSelected(modelData.idx)
                    }
                }
            }
        }
    }
}
