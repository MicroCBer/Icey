let fs = require('fs');

var channels = [], interval = 60;
var log = require('fancy-log');
var itchkey=fs.readFileSync("itchkey.txt")+""
class ModParser {
    constructor(str) {
        this.str = str

    }
    async match() {
        try {
            this.name = /\*\*(.*)\*\*/.exec(this.str.replace(/_/g, '*'))[1].replaceAll("*", "").trim();


            {
                // Match direct .qmod downloads
                if (/(https:\/\/.*\.qmod)/.exec(this.str))
                    this.url = /(https:\/\/.*\.qmod)/.exec(this.str)[1]
            }

            {
                // Match itch.io downloads
                let match = /(https:\/\/\S+\.itch\.io\S+)/.exec(this.str)
                
                if (match && match[1]) {
                    let data = await (await fetch(match[1] + "/data.json")).json()
                    let uploads = await (await fetch(`https://itch.io/api/1/${itchkey}/game/${data.id}/uploads`)).json()
                    let url = await (await fetch(`${match[1]}/file/${uploads.uploads[0].id}?source=game_download&proxy=true`, { method: "POST" })).json()
                    this.url = url.url
                }
            }

            if (!this.url) throw Error("No Url Matched")

            this.succeeded = true
        } catch (e) {
            this.succeeded = false
            this.error = e
        }
    }
    matchName() {
        try {
            this.name = /\*\*(.*)\*\*/.exec(this.str.replace(/_/g, '*'))[1].replaceAll("*", "").trim();
            return 1
        } catch (e) {
            this.succeeded = false
            this.error = e
        }
    }
}
var fetch = () => { }
const DC_API = {
    auth: "", limit: 50, agent: null,
    async getJsonWithAuth(url) {
        return await (await fetch(url , {
                "headers": {
                    "authorization": this.auth,
                    "user-agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/98.0.4758.102 Safari/537.36"
                }
            })).json()
    },
    async getChannelMessages(channel) {
        return this.getJsonWithAuth(`https://discord.com/api/v9/channels/${channel}/messages?limit=${this.limit}`)
    }
}
var md5 = require('md5');

const downloadFile = (async (url, path) => {
    const res = await fetch(url);
    const fileStream = fs.createWriteStream(path);
    await new Promise((resolve, reject) => {
        res.body.pipe(fileStream);
        res.body.on("error", reject);
        fileStream.on("finish", resolve);
    });
});

!(async () => {
    fetch = (await import('node-fetch')).default;
    eval(fs.readFileSync('config.txt') + '');
    DC_API.auth = fs.readFileSync("authorization.txt") + ""
    async function getMods() {
        for (let channel of channels) {
            let exists = fs.existsSync(__dirname + "/files/" + channel.filename) ? JSON.parse(fs.readFileSync(__dirname + "/files/" + channel.filename) + "") : []
            let data = await DC_API.getChannelMessages(channel.channel)
            for (let message of data) {
                if (message.pinned || !message.content) continue;
                let modData = new ModParser(message.content)
                
                modData.url = message.attachments && message.attachments[0] && message.attachments[0].url
                if (modData.matchName()) {
                    if (exists.reduce((pre, cur) => pre || cur.name == modData.name, false)) {
                        // Exists
                        log("Mod exists - " + modData.name)
                    } else {
                        await modData.match()
                        if (!modData.succeeded) continue;
                        log("New mod found - " + modData.name)
                        let tofile="/files/downloads/" + md5(modData.url)+".qmod"
                        log("Attempt to download file " + modData.url + " to " + tofile)
                        await downloadFile(modData.url, __dirname + tofile)
                        log("Download Finished")
                        modData.mirrorUrl = tofile
                        if(modData.url.includes("itch.io"))delete modData.url
                        modData.author=message.author
                        delete modData.succeeded
                        exists.push(modData)
                        fs.writeFileSync(__dirname + "/files/" + channel.filename, JSON.stringify(exists));
                    }
                }else{
                    log.warn("Failed to match ")
                    console.log(modData)
                }
            }

        }
    }
    getMods()
    setInterval(getMods, interval * 1000)
})()