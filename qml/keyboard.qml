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
import QtQuick.Window 2.3
import QtMultimedia 5.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

import "../assets/js/utils.js" as Utils
import '.'

Item {
    id: root
    objectName: 'root'

    property real contextTolerance: win.fixation_radius * layoutConfig.contextTolerance
    property int bridgeMargin: win.fixation_radius * layoutConfig.bridgeMargin
    property int spacing: layoutConfig.spacing
    property int rowspacing: win.fixation_radius * layoutConfig.rowspacing
    property real textSize: win.fixation_radius * layoutConfig.textSize
    property int wmax: layoutConfig.wmax
    property int wctx: layoutConfig.wctx
    property double distanceFactor: layoutConfig.distanceFactor

    //tamanho da tecla
    property real keySize: layoutConfig.keySize ? win.fixation_radius * layoutConfig.keySize :
                                                  win.fixation_radius * layoutConfig.maxKeySize/5
    property int keySpaceSize: keySize * 1.4
    //tamanho maximo da tecla
    property real maxKeySize: win.fixation_radius * layoutConfig.maxKeySize

    property int nLinesCtx: layoutConfig.nLinesCtx
    property var labelLower: layoutConfig.labelLower

    property int nColumnsCtx: layoutConfig.nColumnsCtx
    property var elementsPerLineCtx: layoutConfig.elementsPerLineCtx
    property var elementsOffsetCtx: layoutConfig.maxKeySize

    //Qt Horizontal AlignmentFlag [left:1, right:2, center:4, justify:8]
    property var linesAlignTopCtx: layoutConfig.linesAlignTopCtx
    property var linesAlignBotCtx: layoutConfig.linesAlignBotCtx
    property int kwidth: win.ww
    property int kx: win.xx


    property color displayPhraseColor: '#ffffff'
    property string fontFamily: 'Helvetica'
    property color keyTypedColor: '#ff6f00'
    property double displayPhraseOpacity: 0.8

    //centerline values
    property color centerLineColor: "#007ac1"
    property double centerLineOpacity: 0.4
    property int centerLineHeight: 1
    property real starTextSize: win.fixation_radius * 1.2
    property bool waitTimeTextV: false;
    property bool start: true;

    opacity: 0


    signal message(string msg)

    function updateKeyboardState(eyeGazeState) {
        win.qmlGazeState = eyeGazeState;
        engine.updateKeyboardState(eyeGazeState);
    }

    PropertyAnimation {id: animateStart; target: root; property: "opacity"; to: 1.0; duration: 1800}

    Engine {
        id: engine
        objectName: "engine"

        Component.onCompleted: engine.start(nLinesCtx, labelLower, nColumnsCtx, elementsPerLineCtx);
    }

    //---------------------------TOP LAYOUT--------------------------------------//
    ColumnLayout {
        id: topLayout
        objectName: "topLayout"

        width: root.kwidth
        height: layoutConfig.elementsOffsetCtx.map(function(x) {
                                                        return x * win.fixation_radius;
                                                    }).reduce(function(a, b) {
                                                        return a + b; }, 0)
        anchors.bottom: bridge.top
        anchors.left: bridge.left
        anchors.right: bridge.right
        anchors.bottomMargin: root.bridgeMargin
    }

    WordList {
         id: wordlistTopCtx
         objectName: "wordlistTopCtx"

         anchors.left: topLayout.left
         anchors.bottom: topLayout.top
         anchors.right: topLayout.right

         columnName: "wordlistTopCol"
         columnWidth: 100
         columnHeight: win.fixation_radius

         repeaterName: "wordlistTopRep"
         modelNumber: 3

         wordBoxName: "wlt_"
         wordBoxColor: "#424242"
         wordBoxOpacity: 1.0
         wordBoxWidth: wordlistTopCtx.width
         wordBoxHeight: wordlistTopCtx.height/3
         wordBoxTextSize: root.textSize
         wordBoxTextColor: "#FFFFFF"

     }

    //-------------------BRIDGE---------------//
    Rectangle {
        id: bridge
        objectName: "bridge"

        x: root.kx
        y: Screen.height / 2 - bridge.height / 2
        width: root.kwidth
        height: win.fixation_radius * layoutConfig.bridgeHeight
        color: Qt.rgba(1, 1, 1, 0.1)
        z: 1

        Text {
            id: displayPhrase
            objectName: 'displayPhrase'

            x: 10
            font.family: root.fontFamily
            font.weight: Font.Light
            font.pointSize: root.textSize
            color: root.displayPhraseColor
            text: root.waitTimeTextV ? "": engine.displayPhrase
            opacity: root.displayPhraseOpacity
        }

        Text {
            id: keyTyped
            objectName: 'keyTyped'

            x: displayPhrase.x
            anchors.bottom: bridge.bottom
            font.family: root.fontFamily
            font.weight: Font.Light
            font.pointSize: root.textSize
            color: root.keyTypedColor
            text: root.waitTimeTextV ? "": engine.keyTyped
        }

        Text {
            id: guideBar
            objectName: 'guideBar'

            anchors.bottom: keyTyped.bottom
            anchors.left: keyTyped.right
            font.family: root.fontFamily
            font.weight: Font.Light
            font.pointSize: root.textSize
            color: root.keyTypedColor
            text: "_"
        }

        Text {
            id: waitTimeText
            objectName: 'waitTimeText'

            anchors.horizontalCenter: bridge.horizontalCenter
            anchors.verticalCenter: bridge.verticalCenter
            font.family: root.fontFamily
            font.weight: Font.Light
            font.pointSize: root.starTextSize
            color: root.displayPhraseColor
            visible: root.waitTimeTextV
        }

    }

    //---------------------------BOTTOM LAYOUT--------------------------------------//
    ColumnLayout {
        id: bottomLayout
        objectName: "bottomLayout"

        width: root.kwidth
        height: layoutConfig.elementsOffsetCtx.map(function(x) {
                                                        return x * win.fixation_radius;
                                                    }).reduce(function(a, b) {
                                                        return a + b; }, 0);
        anchors.top: bridge.bottom
        anchors.left: bridge.left
        anchors.right: bridge.right
        anchors.topMargin: root.bridgeMargin
    }

    //---------------------------LOAD SOUND--------------------------------------//
    Audio {
        id: keySound
        source: config.sounds_path + 'shortClick.wav'
        loops: 1
        volume: 0.1
    }

    focus: true
    Keys.onPressed: {
        if (event.key === Qt.Key_Space) {
            engine.process();
        } else if (event.key === Qt.Key_Escape) {
            Qt.quit();
        } else if (event.key === Qt.Key_C) {
            win.showCursor = !win.showCursor;
        } else if (event.key === Qt.Key_Backspace) {
            engine.deleteLastKeyTyped();
        }
    }

   Component.onCompleted: animateStart.start()

}
