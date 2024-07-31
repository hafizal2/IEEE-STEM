[
    {
        "id": "c7926f87.d333a",
        "type": "tab",
        "label": "Track ISS",
        "disabled": false,
        "info": ""
    },
    {
        "id": "fdac59dc.7e7108",
        "type": "debug",
        "z": "c7926f87.d333a",
        "name": "",
        "active": true,
        "tosidebar": true,
        "console": false,
        "tostatus": false,
        "complete": "false",
        "x": 820,
        "y": 100,
        "wires": []
    },
    {
        "id": "e315c195.9065a",
        "type": "inject",
        "z": "c7926f87.d333a",
        "name": "",
        "repeat": "1",
        "crontab": "",
        "once": true,
        "onceDelay": "1",
        "topic": "",
        "payload": "",
        "payloadType": "date",
        "x": 130,
        "y": 60,
        "wires": [
            [
                "b295d758.a5eb08"
            ]
        ]
    },
    {
        "id": "b295d758.a5eb08",
        "type": "http request",
        "z": "c7926f87.d333a",
        "name": "",
        "method": "GET",
        "ret": "txt",
        "url": "http://api.open-notify.org/iss-now.json",
        "tls": "",
        "x": 310,
        "y": 60,
        "wires": [
            [
                "e6d4f16e.c2c9a"
            ]
        ]
    },
    {
        "id": "e6d4f16e.c2c9a",
        "type": "json",
        "z": "c7926f87.d333a",
        "name": "",
        "property": "payload",
        "action": "",
        "pretty": false,
        "x": 490,
        "y": 60,
        "wires": [
            [
                "303c96c9.caf92a",
                "fdac59dc.7e7108"
            ]
        ]
    },
    {
        "id": "303c96c9.caf92a",
        "type": "function",
        "z": "c7926f87.d333a",
        "name": "",
        "func": "var issLocation = msg.payload.iss_position;\nvar currLat = parseFloat(issLocation.latitude);\nvar currLon = parseFloat(issLocation.longitude);\nvar issTime = msg.payload.timestamp;\nvar issDate = new Date(issTime*1e3+28800000);\nvar prevTime = global.get(\"prevTime\");\nvar prevLat = global.get(\"prevLat\");\nvar prevLon = global.get(\"prevLon\");\nglobal.set(\"prevTime\",issTime);\nglobal.set(\"prevLat\",currLat);\nglobal.set(\"prevLon\",currLon);\nvar LatDiff = currLat - prevLat;\nvar LonDiff = currLon - prevLon;\nmsg.payload = {\n    command: {panlock:\"false\",panit:\"true\",zoom:\"6\",showlayer:[\"drawing\",\"countries\",\"day/night\",\"rainfall\",\"ship nav\",\"heatmap\"]},\n    layer : \"Satellite\",\n    name : \"The International Space Station\",\n    lat : currLat,\n    lon : currLon,\n    popped : true,\n    color : \"#00FF00\",\n    icon : \"https://img.icons8.com/office/344/satellite-sending-signal.png\",\n    iconSize : 64,\n    iconColor : \"#FF0000\",\n    weblink : {\"name\":\"Utusan Malaysia\", \"url\":\"https://www.utusan.com.my\", \"target\":\"_new\"},\n    photoUrl : \"https://upload.wikimedia.org/wikipedia/commons/thumb/9/93/Garbage_truck_KAMAZ_on_the_streets_of_Ulan-Ude.jpg/1920px-Garbage_truck_KAMAZ_on_the_streets_of_Ulan-Ude.jpg\",\n    label: \"Diff : \" + LatDiff.toFixed(4) + \" / \" +  LonDiff.toFixed(4) + \" | \" + issDate   \n};\nreturn msg;\n",
        "outputs": 1,
        "noerr": 0,
        "x": 630,
        "y": 60,
        "wires": [
            [
                "fdac59dc.7e7108"
            ]
        ]
    },
    {
        "id": "fd4132e0.1b59e8",
        "type": "mqtt in",
        "z": "c7926f87.d333a",
        "name": "",
        "topic": "FleeTrax",
        "qos": "0",
        "datatype": "utf8",
        "broker": "4d6606e5d2c874c8",
        "nl": false,
        "rap": false,
        "inputs": 0,
        "x": 110,
        "y": 150,
        "wires": [
            [
                "4e4864ae.c50f7c"
            ]
        ]
    },
    {
        "id": "4e4864ae.c50f7c",
        "type": "function",
        "z": "c7926f87.d333a",
        "name": "split and lay on map",
        "func": "var splitmsg = msg.payload.split(\",\");\nmsg.payload = {\n    command: {panlock:\"false\",panit:\"true\",zoom:\"11\",showlayer:[\"drawing\",\"countries\",\"day/night\",\"rainfall\",\"ship nav\",\"heatmap\"]},\n    layer : \"Satellite\",\n    name : \"IP: \" + splitmsg[0],\n    lat : splitmsg[1],\n    lon : splitmsg[2],\n    popped : true,\n    color : \"#00FF00\",\n    icon : \"https://img.icons8.com/external-xnimrodx-lineal-color-xnimrodx/344/external-surf-van-transport-xnimrodx-lineal-color-xnimrodx.png\",\n    iconSize : 64,\n    iconColor : \"#FF0000\",\n    weblink : {\"name\":\"Laporkan cara pemanduan\", \"url\":\"https://api.whatsapp.com/send?phone=60199565858\", \"target\":\"_new\"},\n    photoUrl : \"http://cnnphilippines.com/.imaging/mte/demo-cnn-new/750x450/dam/cnn/2020/6/23/J-T-Express_CNNPH.jpg/jcr:content/J-T-Express_CNNPH.jpg\",\n    label: \"Speed: \" + splitmsg[3] + \"km/h\"\n};\nreturn msg;\n\n",
        "outputs": 1,
        "noerr": 0,
        "x": 300,
        "y": 150,
        "wires": [
            [
                "a9d621f1.0a15d8"
            ]
        ]
    },
    {
        "id": "a9d621f1.0a15d8",
        "type": "worldmap-tracks",
        "z": "c7926f87.d333a",
        "name": "history",
        "depth": "5400",
        "layer": "combined",
        "smooth": true,
        "x": 625,
        "y": 175,
        "wires": [
            []
        ]
    },
    {
        "id": "4d6606e5d2c874c8",
        "type": "mqtt-broker",
        "name": "",
        "broker": "174.138.28.115",
        "port": "1883",
        "clientid": "",
        "autoConnect": true,
        "usetls": false,
        "protocolVersion": "4",
        "keepalive": "60",
        "cleansession": true,
        "birthTopic": "",
        "birthQos": "0",
        "birthPayload": "",
        "birthMsg": {},
        "closeTopic": "",
        "closeQos": "0",
        "closePayload": "",
        "closeMsg": {},
        "willTopic": "",
        "willQos": "0",
        "willPayload": "",
        "willMsg": {},
        "userProps": "",
        "sessionExpiry": ""
    }
]
