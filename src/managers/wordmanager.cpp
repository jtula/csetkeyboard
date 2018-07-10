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

#include "wordmanager.h"
#include <QDebug>
#include <typeinfo>

WordManager::WordManager(QObject *parent, QJsonObject conf, QString path) :
    QObject(parent),
    parent(parent),
    config(conf),
    appPath(path),
    wordlistTopCol(parent->findChild<QObject*>("wordlistTopCol")),
    wordlistBotCol(parent->findChild<QObject*>("wordlistBotCol"))
{
    predictN = 0;
    lastAction = false;    
    QString dbPath = path+config["presage_db"].toString();
    presage = new Presage(&callback, std::string(dbPath.toUtf8().constData()));
    qInfo() << "Initializing presage with language: " << dbPath;
    setPresageStatus(PRESAGE_NORMAL);
    presageLastAddedString2Context[0] = '\0';
    presageLastPredictedPosfix[0] = '\0';
    presageLastTypedPosfix[0] = '\0';
    // Begin with the predefined words
    phraseBegin();
    qInfo()<<"XCC";
}

template <class T>
T WordManager::findChild(QQuickItem* object, const QString& objectName) {
    QList<QQuickItem*> children = object->childItems();
    foreach (QQuickItem* item, children) {
        if (QQmlProperty::read(item, "objectName").toString() == objectName)
            return item;

        T child = findChild<QQuickItem*>(item, objectName);

        if (child)
            return child;
    }
    return nullptr;
}

void WordManager::phraseBegin() {
    clearPresageContext();

    words.clear();
    if (QString::compare(config["language"].toString(), QString("language_pt"))) {
        words.push_back(std::string("o"));
        words.push_back(std::string("a"));
        words.push_back(std::string("os"));
    }
    else if (QString::compare(config["language"].toString(), QString("language_es"))) {
        words.push_back(std::string("el"));
        words.push_back(std::string("la"));
        words.push_back(std::string("los"));
    }
    else if (QString::compare(config["language"].toString(), QString("language_en"))) {
        words.push_back(std::string("the"));
        words.push_back(std::string("a"));
        words.push_back(std::string("to"));
    }
    else {
        words.push_back(std::string(""));
        words.push_back(std::string(""));
        words.push_back(std::string(""));
    }
    predictN = words.size();
    updateWordList();
}

void WordManager::wordTyped(char *word) {
    qInfo() << "wordTyped: " << word;
}

void WordManager::add2presage(const char *str) {
    callback.update(std::string(str));
    strcpy(presageLastAddedString2Context, str);
}

void WordManager::updatePredictions(char *content) {

    if (content != NULL && strcmp(content, "") != 0) {
        add2presage(content);     
    }

    if (callback.get_past_stream().size() > 0) {
        context = std::string("q");
        words = presage->predict();        
        predictN = words.size();
        if (predictN > 1) {
            std::string tmp;
            tmp.assign(words[predictN/2]);
            words[predictN/2].assign(words[0]);
            words[0].assign(tmp);
        }
    }
    else {
        phraseBegin();
    }

}

void WordManager::wordTyped() {

}

void WordManager::removeFromPresage(int n) {
    if ((unsigned)n > callback.get_past_stream().size())
        n = callback.get_past_stream().size();
    for (int i = 0; i < n; ++i)
        callback.update("\b");
    presageLastAddedString2Context[0] = '\0';
}

void WordManager::clearPresageContext() {
    removeFromPresage(callback.get_past_stream().size());
    presageLastAddedString2Context[0] = '\0';
}

void WordManager::getPosfix(const char *word, char *posfix) {
    std::string posfixStr;
    try {
        posfixStr = presage->completion(std::string(word));
    }
    catch (...) {
        posfixStr = std::string("");
    }

    strcpy(posfix, posfixStr.c_str());
    if (posfix[strlen(posfix)] != '\0') {
        posfix[strlen(posfix)] = '\0';
    }
}

void WordManager::keyTyped(QVariant key) {
    QObject* keyObj = qvariant_cast<QObject*>(key);

    //log here
    lastAction = true;
    presageTransition(TRANSITION_SELECT_CHAR,
                      keyObj->property("text").toString().toLocal8Bit().data());
}

void WordManager::clearLastAction() {
    lastAction = false;
}


void WordManager::getWord2Remove(char *word2remove) {

}

void WordManager::getLastTypedWord(char *word) {

}

void WordManager::setPresageStatus(int newStatus) {
    presageState = newStatus;
}

void WordManager::presageTransition(int transition, char *content) {
    switch(transition) {
        case TRANSITION_FOCUS_CHAR:
            if (presageState == PRESAGE_NORMAL) {
                //qInfo() << "FOCUS CHAR";
                updatePredictions(content);
                presageState = PRESAGE_CHAR_ADDED;
            }
            else if (presageState == PRESAGE_WORD_ADDED) {
                removeFromPresage(strlen(presageLastAddedString2Context));
                updatePredictions();
                updateWordList();
                updatePredictions(content);
                presageState = PRESAGE_CHAR_ADDED;
            }
            break;
        case TRANSITION_FOCUS_ANOTHER_CHAR:
            if (presageState == PRESAGE_CHAR_ADDED) {
                //qInfo() << "ANOTHER FOCUS CHAR: " << content;
                removeFromPresage(1);
                add2presage(content);
                updatePredictions();
            }
            else if (presageState == PRESAGE_NORMAL) {
                //qInfo() << "ANOTHER FOCUS CHAR 2";
                updatePredictions(content);
                presageState = PRESAGE_CHAR_ADDED;
            }
            break;
        case TRANSITION_LOSE_FOCUS_CHAR:
            //qInfo() << "LOSE FOCUS CHAR: ";
            if (presageState == PRESAGE_CHAR_ADDED) {
                removeFromPresage(1);
                updatePredictions();
                presageState = PRESAGE_NORMAL;
            }
            break;
        case TRANSITION_SELECT_CHAR:
            if (presageState == PRESAGE_CHAR_ADDED) {
                updateWordList();
                presageState = PRESAGE_NORMAL;
            }
            break;
        case TRANSITION_FOCUS_WORD:
            if (presageState == PRESAGE_NORMAL) {
                getPosfix(content, presageLastPredictedPosfix);
                updatePredictions(presageLastPredictedPosfix);
                presageState = PRESAGE_WORD_ADDED;
            }
            else if (presageState == PRESAGE_CHAR_ADDED) {
                //removeFromPresage(1);
                updatePredictions();
                updateWordList();
                getPosfix(content, presageLastPredictedPosfix);
                updatePredictions(presageLastPredictedPosfix);
                presageState = PRESAGE_WORD_ADDED;
            }
            break;
        case TRANSITION_FOCUS_ANOTHER_WORD:
            if (presageState == PRESAGE_WORD_ADDED) {
                //removeFromPresage(strlen(presageLastAddedString2Context));
                getPosfix(content, presageLastPredictedPosfix);
                updatePredictions(presageLastPredictedPosfix);
            }
            else if (presageState == PRESAGE_NORMAL) {
                getPosfix(content, presageLastPredictedPosfix);
                updatePredictions(presageLastPredictedPosfix);
                presageState = PRESAGE_WORD_ADDED;
            }
            break;
        case TRANSITION_LOSE_FOCUS_WORD:
            if (presageState == PRESAGE_WORD_ADDED) {
                //removeFromPresage(strlen(presageLastAddedString2Context));
                updatePredictions();
                presageState = PRESAGE_NORMAL;
            }
            break;
        case TRANSITION_SELECT_WORD:
            if (presageState == PRESAGE_WORD_ADDED) {
                presageState = PRESAGE_NORMAL;
            }
            break;
    }
}

char *WordManager::getLastPosfixAdded() {
    return presageLastPredictedPosfix;
}

void WordManager::updateWordList() {

    for (int i=0; i < config["number_words"].toInt(); ++i) {
        if (wordlistTopCol && wordlistBotCol) {
            QQuickItem* wlt = findChild<QQuickItem*>(qobject_cast<QQuickItem*>(wordlistTopCol), "wlt_"+QString::number(i));
            QQuickItem* wlb = findChild<QQuickItem*>(qobject_cast<QQuickItem*>(wordlistBotCol), "wlb_"+QString::number(i));

            //Todo: I need check for valid wlt and wlb

            if (wlt && wlb) {
                if (i < predictN) {
                    wlt->setProperty("text", words[i].c_str());
                    wlb->setProperty("text", words[i].c_str());
                    //Todo: log text
                } else {
                    wlt->setProperty("text", "");
                    wlt->setProperty("text", "");
                    //Todo: log text
                }
            }
        }
    }
}

void WordManager::updateTransition(int t, QString content) {
    char * cont = content.toLocal8Bit().data();
    presageTransition(t, cont);
}

void WordManager::removeLastWord() {

}


void WordManager::printPrediction(const std::vector<std::string> &words) {
    for( std::vector<std::string>::const_iterator i = words.begin(); i != words.end(); i++ ) {
        std::cout << *i << std::endl;
    }
}

void WordManager::updatePosfixString() {

}

void WordManager::updatePrefixString() {

}


