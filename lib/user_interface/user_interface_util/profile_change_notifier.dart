import 'package:flutter/material.dart';


class ProfileChangeNotifier extends ChangeNotifier {

  bool showProfile = false;

  static final ProfileChangeNotifier _instance = ProfileChangeNotifier._internal();

  ProfileChangeNotifier._internal();

  factory ProfileChangeNotifier() {
    return _instance;
  }

  setProfileVisible(bool visible) {
    showProfile = visible;
    notifyListeners();
  }

  getProfileVisible() {
    return showProfile;
  }
}
