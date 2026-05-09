import QtQuick

/**
 * DishModal - Form for creating/editing dishes
 * (Stub implementation - full implementation in Phase 2)
 */
Rectangle {
    id: modal
    
    property bool open: false
    property string mode: 'new'  // 'new' or 'edit'
    
    signal saved()
    signal deleted()
    signal closed()
    
    color: Theme.colors.card
    radius: Theme.sizes.radius.xxxl
    visible: open
    
    Text {
        anchors.centerIn: parent
        text: "DishModal\n(Phase 2 Implementation)"
        color: Theme.colors.ink3
        font.pixelSize: 14
        horizontalAlignment: Text.AlignHCenter
    }
}
