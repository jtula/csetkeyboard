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

QtObject {

    id: engine

    readonly property string displayPhrase: __sm.displayPhrase
    readonly property string keyTyped: __sm.keyTyped
    readonly property var distanceCheck: __sm.distanceCheck
    readonly property var updateKeyboardState: __sm.updateKeyboardState
    readonly property var deleteLastKeyTyped: __sm.deleteLastKeyTyped

    readonly property var process: __sm.process    
    readonly property bool running: __sm.running

    readonly property var start: __sm.start
    readonly property var stop: __sm.stop

    readonly property var started: __sm.started
    readonly property var stopped: __sm.stopped

    property var __sm: StateMachine {  }
}
