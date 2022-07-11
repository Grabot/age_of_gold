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

  int qHalf = (hexagonList.tiles.length / 2).floor();
  int rHalf = (hexagonList.tiles.length / 2).floor();
  Tile? cameraTile = hexagonList.tiles[qHalf + hexagonList.qOffset][rHalf + hexagonList.rOffset];
    if (cameraTile != null) {
    Hexagon? cameraHexagon = cameraTile.hexagon;
    if (cameraHexagon != null) {
      Hexagon? currentHexagon = cameraHexagon;
      bool goingRight = true;
      // To draw in possibly isometric we draw from top down.
      // First we go to the top.
      // double currentX = cameraHexagon.getPos(0).x;
      double currentY = cameraHexagon.getPos(0).y;
      while (currentY > screen.top) {
        if (currentHexagon != null) {
          currentY = currentHexagon.getPos(0).y;
          if (goingRight) {
            currentHexagon = currentHexagon.topRight;
            goingRight = false;
          } else {
            currentHexagon = currentHexagon.topLeft;
            goingRight = true;
          }
        } else {
          break;
        }
      }
      if (currentHexagon != null) {
        currentHexagon.renderHexagon(canvas, variation);
        goingRight = true;
      }
      // We draw all the way back down for the possible isometric stuff.
      while (currentY < screen.bottom) {
        if (currentHexagon != null) {
          currentHexagon.renderHexagon(canvas, variation);
          // Draw left and draw right
          drawLeft(canvas, variation, currentHexagon, screen);
          drawRight(canvas, variation, currentHexagon, screen);
          currentY = currentHexagon.getPos(0).y;
          if (goingRight) {
            currentHexagon = currentHexagon.bottomRight;
            goingRight = false;
          } else {
            currentHexagon = currentHexagon.bottomLeft;
            goingRight = true;
          }
        } else {
          break;
        }
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
}