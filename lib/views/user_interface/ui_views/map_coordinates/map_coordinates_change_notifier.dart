import 'package:flutter/material.dart';


class MapCoordinatesChangeNotifier extends ChangeNotifier {

  int qCoordinate = 0;
  int rCoordinate = 0;

  static final MapCoordinatesChangeNotifier _instance = MapCoordinatesChangeNotifier._internal();

  MapCoordinatesChangeNotifier._internal();

  factory MapCoordinatesChangeNotifier() {
    return _instance;
  }

  setCoordinates(List<int> coordinates) {
    qCoordinate = coordinates[0];
    rCoordinate = coordinates[1];
    notifyListeners();
  }

  List<int> getCoordinates() {
    return [qCoordinate, rCoordinate];
  }
}
