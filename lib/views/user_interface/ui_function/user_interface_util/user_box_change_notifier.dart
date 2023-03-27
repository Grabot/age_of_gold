import 'package:age_of_gold/services/models/user.dart';
import 'package:flutter/material.dart';


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
