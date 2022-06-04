import 'dart:ui';
import 'package:age_of_gold/component/tile.dart';
import 'package:age_of_gold/util/hexagon_list.dart';
import 'package:age_of_gold/util/tapped_map.dart';
import 'package:flame/components.dart';

import '../component/hexagon.dart';

renderHexagons(Canvas canvas, Vector2 camera, HexagonList hexagonList, Rect screen, int rotate, int variation) {

  List<int> tileProperties = getTileFromPos(camera.x, camera.y, 0);
  int q = tileProperties[0];
  int r = tileProperties[1];
  int s = tileProperties[2];

  int qHalf = (hexagonList.tiles.length / 2).floor();
  int rHalf = (hexagonList.tiles.length / 2).floor();
  Tile? cameraTile = hexagonList.tiles[qHalf + q][rHalf + r];
  if (cameraTile != null) {
    Hexagon? cameraHexagon = cameraTile.hexagon;
    if (cameraHexagon != null) {
      cameraHexagon.renderHexagon(canvas, variation);
    }
  }
}
