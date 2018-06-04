/*
 * Copyright 2017 LaTIn, Laboratory of Technologies for Interaction.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import QtQuick 2.9
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3

Rectangle {
    id: key

    property var prevKey: 'undefined'
    property var nextKey: 'undefined'
    property alias text: textItem.text
    property string context: 'default'
    property int column
    property int row
    property double xpos
    property double ypos
    property string ctx
    property string lineCtx
    property int minimumWidth
    property int minimumHeight
    property int maximumWidth
    property int maximumHeight
    property int preferredWidth
    property int preferredHeight
    property bool xmod: false
    property bool firstKey: false
    property bool lastKey: false

    property string topLayoutName: 'topLayout'
    property int keyDiff: key.width - root.keySize
    property double highScale: key.maximumWidth
    property double midScale: key.maximumWidth/2
    property double lowScale: midScale/2
    property int fontSize: width * 0.4
    property double highFontScale: key.maximumWidth/1.6
    property double midFontScale: key.maximumWidth/3
    property double lowFontScale: key.maximumWidth/4.6

    property double moveHalfDiffX: key.xpos - (highScale - root.keySize)/2
    property double moveHalfDiffY: (highScale - root.keySize)/2
    property double movePrevX: key.xpos - midScale - root.rowspacing + midScale/2
    property double moveNextX: key.xpos + root.keySize + root.rowspacing - midScale/2
    property int moveSpaceX: key.xpos - (root.keySpaceSize - root.keySize)/2
    property int moveSpaceY: key.ypos - (root.keySpaceSize - root.keySize)/2
    property double moveTopDiffY: - keyDiff/2
    property double moveBotDiffY: keyDiff
    property double moveTopDiffY4: 0
    property double movePrev2: key.xpos - lowScale - root.rowspacing + lowScale/2
    property double moveNext2: key.xpos + root.keySize + root.rowspacing - lowScale/2
    property double movePrev3: key.xpos - root.keySize/2
    property double moveNext3: key.xpos + root.keySize/2

    property double moveToCenterY0: topLayout.height/2 - key.maximumHeight/2
    property double moveToCenterY: (key.maximumHeight- root.keySize) + (topLayout.height - key.maximumHeight)/2
    property double moveHalfDecX: key.xpos - root.keySize/2
    property double moveHalfIncX: key.xpos + root.keySize/2

    //z-index
    property int highOrder: 1
    property int normalOrder: 0
    property int lowOrder: -1

    //key and text colors
    property color normalKeyColor: '#ff6f00'
    property color normalTextColor: '#ffffff'
    property color focusedKeyColor: '#ff6f00'
    property color focusedTextColor: '#ff6f00'
    property color initialKeyColor: "#424242"
    property color backgroundColor: "#000000"


    property double decreasedFactor: 0.9
    property bool showMinimizedKey: false

    color: initialKeyColor
    radius: width/2

    Layout.fillWidth: false
    Layout.fillHeight: false
    Layout.minimumWidth: minimumWidth
    Layout.minimumHeight: minimumHeight
    Layout.maximumWidth: maximumWidth
    Layout.maximumHeight: maximumHeight
    Layout.preferredWidth: preferredWidth
    Layout.preferredHeight: preferredHeight

    function setX(x) {
        if (!key.xmod) {
            key.xpos = key.text === '_'? x + (root.keySpaceSize - root.keySize) / 2 : x;
            key.xmod = true;
        }
    }

    //-----------------------key label text-----------------//
    Text {
        id: textItem
        objectName: "textItem"

        font.pixelSize: fontSize
        renderType: Text.PlainText
        font.hintingPreference: Font.PreferVerticalHinting
        wrapMode: Text.WordWrap
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        color: key.normalTextColor
        anchors.verticalCenterOffset : 0
    }

    //minor key on top of the original
    Rectangle {
        width: key.maximumWidth*decreasedFactor
        height: key.maximumHeight*decreasedFactor
        x: (key.width - width)/2
        y: (key.height - height)/2
        color: key.initialKeyColor
        Text {
            id: textItem2
            objectName: "textItem2"

            font.pixelSize: fontSize
            renderType: Text.PlainText
            font.hintingPreference: Font.PreferVerticalHinting
            wrapMode: Text.WordWrap
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            text: key.text
        }

        radius: width/2
        visible: key.showMinimizedKey
    }

    //-----------------key transition states---------------//
    states: [
        State {
            name: 'focused'
            PropertyChanges {
                target: key
                x: key.moveHalfDiffX
                y: key.moveTopDiffY
                width: key.highScale
                height: key.highScale
                fontSize: key.highFontScale
                color: key.backgroundColor
                showMinimizedKey: true
                z: lowOrder
            }
            PropertyChanges { target: textItem2; color: key.focusedTextColor }
        },
        State {
            name: 'prev'
            PropertyChanges {
                target: key
                x: key.movePrevX
                y: key.moveTopDiffY
                width: key.midScale
                height: key.midScale
                fontSize: key.midFontScale
            }

        },
        State {
            name: 'next'
            PropertyChanges {
                target: key
                x: key.moveNextX
                y: key.moveTopDiffY
                width: key.midScale
                height: key.midScale
                fontSize: key.midFontScale
            }
        },
        State {
            name: 'prev2'
            PropertyChanges {
                target: key
                x: key.movePrev2
                y: key.moveTopDiffY
                width: key.lowScale
                height: key.lowScale
                fontSize: key.lowFontScale
                z: highOrder
            }
        },
        State {
            name: 'next2'
            PropertyChanges {
                target: key
                x: key.moveNext2
                y: key.moveTopDiffY
                width: key.lowScale
                height: key.lowScale
                fontSize: key.lowFontScale
                z: highOrder
            }
        },
        State {
            name: 'prev3'
            PropertyChanges {
                target: key
                x: key.movePrev3
            }
        },
        State {
            name: 'next3'
            PropertyChanges {
                target: key
                x: key.moveNext3
            }
        },
        State {
            name: 'top_0'
            PropertyChanges {
                target: key
                x: key.moveHalfDiffX
                y: key.moveToCenterY0
                width: key.highScale
                height: key.highScale
                fontSize: key.highFontScale
                color: key.backgroundColor
                showMinimizedKey: true
                z: lowOrder
            }
            PropertyChanges { target: parent; z: lowOrder }
            PropertyChanges { target: textItem2; color: key.focusedTextColor }
        },
        State {
            name: 'top_2'
            PropertyChanges {
                target: key
                x:  key.moveHalfDiffX
                y:  -key.moveToCenterY
                width: key.highScale
                height: key.highScale
                fontSize: key.highFontScale
                color: key.backgroundColor
                showMinimizedKey: true
                z: key.lowOrder
            }
            PropertyChanges { target: parent; z: lowOrder }
            PropertyChanges { target: textItem2; color: key.focusedTextColor }
        },
        State {
            name: 'bot_0'
            PropertyChanges {
                target: key
                x: key.moveHalfDiffX
                y: key.moveToCenterY0
                width: key.highScale
                height: key.highScale
                fontSize: key.highFontScale
                color: key.backgroundColor
                showMinimizedKey: true
                z: lowOrder
            }
            PropertyChanges { target: parent; z: lowOrder }
            PropertyChanges { target: textItem2; color: key.focusedTextColor }
        },
        State {
            name: 'bot_2'
            PropertyChanges {
                target: key
                x: key.moveHalfDiffX
                y: -key.moveToCenterY
                width: key.highScale
                height: key.highScale
                fontSize: key.highFontScale
                color: key.backgroundColor
                showMinimizedKey: true
                z: lowOrder
            }
            PropertyChanges { target: parent; z: lowOrder }
            PropertyChanges { target: textItem2; color: key.focusedTextColor }

        },
        State {
            name: 'k2_prev'
            PropertyChanges {
                target: key
                x: key.movePrevX + root.rowspacing
                y: key.moveTopDiffY
                width: key.midScale
                height: key.midScale
                fontSize: key.midFontScale
                z: highOrder
            }
        },
        State {
            name: 'k2_next'
            PropertyChanges {
                target: key
                x: key.moveNextX  - root.rowspacing
                y: key.moveTopDiffY
                width: key.midScale
                height: key.midScale
                fontSize: key.midFontScale
                z: highOrder
            }
        },
        State {
            name: 'k4_prev'
            PropertyChanges {
                target: key
                x: key.movePrevX + root.rowspacing
                y: !key.row ? key.moveTopDiffY4: - key.moveBotDiffY
                width: key.midScale
                height: key.midScale
                fontSize: key.midFontScale
                z: highOrder
            }
        },
        State {
            name: 'k4_next'
            PropertyChanges {
                target: key
                x: key.moveNextX  - root.rowspacing
                y: !key.row ? key.moveTopDiffY4: - key.moveBotDiffY
                width: key.midScale
                height: key.midScale
                fontSize: key.midFontScale
                z: highOrder
            }
        },
        State {
            name: 'nofocus'
            PropertyChanges {
                target: key
                width:  key.text === "_" ? root.keySpaceSize: key.preferredWidth
                height:  key.text === "_" ? root.keySpaceSize: key.preferredWidth
                x:  key.text === "_" ? key.moveSpaceX: key.xpos
                y:  key.text === "_" ? key.moveSpaceY: 0
            }
            PropertyChanges { target: parent }
        }
    ]

}
