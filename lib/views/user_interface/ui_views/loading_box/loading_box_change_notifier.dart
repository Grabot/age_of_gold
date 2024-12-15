import 'package:flutter/material.dart';


class LoadingBoxChangeNotifier extends ChangeNotifier {

  bool showLoading = false;

  static final LoadingBoxChangeNotifier _instance = LoadingBoxChangeNotifier._internal();

  LoadingBoxChangeNotifier._internal();

  factory LoadingBoxChangeNotifier() {
    return _instance;
  }

  setLoadingBoxVisible(bool visible) {
    showLoading = visible;
    notifyListeners();
  }

  getLoadingBoxVisible() {
    return showLoading;
  }
}
