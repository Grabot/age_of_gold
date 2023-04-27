import 'package:flutter/material.dart';


class FriendWindowChangeNotifier extends ChangeNotifier {

  bool showFriendWindow = false;

  static final FriendWindowChangeNotifier _instance = FriendWindowChangeNotifier._internal();

  FriendWindowChangeNotifier._internal();

  factory FriendWindowChangeNotifier() {
    return _instance;
  }

  setFriendWindowVisible(bool visible) {
    showFriendWindow = visible;
    notifyListeners();
  }

  getFriendWindowVisible() {
    return showFriendWindow;
  }
}
