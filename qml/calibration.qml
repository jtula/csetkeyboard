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
import QtQuick.Particles 2.0

import "."

Item {
    id: calibrationWindow
    objectName: 'calibrationWindow'    

    property int gazeX
    property int gazeY
    property var targetCalib
    property int gazeRadius: 15
    property int circleTargetRadius: 25
    property int attempts: -2
    property bool calibrating : false
    property var calibPoints: []

    //colors
    property color greenColor: "#e91e63"
    property color yellowColor: "#ffff00"
    property color blueColor: "#03a9f4"
    property color redColor: "#FF1C0A"
    property color blackColor: "#000000"
    property color textColor: "#ffffff"

    property string fontFamily: "Helvetica"
    property int fontSize: 25

    property int insideRadius: 15
    property int ctDuration1: 0
    property int ctDuration2: 1500
    property int msgDuration: 1000

    signal message(string msg)

    function resetValues() {
        calibrating = false;
        calibrationWindow.calibPoints = [];
        gaze.visible = false;
        screen_calibpoint.visible = false;
    }

    function insideCircle(x, y, r) {
        var res;
        for (var i=0; i < calibPoints.length; ++i) {
            var dx  = Math.abs(x - calibPoints[i].x);
            var dy  = Math.abs(y - calibPoints[i].y);
            res = (dx*dx + dy*dy) <= r*r
            if (res)
                return i;
        }

        return -1;
    }

    Text {
        id: err
        text: "Falha na comunicacao com o SMI!!!"
        x: Screen.width / 3
        y: Screen.height / 2
        font.family: fontFamily
        font.pointSize: fontSize
        opacity: 1.0
        visible: false
        color: textColor

        SequentialAnimation on opacity {
            loops: Animation.Infinite
            PropertyAnimation { target:err ; properties:"opacity" ;to: 0.4; duration: msgDuration }
            PropertyAnimation { target:err ; properties:"opacity" ;to: 1.0; duration: msgDuration }
        }
    }

    Text {
        id: msg
        text: ""
        x: Screen.width / 3
        y: Screen.height / 2
        font.family: fontFamily
        font.pointSize: fontSize
        color: textColor
        opacity: 1.0

        SequentialAnimation on opacity {
            loops: Animation.Infinite
            PropertyAnimation { target:msg ; properties:"opacity" ;to: 0.4; duration: msgDuration }
            PropertyAnimation { target:msg ; properties:"opacity" ;to: 1.0; duration: msgDuration }
        }
    }

    Rectangle {
        id: gaze
        x: calibrationWindow.gazeX
        y: calibrationWindow.gazeY
        visible: false
        width: gazeRadius
        height: gazeRadius
        radius: width/2
    }

    Rectangle {
        id: circle_target
        width: circleTargetRadius
        height: circleTargetRadius
        radius: width/2
        color: greenColor
        visible: false

        Behavior on x {
            id: circle_shift
            SequentialAnimation {
                PropertyAnimation {target: circle_target; properties: "color"; to: blackColor; duration: ctDuration1}
                PropertyAnimation {target: circle_target; properties: "color"; to: greenColor; duration: ctDuration2}
            }
        }

        Behavior on y {
            SequentialAnimation {
                PropertyAnimation {target: circle_target; properties: "color"; to: blackColor; duration: ctDuration1}
                PropertyAnimation {target: circle_target; properties: "color"; to: greenColor; duration: ctDuration2}
            }
        }
    }

    CalibPoints {
        id: screen_calibpoint
        visible: false
    }

    focus: true
    Keys.onPressed: {

        var eyeState = keyboard.getEyeTrackerState();
        var eyeStateType = keyboard.getEyeGaze().type;

        if(keyboard.isEyeTrackerRunning() && !calibrating) {
            keyboard.setEyeTrackerState(Constants.iviewx_state_uncalibrated);
            msg.visible = false;
            keyboard.startCalibration();
            calibrating = true;
        }
        if (event.key === Qt.Key_Escape) {
            keyboard.stopEyeTracker();
            Qt.quit();
        } else if (event.key === Qt.Key_Space) {
            if (attempts) attempts++
            eyeState === attempts ? err.visible = true : err.visible = false
            if (eyeState === Constants.iviewx_state_calibrating) {
                keyboard.acceptCP();
                calibrationWindow.calibPoints.push(targetCalib);
            } else if(eyeState === Constants.iviewx_state_calibrated) {
                gaze.visible = true;
            }
        } else if (event.key === Qt.Key_Tab) {
            resetValues()
            msg.visible = true;
        } else if (event.key === Qt.Key_Enter && eyeState === Constants.iviewx_state_calibrated) {
            resetValues();
            calibrationWindow.message('calibration_ready');
        }
    }

    Rectangle {
        id: dummyAnimator
        width: 0
        height: 0
        visible: false

        onRotationChanged: {
            var eyeState = keyboard.getEyeTrackerState();
            var eyeStateType = keyboard.getEyeGaze().type;

            if (eyeState === Constants.iviewx_state_calibrating) {
                var target = keyboard.nextCalibrationTarget();
                targetCalib = target;
                circle_target.x = target.x;
                circle_target.y = target.y;
                circle_target.visible = true;
            } else if (eyeState === Constants.iviewx_state_calibrated) {
                calibrationWindow.gazeX = keyboard.getEyeGaze().x;
                calibrationWindow.gazeY = keyboard.getEyeGaze().y;
                var over = insideCircle(keyboard.getEyeGaze().x, keyboard.getEyeGaze().y, insideRadius);
                if (over>=0)
                    screen_calibpoint.changeColor = over;                
                else
                    screen_calibpoint.changeColor = -1;
                circle_target.visible = false;
                if (eyeStateType === Constants.gazeevent_fixation)
                    gaze.color = greenColor;
                else if (eyeStateType === Constants.gazeevent_saccade)
                    gaze.color = yellowColor;
                else if (eyeStateType === Constants.gazeevent_drift)
                    gaze.color = blueColor;
                else if (eyeStateType === Constants.gazeevent_blink)
                    gaze.color = redColor;
                screen_calibpoint.visible = true;
                screen_calibpoint.calibPoints = calibrationWindow.calibPoints
            } else if (eyeState === Constants.iviewx_state_uncalibrated) {
                circle_target.visible = false;
                msg.text = 'Pressione <espaco> para começar..';
            }
        }
    }

    NumberAnimation {
        target: dummyAnimator
        property: 'rotation'
        from: 0
        to: 360
        loops: Animation.Infinite
        running: true
    }

}
