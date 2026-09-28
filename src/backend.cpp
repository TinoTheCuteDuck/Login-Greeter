#include "backend.h"

#include "json/jsonParser.hpp"

#include <QSettings>
#include <QtConcurrent>
#include <filesystem>
#include <iostream>
#include <qcontainerfwd.h>
#include <stdexcept>
#include <sys/socket.h>

Backend::Backend(QObject *parent) : QObject(parent) {}

QString Backend::getLastUser() {
  QSettings settings;
  return settings.value("lastUser", "").toString();
}

void Backend::saveLastUser(const QString &username) {
  QSettings settings;
  settings.setValue("lastUser", username);
}

std::string Backend::handleAuthentication(const JsonValue &authMessage,
                                          const std::string &authType,
                                          const QString &password) {
  if (authType == "success") {
    return "Successful login!";
  } else if (authType == "error") {
    close(fd);
    return std::string("An error occurred!\n" +
                       authMessage["description"].get<std::string>());
  } else if (authType == "auth_message") {
    if (authMessage["auth_message"].get<std::string>() == "Password: ") {
      const std::string sendPassword =
          "{\n \"type\": \"post_auth_message_response\",\n \"response\": \"" +
          password.toStdString() + "\"\n}\n";

      uint32_t passwordLength = sendPassword.size();
      int passLenSent = send(fd, &passwordLength, sizeof(passwordLength), 0);
      if (passLenSent == -1) {
        close(fd);
        return "An error occurred!\n Connection error.";
      }
      int passDataSent = send(fd, sendPassword.data(), sendPassword.size(), 0);
      if (passDataSent == -1) {
        close(fd);
        return "An error occurred!\n Connection error.";
      }

      uint32_t authLength;
      char authBuffer[1025];

      int authLenRecv = recv(fd, &authLength, sizeof(authLength), 0);
      if (authLenRecv == -1) {
        close(fd);
        return "An error occurred!\n Connection error.";
      } else if (authLenRecv == 0) {
        close(fd);
        return "An error occurred!\n Connection closed by server.";
      }
      int authDataRecv = recv(fd, authBuffer, sizeof(authBuffer) - 1, 0);
      if (authDataRecv == -1) {
        close(fd);
        return "An error occurred!\n Connection error.";
      } else if (authDataRecv == 0) {
        close(fd);
        return "An error occurred!\n Connection closed by server.";
      }
      authBuffer[authLength] = '\0';

      JsonValue newAuthMessage = JsonParser::load(std::string(authBuffer));
      std::string newAuthType = newAuthMessage["type"].get<std::string>();

      return handleAuthentication(newAuthMessage, newAuthType, password);
    } else {
      if (authMessage["auth_message_type"].get<std::string>() == "error") {
        close(fd);
        return "An error occurred!\n" +
               authMessage["auth_message"].get<std::string>();
      } else if (authMessage["auth_message_type"].get<std::string>() ==
                 "info") {
        close(fd);
        return "Info:\n" + authMessage["auth_message"].get<std::string>();
      } else {
        close(fd);
        return "An error occurred!\n Unknown authentication method.";
      }
    }
  } else {
    close(fd);
    return "An error occurred!\n Unknown authentication type.";
  }
}

void Backend::login(const QString &username, const QString &password) {
  (void)QtConcurrent::run([this, username, password]() {
    QString result = loginThreaded(username, password);
    emit loginFinished(result);
  });
}

QString Backend::loginThreaded(const QString &username,
                               const QString &password) {
  fd = socket(AF_UNIX, SOCK_STREAM, 0);
  const char *greetdPath = std::getenv("GREETD_SOCK");
  if (!greetdPath) {
    close(fd);
    return "An error occurred!\n Failed to get greetd socket.";
  }
  sockaddr_un address{};
  address.sun_family = AF_UNIX;

  strncpy(address.sun_path, greetdPath, sizeof(address.sun_path) - 1);

  if (::connect(fd, reinterpret_cast<sockaddr *>(&address), sizeof(address)) ==
      -1) {
    close(fd);
    return "An error occurred!\n Failed to connect to greetd.";
  }

  const std::string requestSession =
      "{\n \"type\": \"create_session\",\n \"username\": \"" +
      username.toStdString() + "\"\n}\n";

  uint32_t requestLength = requestSession.size();

  int requestLenSent = send(fd, &requestLength, sizeof(requestLength), 0);
  if (requestLenSent == -1) {
    close(fd);
    return "An error occurred!\n Connection error.";
  }
  int requestDataSent =
      send(fd, requestSession.data(), requestSession.size(), 0);
  if (requestDataSent == -1) {
    close(fd);
    return "An error occurred!\n Connection error.";
  }

  uint32_t authLength;
  char authBuffer[1025];

  int authLenRecv = recv(fd, &authLength, sizeof(authLength), 0);
  if (authLenRecv == -1) {
    close(fd);
    return "An error occurred!\n Connection error.";
  } else if (authLenRecv == 0) {
    close(fd);
    return "An error occurred!\n Connection closed by server.";
  }
  int authDataRecv = recv(fd, authBuffer, sizeof(authBuffer) - 1, 0);
  if (authDataRecv == -1) {
    close(fd);
    return "An error occurred!\n Connection error.";
  } else if (authDataRecv == 0) {
    close(fd);
    return "An error occurred!\n Connection closed by server.";
  }
  authBuffer[authLength] = '\0';

  JsonValue authMessage = JsonParser::load(std::string(authBuffer));
  std::string authType = authMessage["type"].get<std::string>();

  std::string returnMessage =
      handleAuthentication(authMessage, authType, password);

  return QString(returnMessage.c_str());
}

void Backend::startSession() {
  const std::string startSession =
      "{\n \"type\": \"start_session\",\n \"cmd\": "
      "[\"/usr/bin/start-hyprland\"],\n \"env\": []\n}\n";

  uint32_t sessionLength = startSession.size();

  int startLenSent = send(fd, &sessionLength, sizeof(sessionLength), 0);
  if (startLenSent == -1) {
    close(fd);
    throw std::runtime_error("An error occurred!\n Connection error.");
  }

  int statDataSent = send(fd, startSession.data(), startSession.size(), 0);
  if (statDataSent == -1) {
    close(fd);
    throw std::runtime_error("An error occurred!\n Connection error.");
  }

  close(fd);
}

void Backend::shutdown() {
  QProcess::startDetached("systemctl", QStringList() << "poweroff");
}
void Backend::restart() {
  QProcess::startDetached("systemctl", QStringList() << "reboot");
}