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

#ifndef CONFIG_H
#define CONFIG_H

#include <QObject>
#include <QJsonObject>
#include <QVariantMap>

class Config : public QObject{
Q_OBJECT
public:
    explicit Config(QObject *parent = 0);
    void load(QUrl path);
    void loadLayoutConfig(QUrl path);
    bool save();
    QJsonObject getConfiguration();
    bool isValidConfig();

public slots:
    void setVarDialog(QString, int, int, int, int, int, int);
    void quit();

private:
    QJsonObject configuration;
    bool validConfig;

};

#endif // CONFIG_H
