import 'package:age_of_gold/user_interface/user_interface_components/message.dart';
import 'package:flutter/material.dart';

import '../component/tile.dart';

class SelectedTileInfo extends ChangeNotifier {
  Tile? selectedTile;

  static final SelectedTileInfo _instance = SelectedTileInfo._internal();

  SelectedTileInfo._internal();

  setCurrentTile(Tile currentTile) {
    selectedTile = currentTile;
    notifyListeners();
  }

  factory SelectedTileInfo() {
    return _instance;
  }

  String tileInfo() {
    if (selectedTile != null) {
      return "q: ${selectedTile!.q} r: ${selectedTile!.r}";
    } else {
      return "no tile selected";
    }
  }
}