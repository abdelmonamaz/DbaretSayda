import QtQuick

Rectangle {
    id: stepper

    property int    value:    1
    property string size:     'lg'   // 'lg' | 'sm'
    property int    minValue: 1
    property int    maxValue: 999

    readonly property bool isLg:    size === 'lg'
    readonly property int  btnSize: isLg ? 32 : 24
    readonly property int  numW:    isLg ? 42 : 30

    // Container: white · 1px border · pill
    color:  Theme.colors.card
    radius: Theme.sizes.radius.pill
    border.color: Theme.colors.line
    border.width: 1

    implicitWidth:  btnSize * 2 + numW + 6 * 4   // 2 btns + num + 2 inner gaps + 2 side paddings
    implicitHeight: btnSize + 8                   // btn + 4 top + 4 bottom

    Row {
        anchors.centerIn: parent
        spacing: 6

        // ── Minus ────────────────────────────────────────────────────────────
        Rectangle {
            width:  btnSize
            height: btnSize
            radius: Theme.sizes.radius.pill
            color:  Theme.colors.bone2

            Text {
                anchors.centerIn: parent
                text:           "−"
                font.pixelSize: isLg ? 17 : 14
                font.weight:    Font.DemiBold
                color:          Theme.colors.ink
            }
            MouseArea {
                anchors.fill: parent
                onClicked: if (stepper.value > stepper.minValue) stepper.value--
            }
        }

        // ── Value ─────────────────────────────────────────────────────────────
        Item {
            width:  numW
            height: btnSize

            Text {
                anchors.centerIn:   parent
                text:               I18n.formatNumber(stepper.value)
                font.pixelSize:     isLg ? 15 : 12
                font.family:        Theme.typography.fontMono
                font.weight:        Font.Bold
                font.letterSpacing: isLg ? 0.6 : 0.5
                color:              Theme.colors.ink
            }
        }

        // ── Plus ─────────────────────────────────────────────────────────────
        Rectangle {
            width:  btnSize
            height: btnSize
            radius: Theme.sizes.radius.pill
            color:  Theme.colors.bone2

            Text {
                anchors.centerIn: parent
                text:           "+"
                font.pixelSize: isLg ? 17 : 14
                font.weight:    Font.DemiBold
                color:          Theme.colors.ink
            }
            MouseArea {
                anchors.fill: parent
                onClicked: if (stepper.value < stepper.maxValue) stepper.value++
            }
        }
    }
}
