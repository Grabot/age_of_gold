import 'package:tuple/tuple.dart';

import '../component/hexagon.dart';
import '../component/tile.dart';
import '../services/socket_services.dart';
import 'util.dart';

class HexagonList {
  static final HexagonList _instance = HexagonList._internal();

  late List<List<Tile?>> tiles;
  late List<List<Hexagon?>> hexagons;
  late SocketServices socketServices;

  int currentQ = 0;
  int currentR = 0;

  int currentHexQ = 0;
  int currentHexR = 0;

  int tileQ = 0;
  int tileR = 0;

  int hexQ = 0;
  int hexR = 0;

  HexagonList._internal() {
    int initialHexSize = 8;
    int initialTileSize = initialHexSize * 14 + 50;
    tiles = List.generate(initialTileSize, (_) =>
        List.filled(initialTileSize, null, growable: true), growable: true);
    hexagons = List.generate(initialHexSize, (_) =>
        List.filled(initialHexSize, null, growable: true), growable: true);

    tileQ = (tiles.length / 2).ceil();
    tileR = (tiles[0].length / 2).ceil();

    hexQ = (hexagons.length / 2).ceil();
    hexR = (hexagons[0].length / 2).ceil();
  }

  factory HexagonList() {
    return _instance;
  }

  setSocketService(SocketServices socketServices) {
    this.socketServices = socketServices;
  }

  retrieveHexagons(int startHexQ, int startHexR) {
    int currentSizeHex = hexagons.length;
    int currentSizeTile = currentSizeHex * 14 + 50;
    hexagons = List.generate(currentSizeHex, (_) =>
        List.filled(currentSizeHex, null, growable: true), growable: true);
    tiles = List.generate(currentSizeTile, (_) =>
        List.filled(currentSizeTile, null, growable: true), growable: true);
    currentHexQ = startHexQ;
    currentHexR = startHexR;
    currentQ = convertHexToTileQ(currentHexQ, currentHexR);
    currentR = convertHexToTileR(currentHexQ, currentHexR);
    for (int qSock = -hexQ; qSock < hexQ; qSock ++) {
      for (int rSock = -hexR; rSock < hexR; rSock ++) {
        socketServices.getHexagon(qSock + currentHexQ, rSock + currentHexR);
      }
    }
  }

  Tile? getTileFromCoordinates(int q, int r) {
    int qTile = tileQ + q - currentQ;
    int rTile = tileR + r - currentR;
    if (qTile < 0 || qTile >= tiles.length
        || rTile < 0 || rTile >= tiles[0].length) {
      return null;
    } else {
      return tiles[qTile][rTile];
    }
  }

  changeArraySize(int arraySize) {
    List<Tuple2> hexRetrievals = [];
    if (hexagons.length != arraySize) {
      int arraySizeTile = arraySize * 14 + 50;
      if (hexagons.length < arraySize) {
        while (hexagons.length < arraySize) {
          for (int i = 0; i < hexagons.length; i++) {
            hexagons[i].insert(hexagons[i].length, null);
            hexagons[i].insert(0, null);
          }
          List<Hexagon?> row1 = List.filled(
              hexagons[0].length, null, growable: true);
          List<Hexagon?> row2 = List.filled(
              hexagons[0].length, null, growable: true);
          hexagons.insert(hexagons.length, row1);
          hexagons.insert(0, row2);

          // The size has changed now, so reset the hexQ and hexR variables.
          // We need these to retrieve new Hexagons so we set it in the while.
          hexQ = (hexagons.length / 2).ceil();
          hexR = (hexagons[0].length / 2).ceil();

          hexRetrievals = fillNewArrayEdges(hexRetrievals);
        }
        while (tiles.length < arraySizeTile) {
          for (int i = 0; i < tiles.length; i++) {
            tiles[i].insert(tiles[i].length, null);
            tiles[i].insert(0, null);
          }
          List<Tile?> row1 = List.filled(tiles[0].length, null, growable: true);
          List<Tile?> row2 = List.filled(tiles[0].length, null, growable: true);
          tiles.insert(tiles.length, row1);
          tiles.insert(0, row2);
        }
        tileQ = (tiles.length / 2).ceil();
        tileR = (tiles[0].length / 2).ceil();
      } else {
        while (hexagons.length > arraySize) {
          hexagons.removeAt(hexagons.length - 1);
          hexagons.removeAt(0);
          for (int i = 0; i < hexagons[0].length; i++) {
            hexagons[i].removeAt(0);
            hexagons[i].removeAt(hexagons[i].length - 1);
          }
          removeArrayEdges();
        }
        while (tiles.length > arraySizeTile) {
          tiles.removeAt(tiles.length - 1);
          tiles.removeAt(0);
          for (int i = 0; i < tiles[0].length; i++) {
            tiles[i].removeAt(0);
            tiles[i].removeAt(tiles[i].length - 1);
          }
        }
        // The size has changed now, so reset the Q and R variables.
        hexQ = (hexagons.length / 2).ceil();
        hexR = (hexagons[0].length / 2).ceil();

        tileQ = (tiles.length / 2).ceil();
        tileR = (tiles[0].length / 2).ceil();
      }
    }
    for (Tuple2 retrieve in hexRetrievals) {
      // Here we will add empty hexagons to the newly made array.
      // We will fill these with the retrieved hexagons once they are needed.
      socketServices.getHexagon(retrieve.item1, retrieve.item2);
    }
  }

  removeArrayEdges() {
    // This is only needed to leave the hex rooms from the socket connection.
    List oldHexes = [];

    for (int qSock = -2; qSock < hexagons[0].length; qSock ++) {
      // We start from -2 because the array is too small by 2
      int qNew1 = qSock - hexQ + currentHexQ + 2;
      int rNew1 = 0 - hexR + currentHexR;
      oldHexes.add([qNew1, rNew1]);
      int qNew2 = qSock - hexQ + currentHexQ + 2;
      // The length is off by 2 and we add 1 more to get the correct row
      int rNew2 = hexagons[0].length - hexR + currentHexR + 1;
      oldHexes.add([qNew2, rNew2]);
    }

    for (int rSock = -2; rSock < hexagons.length; rSock ++) {
      int qNew1 = 0 - hexQ + currentHexQ;
      int rNew1 = rSock - hexR + currentHexR + 2;
      oldHexes.add([qNew1, rNew1]);
      int qNew2 = hexagons.length - hexQ + currentHexQ + 1;
      int rNew2 = rSock - hexR + currentHexR + 2;
      oldHexes.add([qNew2, rNew2]);
    }

    // TODO: Leave hex room done differently, can this be removed?
    List hexLeaveUnique = removeDuplicates(oldHexes);
    for (int x = 0; x < hexLeaveUnique.length; x++) {
      // socketServices.leaveHexRoom(hexLeaveUnique[x][0], hexLeaveUnique[x][1]);
    }
  }

  List<Tuple2> fillNewArrayEdges(List<Tuple2> currentHexRetrievals) {
    List newHexes = [];

    for (int qSock = 0; qSock < hexagons[0].length; qSock ++) {
      int qNew1 = qSock - hexQ + currentHexQ;
      int rNew1 = 0 - hexR + currentHexR;
      newHexes.add([qNew1, rNew1]);
      int qNew2 = qSock - hexQ + currentHexQ;
      int rNew2 = hexagons[0].length - 1 - hexR + currentHexR;
      newHexes.add([qNew2, rNew2]);
    }

    for (int rSock = 0; rSock < hexagons.length; rSock ++) {
      int qNew1 = 0  - hexQ + currentHexQ;
      int rNew1 = rSock  - hexR + currentHexR;
      newHexes.add([qNew1, rNew1]);
      int qNew2 = hexagons.length - 1 - hexQ + currentHexQ;
      int rNew2 = rSock - hexR + currentHexR;
      newHexes.add([qNew2, rNew2]);
    }

    List hexNewUnique = removeDuplicates(newHexes);
    for (int x = 0; x < hexNewUnique.length; x++) {
      Tuple2 retrieve = Tuple2(hexNewUnique[x][0], hexNewUnique[x][1]);
      if (!currentHexRetrievals.contains(retrieve)) {
        currentHexRetrievals.add(retrieve);
      }
    }
    return currentHexRetrievals;
  }

  setBackToRetrieve() {
    // In case of a big issue, we set all hexagons back to be retrieved
    for (int q = 0; q < hexagons.length; q++) {
      for (int r = 0; r < hexagons[0].length; r++) {
        if (hexagons[q][r] != null) {
          hexagons[q][r]!.setToRetrieve = true;
          hexagons[q][r]!.retrieved = false;
        }
      }
    }
  }

  rotateHexagonsAndTiles(int rotation) {
    for (int q = 0; q < hexagons.length; q++) {
      for (int r = 0; r < hexagons[0].length; r++) {
        if (hexagons[q][r] != null) {
          hexagons[q][r]!.setPosition(rotation);
          for (Tile? tile in hexagons[q][r]!.hexagonTiles) {
            tile!.setPosition(rotation);
          }
          hexagons[q][r]!.updateHexagon(rotation);
        }
      }
    }
  }

}
