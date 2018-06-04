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

#ifndef KEYBOARD_H
#define KEYBOARD_H

#include <QObject>
#include <QQuickItem>
#include <QPoint>
#include <QtCore/QJsonObject>

#include "mouselistener.h"
#include "tobiilistener.h"
#include "managers/gazemanager.h"
#include "managers/wordmanager.h"

class Keyboard : public QObject {
    Q_OBJECT
public:
    Keyboard(QObject *parent, QJsonObject conf, bool useMouse, bool noise, int radius, QString path);
    GazeManager& getGazeManager();

private:
    QObject* parent;
    QJsonObject config;
    QObject* gaze;
    QObject* keyboardManager;
    bool useMouse;
    bool noise;
    int radius;
    Q_INVOKABLE double getFixationRadius() const;
    QString appPath;
    MouseListener mouseListener;
    TobiiListener tobiiListener;
    GazeManager gazeManager;
    WordManager wordManager;

};

#endif // KEYBOARD_H
