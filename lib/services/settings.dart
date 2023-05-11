import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:isolated_worker/js_isolated_worker.dart';
import 'models/friend.dart';
import 'models/user.dart';


class Settings extends ChangeNotifier {
  static final Settings _instance = Settings._internal();

  String accessToken = "";
  String refreshToken = "";
  int accessTokenExpiration = 0;

  User? user;

  // String? avatar;
  Uint8List? avatar;

  Settings._internal() {
    if (kIsWeb) {
      // This script had lots of compiled code, so it is not included in the git repo.
      // The file can be viewed in a previous commit
      // https://github.com/Grabot/age_of_gold/blob/cf11e6b237caa4bc67fecd7a9bd9250d8b8fe918/web/crop_web.js
      JsIsolatedWorker().importScripts(['crop/crop_web.js']).then((value) {
        print("importScripts");
      });
    }
  }

  factory Settings() {
    return _instance;
  }

  logout() {
    // TODO: clear messages?
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

  setAvatar(Uint8List avatar) {
    this.avatar = avatar;
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
}
