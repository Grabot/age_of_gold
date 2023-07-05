import 'package:flutter/material.dart';


class GuildWindowChangeNotifier extends ChangeNotifier {

  bool showGuildWindow = false;

  static final GuildWindowChangeNotifier _instance = GuildWindowChangeNotifier._internal();

  GuildWindowChangeNotifier._internal();

  factory GuildWindowChangeNotifier() {
    return _instance;
  }

  setGuildWindowVisible(bool visible) {
    showGuildWindow = visible;
    notifyListeners();
  }

  getGuildWindowVisible() {
    return showGuildWindow;
  }
}
