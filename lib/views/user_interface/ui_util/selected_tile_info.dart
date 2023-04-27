import 'dart:typed_data';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../component/tile.dart';
import '../../../util/util.dart';


class SelectedTileInfo extends ChangeNotifier {
  Tile? selectedTile;
  String? lastChangedBy;
  DateTime? lastChangedTime;
  Uint8List? userChangedAvatar;
  Vector2? tapPos;

  static final SelectedTileInfo _instance = SelectedTileInfo._internal();

  SelectedTileInfo._internal();

  setCurrentTile(Tile? currentTile) {
    selectedTile = currentTile;
  }

  factory SelectedTileInfo() {
    return _instance;
  }

  setTapPos(Vector2 tapPos) {
    this.tapPos = tapPos;
  }

  Vector2? getTapPos() {
    return tapPos;
  }

  String? getLastChangedBy() {
    return lastChangedBy;
  }

  setLastChangedBy(String lastChangedBy) {
    this.lastChangedBy = lastChangedBy;
  }

  DateTime? getLastChangedTime() {
    return lastChangedTime;
  }

  setLastChangedTime(DateTime lastChangedTime) {
    this.lastChangedTime = lastChangedTime;
  }

  setLastChangedByAvatar(Uint8List userChangedAvatar) {
    this.userChangedAvatar = userChangedAvatar;
  }

  Uint8List? getLastChangedByAvatar() {
    return userChangedAvatar;
  }

  untouched() {
    lastChangedBy = null;
    lastChangedTime = null;
    userChangedAvatar = null;
  }

  String? getTileChangedBy() {
    if (selectedTile == null) {
      return null;
    } else {
      if (lastChangedBy == null) {
        return null;
      } else {
        return lastChangedBy;
      }
    }
  }

  String? getChangedAt() {
    if (selectedTile == null) {
      return null;
    } else {
      if (lastChangedBy == null) {
        return null;
      } else {
        if (lastChangedTime != null) {
          String time = DateFormat('dd:MM:yyyy - HH:mm').format(
              lastChangedTime!);
          return "at $time";
        } else {
          return null;
        }
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