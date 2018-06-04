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


#include <QQmlApplicationEngine>
#include <QGuiApplication>
#include <QtQml>
#include <QPixmap>
#include <QCursor>
#include <QDebug>
#include "config.h"
#include "keyboard.h"
#include "managers/experimentmanager.h"

int main(int argc, char *argv[]) {
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication app(argc, argv);
    app.setApplicationName("CSETUDET");
    app.setOrganizationName("LaTIn - Laboratory of Technologies for Interaction");
    app.setOrganizationDomain("latin.ime.usp.br");
    app.setApplicationVersion("0.1");

    qRegisterMetaType<SamplePoint>("SamplePoint");

    QDir appPath = QDir(app.applicationDirPath());
    appPath.cdUp();

    #ifdef Q_OS_WIN
        appPath.cdUp();
    #endif

    appPath.cd("csetkeyboard");

    //Load configuration
    Config *configuration = new Config();
    Config *lc = new Config();
    configuration->load(QUrl("file:///" + appPath.absolutePath() + "/config/experiments.json"));

    if (!configuration->isValidConfig() )
        return 0;

    QQmlApplicationEngine engineConfig;
    engineConfig.load(QUrl(QStringLiteral("qrc:/qml/dialog.qml")));
    QObject::connect(engineConfig.rootObjects()[0], SIGNAL(insert(QString, int, int, int, int, int, int)),
                     configuration, SLOT(setVarDialog(QString, int, int, int, int, int, int)));
    QObject::connect(engineConfig.rootObjects()[0], SIGNAL(quit()), &app, SLOT(quit()));
    QObject::connect(engineConfig.rootObjects()[0], SIGNAL(quit()), configuration, SLOT(quit()));
    app.exec();


    QJsonObject config = configuration->getConfiguration();
    lc->loadLayoutConfig(QUrl("file:///" + appPath.absolutePath()+"/config/"+QString::number(config["layout"].toInt())+".json"));

    if (!lc->isValidConfig() )
        return 0;

    QJsonObject layoutConfig = lc->getConfiguration();


    config.insert("appPath", appPath.absolutePath());
    bool useMouse = config["input_type"].toInt() ? 0 : 1;
    bool noise = config["mouse_noise"].toInt() ? 1 : 0;

    QQmlApplicationEngine engine;
    QQmlContext *context = engine.rootContext();
    QScopedPointer<ExperimentManager> experiment(new ExperimentManager(0, config, appPath.absolutePath()));
    context->setContextProperty("experiment", experiment.data());
    context->setContextProperty("config", config);    
    context->setContextProperty("layoutConfig", layoutConfig);
    engine.load(QUrl(QStringLiteral("qrc:/qml/main.qml")));
    QObject *parent = engine.rootObjects()[0];
    //TODO: calculate fixation radius in c++
    int fr = parent->property("fixation_radius").toInt();
    int radius = config["noise_radius"].toDouble() * fr;
    QScopedPointer<Keyboard> keyboard(new Keyboard(parent, config, useMouse, noise, radius, appPath.absolutePath()));
    QPixmap hideCursor(20, 20);
    hideCursor.fill(Qt::transparent);
    app.setOverrideCursor(QCursor(hideCursor));

    return app.exec();
}
