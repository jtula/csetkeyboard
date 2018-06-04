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
import "../assets/js/utils.js" as Utils
import "."

QtObject {
    id: keyboardManager
    objectName: "keyboardManager"

    property var config
    property bool __setup: false
    property string displayP
    property string phraseTyped
    property var boardTop: []
    property var boardBottom: []
    property int keySize: 0
    property int maxKeySize: root.maxKeySize
    property int wmax: root.wmax
    property int wctx: root.wctx
    property int startTime
    property string topLayoutName: "topLayout"
    property string botLayoutName: "bottomLayout"
    property bool logEnd: false
    property bool transition_lost: true

    property var currentState: {
         'state': st_undefined,                  
         'focusedKey': 0,
         'ctx': 0,
         'w': 0,
         'wctx': 0
     }

     property var lastState: {
         'state': st_undefined,         
         'focusedKey': 0,
         'ctx': 0,
         'w': 0,
         'wctx': 0,
     }

     property var lastFixState: {
         'state': st_undefined,         
         'focusedKey': 0,
         'ctx': 0,
         'w': 0,
         'wctx': 0
     }

    //signals
    signal stop()
    signal undefinedStateActivated()
    signal contextSwitchStateActivated(var state, var focusedKey, var focusedCtx, var saveFix)
    signal dwellStateActivated(var state, var focusedKey, var focusedCtx, var saveFix)
    signal lostStateActivated(var state, var focusedKey, var focusedCtx, var saveFix)
    signal kbReadyAtivated()
    signal kbRunningActivated()
    signal kbStopActivated()
    signal kbWaitingActivated()
    signal kbHistoryActivated()
    signal keyTyped(var key)
    signal updateWordList(string ctx)
    signal presageTransition(int t, string content)
    signal phraseBegin()

    Component.onCompleted: {
        keyboardManager.undefinedStateActivated.connect(clearCurrentState)
        keyboardManager.dwellStateActivated.connect(updateCurrentState)
        keyboardManager.contextSwitchStateActivated.connect(updateCurrentState)
        keyboardManager.kbStopActivated.connect(restoreKeySize)
    }

    function setup(config) {
        if (__setup) return;
        try {
            keyboardManager.config = config;
            displayP = config.welcome_phrase;
            startTime = Date.now();
            var ratios = Math.floor((root.kwidth - root.rowspacing*(root.nColumnsCtx)) / (root.nColumnsCtx));

            if (!root.keySize)
                root.keySize = ratios;

            if (!root.maxKeySize)
                keyboardManager.maxKeySize = root.keySize;

            console.log('degrees2px: ', win.fixation_radius);

            var count = 0;
            var topLayoutObj = 0;
            var bottomLayoutObj = 0;

            for (var i = 0; i < nLinesCtx; ++i) {
                boardTop[i]= [];
                boardBottom[i] = [];
                topLayoutObj = createLayout(topLayout, i);
                bottomLayoutObj = createLayout(bottomLayout, i);
                for (var j = 0; j < elementsPerLineCtx[i]; ++j) {
                    createKey('top', topLayoutObj, i, j, labelLower[count]);
                    createKey('bottom', bottomLayoutObj, i, j, labelLower[count]);
                    count++;
                }
            }

            for (var r = 0; r < nLinesCtx; ++r) {
                for (var c = 0; c < elementsPerLineCtx[r]; ++c) {
                    boardTop[r][c].xpos = boardTop[r][c].x;
                    boardTop[r][c].ypos = boardTop[r][c].y;
                    boardBottom[r][c].xpos = boardBottom[r][c].x;
                    boardBottom[r][c].ypos = boardBottom[r][c].y;

                    if (boardTop[r][c].firstKey) {
                        boardTop[r][c].nextKey = boardTop[r][c+1];
                    } else if (boardTop[r][c].lastKey) {
                        boardTop[r][c].prevKey = boardTop[r][c-1];
                    } else {
                        boardTop[r][c].prevKey = boardTop[r][c-1];
                        boardTop[r][c].nextKey = boardTop[r][c+1];
                    }

                    if (boardBottom[r][c].firstKey) {
                        boardBottom[r][c].nextKey = boardBottom[r][c+1];
                    } else if (boardBottom[r][c].lastKey) {
                        boardBottom[r][c].prevKey = boardBottom[r][c-1];
                    } else {
                        boardBottom[r][c].prevKey = boardBottom[r][c-1];
                        boardBottom[r][c].nextKey = boardBottom[r][c+1];
                    }
                }
            }

            if (keyboardManager.keySize) {
                root.kwidth = keyboardManager.keySize*root.nColumnsCtx + (root.nColumnsCtx*root.rowspacing);
                root.kx = (win.width - root.kwidth)/2;
                console.log("keySize: ", keyboardManager.keySize);
            }

            kbReadyAtivated();

        } catch(e) {
            console.log('Setup: ' + e.message);
        }
        __setup = true;
    }

    function createLayout(rootLayout, i) {
        var keyObj;
        keyObj = Utils.createObject('qrc:qml/KeyboardRow.qml', rootLayout, 0);

        if (rootLayout.objectName === topLayoutName) {            
            keyObj.objectName = "top_"+i;            
            keyObj.align = linesAlignTopCtx[i];
        } else if (rootLayout.objectName === botLayoutName){
            keyObj.objectName = "bot_"+i;
            keyObj.align = linesAlignBotCtx[i];
        }

        return keyObj;
    }

    function createKey(position, layout, row, column, letter) {
        var keyObj = Utils.createObject('qrc:qml/Key.qml', layout, 0);

        if (keyObj) {
            keyObj.objectName = position+'-'+letter;
            keyObj.column = column;
            keyObj.row = row;
            keyObj.lineCtx = layout.objectName;
            keyObj.preferredWidth = root.keySize;
            keyObj.preferredHeight = root.keySize;
            keyObj.maximumWidth = keyboardManager.maxKeySize;
            keyObj.maximumHeight = keyboardManager.maxKeySize;
            keyObj.text = letter;

            if (column === 0)
                keyObj.firstKey = true;
            else if (column === elementsPerLineCtx[row]-1)
                keyObj.lastKey = true;

            if (position === 'top') {
                keyObj.ctx = topLayoutName;
                boardTop[row][column] = keyObj;
            } else if (position === 'bottom') {
                keyObj.objectName = 'bottom-'+letter;
                keyObj.ctx = botLayoutName;
                boardBottom[row][column] = keyObj;
            }

            if (!keyboardManager.keySize)
                keyboardManager.keySize = keyObj.width;

        } else {
            console.log('error creating keys');
        }

        return true;
    }

    function processContinue() {
        root.waitTimeTextV = false;
        if(kb_ready.active) {
            kbRunningActivated();
            experiment.start();
            experiment.nextPhrase(0);
            logEnd = true;
            displayP = experiment.getCurrentPhrase();
        } else if (kb_running.active) {
            phraseTyped = '';
            experiment.nextPhrase(1);
            phraseBegin();
            if (experiment.isFinished()) {
                displayP = config.end_phrase;
                kbStopActivated();
            } else {
                displayP = experiment.getCurrentPhrase();
            }
}
    }

    function process() {
        if (!experiment.isFinished()) {
            if (logEnd)
                experiment.logPhraseEnd(phraseTyped);
            kbWaitingActivated();
        }
    }

    function updateKeyboardState(gazeState) {

        var winner, winnerGrid, winnerGrid2, otherCtx;       

        if (kb_running.active) {

            experiment.logRawEye(gazeState.x, gazeState.y);

            // ----------------------- UNDEFINED STATE -----------------------------
            if (st_undefined.active) {
                if (gazeState.valid) {
                    winnerGrid = getActiveContext(gazeState.x, gazeState.y);
                    if (winnerGrid) {                        
                        var winnerKey = getFixatedKey(gazeState, winnerGrid);
                        if (winnerKey !== 0) {
                            experiment.logFocusIn(winnerKey.text);
                            manageKey(winnerKey);
                            dwellStateActivated(st_dwell, winnerKey, winnerGrid, 0);
                        }
                    }
                }

                if (!keyboardManager.transition_lost) {
                    presageTransition(Constants.transition_lose_focus_char, "");
                    keyboardManager.transition_lost = true;
                }

            // ----------------------- ACTIVATED STATE -----------------------------
            } else if (st_dwell.active) {
                if (gazeState.valid) {
                    //no mesmo contexto
                    var grid = getActiveContext(gazeState.x, gazeState.y);
                    if (grid === currentState.ctx) {                        
                        winner = getFixatedKey(gazeState, currentState.ctx);
                        if (winner && winner === currentState.focusedKey) { //mesmo contexto e mesma tecla
                            if (currentState.w < keyboardManager.wmax)
                                currentState.w += 1;                            
                        } else { //no mesmo contexto e tecla diferente
                            if (currentState.w) {
                                currentState.w -= 1;                                
                            } else {
                                experiment.logFocusOut(currentState.focusedKey.text);
                                experiment.logFocusIn(winner.text);
                                resetFocus();
                                manageKey(winner);
                                dwellStateActivated(st_dwell, winner, currentState.ctx, 0);
                            }
                        }
                    } else if (!getActiveContext(gazeState.x, gazeState.y)) {
                        if (currentState.wctx < keyboardManager.wctx) {                            
                            currentState.wctx += 1;
                        } else {
                            if (currentState.w) {
                                currentState.w -= 1;
                            } else {
                                experiment.logFocusOut(currentState.focusedKey.text);
                                resetFocus();
                                undefinedStateActivated(st_undefined);
                            }
                        }
                    //mudou de contexto
                    } else {
                        if (currentState.w) {
                            currentState.w -= 1;
                        } else {
                            otherCtx = (currentState.ctx === topLayout) ? bottomLayout : topLayout;
                            if (Utils.overItem(otherCtx, gazeState.x, gazeState.y, root.contextTolerance) && currentState.focusedKey !== 0) {
                                keySound.play();
                                contextSwitchStateActivated(st_context_switch, currentState.focusedKey, currentState.ctx, 1);                                
                            }
                        }
                    }
                } else {
                    if (currentState.w) {
                        currentState.w -= 1;
                    } else {
                        experiment.logFocusOut(currentState.focusedKey.text);
                        undefinedStateActivated(st_undefined);
                    }
                }
            }
            // ------------------------- CONTEXT SWITCH ---------------------
            else if (st_context_switch.active) {
                if (gazeState.valid) {
                    winnerGrid2 = getActiveContext(gazeState.x, gazeState.y);
                    if (winnerGrid2) {                        
                        winnerKey = getFixatedKey(gazeState, winnerGrid);
                        if (winnerKey) {
                            resetFocus();
                            manageKey(winnerKey);
                            presageTransition(Constants.transition_focus_char, winnerKey.text);
                            keyboardManager.transition_lost = false;
                            dwellStateActivated(st_dwell, winner, winnerGrid2, 0);
                        } else {
                            resetFocus();
                            undefinedStateActivated(st_undefined);
                        }
                    } else {
                        resetFocus();
                        undefinedStateActivated(st_undefined);
                    }
                }
            }
         }

        if (st_context_switch.active) {
            var selKey = getFocusedKey();            
            appendText(selKey);
            experiment.logFocusOut(selKey.text);
        }
    }

    function deleteLastKeyTyped() {
        if (phraseTyped.length) {
            var res = phraseTyped.slice(0, phraseTyped.length - 1);
            phraseTyped = res;
        }
    }

    function appendText(value) {        
        if (value.text !== "<" && value.text !== "_" && value.text !== "." ) {
          keyTyped(value);
          experiment.logKey(value.text);
          phraseTyped = phraseTyped.length ? (phraseTyped + value.text) : value.text;
        } else if (value.text === "<" && phraseTyped.length) {
          experiment.logKey(value.text, 8);
          var res = phraseTyped.slice(0, phraseTyped.length - 1);
          phraseTyped = res;
        } else if (value.text === "_" && phraseTyped.length) {
          keyTyped(value);
          experiment.logKey(value.text);
          phraseTyped += " ";
        } else if (value.text === "." && phraseTyped.length) {
          experiment.logKey(value.text);
          phraseTyped += value.text;
        }
    }

    function getActiveContext(x, y) {
         var tolerance = root.contextTolerance;
         if (Utils.overItem(topLayout, x, y, tolerance)) {
             restoreKeySize(bottomLayout.objectName);
             return topLayout;

         } else if (Utils.overItem(bottomLayout, x, y, tolerance)) {
            restoreKeySize(topLayout.objectName);
            return bottomLayout;
         }

         return 0;
     }

    function getFixatedKey(gazeState, ctx) {
        var winner = 0;
        var dist = 0;
        var distanceFactor = root.distanceFactor;
        var min = Number.MAX_VALUE;
        var contextPosition;

        var r = root.maxKeySize/2;
        var spacing = config.layout === 3 ? 0 : root.rowspacing/2        

        if (ctx) {
            if (ctx.objectName === topLayoutName)
                contextPosition = boardTop;

            else if (ctx.objectName === botLayoutName)
                contextPosition = boardBottom;

            for (var i = 0; i < nLinesCtx; ++i) {
                for (var j = 0; j < elementsPerLineCtx[i]; ++j) {
                    var key = contextPosition[i][j];

                    if (key) {
                        var keyX, keyY;
                        keyX = key.mapToItem(root, 0, 0).x + key.width/2 - spacing;
                        keyY = key.mapToItem(root, 0, 0).y + key.height/2;
                        dist = Math.sqrt( (gazeState.x-keyX)*(gazeState.x-keyX) + (gazeState.y-keyY)*(gazeState.y-keyY) );
                        var distX = Math.abs(gazeState.x - keyX);

                        if (getFocusedKey() === key) {
                            var difference;                            

                            if(config.layout === 1) {
                                if (distX <= distanceFactor*r) {
                                    winner = key;
                                    break;
                                }
                            } else if (config.layout === 2) {
                                if (dist <= distanceFactor*r) {
                                    winner = key;
                                }
                            } else {
                                dist *= distanceFactor;
                            }
                        }

                        if (dist < min) {
                            min = dist;
                            winner = key;
                        }
                    }
                }
            }

            return winner;
        }

        return 0;
    }

    function getFocusedKey() {
         if (st_dwell.active)
             return currentState.focusedKey;
         else if (st_context_switch.active)
             return lastFixState.focusedKey;

         return 0;
     }

    function manageKey(winnerKey) {
        var layout = config.layout;

        if (layout === 1 || layout === 2) {
            winnerKey.setX(winnerKey.x);
            newKeyFocus(winnerKey, 'focused');        
        } else if (layout === 3) {
            newKeyFocus(winnerKey, 'focused');
        }
    }


    function newKeyFocus(winnerKey, state) {

        var layout = config.layout;

        if (typeof winnerKey != 'undefined') {
            winnerKey.state = state;
            var prev, next;

            if (layout === 1 || layout === 2) {
                if (winnerKey.firstKey && typeof winnerKey.nextKey != 'undefined') {
                    next = winnerKey.nextKey;
                    next.state = 'next';
                    if (typeof next.nextKey != 'undefined')
                        next.nextKey.state = 'next2';

                    if (typeof winnerKey.nextKey.nextKey.nextKey != 'undefined')
                        next.nextKey.nextKey.state = 'next3';
                } else if (winnerKey.lastKey && typeof winnerKey.prevKey != 'undefined') {
                    prev = winnerKey.prevKey;
                    prev.state = 'prev';
                    if (typeof prev.prevKey != 'undefined')
                        prev.prevKey.state = 'prev2';

                    if (typeof prev.prevKey.prevKey != 'undefined')
                        prev.prevKey.prevKey.state = 'prev3';
                } else {
                    winnerKey.nextKey.state = 'next';
                    winnerKey.prevKey.state = 'prev';

                    var prev2 = winnerKey.prevKey.prevKey;
                    var next2 = winnerKey.nextKey.nextKey;

                    var prev3 = prev2.prevKey;
                    var next3 = next2.nextKey;

                    if (typeof prev2 != 'undefined')
                        prev2.state = 'prev2';

                    if (typeof next2 != 'undefined')
                        next2.state = 'next2';

                    if (typeof prev3 != 'undefined')
                        prev3.state = 'prev3';

                    if (typeof next3 != 'undefined')
                        next3.state = 'next3';

                }
            }
        }
     }


    function resetFocus() {
        for (var i = 0; i < nLinesCtx; ++i)
            for (var j = 0; j < elementsPerLineCtx[i]; ++j) {
                boardTop[i][j].state = 'nofocus';
                boardBottom[i][j].state = 'nofocus';                
            }
    }

    function restoreKeySize(ctx) {
        for (var i = 0; i < nLinesCtx; ++i) {
            for (var j = 0; j < elementsPerLineCtx[i]; ++j) {
                if (ctx === topLayoutName) {
                    boardTop[i][j].state = 'nofocus';
                } else if(ctx === botLayoutName) {
                    boardBottom[i][j].state = 'nofocus';
                } else {
                    boardTop[i][j].state = 'nofocus';
                    boardBottom[i][j].state = 'nofocus';
                }
            }
        }
    }

    function updateCurrentState(state, key, ctx, saveFix) {
        if (saveFix) lastFixState = currentState;

        lastState = currentState;
        currentState.state = state;        
        currentState.focusedKey = key;
        currentState.ctx = ctx;
        currentState.w = 1;
        currentState.wctx = 0;
    }

    function clearCurrentState(state) {                
        lastState = currentState;
        currentState.state = state;
        currentState.focusedKey = 0;
        currentState.ctx = 0;
        currentState.w = 0;
        currentState.wctx = 0;
    }

}
