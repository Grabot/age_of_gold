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
        // if (currentHexagon.center.x > (screen.left + 100)
        //     && currentHexagon.center.x < (screen.right - 200)
        //     && currentHexagon.center.y > (screen.top + 100)
        //     && currentHexagon.center.y < (screen.bottom - 100)) {
          currentHexagon.renderHexagon(canvas, variation);
        // }
      }
    }
  }

  // Debugging
  // Tile? hexagonTile = hexagonList.getTileFromCoordinates(q, r);
  // if (hexagonTile != null) {
  //   Hexagon? currentHexagon = hexagonTile.hexagon;
  //   final shapeBounds = Rect.fromLTRB(hexagonTile.getPos(0).x - 10, hexagonTile.getPos(0).y - 10, hexagonTile.getPos(0).x + 10, hexagonTile.getPos(0).y + 10);
  //   final paint = Paint()..color = Colors.blue;
  //   canvas.drawRect(shapeBounds, paint);
  //   if (currentHexagon != null) {
  //     final shapeBounds = Rect.fromLTRB(currentHexagon.center.x - 10, currentHexagon.center.y - 10, currentHexagon.center.x + 10, currentHexagon.center.y + 10);
  //     final paint = Paint()..color = Colors.red;
  //     canvas.drawRect(shapeBounds, paint);
  //   }
  // }
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

  List hexToRetrieve = [];
  List hexToRemove = [];
  if (q != hexagonList.currentQ) {
    int qDiff = (q - hexagonList.currentQ);
    if (qDiff >= tileOffset || qDiff <= -tileOffset) {

      int offsetTimes = (qDiff.abs() / tileOffset).floor();

      for (int i = 0; i < offsetTimes; i++) {
        List<List<Tile?>> newTiles = [];
        for (int i = 0; i < tileOffset; i++) {
          newTiles.add(List.filled(hexagonList.tiles.length, null, growable: true));
        }
        if (qDiff <= -tileOffset) {
          hexagonList.tiles.removeRange(hexagonList.tiles.length - (tileOffset + 1), hexagonList.tiles.length - 1);
          // We fill it with empty values first, once they are retrieved these entries are filled
          hexagonList.tiles.insertAll(0, newTiles);
        } else if (qDiff >= tileOffset) {
          hexagonList.tiles.removeRange(0, tileOffset);
          hexagonList.tiles.insertAll(hexagonList.tiles.length, newTiles);
        } else {
          print("something went wrong! q");
        }

        Tile? hexagonTile = hexagonList.getTileFromCoordinates(q, r);
        if (hexagonTile != null) {
          Hexagon? currentHexagon = hexagonTile.hexagon;
          if (currentHexagon != null) {
            int qDiffHex = currentHexagon.hexQArray - hexagonList.currentHexQ;
            int rDiffHex = currentHexagon.hexRArray - hexagonList.currentHexR;

            // We have already calculated the diff. We set the current Q and R for the new retrieved hexagons
            hexagonList.currentHexQ = currentHexagon.hexQArray;
            hexagonList.currentHexR = currentHexagon.hexRArray;

            List hexesR = checkRDiffHexagons(currentHexagon, rDiffHex, hexagonList, socketServices);
            hexToRetrieve.addAll(hexesR[0]);
            hexToRemove.addAll(hexesR[1]);
            List hexesQ = checkQDiffHexagons(currentHexagon, qDiffHex, hexagonList, socketServices);
            hexToRetrieve.addAll(hexesQ[0]);
            hexToRemove.addAll(hexesQ[1]);
          }
        }
      }
      hexagonList.currentQ = q;
      if (qDiff < 0) {
        hexagonList.qOffset = (qDiff.abs() % tileOffset) * -1;
      } else {
        hexagonList.qOffset = (qDiff % tileOffset);
      }
    } else {
      hexagonList.qOffset = qDiff;
    }
  }
  if (r != hexagonList.currentR) {
    int rDiff = (r - hexagonList.currentR);
    if (rDiff >= tileOffset || rDiff <= -tileOffset) {

      int offsetTimes = (rDiff.abs() / tileOffset).floor();

      for (int i = 0; i < offsetTimes; i++) {
        List<Tile?> newTiles = [];
        for (int i = 0; i < tileOffset; i++) {
          newTiles.add(null);
        }
        if (rDiff <= -tileOffset) {
          for (int i = 0; i < hexagonList.tiles.length; i++) {
            hexagonList.tiles[i].removeRange(hexagonList.tiles[i].length - (tileOffset + 1), hexagonList.tiles[i].length - 1);
            hexagonList.tiles[i].insertAll(0, newTiles);
          }
        } else if (rDiff >= tileOffset) {
          for (int i = 0; i < hexagonList.tiles.length; i++) {
            hexagonList.tiles[i].removeRange(0, tileOffset);
            hexagonList.tiles[i].insertAll(hexagonList.tiles[i].length - 1, newTiles);
          }
        } else {
          print("something went wrong! r");
        }

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

            List hexesR = checkRDiffHexagons(currentHexagon, rDiffHex, hexagonList, socketServices);
            hexToRetrieve.addAll(hexesR[0]);
            hexToRemove.addAll(hexesR[1]);
            List hexesQ = checkQDiffHexagons(currentHexagon, qDiffHex, hexagonList, socketServices);
            hexToRetrieve.addAll(hexesQ[0]);
            hexToRemove.addAll(hexesQ[1]);
          }
        }
        hexagonList.currentR = r;
        if (rDiff < 0) {
          hexagonList.rOffset = (rDiff.abs() % tileOffset) * -1;
        } else {
          hexagonList.rOffset = (rDiff % tileOffset);
        }
      }
    } else {
      hexagonList.rOffset = rDiff;
    }
  }
  // If coordinates were found to retrieve
  if (hexToRetrieve.isNotEmpty) {
    // Remove duplicates (using sets doesn't seem to work) TODO: make better?
    List hexToRetrieveUnique = [];
    for (int x = 0; x < hexToRetrieve.length; x++) {
      bool noRepeat = true;
      List value1 = hexToRetrieve[x];
      for (int y = x + 1; y < hexToRetrieve.length; y++) {
        List value2 = hexToRetrieve[y];
        if (value1[0] == value2[0] && value1[1] == value2[1]) {
          noRepeat = false;
          break;
        }
      }
      if (noRepeat) {
        hexToRetrieveUnique.add(value1);
      }
    }
    for (int x = 0; x < hexToRetrieveUnique.length; x++) {
      socketServices.getHexagon(hexToRetrieveUnique[x][0], hexToRetrieveUnique[x][1]);
    }
  }

  if (hexToRemove.isNotEmpty) {
    List hexToRemoveUnique = [];
    for (int x = 0; x < hexToRemove.length; x++) {
      bool noRepeat = true;
      List value1 = hexToRemove[x];
      for (int y = x + 1; y < hexToRemove.length; y++) {
        List value2 = hexToRemove[y];
        if (value1[0] == value2[0] && value1[1] == value2[1]) {
          noRepeat = false;
          break;
        }
      }
      if (noRepeat) {
        hexToRemoveUnique.add(value1);
      }
    }
    for (int x = 0; x < hexToRemoveUnique.length; x++) {
      socketServices.leaveHexRoom(hexToRemoveUnique[x][0], hexToRemoveUnique[x][1]);
    }
  }
}

List<List> checkRDiffHexagons(Hexagon currentHexagon, int rDiffHex, HexagonList hexagonList, SocketServices socketServices) {

  List rDiffHexagons = [];
  List rDiffOldHexagons = [];
  print("offsetting R $rDiffHex");
  if (rDiffHex > 0) {
    // The diff is positive
    for (int i = 0; i < rDiffHex; i++) {
      for (int i = 0; i < hexagonList.hexagons[0].length; i++) {
        hexagonList.hexagons[i].insert(hexagonList.hexagons[i].length, null);
        hexagonList.hexagons[i].removeAt(0);
      }
    }
    for (int i = rDiffHex-1; i >= 0; i--) {
      for (int qSock = 0; qSock < hexagonList.hexagons[0].length; qSock ++) {
        int qNew = qSock - hexagonList.hexQ + hexagonList.currentHexQ;
        int rNew = hexagonList.hexagons[0].length - 1 - hexagonList.hexR + hexagonList.currentHexR - i;
        rDiffHexagons.add([qNew, rNew]);

        rDiffOldHexagons.add([qNew, rNew - hexagonList.hexagons[0].length]);
      }
    }
  } else if (rDiffHex < 0) {
    for (int i = 0; i < rDiffHex * -1; i++) {
      for (int i = 0; i < hexagonList.hexagons[0].length; i++) {
        hexagonList.hexagons[i].removeAt(hexagonList.hexagons[i].length - 1);
        hexagonList.hexagons[i].insert(0, null);
      }
    }

    for (int i = rDiffHex * -1 - 1; i >= 0; i--) {
      // int rNew = 0 - tileR + hexagonList.currentHexR + i;
      for (int qSock = 0; qSock < hexagonList.hexagons[0].length; qSock ++) {
        int qNew = qSock - hexagonList.hexQ + hexagonList.currentHexQ;
        int rNew = 0 - hexagonList.hexR + hexagonList.currentHexR + i;
        rDiffHexagons.add([qNew, rNew]);

        rDiffOldHexagons.add([qNew, rNew + hexagonList.hexagons[0].length]);
      }
    }
  } else {
    print("R diff is 0");
  }
  return [rDiffHexagons, rDiffOldHexagons];
}

List<List> checkQDiffHexagons(Hexagon currentHexagon, int qDiffHex, HexagonList hexagonList, SocketServices socketServices) {

  List qDiffHexagons = [];
  List qDiffOldHexagons = [];
  print("offsetting Q $qDiffHex");
  if (qDiffHex > 0) {
    // The diff is positive
    for (int i = 0; i < qDiffHex; i++) {
      List<Hexagon?> row = List.filled(hexagonList.hexagons.length, null, growable: true);
      hexagonList.hexagons.removeAt(0);
      hexagonList.hexagons.insert(hexagonList.hexagons.length, row);
    }
    for (int i = 0; i < qDiffHex; i++ ) {
      for (int rSock = 0; rSock < hexagonList.hexagons.length; rSock ++) {
        int qNew = hexagonList.hexagons.length - 1 - hexagonList.hexQ + hexagonList.currentHexQ - i;
        int rNew = rSock - hexagonList.hexR + hexagonList.currentHexR;
        qDiffHexagons.add([qNew, rNew]);

        qDiffOldHexagons.add([qNew - hexagonList.hexagons.length, rNew]);
      }
    }
  } else if (qDiffHex < 0) {
    for (int i = 0; i < qDiffHex * -1; i++) {
      List<Hexagon?> row = List.filled(hexagonList.hexagons.length, null, growable: true);
      hexagonList.hexagons.insert(0, row);
      hexagonList.hexagons.removeAt(hexagonList.hexagons.length - 1);
    }
    for (int i = qDiffHex * -1 - 1; i >= 0; i--) {
      for (int rSock = 0; rSock < hexagonList.hexagons.length; rSock ++) {
        int qNew = 0 - hexagonList.hexQ + hexagonList.currentHexQ + i;
        int rNew = rSock - hexagonList.hexR + hexagonList.currentHexR;
        qDiffHexagons.add([qNew, rNew]);

        qDiffOldHexagons.add([qNew + hexagonList.hexagons.length, rNew]);
      }
    }
  } else {
    print("Q diff exactly 0");
  }
  return [qDiffHexagons, qDiffOldHexagons];
}
