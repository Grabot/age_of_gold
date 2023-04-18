import 'package:age_of_gold/services/models/user.dart';
import 'package:flutter/material.dart';


class SendMessageBoxChangeNotifier extends ChangeNotifier {

  bool showMessageBox = false;
  User? toUser;

  static final SendMessageBoxChangeNotifier _instance = SendMessageBoxChangeNotifier._internal();

  SendMessageBoxChangeNotifier._internal();

  factory SendMessageBoxChangeNotifier() {
    return _instance;
  }

  setSendMessageBoxVisible(bool visible) {
    showMessageBox = visible;
    notifyListeners();
  }

  getSendMessageBoxVisible() {
    return showMessageBox;
  }

  setToUser(User? toUser) {
    this.toUser = toUser;
  }

  User? getToUser() {
    return toUser;
  }
}
