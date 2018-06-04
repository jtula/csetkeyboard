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

#include <math.h>
#include "keyboard.h"

Keyboard::Keyboard(QObject *parent, QJsonObject conf, bool useMouse, bool noise, int radius, QString path) :
    QObject(parent),
    parent(parent),
    config(conf),
    gaze(parent->findChild<QObject*>("gaze")),
    keyboardManager(parent->findChild<QObject*>("keyboardManager")),
    useMouse(useMouse),
    noise(noise),
    radius(radius),
    appPath(path),
    mouseListener(parent, useMouse, noise, radius),
    tobiiListener(parent, !useMouse),
    gazeManager(parent, gaze, !useMouse, appPath),
    wordManager(parent, conf, path)
{    
    connect(&mouseListener, SIGNAL(newMousePos(SamplePoint)), &gazeManager, SLOT(updateGaze(SamplePoint)));
    connect(&tobiiListener, SIGNAL(newGaze(SamplePoint)), &gazeManager, SLOT(updateGaze(SamplePoint)));
    connect(keyboardManager, SIGNAL(keyTyped(QVariant)), &wordManager, SLOT(keyTyped(QVariant)));
    connect(keyboardManager, SIGNAL(updateWordList(QString)), &wordManager, SLOT(updateWordList()));
    connect(keyboardManager, SIGNAL(presageTransition(int, QString)), &wordManager, SLOT(updateTransition(int, QString)));
    connect(keyboardManager, SIGNAL(phraseBegin()), &wordManager, SLOT(phraseBegin()));
}

GazeManager& Keyboard::getGazeManager() {
    return gazeManager;
}

double Keyboard::getFixationRadius() const {

    double distance = config["distance_from_screen"].toDouble();
    double diameter = config["screen_diameter"].toDouble();
    double hr = config["screen_width"].toDouble();
    double vr = config["screen_height"].toDouble();
    double a = config["alpha"].toDouble() * M_PI / 180;

    double p = distance * tan(a) /  ((diameter * sin(atan(vr/hr)) * 25.4) / vr);

    p = (round(p * 100))/100;

    return p;
}
