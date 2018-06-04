import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

ColumnLayout {

    property string columnName
    property int columnWidth
    property int columnHeight
    property string repeaterName
    property int modelNumber
    property string wordBoxName
    property color wordBoxColor
    property real wordBoxOpacity
    property int wordBoxWidth
    property int wordBoxHeight
    property string wordBoxText
    property real wordBoxTextSize
    property color wordBoxTextColor

    Column {
        objectName: columnName

        width: columnWidth
        height: columnHeight

        Repeater {
            objectName: repeaterName

            model: modelNumber
            Rectangle {
                objectName: wordBoxName+index

                property string text
                width: wordBoxWidth
                height: wordBoxHeight
                color: wordBoxColor
                opacity: wordBoxOpacity

                Text {
                    text: parent.text
                    font.pointSize: wordBoxTextSize
                    anchors.centerIn: parent
                    color: wordBoxTextColor
                }
            }
        }
    }

}
