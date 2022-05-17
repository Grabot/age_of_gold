import 'dart:ui';
import 'package:age_of_gold/component/tile.dart';
import 'package:age_of_gold/util/hexagon_list.dart';
import 'package:flame/components.dart';

renderHexagons(Canvas canvas, Vector2 camera, HexagonList hexagonList, Rect screen, int rotate, int variation) {

  int q = 0;
  int r = 0;
  int s = 0;

  int qArray = q + (hexagonList.tiles.length / 2).ceil();
  int rArray = r + (hexagonList.tiles[0].length / 2).ceil();
  if (qArray >= 0 && qArray < hexagonList.tiles.length && rArray >= 0 &&
      rArray < hexagonList.tiles[0].length) {
    Tile? cameraTile = hexagonList.tiles[qArray][rArray];
    // We assume there will be a tile in the center of the screen
    // But it's possible the tile is not linked to a hexagon.
    if (cameraTile != null && cameraTile.hexagon != null) {
      // drawField(hexagonList, cameraTile.hexagon!.hexQArray,
      //     cameraTile.hexagon!.hexRArray, screen, canvas, variation);
      // TODO: move back
      cameraTile.hexagon!.renderHexagon(canvas, variation);
    }
  }
}
