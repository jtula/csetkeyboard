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

#include <QDebug>
#include <QFile>
#include <QByteArray>
#include <QJsonDocument>
#include <QUrl>
#include <QVariant>
#include "config.h"

Config::Config(QObject *parent) : QObject(parent){
    validConfig = true;
}

void Config::load(QUrl path){
    QFile configFile(path.toLocalFile());

    if (!configFile.open(QIODevice::ReadOnly)) {
        qWarning("Couldn't open config file.");
        validConfig = false;
    }

    QByteArray jsonData = configFile.readAll();
    QJsonDocument config(QJsonDocument::fromJson(jsonData));

    auto json = config.object();
    QJsonObject configObject = json["global"].toObject();   
    configuration = json.value("configuration").toObject();
}

void Config::loadLayoutConfig(QUrl path){
    QFile configFile(path.toLocalFile());

    if (!configFile.open(QIODevice::ReadOnly)) {
        qWarning("Couldn't open config file.");
        validConfig = false;
    }

    QByteArray jsonData = configFile.readAll();
    QJsonDocument config(QJsonDocument::fromJson(jsonData));

    auto json = config.object();

    if (!json.count()) {
        qWarning("Problems with the layout json format");
        validConfig = false;
    }

    configuration = json;
}

QJsonObject Config::getConfiguration() {
    return configuration;
}

bool Config::isValidConfig() {
    return validConfig;
}

void Config::setVarDialog(QString language, int user, int session, int exptime, int nphrases, int layout, int input) {
    QJsonObject lang = configuration[language].toObject();
    configuration.insert("language", language);
    configuration.insert("welcome_phrase", lang["welcome_phrase"].toString());
    configuration.insert("end_phrase", lang["end_phrase"].toString());
    configuration.insert("phrases_file", lang["phrases_file"].toString());
    configuration.insert("presage_db", lang["presage_db"].toString());
    configuration.insert("userId", user);
    configuration.insert("sessionId", session);
    configuration.insert("modeId", layout);
    configuration.insert("layout", layout);
    configuration.insert("input_type", input);
    configuration.insert("experiment_duration_in_sec", exptime);
    configuration.insert("experiment_number_phrases", nphrases);
}

void Config::quit() {
    validConfig = false;
}

bool Config::save(){
    return false;
}
