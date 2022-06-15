import QtQuick 2.0
import QtQuick.Controls 2.15

Item {
    property alias announcement:te.text;
    Column{
        spacing:10
        Label{
            padding:20
            text:"Icey"
            font.pixelSize: 30
            font.bold:true
        }
        Label{
            leftPadding: 20
            text:"Yet another mod assistant for Beat Saber on the Quest 2.\n一个Quest 2上轻量级的BeatSaber Mod管理器"
            font.pixelSize: 20
        }
        Label{
            leftPadding: 20
            text:"By MicroBlock   V"+nowVersionDisplay
            font.pixelSize: 15
            color:"gray"
        }
        Label{
            leftPadding: 20
            topPadding: 20
            text:"横向滑动即可切换功能界面"
            font.pixelSize: 18
        }
        Label{
            leftPadding: 20
            topPadding: 30
            text:"公告"
            font.pixelSize: 22
        }
            TextEdit{
x:20
                id:te
                textFormat: TextEdit.MarkdownText
                width:parent.parent.width
                height: parent.parent.height
                enabled: false
                text:""
            }

    }

}
