import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Dialogs

Rectangle {
    id: settingsPage
    color: Theme.colors.bone

    // ── Export : sélecteur de destination ─────────────────────────────────
    FileDialog {
        id: exportFileDialog
        fileMode:      FileDialog.SaveFile
        title:         "Enregistrer la base de données"
        defaultSuffix: "db"
        // Nom pré-rempli : Downloads/ftour_jomaa.db
        currentFile:   dbManager.defaultExportFolder() + "/ftour_jomaa.db"
        nameFilters:   ["Base SQLite (*.db)", "Tous les fichiers (*)"]

        onAccepted: {
            var url  = selectedFile.toString()
            var path = dbManager.exportDbTo(url)
            exportBtn.resultText = path.length > 0
                ? (url.startsWith("content://") ? "✓ Enregistré" : "✓ " + path.split("/").pop())
                : "❌ Échec de l'export"
        }
    }

    // ── Import : sélecteur de source ──────────────────────────────────────
    FileDialog {
        id: importFileDialog
        fileMode:    FileDialog.OpenFile
        title:       "Choisir un fichier de base de données"
        nameFilters: ["Base SQLite (*.db)", "Tous les fichiers (*)"]

        onAccepted: {
            var ok = dbManager.importDb(selectedFile.toString())
            if (ok) {
                // Rechargement complet de tous les modèles
                dishModel.loadFromDatabase()
                ingredientModel.loadFromDatabase()
                weeklyPlanningModel.loadForCurrentWeek()
                shoppingListModel.generateForCurrentWeek()
                importBtn.resultText = "✓ Base importée"
            } else {
                importBtn.resultText = "❌ Échec import"
            }
        }
    }

    ColumnLayout {
        anchors.fill:    parent
        anchors.margins: Theme.sizes.lg
        spacing:         Theme.sizes.xl

        Text {
            text:           (I18n.currentLanguage, I18n.t('settings.title'))
            color:          Theme.colors.ink
            font.pixelSize: Theme.typography.headerSize
            font.family:    Theme.typography.fontSerif
            font.bold:      true
        }

        // ── Langue ──────────────────────────────────────────────────────────
        Column {
            Layout.fillWidth: true
            spacing: Theme.sizes.md

            Text {
                text:           (I18n.currentLanguage, I18n.t('settings.language'))
                color:          Theme.colors.ink
                font.pixelSize: Theme.typography.buttonSize
                font.family:    Theme.typography.fontUI
                font.bold:      true
            }

            RowLayout {
                width: parent.width; spacing: Theme.sizes.lg

                ButtonDS {
                    text:    (I18n.currentLanguage, I18n.t('settings.arabic') + " 🇸🇦")
                    variant: I18n.currentLanguage === 'ar' ? 'primary' : 'secondary'
                    size:    'md'
                    Layout.fillWidth: true
                    onClicked: { I18n.setLanguage('ar'); Theme.language = 'ar' }
                }
                ButtonDS {
                    text:    (I18n.currentLanguage, I18n.t('settings.french') + " 🇫🇷")
                    variant: I18n.currentLanguage === 'fr' ? 'primary' : 'secondary'
                    size:    'md'
                    Layout.fillWidth: true
                    onClicked: { I18n.setLanguage('fr'); Theme.language = 'fr' }
                }
            }
        }

        // ── Export / Import BDD ──────────────────────────────────────────────
        Column {
            Layout.fillWidth: true
            spacing: Theme.sizes.md

            Text {
                text:           "Base de données"
                color:          Theme.colors.ink
                font.pixelSize: Theme.typography.buttonSize
                font.family:    Theme.typography.fontUI
                font.bold:      true
            }

            // ── Bouton Export ────────────────────────────────────────────
            DbActionButton {
                id:          exportBtn
                width:       parent.width
                icon:        "qrc:/icons/database.svg"
                label:       "Exporter ftour_jomaa.db"
                gradientTop: "#336FA8"
                gradientBot: "#1E4F7A"
                shadowColor: "#881B3A5C"
                onClicked: {
                    resultText = label   // remet le label par défaut
                    exportFileDialog.open()
                }
            }

            // ── Bouton Import ────────────────────────────────────────────
            DbActionButton {
                id:          importBtn
                width:       parent.width
                icon:        "qrc:/icons/database.svg"
                label:       "Importer une base de données"
                gradientTop: "#4A7C59"
                gradientBot: "#2E5237"
                shadowColor: "#882E5237"
                onClicked: {
                    resultText = label
                    importFileDialog.open()
                }
            }
        }

        Item { Layout.fillHeight: true }
    }

    // ── Composant bouton BDD réutilisable ──────────────────────────────────
    component DbActionButton: Rectangle {
        id: dbBtn
        height: 56; radius: 18

        property string icon:        ""
        property string label:       ""
        property string resultText:  label
        property string gradientTop: "#336FA8"
        property string gradientBot: "#1E4F7A"
        property string shadowColor: "#881B3A5C"

        signal clicked()

        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: dbBtn.gradientTop }
            GradientStop { position: 1.0; color: dbBtn.gradientBot }
        }

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled:        true
            shadowColor:          dbBtn.shadowColor
            shadowVerticalOffset: 8
            shadowBlur:           0.55
        }

        // Reflet interne haut
        Rectangle {
            anchors { top: parent.top; left: parent.left; right: parent.right }
            height: 2; radius: parent.radius
            color: Qt.rgba(1, 1, 1, 0.28)
        }

        RowLayout {
            anchors { fill: parent; leftMargin: 16; rightMargin: 16 }
            spacing: 10

            Image {
                width:      18; height: 18
                source:     dbBtn.icon
                sourceSize: Qt.size(36, 36)
                fillMode:   Image.PreserveAspectFit; smooth: true
                layer.enabled: true
                layer.effect: MultiEffect {
                    colorization: 1.0; colorizationColor: "#ffffff"
                }
            }

            Text {
                Layout.fillWidth: true
                text:           dbBtn.resultText
                font.pixelSize: 14; font.family: Theme.typography.fontUI
                font.weight:    Font.Bold; font.letterSpacing: 0.4
                color:          "#ffffff"; elide: Text.ElideMiddle
            }
        }

        MouseArea { anchors.fill: parent; onClicked: dbBtn.clicked() }
    }
}
