import 'package:flutter/material.dart';


class ChatWindowChangeNotifier extends ChangeNotifier {

  bool showChatWindow = false;

  static final ChatWindowChangeNotifier _instance = ChatWindowChangeNotifier._internal();

  ChatWindowChangeNotifier._internal();

  factory ChatWindowChangeNotifier() {
    return _instance;
  }

  setChatWindowVisible(bool visible) {
    showChatWindow = visible;
    notifyListeners();
  }

  getChatWindowVisible() {
    return showChatWindow;
  }
}
