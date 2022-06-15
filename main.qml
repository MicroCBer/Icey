import QtQuick 2.12
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15
import com.blackgrain.qml.quickdownload 1.0
import QtWebView 1.1

ApplicationWindow {
    property var nowVersionNumber:102;
    property var nowVersionDisplay:"1.0.2";


    id:win
    width: 640
    height: 480
    visible: true
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

    Component.onCompleted: {
        // Check update
        request("https://ganbei-hot-update-1258625969.file.myqcloud.com/questpatcher_mirror/icey-update.json",(a)=>{
                    console.log(a.responseText)
                let update=JSON.parse(a.responseText)

                    if(update.latest>nowVersionNumber){
                        centeredDialog.title="Icey 有更新~"
                        centeredDialog.text=`您的版本： **${nowVersionDisplay}**  \n最新版本: **${update.latestName}**  \n更新日志:\n\n${update.changelog}  \n\n在QuestPatcher内再次点击“安装Icey”即可更新~`
                        centeredDialog.visible=true
                        console.log(update.forceUpdateBelow,nowVersionNumber)
                        if(update.forceUpdateBelow>=nowVersionNumber){
                            view.visible=false
                            statusText.text="你的Icey版本过低，请先更新再使用，通过最新版QP重新安装Icey即可完成更新。"
                            statusText.visible=true
                        }
                    }
                    local.announcement=update.announcement
                })
    }




/*
    property var modsStatusPath:"I:/QT/Icey/Files/modsStatus.json"
    property var modFilesPath:"I:/QT/Icey/Files/installedMods"
    property var modDataPath:"I:/QT/Icey/Files/com.beatgames.beatsaber"
    property var bsDataPath:"I:/QT/Icey/Files/files"
*/



    property string modsStatusPath:"/sdcard/QuestPatcher/com.beatgames.beatsaber/modsStatus.json"
    property string modFilesPath:"/sdcard/QuestPatcher/com.beatgames.beatsaber/installedMods"
    property string modDataPath:"/sdcard/ModData/com.beatgames.beatsaber"
    property string bsDataPath:"/sdcard/Android/data/com.beatgames.beatsaber/files"

    property var modsStatus:JSON.parse(ctx.read(modsStatusPath));
    title: qsTr("Icey Mods Manager")
    BusyIndicator{
        id:busy
        running: false
        z: 99
        anchors.centerIn: parent
        states:[
            State{
                when:!busy.running
                PropertyChanges{
                    target:cover
                    opacity:0
                }
            },State{
                when:busy.running
                PropertyChanges{
                    target:cover
                    opacity:1
                }
            }
        ]
        Behavior on opacity{
            SmoothedAnimation{duration: 200}
        }
    }
    Rectangle{
        id:cover
        anchors.fill: parent
        color:"#fafafa";
        z:98
        states:[
            State{
                when:!busy.running
                PropertyChanges{
                    target:cover
                }
            },State{
                when:busy.running
                PropertyChanges{
                    target:cover
                }
            }
        ]
        MouseArea{
            anchors.fill: parent
            visible: busy.running
        }
        Behavior on opacity{
            NumberAnimation{ easing.type: Easing.OutQuad; duration: 200}
        }
    }
    Label{
        id:statusText
        anchors.centerIn: parent
        topPadding: 80
        z:99
        visible: busy.running
    }

    SwipeView{
        id: view
        currentIndex: 0
        anchors.fill: parent
        Item{
            MainPage{
                id:local

                anchors.fill:parent
            }
//            Loader{
//                source:"https://ganbei-hot-update-1258625969.file.myqcloud.com/questpatcher_mirror/MainPage.qml"
//                anchors.fill:parent
//                onLoaded: {
//                    local.visible=false
//                }

//            }
        }
        Item{
            Text {
                id:modmanagetext
                text: qsTr("Mod管理")
                font.pixelSize:30;
                padding: 20;
            }
            ListView{
                id:mmanage
                anchors.top:modmanagetext.bottom
                maximumFlickVelocity:500
                topMargin: 10;
                leftMargin:20;
                model:modsStatus.mods
                height:parent.height-100
                spacing: 10
                width:parent.width
                delegate:Component{
                    Rectangle {
                        property bool isCoremod:modsStatus.mods[index].qmod.modFiles.length==0
                        enabled:!isCoremod
                        opacity: isCoremod?0.7:1
                        height: 70
                        width:parent.width-20
                        color: (index%2)?"#bbffffff":"white";
                        radius: 5;
                        layer.enabled: true

                        layer.effect: DropShadow{
                            horizontalOffset: 3
                            verticalOffset: 3
                            radius: 6
                            samples: 20
                            color: "#33dddddd"
                        }
                        Row{
                            padding: 10
                            width:parent.width

                            Column{
                                spacing: 10
                                width: parent.width-130

                                Text{
                                    text:modsStatus.mods[index].qmod.name
                                    font.weight: "Bold"
                                    font.pixelSize:19
                                }
                                Row{
                                    spacing: 10
                                    Text{
                                        text:modsStatus.mods[index].qmod.author
                                        font.pixelSize: 13
                                    }
                                    Text{
                                        text:modsStatus.mods[index].qmod.version
                                        font.pixelSize: 13
                                        color:"gray"
                                    }
                                }
                            }
                            Switch{
                                visible: !isCoremod
                                property bool _checked:ctx.dir(bsDataPath+"/mods").includes(modsStatus.mods[index].qmod.modFiles[0]);
                                checked:ctx.dir(bsDataPath+"/mods").includes(modsStatus.mods[index].qmod.modFiles[0])

                                Component.onCompleted:{
                                    //                                    checked=ctx.dir(bsDataPath+"/mods").includes(modsStatus.mods[index].qmod.modFiles[0])
                                }
                                onCheckedChanged:{
                                    if(_checked==checked)return;
                                    if(busy.running)return;
                                    busy.running=true
                                    if(modsStatus.mods[index].qmod.libraryFiles)
                                    for(let libFile of modsStatus.mods[index].qmod.libraryFiles){
                                        if(checked){
                                            // Enable the mod
                                            ctx.copy(modFilesPath+"/"+modsStatus.mods[index].qmod.id+"/"+libFile,bsDataPath+"/libs/"+libFile)
                                        }else{
                                            // Disable the mod
                                            //                                            ctx.remove(bsDataPath+"/mods/"+modFile) not removing libs
                                        }
                                    }
                                    if(modsStatus.mods[index].qmod.modFiles)
                                    for(let modFile of modsStatus.mods[index].qmod.modFiles){
                                        if(checked){
                                            // Enable the mod
                                            ctx.copy(modFilesPath+"/"+modsStatus.mods[index].qmod.id+"/"+modFile,bsDataPath+"/mods/"+modFile)
                                        }else{
                                            // Disable the mod
                                            ctx.remove(bsDataPath+"/mods/"+modFile)
                                        }
                                    }
                                    if(modsStatus.mods[index].qmod.fileCopies)
                                    for(let filecopy of modsStatus.mods[index].qmod.fileCopies){
                                        if(checked){
                                            // Enable the mod
                                            ctx.copy(modFilesPath+"/"+modsStatus.mods[index].qmod.id+"/"+filecopy.name,filecopy.destination)
                                        }else{
                                            // Disable the mod
                                            ctx.remove(filecopy.destination)
                                        }
                                    }
                                    busy.running=false

                                }
                            }
                            ToolButton{
                                visible: !isCoremod
                                enabled: false
                                icon.source: "uninstall-line.png"
                                icon.width: 20
                                icon.height: 20
                                icon.color:"#2e2f30"
                            }
                        }

                    }

                }
                clip: true

                add: Transition {
                    NumberAnimation { property: "opacity";easing.type: Easing.OutCubic; from: 0; to: 1.0; duration: 200 }
                    NumberAnimation { property: "x"; easing.type: Easing.OutCubic; from: -width; to: 0; duration: 200 }
                }

                displaced: Transition {
                    NumberAnimation { properties: "x,y"; duration: 400; easing.type: Easing.OutBounce }
                }
            }
        }
        Item{
            id:modspage
            property var mods:[];
            property var mirror:({});

            Row{
                id:moddownloadtext
                Text{
                    text:"Mod下载"
                    font.pixelSize: 30;
                    padding: 20
                }
                Row{
                    id:moddownloadversionchoose
                    Text{
                        text:"请选择版本 →"
                        font.pixelSize: 20;
                        padding: 20
                    }
                    Button{
                        text:"1.17.1"
                        onClicked:{
                            moddownloadversionchoose.visible=false
                            request("https://bs.wgzeyu.com/speedlimit/bsmgspider/qmods-1.17.1.json",(a)=>{
                                        modspage.mods=[]
                                        modspage.mods.push(...JSON.parse(a.responseText))
                                        moddownload.model=modspage.mods.length
                                    })
                        }
                        font.pixelSize: 10;
                    }
                    Button{
                        text:"1.19.1"
                        onClicked:{
                            moddownloadversionchoose.visible=false
                            request("https://bs.wgzeyu.com/speedlimit/bsmgspider/qmods-1.19.1.json",(a)=>{
                                        modspage.mods=[]
                                        modspage.mods.push(...JSON.parse(a.responseText))
                                        moddownload.model=modspage.mods.length
                                    })
                        }
                        font.pixelSize: 10;
                    }
                    Button{
                        text:"1.20.0"
                        onClicked:{
                            moddownloadversionchoose.visible=false
                            request("https://bs.wgzeyu.com/speedlimit/bsmgspider/qmods-1.20.0.json",(a)=>{
                                        modspage.mods=[]
                                        modspage.mods.push(...JSON.parse(a.responseText))
                                        moddownload.model=modspage.mods.length
                                    })
                        }
                        font.pixelSize: 10;
                    }
                    Button{
                        text:"1.21.0"
                        onClicked:{
                            moddownloadversionchoose.visible=false
                            request("https://bs.wgzeyu.com/speedlimit/bsmgspider/qmods-1.21.0.json",(a)=>{
                                        modspage.mods=[]
                                        modspage.mods.push(...JSON.parse(a.responseText))
                                        moddownload.model=modspage.mods.length
                                    })
                        }
                        font.pixelSize: 10;
                    }
                }
            }


            ListView{
                maximumFlickVelocity:500
                id:moddownload
                anchors.top:moddownloadtext.bottom
                topMargin: 10;
                clip: true
                leftMargin:20;
                model:modspage.mods.length


                delegate: Component{

                    Rectangle{
                        property var installlist:[]
                        function installListRun(){
                            if(dependence_download.running)return;
                            let mod=installlist.pop()
                            if(mod){
                                statusText.text="正在安装Mod："+mod.id
                                nowInstall=mod
                                request("https://bs.wgzeyu.com/localization/mods.json",(a)=>{
                                        let mirrorlist=JSON.parse(a.responseText)
                                        let url=(mirrorlist[mod.downloadIfMissing]&&mirrorlist[mod.downloadIfMissing].mirrorUrl)||mod.downloadIfMissing

                                        dependence_download.url=url
                                        dependence_download.destination="file:///"+modFilesPath+"/"+url.split("/").pop()
                                        dependence_download.running=true
                                })

                            }else{
                            busy.running=false;
                                centeredDialog.visible=true
                                statusText.text=""
                                mmanage.model=modsStatus.mods
                            }
                        }
                        property var nowInstall:null

                        height:60

                        width: parent.width-20
                        radius: 5;
                        layer.enabled: true

                        layer.effect: DropShadow{
                            horizontalOffset: 3
                            verticalOffset: 3
                            radius: 6
                            samples: 20
                            color: "#33dddddd"
                        }
                        property var moddata:modspage.mods[index]
                        Row{
                            width: parent.width
                            padding: 10
                            Row{

                                anchors.topMargin: 10
                                width: parent.width-150
                                spacing: 10
                                Column{
                                    Text{
                                        text:moddata.name
                                        font.bold: true
                                        font.pixelSize: 19
                                    }
                                    Text{
                                        text:moddata.author.username
                                        font.pixelSize: 15
                                        color:"gray"
                                    }
                                }
                            }
                            Row{
                                spacing:5
                                Button{
                                    text:"安装"
                                    onClicked:{

                                        busy.running=true
                                        console.log(moddata)
                                        installlist.push({
                                                             downloadIfMissing:"https://bs.wgzeyu.com/speedlimit/bsmgspider/"+moddata.mirrorUrl.replace("/files/",""),
                                                             id:moddata.name
                                                         })
                                        centeredDialog.title="Mod安装成功！"
                                        centeredDialog.text=`Mod名：${moddata.name}`


                                        installListRun()
//                                        console.log("https://bs.wgzeyu.com/speedlimit/bsmgspider/"+moddata.mirrorUrl.replace("/files/",""),"file://"+modFilesPath+"/"+moddata.mirrorUrl.split("/").pop())
//                                        download.url="https://bs.wgzeyu.com/speedlimit/bsmgspider/"+moddata.mirrorUrl.replace("/files/","")
//                                        download.destination="file:///"+modFilesPath+"/"+moddata.mirrorUrl.split("/").pop()
//                                        download.running=true
                                    }



                                    Download {
                                        id: dependence_download
overwrite: true
                                        running: false

                                        followRedirects: true
                                        onError: {
                                            centeredDialog.title="下载Mod失败！"
                                            centeredDialog.text=`错误信息：${errorString}`
                                            centeredDialog.visible=true
                                        }
                                        onFinished: {

                                            let path=this.destination.toString().replace("file:///","")
                                            let folder=ctx.unzip(path)
                                            ctx.remove(path)
                                            let moddata=JSON.parse(ctx.read(folder+"/mod.json"));
                                            ctx.renameDir(folder,moddata.id)

                                            if(moddata.dependencies)
                                            for(let mod of moddata.dependencies){
                                                let installed=false;
                                                for(let modm of modsStatus.mods)
                                                {
                                                    if(modm.qmod.id===mod.id)installed=true
                                                }
                                                if(!installed)installlist.push(mod)
                                            }
                                            if(modsStatus&&modsStatus.mods)
                                            for(let mod of modsStatus.mods)
                                            {
                                                console.log(mod.qmod.id,moddata.id)
                                                if(mod.qmod.id===moddata.id)return;
                                            }
                                            modsStatus.mods.push({qmod:moddata})
                                            ctx.write(modsStatusPath,JSON.stringify(modsStatus))
                                            mmanage.model=modsStatus.mods
                                            installListRun()
                                        }

                                    }

                                    Download {
                                        id: download
overwrite: true
                                        running: false

                                        followRedirects: true
                                        onError: {
                                            centeredDialog.title="下载Mod失败！"
                                            centeredDialog.text=`错误信息：${errorString}`
                                            centeredDialog.visible=true
                                        }
                                        onFinished: {
                                            console.log(this.destination,this.running)
                                            let path=modFilesPath+"/"+modspage.mods[index].mirrorUrl.split("/").pop()


                                            let folder=ctx.unzip(path)
                                            ctx.remove(path)
                                            let moddata=JSON.parse(ctx.read(folder+"/mod.json"));
                                            ctx.renameDir(folder,moddata.id)

                                            for(let mod of modsStatus.mods)
                                            {
                                                busy.running=false
                                                if(mod.qmod.id===moddata.id)return;
                                            }
                                            modsStatus.mods.push({qmod:moddata})
                                            ctx.write(modsStatusPath,JSON.stringify(modsStatus))
                                            mmanage.model=modsStatus.mods

                                            installListRun()
                                        }

                                    }

                                }


                                Button{
                                    text:"详情"
                                    onClicked:{
                                        centeredDialog.title=moddata.name
                                        centeredDialog.text=moddata.str
                                        centeredDialog.visible=true
                                    }
                                }
                            }
                        }
                    }
                }
                height:parent.height-100
                spacing: 10
                width:parent.width
            }

        }

        Item{
            Text {
                id:songsmanagetext
                text: qsTr("歌曲管理")
                font.pixelSize:30;
                padding: 20;
            }
            ListView{
                maximumFlickVelocity:500
                id:songs
                anchors.top:songsmanagetext.bottom
                topMargin: 10;
                clip: true
                leftMargin:20;
                property var customlevels:ctx.dir(modDataPath+"/Mods/SongLoader/CustomLevels").slice(2).reduce((p,c)=>{
                                                                                                                   if(ctx.exists(`${modDataPath}/Mods/SongLoader/CustomLevels/${c}/info.dat.disabled`)||
                                                                                                                      ctx.exists(`${modDataPath}/Mods/SongLoader/CustomLevels/${c}/info.dat`))p.push(c)
                                                                                                                   return p
                                                                                                               },[]);
                delegate: Component{

                    Rectangle{

                        height:60
                        property var songdata:
                            ctx.exists(`${modDataPath}/Mods/SongLoader/CustomLevels/${songs.customlevels[index]}/info.dat.disabled`)?
                                JSON.parse(ctx.read(`${modDataPath}/Mods/SongLoader/CustomLevels/${songs.customlevels[index]}/info.dat.disabled`)):
                                JSON.parse(ctx.read(`${modDataPath}/Mods/SongLoader/CustomLevels/${songs.customlevels[index]}/info.dat`))

                        width: parent.width-20
                        radius: 5;
                        layer.enabled: true

                        layer.effect: DropShadow{
                            horizontalOffset: 3
                            verticalOffset: 3
                            radius: 6
                            samples: 20
                            color: "#33dddddd"
                        }
                        Row{
                            width: parent.width
                            padding: 10
                            Row{

                                anchors.topMargin: 10
                                width: parent.width-80
                                spacing: 10
                                Image {
                                    id:img
                                    width:40
                                    height: 40
                                    source: `file:///${modDataPath}/Mods/SongLoader/CustomLevels/${songs.customlevels[index]}/${songdata._coverImageFilename}`
                                    layer.enabled: true
                                    layer.effect: OpacityMask {
                                        maskSource: Item {
                                            width: img.width
                                            height: img.height
                                            Rectangle {
                                                anchors.centerIn: parent
                                                width: img.adapt ? img.width : Math.min(img.width, img.height)
                                                height: img.adapt ? img.height : width
                                                radius: 5
                                            }
                                        }
                                    }
                                }
                                Column{
                                    Text{
                                        text:`${songdata._songName}`
                                        font.bold: true
                                        font.pixelSize: 19
                                    }
                                    Text{
                                        text:`${songdata._songSubName}`
                                        font.pixelSize: 15
                                        color:"gray"
                                    }
                                }
                            }
                            Switch{
                                property bool _firstTime:true;
                                Component.onCompleted:{
                                    checked=ctx.exists(`${modDataPath}/Mods/SongLoader/CustomLevels/${songs.customlevels[index]}/info.dat`)
                                }
                                onCheckedChanged:{
                                    if(_firstTime){
                                        _firstTime=false;return;
                                    }
                                    if(busy.running)return;
                                    busy.running=true
                                    let ctrl=checked
                                    checked=!checked
                                    let path=`${modDataPath}/Mods/SongLoader/CustomLevels/${songs.customlevels[index]}`
                                    if(ctrl){
                                        // Enable the song
                                        ctx.move(`${path}/info.dat.disabled`,`${path}/info.dat`)
                                    }else{
                                        // Disable the song
                                        ctx.move(`${path}/info.dat`,`${path}/info.dat.disabled`)
                                    }
                                    checked=ctrl
                                    busy.running=false
                                }


                            }
                        }
                    }
                }
                height:parent.height-100
                spacing: 10
                width:parent.width
                Component.onCompleted: {
                    model=Qt.binding(()=>customlevels.length)
                }
            }
        }
        Item{
            Loader{
                source:"Serverpage.qml"
                anchors.fill:parent
            }
        }
        Item{
            Text {
                id:songdownloadtext
                text: qsTr("歌曲下载")
                font.pixelSize:30;
                padding: 20;
            }
            WebView {
                id: webView
                x:20;
                y:70;
                width:win.width-300;
                height:win.height-100;
                url: "https://bs.wgzeyu.com"
                onTitleChanged: {
                    let flag="_@@Icey_DownloadFlag@@_"
                    if(webView.title.indexOf(flag)>=0){
                        let url1=webView.title.replace(flag,"");
                        centeredDialog.title="Download File"
                        centeredDialog.text=url1
                        centeredDialog.visible=true
                        webView.reload();
                    }

                }
                onUrlChanged: {
console.log("-".repeat(20)+url)
//                    webView.runJavaScript(`
//                                          document.write(\`
//                                          writed
//                                          <a href="https://cdn.beatleader.xyz/replays/69-ExpertPlus-Standard-83FCF7F36599F78D231C8C4A302542853E491AF0.bsor" type="download">download</a>
//                                          localstorage:\${localStorage}
//                                          \`)
//                                          `)
                }

                onLoadingChanged: {
                    if (loadRequest.errorString)
                        console.error(loadRequest.errorString);
                }
            }
            Column{
                width: 100;
                anchors.left: webView
                Label{
                    text:"人"
                }
            }
        }

    }
    CenteredDialog { id: centeredDialog  }
    PageIndicator {
        id: indicator

        count: view.count
        currentIndex: view.currentIndex

        anchors.bottom: view.bottom
        anchors.horizontalCenter: parent.horizontalCenter
    }
}
