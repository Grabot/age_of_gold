import 'dart:ui';
import 'package:age_of_gold/component/tile.dart';
import 'package:age_of_gold/util/global.dart';
import 'package:age_of_gold/util/hexagon_list.dart';
import 'package:age_of_gold/util/tapped_map.dart';
import 'package:flame/components.dart';

import '../component/hexagon.dart';

renderHexagons(Canvas canvas, Vector2 camera, HexagonList hexagonList, Rect screen, int rotate, int variation) {

  List<int> tileProperties = getTileFromPos(camera.x, camera.y, 0);
  int q = tileProperties[0];
  int r = tileProperties[1];
  int s = tileProperties[2];
  if (q != hexagonList.currentQ) {
    int qDiff = (q - hexagonList.currentQ);
    if (qDiff == tileOffset || qDiff == -tileOffset) {
      List<List<Tile?>> newTiles = [];
      for (int i = 0; i < tileOffset; i++) {
        newTiles.add(List.filled(hexagonList.tiles.length, null, growable: true));
      }
      if (qDiff == -tileOffset) {
        hexagonList.tiles.removeRange(hexagonList.tiles.length - (tileOffset + 1), hexagonList.tiles.length - 1);
        // We fill it with empty values first, once they are retrieved these entries are filled
        hexagonList.tiles.insertAll(0, newTiles);
      } else if (qDiff == tileOffset) {
        hexagonList.tiles.removeRange(0, tileOffset);
        hexagonList.tiles.insertAll(hexagonList.tiles.length, newTiles);
      } else {
        print("something went wrong! q");
      }
      hexagonList.currentQ = q;
      hexagonList.qOffset = 0;
    } else {
      hexagonList.qOffset = qDiff;
    }
  }
  if (r != hexagonList.currentR) {
    int rDiff = (r - hexagonList.currentR);
    if (rDiff == tileOffset || rDiff == -tileOffset) {
      List<Tile?> newTiles = [];
      for (int i = 0; i < tileOffset; i++) {
        newTiles.add(null);
      }
      if (rDiff == -tileOffset) {
        for (int i = 0; i < hexagonList.tiles.length; i++) {
          hexagonList.tiles[i].removeRange(hexagonList.tiles[i].length - (tileOffset + 1), hexagonList.tiles[i].length - 1);
          hexagonList.tiles[i].insertAll(0, newTiles);
        }
      } else if (rDiff == tileOffset) {
        for (int i = 0; i < hexagonList.tiles.length; i++) {
          hexagonList.tiles[i].removeRange(0, tileOffset);
          hexagonList.tiles[i].insertAll(hexagonList.tiles[i].length - 1, newTiles);
        }
      } else {
        print("something went wrong! r");
      }
      hexagonList.currentR = r;
      hexagonList.rOffset = 0;
    } else {
      hexagonList.rOffset = rDiff;
    }
  }

  int qHalf = (hexagonList.tiles.length / 2).floor();
  int rHalf = (hexagonList.tiles.length / 2).floor();
  Tile? cameraTile = hexagonList.tiles[qHalf + hexagonList.qOffset][rHalf + hexagonList.rOffset];
  if (cameraTile != null) {
    Hexagon? cameraHexagon = cameraTile.hexagon;
    if (cameraHexagon != null) {
      cameraHexagon.renderHexagon(canvas, variation);
    }
  }
}
