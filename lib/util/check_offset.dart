import 'package:age_of_gold/util/socket_services.dart';
import 'package:age_of_gold/util/tapped_map.dart';
import 'package:age_of_gold/util/util.dart';
import 'package:flame/components.dart';
import '../component/hexagon.dart';
import '../component/tile.dart';
import 'global.dart';
import 'hexagon_list.dart';


offsetMap(int q, int r, HexagonList hexagonList, SocketServices socketServices) {

  Tile? cameraTile = hexagonList.getTileFromCoordinates(q, r);

  if (cameraTile != null) {
    Hexagon? cameraHexagon = cameraTile.hexagon;
    if (cameraHexagon != null) {
      checkOffset(q, r, cameraHexagon, hexagonList, socketServices);
    }
  }

  // Check the tile array
  if (q != hexagonList.currentQ) {
    setTilesQ(q, hexagonList);
  }
  if (r != hexagonList.currentR) {
    setTilesR(r, hexagonList);
  }
}

checkOffset(int q, int r, Hexagon cameraHexagon, HexagonList hexagonList, SocketServices socketServices) {

  List hexToRetrieve = [];
  List hexToRemove = [];

  if (cameraHexagon.hexQArray != hexagonList.currentHexQ) {
    print("current hex q different");
    List diffHexagonsQ = updateTilesQ(
        cameraHexagon, hexagonList, socketServices);
    hexToRetrieve.addAll(diffHexagonsQ);

    hexagonList.currentHexQ = cameraHexagon.hexQArray;
  }
  if (cameraHexagon.hexRArray != hexagonList.currentHexR) {
    print("current hex r different");
    List diffHexagonsR = updateTilesR(
        cameraHexagon, hexagonList, socketServices);
    hexToRetrieve.addAll(diffHexagonsR);

    hexagonList.currentHexR = cameraHexagon.hexRArray;
  }

  if (hexToRetrieve.isNotEmpty) {
    List hexToRetrieveUnique = removeDuplicates(hexToRetrieve);
    for (int x = 0; x < hexToRetrieveUnique.length; x++) {
      socketServices.getHexagon(
          hexToRetrieveUnique[x][0], hexToRetrieveUnique[x][1]);
    }
  }
}

setTilesQ(int q, HexagonList hexagonList) {

  int qDiffTile = q - hexagonList.currentQ;
  print("q diff tile $qDiffTile");

  List<List<Tile?>> newTiles = [];

  for (int i = 0; i < qDiffTile.abs(); i++) {
    newTiles.add(
        List.filled(hexagonList.tiles.length, null, growable: true));
  }
  if (qDiffTile < 0) {
    hexagonList.tiles.removeRange(
        hexagonList.tiles.length - (qDiffTile.abs() + 1),
        hexagonList.tiles.length - 1);
    // We fill it with empty values first, once they are retrieved these entries are filled
    hexagonList.tiles.insertAll(0, newTiles);
  } else if (qDiffTile > 0) {
    hexagonList.tiles.removeRange(0, qDiffTile);
    hexagonList.tiles.insertAll(hexagonList.tiles.length, newTiles);
  } else {
    print("something went wrong! q");
  }

  hexagonList.currentQ = q;
}

setTilesR(int r, HexagonList hexagonList) {

  int rDiffTile = r - hexagonList.currentR;
  print("r diff tile $rDiffTile");

  List<Tile?> newTiles = [];

  for (int i = 0; i < rDiffTile.abs(); i++) {
    newTiles.add(null);
  }
  if (rDiffTile < 0) {
    for (int i = 0; i < hexagonList.tiles.length; i++) {
      hexagonList.tiles[i].removeRange(
          hexagonList.tiles[i].length - (rDiffTile.abs() + 1),
          hexagonList.tiles[i].length - 1);
      hexagonList.tiles[i].insertAll(0, newTiles);
    }
  } else if (rDiffTile > 0) {
    for (int i = 0; i < hexagonList.tiles.length; i++) {
      hexagonList.tiles[i].removeRange(0, rDiffTile);
      hexagonList.tiles[i].insertAll(
          hexagonList.tiles[i].length - 1, newTiles);
    }
  } else {
    print("something went wrong! r");
  }

  hexagonList.currentR = r;
}

updateTilesQ(Hexagon cameraHexagon, HexagonList hexagonList, SocketServices socketServices) {
  List qDiffHexagons = [];
  // List qDiffOldHexagons = [];

  int qDiffHex = cameraHexagon.hexQArray - hexagonList.currentHexQ;

  if (qDiffHex > 0) {
    // The diff is positive
    for (int i = 0; i < qDiffHex; i++) {
      List<Hexagon?> row = List.filled(hexagonList.hexagons.length, null, growable: true);
      hexagonList.hexagons.removeAt(0);
      hexagonList.hexagons.insert(hexagonList.hexagons.length, row);
    }
    for (int i = 0; i < qDiffHex; i++ ) {
      int qNew = hexagonList.hexagons.length - hexagonList.hexQ + hexagonList.currentHexQ + i;
      for (int rSock = 0; rSock < hexagonList.hexagons.length; rSock ++) {
        int rNew = rSock - hexagonList.hexR + hexagonList.currentHexR;
        qDiffHexagons.add([qNew, rNew]);
        // qDiffOldHexagons.add([qNew - hexagonList.hexagons.length, rNew]);
      }
    }
  } else if (qDiffHex < 0) {
    for (int i = 0; i < qDiffHex * -1; i++) {
      List<Hexagon?> row = List.filled(hexagonList.hexagons.length, null, growable: true);
      hexagonList.hexagons.insert(0, row);
      hexagonList.hexagons.removeAt(hexagonList.hexagons.length - 1);
    }
    for (int i = 0; i < qDiffHex * -1; i++) {
      int qNew = 0 - hexagonList.hexQ + hexagonList.currentHexQ - 1 - i;
      for (int rSock = 0; rSock < hexagonList.hexagons.length; rSock ++) {
        int rNew = rSock - hexagonList.hexR + hexagonList.currentHexR;
        qDiffHexagons.add([qNew, rNew]);
        // qDiffOldHexagons.add([qNew + hexagonList.hexagons.length, rNew]);
      }
    }
  } else {
    print("Q diff exactly 0");
  }

  return qDiffHexagons;
}

updateTilesR(Hexagon cameraHexagon, HexagonList hexagonList, SocketServices socketServices) {

  List rDiffHexagons = [];
  // List rDiffOldHexagons = [];

  int rDiffHex = cameraHexagon.hexRArray - hexagonList.currentHexR;

  if (rDiffHex > 0) {
    // The diff is positive
    for (int i = 0; i < rDiffHex; i++) {
      for (int i = 0; i < hexagonList.hexagons[0].length; i++) {
        hexagonList.hexagons[i].insert(hexagonList.hexagons[i].length, null);
        hexagonList.hexagons[i].removeAt(0);
      }
    }
    for (int i = 0; i < rDiffHex; i++ ) {
      int rNew = hexagonList.hexagons[0].length - hexagonList.hexR + hexagonList.currentHexR + i;
      for (int qSock = 0; qSock < hexagonList.hexagons[0].length; qSock ++) {
        int qNew = qSock - hexagonList.hexQ + hexagonList.currentHexQ;
        rDiffHexagons.add([qNew, rNew]);
        // rDiffOldHexagons.add([qNew, rNew - hexagonList.hexagons[0].length]);
      }
    }
  } else if (rDiffHex < 0) {
    for (int i = 0; i < rDiffHex * -1; i++) {
      for (int i = 0; i < hexagonList.hexagons[0].length; i++) {
        hexagonList.hexagons[i].removeAt(hexagonList.hexagons[i].length - 1);
        hexagonList.hexagons[i].insert(0, null);
      }
    }

    for (int i = 0; i < rDiffHex * -1; i++ ) {
      int rNew = 0 - 1 - hexagonList.hexR + hexagonList.currentHexR - i;
      for (int qSock = 0; qSock < hexagonList.hexagons[0].length; qSock ++) {
        int qNew = qSock - hexagonList.hexQ + hexagonList.currentHexQ;
        rDiffHexagons.add([qNew, rNew]);
        // rDiffOldHexagons.add([qNew, rNew + hexagonList.hexagons[0].length]);
      }
    }
  } else {
    print("R diff is 0");
  }

  return rDiffHexagons;
}
