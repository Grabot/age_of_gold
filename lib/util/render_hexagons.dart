import 'dart:ui';
import 'package:age_of_gold/component/tile.dart';
import 'package:age_of_gold/util/hexagon_list.dart';
import 'package:age_of_gold/util/tapped_map.dart';
import 'package:flame/components.dart';

import '../component/hexagon.dart';
import 'package:matrix2d/matrix2d.dart';

renderHexagons(Canvas canvas, Vector2 camera, HexagonList hexagonList, Rect screen, int rotate, int variation) {

  List<int> tileProperties = getTileFromPos(camera.x, camera.y, 0);
  int q = tileProperties[0];
  int r = tileProperties[1];
  int s = tileProperties[2];
  if (q != hexagonList.currentQ) {
    int qDiff = (q - hexagonList.currentQ);
    print("qDiff: $qDiff");
    if (qDiff == 1 || qDiff == -1) {
      if (q - hexagonList.currentQ == -1) {
        hexagonList.tiles.removeAt(hexagonList.tiles.length - 1);
        // We fill it with empty values first, once they are retrieved these entries are filled
        hexagonList.tiles.insert(0, List.filled(hexagonList.tiles.length + 1, null, growable: true));
      } else if (q - hexagonList.currentQ == 1) {
        hexagonList.tiles.removeAt(0);
        hexagonList.tiles.insert(hexagonList.tiles.length, List.filled(hexagonList.tiles.length + 1, null, growable: true));
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
    print("rDiff: $rDiff");
    if (rDiff == 1 || rDiff == -1) {
      if (r - hexagonList.currentR == -1) {
        for (int i = 0; i < hexagonList.tiles.length; i++) {
          hexagonList.tiles[i].insert(0, null);
          hexagonList.tiles[i].removeAt(hexagonList.tiles[i].length - 1);
        }
      } else if (r - hexagonList.currentR == 1) {
        for (int i = 0; i < hexagonList.tiles.length; i++) {
          hexagonList.tiles[i].insert(hexagonList.tiles[i].length - 1, null);
          hexagonList.tiles[i].removeAt(0);
        }
      } else {
        print("something went wrong! r");
      }
      hexagonList.currentR = r;
      hexagonList.rOffset = 0;
    } else {
      hexagonList.rOffset = rDiff;
    }
    // print("current R: ${hexagonList.currentR}");
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
