import 'package:flutter/material.dart';


class AreYouSureBoxChangeNotifier extends ChangeNotifier {

  bool showAreYouSure = false;

  // this controls what kind of are you sure box is shown
  bool showLeaveGuild = false;
  bool showLogout = false;

  int? userId;
  int? guildId;

  static final AreYouSureBoxChangeNotifier _instance = AreYouSureBoxChangeNotifier._internal();

  AreYouSureBoxChangeNotifier._internal();

  factory AreYouSureBoxChangeNotifier() {
    return _instance;
  }

  setAreYouSureBoxVisible(bool visible) {
    showAreYouSure = visible;
    notifyListeners();
  }

  getAreYouSureBoxVisible() {
    return showAreYouSure;
  }

  setShowLeaveGuild(bool showLeaveGuild) {
    this.showLeaveGuild = showLeaveGuild;
  }

  getShowLeaveGuild() {
    return showLeaveGuild;
  }

  setShowLogout(bool showLogout) {
    this.showLogout = showLogout;
  }

  getShowLogout() {
    return showLogout;
  }

  setUserId(int? userId) {
    this.userId = userId;
  }

  int? getUserId() {
    return userId;
  }

  setGuildId(int? guildId) {
    this.guildId = guildId;
  }

  int? getGuildId() {
    return guildId;
  }
}
