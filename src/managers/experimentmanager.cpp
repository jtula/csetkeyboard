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

#define EXPERIMENT_MANAGER_STATE_WAITING  0
#define EXPERIMENT_MANAGER_STATE_RUNNING  1
#define EXPERIMENT_MANAGER_STATE_FINISHED 2

#define EXPERIMENT_MANAGER_SESSION_DURATION 300.0

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <QDebug>

#include "experimentmanager.h"


ExperimentManager::ExperimentManager(QObject *parent, QJsonObject conf, QString path) : QObject(parent) {
    int i, userPhrasesIndex;
    this->config = conf;
    this->appPath = path;
    state = EXPERIMENT_MANAGER_STATE_WAITING;
    phrasesCount = 0;
    loadPhrasesList();

    QString userPhrasesIndexPath = QString(appPath + "/feedbackExp/userConfig/user%1_phrasesIndex.cfg")
                                   .arg(config["userId"].toInt());
    QString userPhrasesLastIndexPath = QString(appPath + "/feedbackExp/userConfig/user%1_lastIndex.cfg")
                                   .arg(config["userId"].toInt());

    loadFile(userPhrasesIndexPath, userPhraseFile, userPhraseFileStream, QChar('r'));
    loadFile(userPhrasesLastIndexPath, userFileLastIndex, userFileLastIndexStream, QChar('r'));

    if (userPhraseFile.exists() && !userPhraseFile.atEnd() && userFileLastIndex.exists() && !userFileLastIndex.atEnd()) {
        userPhrasesIndex = userPhraseFileStream.readLine().toInt();

        for (i = 0; i < nPhrases; i++) {
            userPhrasesIndex = userPhraseFileStream.readLine().toInt();
            if (userPhrasesIndex >= 0) {
                rndIndices.append(userPhrasesIndex);
            } else{
                qDebug() << "Error reading user index file";
                exit(-1);
            }
        }

        index = userFileLastIndexStream.readLine().toInt();

        if (!index) {
            qDebug() << "User index file does not have index";
            exit(-1);
        }

        userPhraseFile.close();
        userFileLastIndex.close();
    }
    else {
        index = -1;
        // Grava arquivo para usuario com os indices da lista de frases sorteadas
        loadFile(userPhrasesIndexPath, userPhraseFile, userPhraseFileStream, QChar('w'));
        loadFile(userPhrasesLastIndexPath, userFileLastIndex, userFileLastIndexStream, QChar('w'));

        if (!userPhraseFile.exists() || !userFileLastIndex.exists()) {
            qDebug() << "Can not create phrases file drawn for the user";
            exit(-1);
        }

        rndIndices = QVector<int>(nPhrases);
        std::iota (std::begin(rndIndices), std::end(rndIndices), 0);
        std::random_shuffle(rndIndices.begin(), rndIndices.end());

        userPhraseFileStream << nPhrases << "\n";

        for (std::vector<int>::size_type i = 0; i != rndIndices.size(); i++)
            userPhraseFileStream << rndIndices[i] << "\n";

        userFileLastIndexStream << index << "\n";

        userPhraseFile.close();
        userFileLastIndex.close();
    }

    count = 0;

}

ExperimentManager::~ExperimentManager() {
    closeFiles();
}

void ExperimentManager::loadFile(QString path, QFile &file, QTextStream &stream, QChar mode) {
    file.setFileName(path);

    if(mode == 'r') {
        if (file.open(QIODevice::ReadOnly | QIODevice::Text))
            stream.setDevice(&file);
    }  else if ('w') {
        if (file.open(QIODevice::WriteOnly | QIODevice::Text))
            stream.setDevice(&file);
    }
}

void ExperimentManager::closeFiles(){
    if (out.isOpen())
        out.close();
    if (rawEye.isOpen())
        rawEye.close();
}

void ExperimentManager::start(){
  startTime.start();
  QString str;
  str = appPath + QString("/feedbackExp/logs/expU%1S%2M%3.log")
                         .arg(config["userId"].toInt())
                         .arg(config["sessionId"].toInt())
                         .arg(config["modeId"].toInt());

  loadFile(str, out, outStream, QChar('w'));
  str.clear();  
  str = appPath + QString("/feedbackExp/logs/expU%1S%2M%3_raw.log")
                         .arg(config["userId"].toInt())
                         .arg(config["sessionId"].toInt())
                         .arg(config["modeId"].toInt());
  loadFile(str, rawEye, rawEyeStream, QChar('w'));

  if (!rawEye.isOpen()) {
    qDebug() << "File log opening failed";
  } else {      
      rawEyeStream << "tstamp, x, y\n";
      state = EXPERIMENT_MANAGER_STATE_RUNNING;
      str.clear();
      char header[100];
      sprintf(header, "experiment_start user = %d, session = %d, mode = %d",
                                                   config["userId"].toInt(),
                                                   config["sessionId"].toInt(),
                                                   config["modeId"].toInt());
      log(header);
  }
}

 void ExperimentManager::loadPhrasesList() {
    QFile phrasesFile;
    QTextStream phrasesFileStream;

    QString phrasesList = QString(appPath + config["phrases_file"].toString());

    loadFile(phrasesList, phrasesFile, phrasesFileStream, 'r');

    if (!phrasesFile.exists()) {
        qDebug() << "Cannot open " << phrasesList << " file";
        exit(-1);
    }

    nPhrases = phrasesFileStream.readLine().toInt();

    if (!nPhrases) {
        qDebug() << "Phrase file of the experiment don't have the number of sentences in the first row";
        exit(-1);
    }

    while (!phrasesFileStream.atEnd())
        phrases.append(phrasesFileStream.readLine());

    phrasesFile.close();
}

 void ExperimentManager::nextPhrase(bool previousValid){

     if (previousValid)
         phrasesCount += 1;
     int duration = startTime.elapsed();
     int durationConfig = config["experiment_duration_in_sec"].toInt() +
                          (config["experiment_number_phrases"].toInt() *
                           config["waitTimeContinue"].toInt());

     if ((duration > config["max_session_time"].toInt() &&
          phrasesCount >= config["experiment_number_phrases"].toInt()) ||
         (duration > durationConfig &&
          phrasesCount >= config["experiment_number_phrases"].toInt() - 5)) {
         log("experiment_end");
         state = EXPERIMENT_MANAGER_STATE_FINISHED;
     } else {
       count++;
       index = (index+1)%nPhrases;
       userFileLastIndex.open(QIODevice::WriteOnly);
       userFileLastIndexStream << index << "\n";
       userFileLastIndex.close();       
       logPhraseStart(phrases[rndIndices[index]].toLatin1().data());
     }
 }

 QString ExperimentManager::getCurrentPhrase(){

     QString re = QString(phrases[rndIndices[index]]);
     return re;
 }

 void ExperimentManager::log(const char *msg)  {
     if(isRunning())
        outStream << startTime.elapsed() << "\t" << msg <<"\n";
 }

 void ExperimentManager::logKey(QString k, int keyType) {
     const char * key = k.toLatin1().data();
     char msg[500];
     if(keyType == NORMAL_KEY)
         sprintf(msg, "TYP\t\"%s\"", key);
     else if (keyType == ACC_KEY)
         sprintf(msg, "AC_TYP\t\"%s\"", key);
     else if (keyType == WORD_KEY)
         sprintf(msg, "WORD_TYP\t\"%s\"", key);
     else if (keyType == BACK_WORD_KEY)
         sprintf(msg, "DEL\t\"%s\"", key);
     log(msg);
 }

 void ExperimentManager::logFocusIn(QString k, int keyType)  {
     const char * key = k.toLatin1().data();
     char msg[500];
     if(keyType == NORMAL_KEY)
         sprintf(msg, "LIN\t\"%s\"", key);
     else if (keyType == ACC_KEY)
         sprintf(msg, "AC_LIN\t\"%s\"", key);
     else if (keyType == WORD_KEY)
         sprintf(msg, "WORD_LIN\t\"%s\"", key);
     log(msg);
 }

 void ExperimentManager::logFocusOut(QString k, int keyType) {
     const char * key = k.toLatin1().data();
     char msg[500];
     if(keyType == NORMAL_KEY)
         sprintf(msg, "LOS\t\"%s\"", key);
     else if (keyType == ACC_KEY)
         sprintf(msg, "AC_LOS\t\"%s\"", key);
     else if (keyType == WORD_KEY)
         sprintf(msg, "WORD_LOS\t\"%s\"", key);
     log(msg);
 }

 void ExperimentManager::logPhraseStart(const char *phrase) {
     char msg[500];
     sprintf(msg, "STR\t%d\t%d\t\"%s\"", count, index, phrase);
     log(msg);
 }

 void ExperimentManager::logPhraseEnd(QString p) {
     const char *phrase = p.toLatin1().data();
     char msg[500];
     sprintf(msg, "END\t%d\t%d\t\"%s\"", count, index, phrase);
     log(msg);
 }

 void ExperimentManager::logRawEye(int x, int y) {
     char msg[500];
     sprintf(msg, "%i\t%i", x, y);
     if(isRunning())
        rawEyeStream << startTime.elapsed() << "\t" << msg << "\n";
 }

 int ExperimentManager::isRunning() {
     return (getState() == EXPERIMENT_MANAGER_STATE_RUNNING);
 }

 int ExperimentManager::isFinished() {
     return (getState() == EXPERIMENT_MANAGER_STATE_FINISHED);
 }
