#include "backend.h"

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <qqmlapplicationengine.h>

int main(int argc, char *argv[]) {
  QGuiApplication app(argc, argv);
  QQmlApplicationEngine engine;
  Backend backend;

  engine.rootContext()->setContextProperty("Backend", &backend);
  engine.loadFromModule("MainQML", "Main");
  if (engine.rootObjects().isEmpty())
    return -1;

  return app.exec();
}