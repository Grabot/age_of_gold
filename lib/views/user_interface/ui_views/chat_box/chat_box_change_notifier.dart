import 'package:flutter/material.dart';


class ChatBoxChangeNotifier extends ChangeNotifier {

  bool showChatBox = false;

  static final ChatBoxChangeNotifier _instance = ChatBoxChangeNotifier._internal();

  ChatBoxChangeNotifier._internal();

  factory ChatBoxChangeNotifier() {
    return _instance;
  }

  setChatBoxVisible(bool visible) {
    showChatBox = visible;
    notifyListeners();
  }

  getChatBoxVisible() {
    return showChatBox;
  }

  notify() {
    notifyListeners();
  }
}
