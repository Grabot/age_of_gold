import 'package:flutter/material.dart';


class LoadingBoxChangeNotifier extends ChangeNotifier {

  bool showLoading = false;
  bool withBlackout = false;

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

  setWithBlackout(bool visible) {
    withBlackout = visible;
    notifyListeners();
  }

  getWithBlackout() {
    return withBlackout;
  }
}
