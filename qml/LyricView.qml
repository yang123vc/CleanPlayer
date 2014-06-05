import QtQuick 2.0
import MyComponents 1.0

Rectangle {
    width: 220
    height: 300
    color:"#00000000"
    radius: 5
    property real msec: 0
    property int fontSize: 8
    property int lineSpace: 20

    Image {
        id: netStateImg
        anchors.centerIn: parent
        visible: false
        source: "qrc:/image/image/update.png"

        RotationAnimation {
               id:updateRotation
               target: netStateImg
               //一直循环
               loops: Animation.Infinite
               from: 0
               to: 360
               running: false
               duration: 1000
           }

        //显示的时候转动
        onVisibleChanged: {
            if(visible){
                updateRotation.start();
            }
            else
                updateRotation.stop();
        }
    }


    ListModel{
        id:lyricModel

    }

    Component{
        id:lyricDelegate
        Rectangle{
            id:lyricLineRect
            height: lineSpace
            width: parent.parent.width
            color:"#00000000"
            Text{
                id:lyricTxt
                anchors.centerIn: parent
                color:lyricLineRect.ListView.isCurrentItem ? "white":"grey"
                text:lyricLine
                font.family: "微软雅黑"
                font.pointSize: fontSize
            }
        }


    }
    ListView{
        id:lyricView
        anchors.fill: parent
        spacing:5
        model:lyricModel
        delegate: lyricDelegate
        clip: true
        onCurrentItemChanged: NumberAnimation {
                        target: lyricView;
                        property: "contentY";
                        to:lyricView.currentItem.y-70;
                        duration: 200;
                        easing.type: Easing.InOutQuad
                    }
        MouseArea{
            anchors.fill: parent
            hoverEnabled: true
            onEntered:parent.parent.color="#304d6557"
            onExited: parent.parent.color="#00000000"
            onDoubleClicked:  {
                if(listShowHideBtn.isHide){
                    expandList.start();
                }
                else{
                    scrollList.start();
                }
                listShowHideBtn.isHide=!listShowHideBtn.isHide;
            }
        }

    }
    Lyric{
        id:lyric
    }

    //MediaPlayer的positionChanged信号大概1s发射一次，
    //所以自定义timer计时刷新歌词
    Timer{
        id:timer
        repeat: true
        running: true
        interval: 30
        onTriggered:{
            msec+=30
            var i=lyric.getLyric(player.position);
            if(i>0){
                lyricView.currentIndex=i
            }
        }
    }

    Connections{
        target: playlist
        onCurrentMediaIndexChanged:{
            if(playlist.currentMediaIndex()>=0){
                //如果原歌词无效，则重新下载
                if(!playlist.isLyricValid(jsonObj.lyric)){
                    network.getLyric(playlist.at(playlist.currentMediaIndex()));
                    netStateImg.visible=true
                }
            }
        }

    }

    Connections{
        target: root
        //当前jsonObj改变，则加载歌词
        onJsonObjChanged:{
            lyricModel.clear();
            lyric.loadFile(jsonObj.lyric);
            for(var i=0;i<lyric.lineCount();i++){
                lyricModel.append({"lyricLine":lyric.lyricAt(i)});
            }
        }
    }

    Connections{
        target: network
        onAllDownloaded:{
            console.log("downloaded...")
            netStateImg.visible=false;

        }
    }
}
