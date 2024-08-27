import 'package:flutter/material.dart';


class LoginWindowChangeNotifier extends ChangeNotifier {

  bool showLogin = false;

  static final LoginWindowChangeNotifier _instance = LoginWindowChangeNotifier._internal();

  LoginWindowChangeNotifier._internal();

  factory LoginWindowChangeNotifier() {
    return _instance;
  }

  setLoginWindowVisible(bool visible) {
    showLogin = visible;
    notifyListeners();
  }

  getLoginWindowVisible() {
    return showLogin;
  }
}
