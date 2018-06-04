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

#ifndef EXPERIMENTMANAGER_H
#define EXPERIMENTMANAGER_H

#define EXPERIMENT_MANAGER_MAX_NUMBER_OF_PHRASES 500
#define EXPERIMENT_MANAGER_MAX_LINE_LENGTH 100

#include <QObject>
#include <QFile>
#include <QTextStream>
#include <QJsonObject>
#include <QElapsedTimer>
#include <QVector>

#define NORMAL_KEY      1
#define ACC_KEY    		2
#define WORD_KEY   		4
#define BACK_WORD_KEY 	8

class ExperimentManager : public QObject {
    Q_OBJECT
public:
    ExperimentManager(QObject *parent, QJsonObject conf, QString path);
    ~ExperimentManager();

    Q_INVOKABLE void start();
    Q_INVOKABLE void nextPhrase(bool previousValid = true);
    Q_INVOKABLE QString getCurrentPhrase();
    Q_INVOKABLE void logKey(QString k, int keyType = NORMAL_KEY);
    Q_INVOKABLE void logFocusIn(QString k, int keyType = NORMAL_KEY);
    Q_INVOKABLE void logFocusOut(QString k, int keyType = NORMAL_KEY);
    Q_INVOKABLE void logPhraseEnd(QString phrase);
    Q_INVOKABLE int isFinished();    
    Q_INVOKABLE void logRawEye(int x, int y);
    Q_INVOKABLE int isRunning();
    void log(const char * msg);
    void logPhraseStart(const char * phrase);


private:
    QList<QString> phrases;    
    QVector<int> rndIndices;

    int state;
    int index;
    int count;
    int nPhrases;
    int phrasesCount;

    QJsonObject config;
    QString appPath;    
    QElapsedTimer startTime;
    QFile userPhraseFile, userFileLastIndex;
    QFile out, rawEye;
    QTextStream outStream, rawEyeStream;
    QTextStream userPhraseFileStream, userFileLastIndexStream;

    void loadFile(QString path, QFile &file, QTextStream &stream, QChar mode);
    void closeFiles();
    void loadPhrasesList();
    int getState() const { return state; }
};

#endif // EXPERIMENTMANAGER_H
