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

#ifndef WORDMANAGER_H
#define WORDMANAGER_H

#include <QObject>
#include <QJsonObject>
#include <QString>
#include <QQuickItem>
#include <QQmlProperty>
#include <presage.h>
#include <stdio.h>
#include <iostream>

// Estados possiveis do presage
#define PRESAGE_NORMAL			1
#define PRESAGE_CHAR_ADDED 		2
#define PRESAGE_WORD_ADDED		3

#define TRANSITION_FOCUS_CHAR			1
#define TRANSITION_FOCUS_ANOTHER_CHAR	2
#define TRANSITION_LOSE_FOCUS_CHAR		3
#define TRANSITION_SELECT_CHAR			4
#define TRANSITION_FOCUS_WORD			5
#define TRANSITION_FOCUS_ANOTHER_WORD	6
#define TRANSITION_LOSE_FOCUS_WORD		7
#define TRANSITION_SELECT_WORD			8

class WordManager : public QObject {
    Q_OBJECT
public:
    WordManager(QObject *parent, QJsonObject conf, QString path);
    void wordTyped();
    void wordTyped(char* word);
    void updatePredictions(char* content = NULL);
    void removeFromPresage(int n=1);
    void clearPresageContext();
    void add2presage(const char* str);
    void removeLastWord();
    void getPredictedWord(int index, char *out);
    void getWord2Remove(char *word2remove);
    void getLastTypedWord(char* word);
    void setPresageStatus(int newStatus);

    char* getLastPosfixAdded();
    void getPosfix(const char * word, char *posfix);

    //inline
    int getPredictN() const { return predictN; }
    int getPresageStatus() const { return presageState; }

public slots:
    void keyTyped(QVariant key);
    void updateWordList();
    void updateTransition(int t, QString content);
    void phraseBegin();

private:
    template <class T>
    T findChild(QQuickItem* object, const QString& objectName);
    void presageTransition(int transition, char* content);
    QObject *parent;
    QJsonObject config;
    QString appPath;
    QObject* wordlistTopCol;
    QObject* wordlistBotCol;
    Presage *presage;
    std::string context;
    LegacyPresageCallback callback;
    std::vector<std::string> words;
    char ** posfixArray;
    char presageLastPredictedPosfix[150], presageLastTypedPosfix[150], presageLastAddedString2Context[150];
    bool lastAction, needUpdateWordList;
    int	keyWasSelected;
    char prefix[150];
    char blinking[150], posfixAdded[150];
    int blinkStart;
    int presageState;
    int	predictN;    
    void clearLastAction();
    void printPrediction (const std::vector<std::string>& words);
    void updatePosfixString();
    void updatePrefixString();
};

#endif // WORDMANAGER_H
