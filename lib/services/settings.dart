

import 'models/user.dart';

class Settings {
  static final Settings _instance = Settings._internal();

  String accessToken = "";
  String refreshToken = "";
  int accessTokenExpiration = 0;

  User? user;

  Settings._internal();

  factory Settings() {
    return _instance;
  }

  logout() {
    accessToken = "";
    refreshToken = "";
    accessTokenExpiration = 0;
    user = null;
  }

  setAccessToken(String accessToken) {
    this.accessToken = accessToken;
  }

  String getAccessToken() {
    return accessToken;
  }

  setRefreshToken(String refreshToken) {
    this.refreshToken = refreshToken;
  }

  String getRefreshToken() {
    return refreshToken;
  }

  setUser(User user) {
    this.user = user;
  }

  User? getUser() {
    return user;
  }

  setAccessTokenExpiration(int accessTokenExpiration) {
    this.accessTokenExpiration = accessTokenExpiration;
  }

  int getAccessTokenExpiration() {
    return accessTokenExpiration;
  }
}
