import 'package:age_of_gold/services/models/user.dart';
import 'package:flutter/material.dart';


class ChatBoxChangeNotifier extends ChangeNotifier {

  bool showChatBox = false;
  String? chatUser;
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

  String? getChatUser() {
    return chatUser;
  }

  setChatUser(String userName) {
    this.chatUser = userName;
  }
}
