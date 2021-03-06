import QtQuick 2.0
import AsemanTools 1.0
import QtGraphicalEffects 1.0
import "private/"

Item {
    id: md_btn

    property bool hideState: false
    property bool opened: false

    property int layoutDirection: View.layoutDirection

    property bool hasMenu: true
    property variant list: new Array
    property int rotateCount: 0
    property alias icon: btn_img.source

    property alias color: btn_back.color
    property alias background: back_rct.color

    property Flickable flickable

    signal clicked()

    onHideStateChanged: {
        hide_timer.stop()
        if(hideState)
            hide_timer.start()
        else
            md_btn.visible = true
    }

    onOpenedChanged: {
        if(opened) {
            BackHandler.pushHandler(md_btn, md_btn.close)
            listv.refresh()
        } else {
            BackHandler.removeHandler(md_btn)
            listv.clear()
        }
    }

    Connections {
        target: flickable
        onVerticalVelocityChanged: refresh()
        onAtYBeginningChanged: refresh()
        onAtYEndChanged: refresh()

        function refresh() {
            if((flickable.verticalVelocity<-4 && !flickable.atYEnd) || flickable.atYBeginning)
                md_btn.show()
            else
            if((flickable.verticalVelocity>4 && !flickable.atYBeginning) || flickable.atYEnd)
                md_btn.hide()
        }
    }

    MouseArea {
        anchors.fill: parent
        visible: opened
        onClicked: close()
    }

    Timer {
        id: hide_timer
        interval: 400
        onTriggered: md_btn.visible = false
    }

    Rectangle {
        id: back_rct
        anchors.fill: parent
        opacity: opened? 0.5 : 0
        color: "#ffffff"

        Behavior on opacity {
            NumberAnimation{easing.type: Easing.OutCubic; duration: 300}
        }
    }

    Item {
        id: main_scene
        width: 64*Devices.density
        height: 64*Devices.density
        x: md_btn.layoutDirection==Qt.LeftToRight? parent.width-width-10*Devices.density : 10*Devices.density
        anchors.bottom: parent.bottom
        anchors.margins: 10*Devices.density

        ListView {
            id: listv
            width: md_btn.width
            x: md_btn.layoutDirection==Qt.LeftToRight? parent.width-width : 0
            anchors.bottom: btn_rect.bottom
            height: parent.y
            opacity: opened? 1 : 0
            verticalLayoutDirection: ListView.BottomToTop
            visible: opacity != 0
            maximumFlickVelocity: View.flickVelocity
            boundsBehavior: Flickable.StopAtBounds
            rebound: Transition {
                NumberAnimation {
                    properties: "x,y"
                    duration: 0
                }
            }

            model: ListModel{}
            add: Transition {
                NumberAnimation { easing.type: Easing.OutBack; properties: "y"; from: 0; duration: 300 }
            }
            remove: Transition {
                NumberAnimation { easing.type: Easing.OutBack; properties: "y"; to: 0; duration: 300 }
            }

            Behavior on opacity {
                NumberAnimation{easing.type: Easing.OutCubic; duration: 200}
            }

            header: Item {
                height: main_scene.height
                width: listv.width
            }

            delegate: Item {
                height: 64*Devices.density
                width: listv.width

                MouseArea {
                    anchors.fill: parent
                    onClicked: close()
                }

                MaterialDesignButtonItem {
                    text: model.name
                    icon: model.icon
                    height: parent.height
                    x: View.layoutDirection==Qt.RightToLeft? 0 : parent.width-width

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if(md_btn.list[index].method)
                                md_btn.list[index].method()
                            close()
                        }
                    }
                }
            }

            function clear() {
                model.clear()
            }

            function refresh() {
                clear()
                for(var i=0; i<md_btn.list.length; i++) {
                    var map = md_btn.list[i]
                    model.append({"name": map.name, "icon": map.icon})
                }
            }
        }

        Item {
            id: btn_rect
            y: hideState? parent.height+20*Devices.density+View.navigationBarHeight : 0
            width: parent.width
            height: parent.height
            visible: false

            Behavior on y {
                NumberAnimation{easing.type: Easing.OutCubic; duration: 400}
            }

            Rectangle {
                id: btn_back
                anchors.fill: parent
                anchors.margins: 8*Devices.density
                color: "#0d80ec"
                radius: width/2

                Behavior on color {
                    ColorAnimation{easing.type: Easing.OutCubic; duration: 400}
                }
            }
        }

        DropShadow {
            anchors.fill: btn_rect
            horizontalOffset: 0
            verticalOffset: 1
            radius: 8.0
            samples: 16
            color: "#aa000000"
            source: btn_rect
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                if(hasMenu)
                    opened = !opened
                else
                    opened = false

                md_btn.clicked()
            }
        }

        Image {
            id: btn_img
            anchors.centerIn: btn_rect
            width: 22*Devices.density
            height: width
            sourceSize: Qt.size(width,height)
            rotation: {
                if(opened)
                    return 0
                if(layoutDirection == Qt.RightToLeft)
                    return - 45 - rotateCount*90
                else
                    return 45 + rotateCount*90
            }
            source: "files/button-close.png"
            transformOrigin: Item.Center

            Behavior on rotation {
                NumberAnimation{easing.type: Easing.OutBack; duration: 300}
            }
        }
    }

    MouseArea {
        width: parent.width
        visible: opened
        height: {
            var pad = listv.height + listv.contentY - 128*Devices.density
            var res = listv.height - (listv.count+1)*64*Devices.density - pad
            if(res < 0)
                return 0
            else
                return res
        }
        onClicked: close()
    }

    Timer {
        id: close_timer
        interval: 800
        onTriggered: close()
    }

    function hide() {
        hideState = true
    }

    function show() {
        hideState = false
    }

    function close() {
        opened = false
    }
}

