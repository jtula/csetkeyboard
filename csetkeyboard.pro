HEADERS += src/config.h \
    src/tobiilistener.h \
    src/samplepoint.h \
    src/timer.h \
    src/managers/experimentmanager.h \
    src/keyboard.h \
    src/mouselistener.h \
    src/managers/gazemanager.h \
    src/managers/wordmanager.h

SOURCES += src/main.cpp \
    src/config.cpp \
    src/tobiilistener.cpp \
    src/samplepoint.cpp \
    src/timer.cpp \
    src/managers/experimentmanager.cpp \
    src/keyboard.cpp \
    src/mouselistener.cpp \
    src/managers/gazemanager.cpp \
    src/managers/wordmanager.cpp

TEMPLATE = app

QT += qml quick widgets
CONFIG += c++11

RESOURCES += qml.qrc


# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)

OTHER_FILES += assets/* \
               configuration/* \
               feedbackExp/userConfig/* \
               /usr/include/python2.7/*

win32:INCLUDEPATH += c:\Python27\include\ C:\Python27\libs\ "C:\Program Files (x86)\presage\include" "C:\Program Files (x86)\presage\bin" \
                        $$PWD/include
win32:LIBS += C:\Python27\libs\python27.lib -L"C:\Program Files (x86)\presage\bin" -L"C:\Program Files (x86)\presage\lib" -lpresage

unix:INCLUDEPATH += /usr/include/python2.7
unix:LIBS += -lpython2.7 -lpresage

win32 {
    # Copy DLLs
    DEST = $${OUT_PWD}

    !contains(QMAKE_TARGET.arch, x86_64) {
        ## Windows x86 (32bit)
        message("x86 build")
        SRC = $$PWD/lib/x86/Tobii.EyeX.Client.dll
        LIBS += -L$$PWD/lib/x86/ -lTobii.EyeX.Client
    } else {
        ## Windows x64 (64bit)
        message("x86_64 build")
        SRC = $$PWD/lib/x64/Tobii.EyeX.Client.dll
        LIBS += -L$$PWD/lib/x64/ -lTobii.EyeX.Client
    }

    SRC ~= s,/,\\,g
    DEST ~= s,/,\\,g

    copydata.commands = $(COPY_DIR) $$SRC $$DEST
    first.depends = $(first) copydata
    export(first.depends)
    export(copydata.commands)
    QMAKE_EXTRA_TARGETS += first copydata
}

DISTFILES += config/experiments.json \
    qml/qmldir \
    assets/fonts/fontawesome-webfont.ttf
