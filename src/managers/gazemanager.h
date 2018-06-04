#ifndef GAZEMANAGER_H
#define GAZEMANAGER_H

#include <QObject>

#include "../samplepoint.h"

class GazeManager : public QObject {
    Q_OBJECT
public:
    GazeManager(QObject *parent, QObject *gaze, bool useMouse, QString path);
    ~GazeManager();

signals:    
    void newSample(QPointF sample, double timestamp);

public slots:
    void updateGaze(SamplePoint position);
    void setIsMouse(bool isMouse);    

private:
    QObject *parent;
    QObject *gaze;
    QObject* root;
    QObject* engine;
    bool useMouse;
    QString appPath;    
    void updateKeyboardState(QVariant eyeGazeState);
//    GazeEvent_PythonWrapper *gazeEvent;
//    EyeGazeState eyeGazeState;

};

#endif // GAZEMANAGER_H
