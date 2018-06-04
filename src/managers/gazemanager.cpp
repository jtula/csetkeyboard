#include "gazemanager.h"
#include "../timer.h"
#include <QDebug>

GazeManager::GazeManager(QObject *parent, QObject *gaze, bool useMouse, QString path) :
    QObject(parent), parent(parent),
    gaze(gaze),    
    useMouse(useMouse)
{
    appPath = path;
//    gazeEvent = new GazeEvent_PythonWrapper();
//    appPath.append("/Saccades/Statecharts");
//    gazeEvent->init(appPath.toLocal8Bit().data(), "gazeEvents", "GazeEvents", "addSampleList", "current_state");
    root = parent->findChild<QObject*>("root");
}

GazeManager::~GazeManager()
{
}

void GazeManager::updateGaze(SamplePoint position) {

    QVariantMap mapGazeState;
    mapGazeState.insert("x", position.pos.x());
    mapGazeState.insert("y", position.pos.y());
    mapGazeState.insert("valid", !position.pos.isNull());
    updateKeyboardState(mapGazeState);
}

void GazeManager::setIsMouse(bool isMouse) {
    useMouse = !isMouse;
}

void GazeManager::updateKeyboardState(QVariant eyeGazeState) {
    QMetaObject::invokeMethod(root, "updateKeyboardState", Q_ARG(QVariant, eyeGazeState));
}

