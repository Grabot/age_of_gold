import 'package:flutter/material.dart';


class MapCoordinatesWindowChangeNotifier extends ChangeNotifier {

  bool showMapCoordinatesWindow = false;

  static final MapCoordinatesWindowChangeNotifier _instance = MapCoordinatesWindowChangeNotifier._internal();

  MapCoordinatesWindowChangeNotifier._internal();

  factory MapCoordinatesWindowChangeNotifier() {
    return _instance;
  }

  setMapCoordinatesVisible(bool visible) {
    showMapCoordinatesWindow = visible;
    notifyListeners();
  }

  notify() {
    notifyListeners();
  }

  getMapCoordinatesVisible() {
    return showMapCoordinatesWindow;
  }
}
