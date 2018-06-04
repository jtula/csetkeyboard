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
import QtQuick.Controls 2.2
import QtQuick.Window 2.3

import "."
import "../assets/js/utils.js" as Utils

ApplicationWindow {

    id: win
    objectName: "win"

    width: Screen.width
    height: Screen.height
    visible: true
    visibility: "FullScreen"
    color: "black"

    property int spacing: fixation_radius*layoutConfig.spacing
    property int xx: Screen.width >= layoutConfig.width ? (Screen.width - layoutConfig.width)/2: layoutConfig.spacing
    property int ww: Screen.width >= layoutConfig.width ? layoutConfig.width : Screen.width
    /* Degree-to-pixel fixation radius
       parameters:
        - distance_from_screen(mm)
        - screen_diameter(inches)
        - screen_width(Horizontal screen resolution in pixels)
        - screen_height(Vertical screen resolution in pixels)
        - alpha(Fixation radius in degrees)
    */
    property int fixation_radius: Utils.fixationRadius(config.distance_from_screen,
                                                       config.screen_diameter,
                                                       config.screen_width,
                                                       config.screen_height,
                                                       config.alpha)

    property bool showCursor: false
    property var qmlGazeState
    property color gazeColor: "#2196f3"

    //---------------------------GAZE-------------------------------//
    Rectangle {
        id: gaze
        objectName: "gaze"        

        x: qmlGazeState ? qmlGazeState.x : 0
        y: qmlGazeState ? qmlGazeState.y : 0
        visible: win.showCursor
        width: 15
        height: 15
        color: gazeColor
        radius: width/2
        opacity: 0.8
        z: 1
    }

    Loader {
        id: mainLoader
        focus: true
    }

    Connections {
        target: mainLoader.item
        onMessage: {
            if(msg == 'calibration_ready')
                mainLoader.setSource('keyboard.qml');
        }
    }

    Component.onCompleted: {
        mainLoader.setSource('keyboard.qml');
    }
}
