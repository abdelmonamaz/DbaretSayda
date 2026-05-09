import QtQuick
import QtQuick.Layouts
import QtQuick.Effects

Rectangle {
    id: appHeader

    property int globalServings: 4
    property int dishCount: 0

    signal generateMenuClicked

    readonly property bool isAr: I18n.currentLanguage === 'ar'

    readonly property int weekNumber: {
        var d = new Date();
        d.setHours(0, 0, 0, 0);
        d.setDate(d.getDate() + 3 - (d.getDay() + 6) % 7);
        var week1 = new Date(d.getFullYear(), 0, 4);
        return 1 + Math.round(((d - week1) / 86400000 - 3 + (week1.getDay() + 6) % 7) / 7);
    }

    color: Theme.colors.bone
    implicitHeight: col.implicitHeight + 24   // 10 top + 14 bottom

    Column {
        id: col
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            topMargin: 10
            leftMargin:  Theme.sizes.lg
            rightMargin:  Theme.sizes.lg
        }
        spacing: 12

        // ── Row 1 : wordmark · week tag · zellige ────────────────────────────
        RowLayout {
            width: parent.width
            spacing: 0

            // Left group: stacked wordmark + week tag
            Row {
                spacing: 10

                // Stacked wordmark — both lines in fontSerif
                Column {
                    id: brandCol
                    spacing: 0

                    Text {
                        text: (I18n.currentLanguage, I18n.t('brand.top'))
                        height: 28
                        font.pixelSize: 30
                        font.family:        isAr ? "Aref Ruqaa" : Theme.typography.fontSerif
                        font.italic:        false
                        font.letterSpacing: isAr ? 0 : -0.3
                        color: Theme.colors.ink
                    }
                    Text {
                        text: (I18n.currentLanguage, I18n.t('brand.bottom'))
                        height: 28
                        font.pixelSize: 30
                        font.family:        isAr ? "Aref Ruqaa" : Theme.typography.fontSerif
                        font.italic:        !isAr
                        font.letterSpacing: isAr ? 0 : -0.3
                        color: Theme.colors.harissa.deep
                    }
                }

                // Week tag — ancré sur le centre vertical du Column
                Text {
                    anchors.verticalCenter: brandCol.verticalCenter
                    text: "· " + (isAr ? I18n.t('home.weekLabel') : I18n.t('home.weekLabel').toUpperCase()) + " " + I18n.formatNumber(weekNumber)
                    font.pixelSize: 11
                    font.family: Theme.typography.fontUI
                    font.weight: Font.Medium
                    font.letterSpacing: isAr ? 0 : 1.5
                    color: Theme.colors.ink3
                }
            }

            Item {
                Layout.fillWidth: true
            }

            // Zellige icon — two concentric rotated squares
            Item {
                implicitWidth: 22
                implicitHeight: 22
                Layout.alignment: Qt.AlignVCenter

                Rectangle {
                    anchors.centerIn: parent
                    width: 13
                    height: 13
                    rotation: 45
                    radius: 1.5
                    color: Theme.colors.harissa.soft
                    border.color: Theme.colors.harissa.main
                    border.width: 1.5
                }
                Rectangle {
                    anchors.centerIn: parent
                    width: 7
                    height: 7
                    rotation: 0
                    radius: 1
                    color: Theme.colors.harissa.main
                    border.width: 0
                }
            }
        }

        Item { width: 1; height: 3 }   // 3px extra spacing between brand and servings card

        // ── Row 2 : global servings card ─────────────────────────────────────
        Rectangle {
            width: parent.width
            height: peopleRow.implicitHeight + 16   // 8 top + 8 bottom
            color: Theme.colors.card
            radius: Theme.sizes.radius.xl           // 14 px
            border.color: Theme.colors.line
            border.width: 1

            RowLayout {
                id: peopleRow
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    right: parent.right
                    leftMargin: 14
                    rightMargin: 10
                }
                spacing: 10

                // Person icon — Lucide users.svg
                Image {
                    width:      20
                    height:     20
                    source:     "qrc:/icons/users.svg"
                    sourceSize: Qt.size(20, 20)
                    fillMode:   Image.PreserveAspectFit
                    smooth:     true

                    layer.enabled: true
                    layer.effect: MultiEffect {
                        colorization:      1.0
                        colorizationColor: Theme.colors.ink2
                    }
                }

                // Text labels
                Column {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        text: (I18n.currentLanguage, I18n.formatNumber(appHeader.globalServings) + " " + I18n.t('message.servings'))
                        font.pixelSize: 14
                        font.family: Theme.typography.fontUI
                        font.weight: Font.DemiBold
                        color: Theme.colors.ink
                    }
                    Text {
                        text: (I18n.currentLanguage, I18n.t('header.weekRange'))
                        font.pixelSize: 11
                        font.family: Theme.typography.fontUI
                        font.weight: Font.Medium
                        font.letterSpacing: isAr ? 0 : 0.4
                        color: Theme.colors.ink3
                    }
                }

                // Stepper — size lg (matching spec)
                PeopleStepper {
                    value: appHeader.globalServings
                    size: 'lg'
                    onValueChanged: appHeader.globalServings = value
                }
            }
        }

        // ── Row 3 : generate menu button ─────────────────────────────────────
        Rectangle {
            id: genBtn
            width: parent.width
            height: 56
            radius: 18

            // Vertical gradient: harissa → deep
            gradient: Gradient {
                orientation: Gradient.Vertical
                GradientStop {
                    position: 0.0
                    color: Theme.colors.harissa.main
                }
                GradientStop {
                    position: 1.0
                    color: Theme.colors.harissa.deep
                }
            }

            // Outer warm shadow
            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: Qt.rgba(0.55, 0.27, 0.07, 0.55)
                shadowVerticalOffset: 8
                shadowHorizontalOffset: 0
                shadowBlur: 0.55
            }

            // Inner top highlight (inset simulation)
            Rectangle {
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                }
                height: 2
                radius: parent.radius
                color: Qt.rgba(1, 1, 1, 0.35)
            }

            RowLayout {
                anchors {
                    fill: parent
                    leftMargin: 16
                    rightMargin: 16
                }
                spacing: 10

                // Spark icon — mealit-icons.jsx path (24×24 → 20×20)
                Canvas {
                    implicitWidth:  20
                    implicitHeight: 20

                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.clearRect(0, 0, 20, 20)
                        ctx.save()
                        ctx.scale(20 / 24, 20 / 24)   // viewBox 0 0 24 24 → 20×20

                        ctx.fillStyle = "#ffffff"

                        // 4-pointed star
                        ctx.beginPath()
                        ctx.moveTo(12, 3)
                        ctx.lineTo(13.6, 8.4)
                        ctx.lineTo(19, 10)
                        ctx.lineTo(13.6, 11.6)
                        ctx.lineTo(12, 17)
                        ctx.lineTo(10.4, 11.6)
                        ctx.lineTo(5, 10)
                        ctx.lineTo(10.4, 8.4)
                        ctx.closePath()
                        ctx.fill()

                        // Accent dots (opacity 0.5)
                        ctx.globalAlpha = 0.5
                        ctx.beginPath()
                        ctx.arc(19, 5, 1.3, 0, 2 * Math.PI)
                        ctx.fill()
                        ctx.beginPath()
                        ctx.arc(5, 18, 1, 0, 2 * Math.PI)
                        ctx.fill()

                        ctx.restore()
                    }
                }

                // CTA label
                Text {
                    Layout.fillWidth: true
                    text: {
                        var t = I18n.t('header.generate');
                        return isAr ? t : t.toUpperCase();
                    }
                    font.pixelSize: isAr ? 16 : 15
                    font.family: Theme.typography.fontUI
                    font.weight: Font.Bold
                    font.letterSpacing: isAr ? 0 : 0.9
                    color: "#ffffff"
                }

                // Dish count badge — semi-transparent white
                Rectangle {
                    radius: 10
                    color: Qt.rgba(1, 1, 1, 0.18)
                    implicitWidth: ctaBadge.implicitWidth + 20
                    implicitHeight: ctaBadge.implicitHeight + 12

                    Text {
                        id: ctaBadge
                        anchors.centerIn: parent
                        text: (I18n.currentLanguage, I18n.formatNumber(appHeader.dishCount) + " " + I18n.t('dishes.unit'))
                        font.pixelSize: 12
                        font.family: Theme.typography.fontUI
                        font.weight: Font.DemiBold
                        font.letterSpacing: isAr ? 0 : 0.7
                        color: "#ffffff"
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: appHeader.generateMenuClicked()
            }
        }
    }
}
