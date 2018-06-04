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
import QtQuick.Controls 2.2
import QtQuick.Controls.Styles 1.4
import QtQuick.Window 2.3
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0

ApplicationWindow {

    id: dialog
    objectName: "dialog"

    property color itemColor: "#ff6f00"

    width: 400
    height: 500
    visible: true
    color: "black"

    signal insert(string language, int user, int session, int exptime, int nphrases, int layout, int input)
    signal quit()

    Settings {
        id: settings
        property alias languageCurrentIndex: language.currentIndex
        property alias userCurrentIndex: user.currentIndex
        property alias sessionCurrentIndex: session.currentIndex
        property alias layoutCurrentIndex: layout.currentIndex
        property alias inputCurrentIndex: input.currentIndex
        property alias inputExpdur: expdur.text
        property alias inputNphrases: nphrases.text
    }

    Component.onDestruction: {
        settings.languageCurrentIndex= language.currentIndex
        settings.userCurrentIndex = user.currentIndex
        settings.sessionCurrentIndex = session.currentIndex
        settings.layoutCurrentIndex = layout.currentIndex
        settings.inputCurrentIndex = input.currentIndex
        settings.inputExpdur = expdur.text
        settings.inputNphrases = nphrases.text
    }

    GridLayout {
        id: gridLayout
        rows: 8
        flow: GridLayout.TopToBottom
        anchors.centerIn: parent
        rowSpacing: 10

        Label { text: "Language:"; font.pixelSize: 18; color: "#FFFFFF" }
        Label { text: "User ID:"; font.pixelSize: 18; color: "#FFFFFF" }
        Label { text: "Session:"; font.pixelSize: 18; color: "#FFFFFF" }
        Label { text: "Duration:"; font.pixelSize: 18; color: "#FFFFFF" }
        Label { text: "Phrases Number:"; font.pixelSize: 18; color: "#FFFFFF" }
        Label { text: "Layout:"; font.pixelSize: 18; color: "#FFFFFF" }
        Label { text: "Input:"; font.pixelSize: 18; color: "#FFFFFF" }
        Button {
            text: "Iniciar"
            highlighted: true
            anchors.right: cancel.left
            anchors.rightMargin: 10
            onClicked: {
                insert(lgItems.get(language.currentIndex).value, user.currentIndex+1, session.currentIndex+1,
                       expdur.text, nphrases.text, layout.currentIndex+1, input.currentIndex);
                Qt.quit();
            }
        }

        ComboBox {
            id: language
            textRole: "key"
            model: ListModel {
                id: lgItems
                ListElement { key: "Portuguese" ;value:"language_pt" }
                ListElement { key: "English"    ;value:"language_en" }
                ListElement { key: "Spanish"    ;value:"language_es" }
            }

            delegate: ItemDelegate {
                width: language.width
                contentItem: Text {
                    text: key
                    color: itemColor
                    font: language.font
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                }
                highlighted: language.highlightedIndex === index
            }

        }

        ComboBox {
            id: user
            model: 10

            delegate: ItemDelegate {
                width: user.width
                contentItem: Text {
                    text: index+1
                    color: dialog.itemColor
                    font: user.font
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                }
                highlighted: user.highlightedIndex === index
            }

            displayText: currentIndex + 1
        }

        ComboBox {
            id: session
            model: 8

            delegate: ItemDelegate {
                width: session.width
                contentItem: Text {
                    text: index+1
                    color: dialog.itemColor
                    font: session.font
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                }
                highlighted: session.highlightedIndex === index
            }

            displayText: currentIndex + 1
        }

        TextField {
            id: expdur

            placeholderText: "300"
            validator: IntValidator {bottom: 10; top: 500;}
            focus: true
            implicitWidth: session.width
        }

        TextField {
            id: nphrases

            placeholderText: "10"
            validator: IntValidator {bottom: 5; top: 40;}
            focus: true
            implicitWidth: session.width
        }
        ComboBox {
            id: layout
            textRole: "key"
            model: ListModel {
                ListElement { key: "Uma linha" }
                ListElement { key: "Duas linhas" }
                ListElement { key: "QWERTY"; }
            }

            delegate: ItemDelegate {
                width: layout.width
                contentItem: Text {
                    text: key
                    color: dialog.itemColor
                    font: layout.font
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                }
                highlighted: layout.highlightedIndex === index
            }


        }

        ComboBox {
            id: input
            textRole: "key"
            model: ListModel {
                ListElement { key: "Mouse"}
                ListElement { key: "EyeX"}
            }

            delegate: ItemDelegate {
                width: input.width
                contentItem: Text {
                    text: key
                    color: dialog.itemColor
                    font: input.font
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                }
                highlighted: input.highlightedIndex === index
            }
        }

        Button {
            id: cancel

            text: "Cancelar"
            highlighted: true
            onClicked: {
                quit();
            }
        }

        focus: true
        Keys.onPressed: {
            if (event.key === Qt.Key_Escape)
                quit();
        }
    }
}
