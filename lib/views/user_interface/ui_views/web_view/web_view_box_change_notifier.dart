import 'package:flutter/material.dart';


class WebViewBoxChangeNotifier extends ChangeNotifier {

  bool showWebViewBox = false;
  Uri webViewUrl = Uri.parse('about:blank');

  static final WebViewBoxChangeNotifier _instance = WebViewBoxChangeNotifier._internal();

  WebViewBoxChangeNotifier._internal();

  factory WebViewBoxChangeNotifier() {
    return _instance;
  }

  setWebViewBoxVisible(bool visible) {
    showWebViewBox = visible;
    notifyListeners();
  }

  getWebViewBoxVisible() {
    return showWebViewBox;
  }

  setWebViewBoxUrl(String newWebViewUrl) {
    webViewUrl = Uri.parse(newWebViewUrl);
    notifyListeners();
  }

  setWebViewBoxUri(Uri newWebViewUrl) {
    webViewUrl = newWebViewUrl;
    notifyListeners();
  }

  getWebViewBoxUrl() {
    return webViewUrl;
  }
}
