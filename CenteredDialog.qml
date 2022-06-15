import QtQml 2.2

import QtQuick 2.9
import QtQuick.Controls 2.2

Dialog {
    parent: ApplicationWindow.overlay

    x: (parent.width - width) / 2
    y: (parent.height - height) / 2

    focus: true
    modal: true

    property alias text: messageText.text

//    Label {
//        id: messageText

//        verticalAlignment: Text.AlignVCenter
//        horizontalAlignment: Text.AlignHCenter

//        anchors.fill: parent
//    }
    TextEdit{
        enabled: false
                id: messageText
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                anchors.fill: parent
                text:""
                textFormat: TextEdit.MarkdownText
            }

    standardButtons: Dialog.Ok
}
