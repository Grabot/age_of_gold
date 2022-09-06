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

  String getTileType() {
    if (selectedTile != null) {
      if (selectedTile!.tileType == 0) {
        return "Grass";
      } else if (selectedTile!.tileType == 1) {
        return "Water";
      } else if (selectedTile!.tileType == 2) {
        return "Dirt";
      } else {
        return "Type unknown";
      }
    } else {
      return "";
    }
  }

  String tileInfo() {
    if (selectedTile != null) {
      return "q: ${selectedTile!.tileQ} r: ${selectedTile!.tileR}";
    } else {
      return "no tile selected";
    }
  }
}