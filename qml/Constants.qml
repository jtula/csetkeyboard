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

pragma Singleton
import QtQuick 2.9

QtObject {

    //IVIEWX STATES
    readonly property int iviewx_state_uncalibrated: 0
    readonly property int iviewx_state_calibrating: 1
    readonly property int iviewx_state_calibrated: 2

    // Estados possiveis do presage
    readonly property int transition_focus_char: 1
    readonly property int transition_focus_another_char: 2
    readonly property int transition_lose_focus_char: 3
    readonly property int transition_select_char: 4
    readonly property int transition_focus_word: 5
    readonly property int transition_focus_another_word: 6
    readonly property int transition_lose_focus_word: 7
    readonly property int transition_select_word: 8
}
