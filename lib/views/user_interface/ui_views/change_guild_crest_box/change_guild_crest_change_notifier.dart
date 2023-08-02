import 'dart:typed_data';
import 'package:flutter/material.dart';


class ChangeGuildCrestChangeNotifier extends ChangeNotifier {

  Uint8List? imageData;
  bool showChangeGuildCrest = false;
  bool isDefault = false;

  bool createCrest = false;

  static final ChangeGuildCrestChangeNotifier _instance = ChangeGuildCrestChangeNotifier._internal();

  ChangeGuildCrestChangeNotifier._internal();

  factory ChangeGuildCrestChangeNotifier() {
    return _instance;
  }

  setChangeGuildCrestVisible(bool visible) {
    showChangeGuildCrest = visible;
    notifyListeners();
  }

  getChangeGuildCrestVisible() {
    return showChangeGuildCrest;
  }

  setGuildCrest(Uint8List? imageData) {
    this.imageData = imageData;
  }

  Uint8List? getGuildCrest() {
    return imageData;
  }

  setDefault(bool isDefault) {
    this.isDefault = isDefault;
  }

  getDefault() {
    return isDefault;
  }

  setCreateCrest(bool createCrest) {
    this.createCrest = createCrest;
  }

  bool getCreateCrest() {
    return createCrest;
  }
}
