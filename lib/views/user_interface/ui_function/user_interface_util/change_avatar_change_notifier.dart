import 'dart:typed_data';
import 'package:flutter/material.dart';


class ChangeAvatarChangeNotifier extends ChangeNotifier {

  Uint8List _imageData = Uint8List.fromList([]);
  bool showChangeAvatar = false;

  static final ChangeAvatarChangeNotifier _instance = ChangeAvatarChangeNotifier._internal();

  ChangeAvatarChangeNotifier._internal();

  factory ChangeAvatarChangeNotifier() {
    return _instance;
  }

  setChangeAvatarVisible(bool visible) {
    showChangeAvatar = visible;
    notifyListeners();
  }

  getChangeAvatarVisible() {
    return showChangeAvatar;
  }

  setAvatar(Uint8List imageData) {
    this._imageData = imageData;
  }

  Uint8List getAvatar() {
    return _imageData;
  }
}
