#ifndef MOUSELISTENER_H
#define MOUSELISTENER_H

#include <QObject>
#include <QThread>
#include <QTimer>

#include "samplepoint.h"

class MouseListener : public QObject {
    Q_OBJECT
public:
    explicit MouseListener(QObject *root, bool controlling = true, bool noise = false, int radius = 0);
    ~MouseListener();
    void setControlling(bool controlling);

signals:
    void newMousePos(SamplePoint mouse);

public slots:
    void controlToggled(bool isControlling);

private slots:
    void getMousePos();


private:    
    bool controlling;
    bool noise;
    int radius;
    QTimer timer;    
    void createNoise(QPoint &m);
};

#endif // MOUSELISTENER_H
