#pragma once

#include <QObject>
#include <qtmetamacros.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <unistd.h>

class JsonValue;

class Backend : public QObject {
  Q_OBJECT
public:
  int fd;
  explicit Backend(QObject *parent = nullptr);

  Q_INVOKABLE QString getLastUser();
  Q_INVOKABLE void saveLastUser(const QString &username);
  std::string handleAuthentication(const JsonValue &authMessage,
                                   const std::string &authType,
                                   const QString &password);

  Q_INVOKABLE void login(const QString &username, const QString &password);
  QString loginThreaded(const QString &username, const QString &password);
  Q_INVOKABLE void shutdown();
  Q_INVOKABLE void restart();
  Q_INVOKABLE void startSession();
signals:
  void loginFinished(const QString &result);
};