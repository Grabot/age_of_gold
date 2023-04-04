import 'package:flutter/material.dart';
import 'models/user.dart';


class Settings extends ChangeNotifier {
  static final Settings _instance = Settings._internal();

  String accessToken = "";
  String refreshToken = "";
  int accessTokenExpiration = 0;

  User? user;

  String? avatar;

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

  setAvatar(String avatar) {
    this.avatar = avatar;
    notifyListeners();
  }

  String? getAvatar() {
    return avatar;
  }

  setAccessTokenExpiration(int accessTokenExpiration) {
    this.accessTokenExpiration = accessTokenExpiration;
  }

  int getAccessTokenExpiration() {
    return accessTokenExpiration;
  }
}
