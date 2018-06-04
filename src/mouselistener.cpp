#include <QCursor>
#include <QDebug>

#include "mouselistener.h"
#include "timer.h"


MouseListener::MouseListener(QObject *root, bool controlling, bool noise, int radius) :
    QObject(root),
    controlling(controlling),
    noise(noise),
    radius(radius),
    timer(0)
{
    timer.setInterval(15);
    connect(&timer, SIGNAL(timeout()), this, SLOT(getMousePos()));
    if (controlling)
        timer.start();
}

MouseListener::~MouseListener()
{
}

//taken from tobbilistener
void MouseListener::setControlling(bool controlling) {
    this->controlling = controlling;
}

void MouseListener::controlToggled(bool isControlling) {
    controlling = isControlling;
    if (isControlling)
        timer.start();
    else
        timer.stop();
}


void MouseListener::getMousePos() {
    QPoint p = QCursor::pos();

    if (noise)
        createNoise(p);

    emit newMousePos(SamplePoint(p, Timer::timestamp()));
}

void MouseListener::createNoise(QPoint &m) {
    double angle, length;
    angle = ((double)rand() / RAND_MAX) * 2 * M_PI;
    length = ((double)rand() / RAND_MAX) * radius;
    int x = m.x() + cos(angle) * length;
    int y = m.y() + sin(angle) * length;
    m.setX(x);
    m.setY(y);
}
