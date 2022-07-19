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

  checkOffset(q, r, hexagonList);

  for (int top = 0; top < hexagonList.hexagons.length - 1; top++) {
    Hexagon? currentHexagon;
    for (int right = hexagonList.hexagons.length - 1; right >= 0; right--) {
      currentHexagon = hexagonList.hexagons[right][top];
      if (currentHexagon != null) {
        // if (currentHexagon.center.x > (screen.left + 100)
        //     && currentHexagon.center.x < (screen.right - 200)
        //     && currentHexagon.center.y > (screen.top + 100)
        //     && currentHexagon.center.y < (screen.bottom - 100)) {
          currentHexagon.renderHexagon(canvas, variation);
        // }
      }
    }
  }
}

drawLeft(Canvas canvas, int variation, Hexagon currentHexagon, Rect screen) {
  double currentLeft = currentHexagon.getPos(0).x;
  Hexagon? goingLeft = currentHexagon;
  while (currentLeft > screen.left) {
    if (goingLeft != null) {
      goingLeft.renderHexagon(canvas, variation);
      currentLeft = goingLeft.getPos(0).x;
      goingLeft = goingLeft.left;
    } else {
      break;
    }
  }
}

drawRight(Canvas canvas, int variation, Hexagon currentHexagon, Rect screen) {
  double currentRight = currentHexagon.getPos(0).x;
  Hexagon? goingRight = currentHexagon;
  while (currentRight < screen.right) {
    if (goingRight != null) {
      goingRight.renderHexagon(canvas, variation);
      currentRight = goingRight.getPos(0).x;
      goingRight = goingRight.right;
    } else {
      break;
    }
  }
}

checkOffset(int q, int r, HexagonList hexagonList) {
  // The large hexagons have a q and r defined from -4 to 4, so 9 large
  // with and height (it will look wider because the tiles are flattened
  // for possible isometric graphics). 9 is defined in `tileOffset`
  if (q != hexagonList.currentQ) {
    int qDiff = (q - hexagonList.currentQ);
    // TODO: multiples of tileOffset?
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

      // Offset hexagonlist with 1 (or 2) q
      int tileQ = (hexagonList.tiles.length / 2).ceil();
      int tileR = (hexagonList.tiles[0].length / 2).ceil();
      // We also check the r offset, for the q the offset is 0
      Tile? hexagonTile = hexagonList.tiles[tileQ + q][tileR + r + hexagonList.rOffset];
      if (hexagonTile != null) {
        Hexagon? currentHexagon = hexagonTile.hexagon;
        if (currentHexagon != null) {
          int qDiffHex = currentHexagon.hexQArray - hexagonList.currentHexQ;
          int rDiffHex = currentHexagon.hexRArray - hexagonList.currentHexR;
          List<Hexagon?> newHexagons = List.filled(hexagonList.hexagons.length, null, growable: true);
          print("offsetting Q");
          if (qDiffHex == 2) {
            print("offsetting Q 2");
            hexagonList.hexagons.removeAt(0);
            hexagonList.hexagons.removeAt(0);
            hexagonList.hexagons.insert(hexagonList.hexagons.length, newHexagons);
            hexagonList.hexagons.insert(hexagonList.hexagons.length, newHexagons);
          } else if (qDiffHex == -2) {
            print("offsetting Q -2");
            hexagonList.hexagons.removeAt(hexagonList.hexagons.length - 1);
            hexagonList.hexagons.removeAt(hexagonList.hexagons.length - 1);
            hexagonList.hexagons.insert(0, newHexagons);
            hexagonList.hexagons.insert(0, newHexagons);
          }

          hexagonList.currentHexQ = currentHexagon.hexQArray;
          hexagonList.qHexOffset = 0;
        }
      }
      // // TODO: The tiles and hexagons are different! Find a conversion thing or check the hexagon from the tile.
      // List<Hexagon?> newHexagons = List.filled(hexagonList.hexagons.length, null, growable: true);
      // if (qDiff == -tileOffset) {
      //   hexagonList.hexagons.removeAt(hexagonList.hexagons.length - 1);
      //   // We fill it with empty value first, once they are retrieved these entries are filled
      //   hexagonList.hexagons.insert(0, newHexagons);
      // } else if (qDiff == tileOffset) {
      //   hexagonList.hexagons.removeAt(0);
      //   hexagonList.hexagons.insert(hexagonList.hexagons.length, newHexagons);
      // }
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

      // // Offset hexagonlist with 1 r
      // print("offsetting R");
      // // Offset hexagonlist with 1 (or 2) r
      // int tileQ = (hexagonList.tiles.length / 2).ceil();
      // int tileR = (hexagonList.tiles[0].length / 2).ceil();
      // // We also check the r offset, for the r the offset is 0
      // Tile? hexagonTile = hexagonList.tiles[tileQ + q + hexagonList.qHexOffset][tileR + r];
      // if (hexagonTile != null) {
      //   Hexagon? currentHexagon = hexagonTile.hexagon;
      //   if (currentHexagon != null) {
      //     int qDiffHex = hexagonList.currentHexQ + currentHexagon.hexQArray;
      //     int rDiffHex = hexagonList.currentHexR + currentHexagon.hexRArray;
      //     if (rDiffHex == -1) {
      //       for (int i = 0; i < hexagonList.hexagons.length; i++) {
      //         hexagonList.hexagons[i].removeAt(0);
      //         hexagonList.hexagons[i].insert(hexagonList.hexagons[i].length - 1, null);
      //       }
      //     }
      //     else if (rDiffHex == -2) {
      //       for (int i = 0; i < hexagonList.hexagons.length; i++) {
      //         hexagonList.hexagons[i].removeAt(0);
      //         hexagonList.hexagons[i].removeAt(0);
      //         hexagonList.hexagons[i].insert(hexagonList.hexagons[i].length - 1, null);
      //         hexagonList.hexagons[i].insert(hexagonList.hexagons[i].length - 1, null);
      //       }
      //     }
      //     else if (rDiff == 1) {
      //       for (int i = 0; i < hexagonList.hexagons.length; i++) {
      //         hexagonList.hexagons[i].removeAt(hexagonList.hexagons[i].length - 1);
      //         hexagonList.hexagons[i].insert(0, null);
      //       }
      //     } else if (rDiff == 2) {
      //       for (int i = 0; i < hexagonList.hexagons.length; i++) {
      //         hexagonList.hexagons[i].removeAt(hexagonList.hexagons[i].length - 1);
      //         hexagonList.hexagons[i].removeAt(hexagonList.hexagons[i].length - 1);
      //         hexagonList.hexagons[i].insert(0, null);
      //         hexagonList.hexagons[i].insert(0, null);
      //       }
      //     }
      //   }
      // }
      // if (rDiff == -tileOffset) {
      //   // TODO: It seemed to be good once it's done the other way around from the tiles? Is the tiles wrong? Check this!
      //   for (int i = 0; i < hexagonList.hexagons.length; i++) {
      //     hexagonList.hexagons[i].removeAt(0);
      //     hexagonList.hexagons[i].insert(hexagonList.hexagons[i].length - 1, null);
      //   }
      // } else if (rDiff == tileOffset) {
      //   for (int i = 0; i < hexagonList.hexagons.length; i++) {
      //     hexagonList.hexagons[i].removeAt(hexagonList.hexagons[i].length - 1);
      //     hexagonList.hexagons[i].insert(0, null);
      //   }
      // }
    } else {
      hexagonList.rOffset = rDiff;
    }
  }
}