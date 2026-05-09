import QtQuick
import QtQuick.Effects

Item {
    id: root

    property int  value:    4
    property bool expanded: false

    implicitWidth:  expanded ? stepperRow.implicitWidth  : pillRect.implicitWidth
    implicitHeight: Math.max(pillRect.implicitHeight, stepperRow.implicitHeight)

    // ── Compact pill ──────────────────────────────────────────────────────
    Rectangle {
        id:      pillRect
        visible: !root.expanded
        anchors.right:          parent.right
        anchors.verticalCenter: parent.verticalCenter

        implicitWidth:  pillRow.implicitWidth + 18
        implicitHeight: 26
        radius:         Theme.sizes.radius.pill
        color:          Theme.colors.card
        border.color:   "#141B1714"   // rgba(27,23,20,0.08)
        border.width:   1

        Row {
            id:               pillRow
            anchors.centerIn: parent
            spacing:          5

            Image {
                width:      13
                height:     13
                source:     "qrc:/icons/users.svg"
                sourceSize: Qt.size(26, 26)
                fillMode:   Image.PreserveAspectFit
                anchors.verticalCenter: parent.verticalCenter

                layer.enabled: true
                layer.effect: MultiEffect {
                    colorization:      1.0
                    colorizationColor: Theme.colors.ink2
                }
            }

            Text {
                text:           (I18n.currentLanguage, I18n.formatNumber(root.value) + " " + I18n.t('message.servings'))
                color:          Theme.colors.ink2
                font.pixelSize: 12
                font.family:    Theme.typography.fontUI
                font.weight:    Font.DemiBold
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked:    root.expanded = true
        }
    }

    // ── Expanded: stepper + close ─────────────────────────────────────────
    Row {
        id:      stepperRow
        visible: root.expanded
        anchors.right:          parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: 6

        PeopleStepper {
            id:    stepper
            size:  'sm'
            value: root.value
            anchors.verticalCenter: parent.verticalCenter
            onValueChanged: root.value = stepper.value
        }

        Rectangle {
            width:  24
            height: 24
            radius: Theme.sizes.radius.pill
            color:  Theme.colors.bone2
            anchors.verticalCenter: parent.verticalCenter

            Text {
                anchors.centerIn: parent
                text:           "×"
                font.pixelSize: 16
                font.family:    Theme.typography.fontUI
                color:          Theme.colors.ink3
            }

            MouseArea {
                anchors.fill: parent
                onClicked:    root.expanded = false
            }
        }
    }
}
