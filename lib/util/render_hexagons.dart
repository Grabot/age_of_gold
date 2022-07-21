import 'dart:ui';
import 'package:age_of_gold/component/tile.dart';
import 'package:age_of_gold/util/global.dart';
import 'package:age_of_gold/util/hexagon_list.dart';
import 'package:age_of_gold/util/socket_services.dart';
import 'package:age_of_gold/util/tapped_map.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../component/hexagon.dart';

renderHexagons(Canvas canvas, Vector2 camera, HexagonList hexagonList, Rect screen, int rotate, int variation, SocketServices socketServices) {

  List<int> tileProperties = getTileFromPos(camera.x, camera.y, 0);
  int q = tileProperties[0];
  int r = tileProperties[1];
  int s = tileProperties[2];

  checkOffset(q, r, hexagonList, socketServices);

  for (int top = 0; top <= hexagonList.hexagons.length - 1; top++) {
    Hexagon? currentHexagon;
    for (int right = hexagonList.hexagons.length - 1; right >= 0; right--) {
      currentHexagon = hexagonList.hexagons[right][top];
      if (currentHexagon != null) {
        if (currentHexagon.center.x > (screen.left + 100)
            && currentHexagon.center.x < (screen.right - 200)
            && currentHexagon.center.y > (screen.top + 100)
            && currentHexagon.center.y < (screen.bottom - 100)) {
          currentHexagon.renderHexagon(canvas, variation);
        }
      }
    }
  }

  Tile? hexagonTile = hexagonList.getTileFromCoordinates(q, r);
  if (hexagonTile != null) {
    Hexagon? currentHexagon = hexagonTile.hexagon;
    final shapeBounds = Rect.fromLTRB(hexagonTile.getPos(0).x - 10, hexagonTile.getPos(0).y - 10, hexagonTile.getPos(0).x + 10, hexagonTile.getPos(0).y + 10);
    final paint = Paint()..color = Colors.blue;
    canvas.drawRect(shapeBounds, paint);
    if (currentHexagon != null) {
      final shapeBounds = Rect.fromLTRB(currentHexagon.center.x - 10, currentHexagon.center.y - 10, currentHexagon.center.x + 10, currentHexagon.center.y + 10);
      final paint = Paint()..color = Colors.red;
      canvas.drawRect(shapeBounds, paint);
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

checkOffset(int q, int r, HexagonList hexagonList, SocketServices socketServices) {
  // The large hexagons have a q and r defined from -4 to 4, so 9 large
  // with and height (it will look wider because the tiles are flattened
  // for possible isometric graphics). 9 is defined in `tileOffset`

  bool hexagonOffsetDone = false;

  if (q != hexagonList.currentQ) {
    int qDiff = (q - hexagonList.currentQ);
    // TODO: multiples of tileOffset?
    if (qDiff == tileOffset || qDiff == -tileOffset) {
      print("qdiff $qDiff  with ${socketServices.hexagonsToRetrieve} still remaining");
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

      if (socketServices.canRetrieveHexagons()) {
        Tile? hexagonTile = hexagonList.getTileFromCoordinates(q, r);
        if (hexagonTile != null) {
          Hexagon? currentHexagon = hexagonTile.hexagon;
          if (currentHexagon != null) {
            int qDiffHex = currentHexagon.hexQArray - hexagonList.currentHexQ;
            int rDiffHex = currentHexagon.hexRArray - hexagonList.currentHexR;

            // We have already calculated the diff. We set the current Q and R for the new retrieved hexagons
            hexagonList.currentHexQ = currentHexagon.hexQArray;
            hexagonList.currentHexR = currentHexagon.hexRArray;

            checkRDiffHexagons(currentHexagon, rDiffHex, hexagonList, socketServices);
            checkQDiffHexagons(currentHexagon, qDiffHex, hexagonList, socketServices);
            hexagonOffsetDone = true;
          }
        }
      }
    } else {
      hexagonList.qOffset = qDiff;
    }
  }
  if (r != hexagonList.currentR) {
    int rDiff = (r - hexagonList.currentR);
    if (rDiff == tileOffset || rDiff == -tileOffset) {
      print("rDiff $rDiff  with ${socketServices.hexagonsToRetrieve} still remaining");
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

      if (socketServices.canRetrieveHexagons()) {
        if (!hexagonOffsetDone) {
          Tile? hexagonTile = hexagonList.getTileFromCoordinates(q, r);
          // Tile? hexagonTile = hexagonList.tiles[tileQ + q + hexagonList.qOffset][tileR + r + hexagonList.rOffset];
          if (hexagonTile != null) {
            Hexagon? currentHexagon = hexagonTile.hexagon;
            if (currentHexagon != null) {
              int qDiffHex = currentHexagon.hexQArray - hexagonList.currentHexQ;
              int rDiffHex = currentHexagon.hexRArray - hexagonList.currentHexR;

              // We have already calculated the diff. We set the current Q and R for the new retrieved hexagons
              hexagonList.currentHexQ = currentHexagon.hexQArray;
              hexagonList.currentHexR = currentHexagon.hexRArray;

              checkRDiffHexagons(currentHexagon, rDiffHex, hexagonList, socketServices);
              checkQDiffHexagons(currentHexagon, qDiffHex, hexagonList, socketServices);
            }
          }
        }
      }
    } else {
      hexagonList.rOffset = rDiff;
    }
  }
}

checkRDiffHexagons(Hexagon currentHexagon, int rDiffHex, HexagonList hexagonList, SocketServices socketServices) {
  int tileQ = (hexagonList.hexagons.length / 2).ceil();
  int tileR = (hexagonList.hexagons[0].length / 2).ceil();

  print("offsetting R $rDiffHex");
  if (rDiffHex > 0) {
    print("getting positive offset r, current hexagons to retrieve: ${socketServices.hexagonsToRetrieve}");
    // The diff is positive
    for (int i = 0; i < rDiffHex; i++) {
      for (int i = 0; i < hexagonList.hexagons[0].length; i++) {
        hexagonList.hexagons[i].insert(hexagonList.hexagons[i].length, null);
        hexagonList.hexagons[i].removeAt(0);
      }
    }
    for (int i = 0; i < rDiffHex; i++) {
      int rNew = hexagonList.hexagons[0].length - 1 - tileR + hexagonList.currentHexR - i;
      int qBegin = 0 - tileQ + hexagonList.currentHexQ;
      int qEnd = hexagonList.hexagons[0].length - 1 - tileQ + hexagonList.currentHexQ;

      socketServices.getHexagonsQ(qBegin, qEnd, rNew);
    }
  } else if (rDiffHex < 0) {
    print("getting negative offset r, current hexagons to retrieve: ${socketServices.hexagonsToRetrieve}");
    for (int i = 0; i < rDiffHex * -1; i++) {
      for (int i = 0; i < hexagonList.hexagons[0].length; i++) {
        hexagonList.hexagons[i].removeAt(hexagonList.hexagons[i].length - 1);
        hexagonList.hexagons[i].insert(0, null);
      }
    }

    for (int i = 0; i < rDiffHex * -1; i++) {
      int rNew = 0 - tileR + hexagonList.currentHexR + i;
      int qBegin = 0 - tileQ + hexagonList.currentHexQ;
      int qEnd = hexagonList.hexagons[0].length - 1 - tileQ + hexagonList.currentHexQ;

      socketServices.getHexagonsQ(qBegin, qEnd, rNew);
    }
  } else {
    print("R diff is 0");
  }
}

checkQDiffHexagons(Hexagon currentHexagon, int qDiffHex, HexagonList hexagonList, SocketServices socketServices) {
  int tileQ = (hexagonList.hexagons.length / 2).ceil();
  int tileR = (hexagonList.hexagons[0].length / 2).ceil();

  print("offsetting Q $qDiffHex");
  if (qDiffHex > 0) {
    print("getting positive offset q, current hexagons to retrieve: ${socketServices.hexagonsToRetrieve}");
    // The diff is positive
    for (int i = 0; i < qDiffHex; i++) {
      List<Hexagon?> row = List.filled(hexagonList.hexagons.length, null, growable: true);
      hexagonList.hexagons.removeAt(0);
      hexagonList.hexagons.insert(hexagonList.hexagons.length, row);
    }
    for (int i = 0; i < qDiffHex; i++ ) {
      int qNew = hexagonList.hexagons.length - 1 - tileQ + hexagonList.currentHexQ - i;
      int rBegin = 0 - tileR + hexagonList.currentHexR;
      int rEnd = hexagonList.hexagons.length - 1 - tileR + hexagonList.currentHexR;

      socketServices.getHexagonsR(rBegin, rEnd, qNew);
    }
  } else if (qDiffHex < 0) {
    print("getting negative offset q, current hexagons to retrieve: ${socketServices.hexagonsToRetrieve}");
    for (int i = 0; i < qDiffHex * -1; i++) {
      List<Hexagon?> row = List.filled(hexagonList.hexagons.length, null, growable: true);
      hexagonList.hexagons.insert(0, row);
      hexagonList.hexagons.removeAt(hexagonList.hexagons.length - 1);
    }
    for (int i = 0; i < qDiffHex * -1; i++) {
      int qNew = 0 - tileQ + hexagonList.currentHexQ + i;
      int rBegin = 0 - tileR + hexagonList.currentHexR;
      int rEnd = hexagonList.hexagons.length - 1 - tileR + hexagonList.currentHexR;

      socketServices.getHexagonsR(rBegin, rEnd, qNew);
    }
  } else {
    print("Q diff exactly 0");
  }
}
