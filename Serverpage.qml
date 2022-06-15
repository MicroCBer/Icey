import QtQuick 2.0
import QtQuick.Controls 2.15

Item {
    id:win

    Label {
        id:modmanagetext
        text: qsTr("BeatTogether服务器切换")
        font.pixelSize:30;
        leftPadding: 20
        topPadding: 20
    }
    function request(url, callback) {
        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = (function(myxhr) {
            return function() {
                if (xhr.readyState === XMLHttpRequest.DONE) {
                    callback(myxhr);
                }
            }
        })(xhr);

        xhr.open('GET', url+'?_=' + new Date().getTime(), true);
        xhr.send('');
    }

    property var servers:[];

    CenteredDialog { id: centeredDialog  }
    Row{
        id:row;
        x:20
        y:60
        Button{
            id:exit
            text:"关闭程序"
            onClicked: {
                Qt.quit()
            }
            visible: false
        }
        ToolButton{
            id:refBtn
            text:"↓"
            z:8
            onClicked: {
                request("https://bs.wgzeyu.com/localization/online.json",(a)=>{
                            servers=[]
                            servers.push({
                                                          "filename": "BeatTogether.cfg",
                                                          "filepath": "/sdcard/ModData/com.beatgames.beatsaber/Configs/BeatTogether.cfg",
                                                          "fileurl": "__remove__filepath__",
                                                          "id": "source",
                                                          "name": "默认服务器@BeatTogether",
                                                          "serverurl":"MODDED ONLINE",
                                                          "statusurl": "/"
                                                      })
                            servers.push(...JSON.parse(a.responseText)["server"])
                            info.text="公告："+JSON.parse(a.responseText)["info"]
                            listView.model=servers.length
                            console.log(listView.model)
                        })
            }
        }
        Label{
            id:info
            padding: 15;
        }
    }


    ScrollView {
        id:scv

        anchors.top:row.bottom
        anchors.bottom:win.bottom
        width: parent.width
        height:parent.height
        clip:true
//                y:200;
        ListView {
            id: listView
            width: parent.width
            model: 0
            delegate: ItemDelegate {
                onClicked: {
                    if(servers[index].fileurl=="__remove__filepath__"){
                        ctx.remove(servers[index].filepath)
                        centeredDialog.title = "已成功设置！"
                        centeredDialog.text = `已将服务器切换为\n${servers[index].serverurl}\n请在游戏主界面检查联机选项名称，与服务器相同则代表生效`
                        centeredDialog.visible = true
                        return;
                    }
                    request("https://bs.wgzeyu.com/localization"+servers[index].fileurl,(resp)=>{
                            ctx.write(servers[index].filepath,resp.responseText)
                                centeredDialog.title = "已成功设置！"
                                centeredDialog.text = `已将服务器地址切换为\n${servers[index].serverurl}\n请在游戏主界面检查联机选项名称，与服务器相同则代表生效`
                                centeredDialog.visible = true
                    })
                }

                text: servers[index].name
                width: listView.width
            }
        }

    }

    Timer{
        interval:1000
        running: true
        repeat: true
        onTriggered: {
            const mods=[
                {
                    name:"MultiplayerCore",
                    filename:"libMultiplayerCore"
                },{
                    name:"BeatTogether",
                    filename:"libbeattogether",
                }
            ]
            let missing_mods=[];
            modloop:for(let mod of mods){
                for(let fname of ctx.dir(bsDataPath+`/mods/`))
                    if(fname.toLowerCase().includes(mod.filename.toLowerCase()))continue modloop;

                missing_mods.push(mod);
            }


            if(missing_mods.length!=0){
                labelDisabled.text=`
# 联机Mod未安装 #
缺失的Mod:\n${missing_mods.reduce((pre,cur)=>{
                    return pre+"\n"+cur.name
                                                                      },"")}
联机服务器切换功能将被禁用`
                refBtn.visible=false
                labelDisabled.visible=true
            }else {
                refBtn.visible=true
                labelDisabled.visible=false
            }
        }
    }
    Component.onCompleted: {
        const mods=[
                      {
                          name:"MultiplayerCore",
                          filename:"libMultiplayerCore"
                      },{
                name:"BeatTogether",
                filename:"libbeattogether",
            }
        ]
        let missing_mods=[];
        modloop:for(let mod of mods){
            for(let fname of ctx.dir(`/sdcard/Android/data/com.beatgames.beatsaber/files/mods/`))
                if(fname.toLowerCase().includes(mod.filename.toLowerCase()))continue modloop;

            missing_mods.push(mod);
        }


        if(missing_mods.length!=0){
            labelDisabled.text=`
# 联机Mod未安装 #

缺失的Mod:\n${missing_mods.reduce((pre,cur)=>{
                return pre+"\n"+cur.name
                                                                  },"")}
联机服务器切换功能将被禁用`
            refBtn.visible=false
            labelDisabled.visible=true
        }else refBtn.clicked();
    }
    Label{
        id: labelDisabled
        text:"已禁用"
        font.pixelSize: 20
        anchors.centerIn: parent
        visible: false
    }
}
