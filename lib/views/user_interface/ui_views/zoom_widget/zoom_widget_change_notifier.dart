import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';


class ZoomWidgetChangeNotifier extends ChangeNotifier {

  bool showZoomWidget = false;
  double zoomValue = 1;

  double maxZoom = 2;
  double minZoom = 0.2;

  static final ZoomWidgetChangeNotifier _instance = ZoomWidgetChangeNotifier._internal();

  ZoomWidgetChangeNotifier._internal() {
    if (!kIsWeb) {
      minZoom = 0.08;
    }
  }

  factory ZoomWidgetChangeNotifier() {
    return _instance;
  }

  setZoomWidgetVisible(bool visible) {
    showZoomWidget = visible;
    notifyListeners();
  }

  getZoomWidgetVisible() {
    return showZoomWidget;
  }

  setZoomValue(double newValue) {
    zoomValue = newValue;
  }

  getZoomValue() {
    return zoomValue;
  }

  notify() {
    notifyListeners();
  }
}
