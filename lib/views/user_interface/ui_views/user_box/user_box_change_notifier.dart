import 'package:flutter/material.dart';

import '../../../../services/models/user.dart';


class UserBoxChangeNotifier extends ChangeNotifier {

  bool showUser = false;
  User? user;

  static final UserBoxChangeNotifier _instance = UserBoxChangeNotifier._internal();

  UserBoxChangeNotifier._internal();

  factory UserBoxChangeNotifier() {
    return _instance;
  }

  setUserBoxVisible(bool visible) {
    showUser = visible;
    notifyListeners();
  }

  getUserBoxVisible() {
    return showUser;
  }

  setUser(User? user) {
    this.user = user;
  }

  User? getUser() {
    return user;
  }
}
