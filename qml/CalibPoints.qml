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

Item {
    property var calibPoints : []
    property int changeColor: -1
    Repeater {
        model: calibPoints.length
        Rectangle {
            width: 30
            height: 30
            x: calibPoints[index].x
            y: calibPoints[index].y
            radius: width/2
            color: changeColor == index ? '#e91e63' : '#fce4ec'
        }
    }

}
