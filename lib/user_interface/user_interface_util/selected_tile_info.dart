import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../component/tile.dart';
import '../../util/util.dart';


class SelectedTileInfo extends ChangeNotifier {
  Tile? selectedTile;

  static final SelectedTileInfo _instance = SelectedTileInfo._internal();

  SelectedTileInfo._internal();

  setCurrentTile(Tile? currentTile) {
    selectedTile = currentTile;
    notifyListeners();
  }

  factory SelectedTileInfo() {
    return _instance;
  }

  String getTileChangedBy() {
    if (selectedTile == null) {
      return "";
    } else {
      if (selectedTile!.lastChangedBy == null) {
        return "Tile untouched";
      } else {
        String lastChange = "Last changed by: ${selectedTile!.lastChangedBy}";

        if (selectedTile!.lastChangedTime != null) {
          String time = DateFormat('dd:MM:yyyy - HH:mm').format(selectedTile!.lastChangedTime!);
          lastChange += "\nat $time";
        }
        return lastChange;
      }
    }
  }

  String getTileType() {
    if (selectedTile != null) {
      return getTileColour(selectedTile!.tileType);
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