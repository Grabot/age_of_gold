import 'package:flutter/foundation.dart';
import 'package:isolated_worker/js_isolated_worker.dart';
import 'models/user.dart';


class Settings extends ChangeNotifier {
  static final Settings _instance = Settings._internal();

  String accessToken = "";
  String refreshToken = "";
  int accessTokenExpiration = 0;
  int refreshTokenExpiration = 0;

  User? user;

  int rotation = 0;

  Uint8List? avatar;

  bool loggingIn = false;

  Settings._internal() {
    if (kIsWeb) {
      // This script had lots of compiled code, so it is not included in the git repo.
      // The file can be viewed in a previous commit
      // https://github.com/Grabot/age_of_gold/blob/cf11e6b237caa4bc67fecd7a9bd9250d8b8fe918/web/crop_web.js
      JsIsolatedWorker().importScripts(['crop/crop_web.js']).then((value) {});
      print("imported crop_web.js");
    }
  }

  factory Settings() {
    return _instance;
  }

  logout() {
    accessToken = "";
    refreshToken = "";
    accessTokenExpiration = 0;
    user = null;
    avatar = null;
    loggingIn = false;
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

  setAvatar(Uint8List avatar) {
    this.avatar = avatar;
  }

  setLoggingIn(bool loggingIn) {
    this.loggingIn = loggingIn;
  }

  bool getLoggingIn() {
    return loggingIn;
  }

  notify() {
    notifyListeners();
  }

  Uint8List? getAvatar() {
    return avatar;
  }

  setAccessTokenExpiration(int accessTokenExpiration) {
    this.accessTokenExpiration = accessTokenExpiration;
  }

  int getAccessTokenExpiration() {
    return accessTokenExpiration;
  }

  setRefreshTokenExpiration(int refreshTokenExpiration) {
    this.refreshTokenExpiration = refreshTokenExpiration;
  }

  int getRefreshTokenExpiration() {
    return refreshTokenExpiration;
  }

  setRotation(int rotation) {
    this.rotation = rotation;
  }
  getRotation() {
    return rotation;
  }
}
