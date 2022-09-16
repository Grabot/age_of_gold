import 'dart:ui';
import 'package:age_of_gold/component/tile.dart';
import 'package:age_of_gold/util/global.dart';
import 'package:age_of_gold/util/hexagon_list.dart';
import 'package:age_of_gold/util/socket_services.dart';
import 'package:age_of_gold/util/tapped_map.dart';
import 'package:age_of_gold/util/util.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../component/hexagon.dart';

renderHexagons(Canvas canvas, Vector2 camera, HexagonList hexagonList, Rect screen, int variation, SocketServices socketServices) {

  List<int> tileProperties = getTileFromPos(camera.x, camera.y);
  int q = tileProperties[0];
  int r = tileProperties[1];

  // First we check the offset to determine if we adjust the hex array
  checkOffset(q, r, hexagonList, socketServices);

  // Then we draw the hexes, but only the ones that are visible.
  // We also check if they are retrieved yet, if not, we retrieve them.
  for (int top = 0; top <= hexagonList.hexagons.length - 1; top++) {
    Hexagon? currentHexagon;
    for (int right = hexagonList.hexagons.length - 1; right >= 0; right--) {
      currentHexagon = hexagonList.hexagons[right][top];
      if (currentHexagon != null) {
        if (currentHexagon.center.x > screen.left
            && currentHexagon.center.x < screen.right
            && currentHexagon.center.y > screen.top
            && currentHexagon.center.y < screen.bottom) {
          // The hexagon is visible, so draw it.
          currentHexagon.renderHexagon(canvas, variation);

          if (!currentHexagon.setToRetrieve && !currentHexagon.retrieved) {
            // The hexagon has not been retrieved yet and
            // not flagged to be retrieved.
            // We will send out the socket call and flag it as retrieved
            socketServices.actuallyGetHexagons(currentHexagon);
          }
          if (!currentHexagon.visible) {
            // The hex was flagged as not visible, so it has entered the view
            // Set the flag accordingly and join the hex room.
            currentHexagon.visible = true;
            socketServices.joinHexRoom(currentHexagon);
          }
        } else {
          // The hex is not visible.
          if (currentHexagon.visible) {
            // The hex is still flagged as visible so it has just left the view
            // Set the flag accordingly and leave the hex socket room.
            currentHexagon.visible = false;
            socketServices.leaveHexRoom(currentHexagon);
          }
        }
      }
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

  List hexToRetrieveUnique = removeDuplicates(hexToRetrieve);
  for (int x = 0; x < hexToRetrieveUnique.length; x++) {
    socketServices.getHexagon(hexToRetrieveUnique[x][0], hexToRetrieveUnique[x][1]);
  }

  // TODO: Leave hex room done differently, can this be removed?
  List hexToRemoveUnique = removeDuplicates(hexToRemove);
  for (int x = 0; x < hexToRemoveUnique.length; x++) {
    // socketServices.leaveHexRoom(hexToRemoveUnique[x][0], hexToRemoveUnique[x][1]);
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
