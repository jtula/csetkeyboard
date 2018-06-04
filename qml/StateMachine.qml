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
import QtQml.StateMachine 1.0 as DSM
import '.'

DSM.StateMachine {
        id: sm

        readonly property string displayPhrase: keyboardManager.displayP
        readonly property string keyTyped: keyboardManager.phraseTyped
        readonly property var distanceCheck: keyboardManager.distanceCheck        
        readonly property var updateKeyboardState: keyboardManager.updateKeyboardState
        readonly property var deleteLastKeyTyped: keyboardManager.deleteLastKeyTyped
        readonly property var process: keyboardManager.process
        readonly property int startTime: keyboardManager.startTime
        readonly property int timer: 0
        property int waitTimeContinue: config.waitTimeContinue * 1000
        property bool open: true

        function delay(delayTime, cb) {
            wait.interval = delayTime;
            wait.repeat = false;
            wait.triggered.connect(cb);
            wait.start();
        }

        Timer { id: wait }

        initialState: kb_loading

        onStarted: {            
            console.log('setup keyboard..')
            keyboardManager.setup(config)
        }

        KeyboardManager {
            id: keyboardManager
        }

        DSM.State {
            id: kb_loading

            onEntered: console.log('keyboard state: ' + 'loading...')

            DSM.SignalTransition {
                targetState: parent
                signal: keyboardManager.kbReadyAtivated
            }
       }

        DSM.State {
            id: kb_waiting

            onEntered: {
                root.waitTimeTextV = true;
                keyboardManager.resetFocus();
                delay(waitTimeContinue, function() {
                    keyboardManager.kbHistoryActivated()
                    if(open) {
                        keyboardManager.processContinue();
                        open = false;
                    }
                });
            }

            DSM.SignalTransition {
                targetState: historyState
                signal: keyboardManager.kbHistoryActivated
            }
        }

        DSM.State {
            id: parent

            initialState: kb_ready

            DSM.State {
                id: kb_ready

                onEntered: { open = true }

                DSM.SignalTransition {
                    targetState: kb_running
                    signal: keyboardManager.kbRunningActivated
                }

                DSM.SignalTransition {
                    targetState: kb_waiting
                    signal: keyboardManager.kbWaitingActivated
                }
            }

            /*--------------------STATES WHILE KEYBOARD IS RUNNING------------------------*/
            DSM.State {
                id: kb_running
                objectName: 'kb_running'

                initialState: st_undefined
                onEntered: { open = true }

                DSM.SignalTransition {
                    targetState: kb_waiting
                    signal: keyboardManager.kbWaitingActivated
                }

                DSM.SignalTransition {
                    targetState: kb_finalState
                    signal: keyboardManager.kbStopActivated
                }


                DSM.State {
                    id: st_undefined
                    objectName: 'st_undefined'

                    DSM.SignalTransition {
                        targetState: st_dwell
                        signal: keyboardManager.dwellStateActivated
                    }
                }

                DSM.State {
                    id: st_dwell
                    objectName: 'st_dwell'

                    DSM.SignalTransition {
                        targetState: st_dwell
                        signal: keyboardManager.dwellStateActivated
                    }

                    DSM.SignalTransition {
                        targetState: st_undefined
                        signal: keyboardManager.undefinedStateActivated
                    }

                    DSM.SignalTransition {
                        targetState: st_context_switch
                        signal: keyboardManager.contextSwitchStateActivated
                    }
                }

                DSM.State {
                   id: st_context_switch

                   DSM.SignalTransition {
                       targetState: st_dwell
                       signal: keyboardManager.dwellStateActivated
                   }

                   DSM.SignalTransition {
                       targetState: st_undefined
                       signal: keyboardManager.undefinedStateActivated
                   }

                }
            }

            //History state to return when is waiting
             DSM.HistoryState {
                 id: historyState
                 defaultState: kb_running
             }
        }
        /*--------------------END KEYBOARD STATES------------------------*/

        DSM.FinalState {
            id: kb_finalState        
            onEntered: animateEnd.start();

            PropertyAnimation {id: animateEnd; target: root; property: "opacity"; to: .5; duration: 1800}
        }

        onFinished: {
            console.log('state finished');
            //Qt.quit()
        }
    }
