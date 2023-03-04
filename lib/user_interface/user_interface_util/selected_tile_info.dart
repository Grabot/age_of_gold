import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../component/tile.dart';


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
      if (selectedTile!.tileType == 0) {
        return "Amethyst";
      } else if (selectedTile!.tileType == 1) {
        return "Black";
      } else if (selectedTile!.tileType == 2) {
        return "Bondi Blue";
      } else if (selectedTile!.tileType == 3) {
        return "Bright Sun";
      } else if (selectedTile!.tileType == 4) {
        return "Caribbean Green";
      } else if (selectedTile!.tileType == 5) {
        return "Cerulean Blue";
      } else if (selectedTile!.tileType == 6) {
        return "Conifer";
      } else if (selectedTile!.tileType == 7) {
        return "Cornflower Blue";
      } else if (selectedTile!.tileType == 8) {
        return "Governor Bay";
      } else if (selectedTile!.tileType == 9) {
        return "Green Haze";
      } else if (selectedTile!.tileType == 10) {
        return "Iron";
      } else if (selectedTile!.tileType == 11) {
        return "Monza";
      } else if (selectedTile!.tileType == 12) {
        return "Oslo Gray";
      } else if (selectedTile!.tileType == 13) {
        return "Paarl";
      } else if (selectedTile!.tileType == 14) {
        return "Picton Blue";
      } else if (selectedTile!.tileType == 15) {
        return "Pine Green";
      } else if (selectedTile!.tileType == 16) {
        return "Pink Salmon";
      } else if (selectedTile!.tileType == 17) {
        return "Seance";
      } else if (selectedTile!.tileType == 18) {
        return "Spice";
      } else if (selectedTile!.tileType == 19) {
        return "Spray";
      } else if (selectedTile!.tileType == 20) {
        return "Vermillion";
      } else if (selectedTile!.tileType == 21) {
        return "Web Orange";
      } else if (selectedTile!.tileType == 22) {
        return "White";
      } else if (selectedTile!.tileType == 23) {
        return "Wild Strawberry";
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