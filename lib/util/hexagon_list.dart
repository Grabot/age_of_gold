import 'package:age_of_gold/component/hexagon.dart';
import 'package:age_of_gold/component/tile.dart';
import 'package:age_of_gold/util/socket_services.dart';

class HexagonList {
  static final HexagonList _instance = HexagonList._internal();

  late List<List<Tile?>> tiles;
  late List<List<Hexagon?>> hexagons;
  late SocketServices socketServices;

  int currentQ = 0;
  int currentR = 0;

  int qOffset = 0;
  int rOffset = 0;

  int currentHexQ = 0;
  int currentHexR = 0;

  int tileQ = 0;
  int tileR = 0;

  int hexQ = 0;
  int hexR = 0;

  HexagonList._internal() {
    tiles = List.generate(360, (_) => List.filled(360, null, growable: true),
        growable: true);
    hexagons = List.generate(6, (_) => List.filled(6, null, growable: true),
        growable: true);

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

  retrieveHexagons() {
    // Start from the center and retrieve the hexagon outwards
    int q = 0;
    int r = 0;

    // Some simple algorithm to load the map from the center outwards.
    bool done = false;
    socketServices.getHexagon(q, r);
    for (int cycle = 0; cycle < hexagons.length * 2; cycle += 2) {
      for (int first = 1; first < cycle; first++) {
        q -= 1;
        socketServices.getHexagon(q, r);
      }

      for (int second = 1; second < cycle; second++) {
        r -= 1;
        socketServices.getHexagon(q, r);
      }

      if (q == -hexQ && r == -hexR) {
        done = true;
      }

      for (int third = 1; third < cycle + 1; third++) {
        q += 1;
        socketServices.getHexagon(q, r);
        if (done && q == (hexQ - 1)) {
          return;
        }
      }

      for (int fourth = 1; fourth < cycle + 1; fourth++) {
        r += 1;
        socketServices.getHexagon(q, r);
      }
    }
  }

  Tile? getTileFromCoordinates(int q, int r) {
    int qTile = tileQ + q - currentQ;
    int rTile = tileR + r - currentR;
    return tiles[qTile][rTile];
  }

  changeArraySize(int arraySize) {
    print("changing array size! $arraySize");
    if (hexagons.length != arraySize) {
      print("we have to change stuff!");
      if (hexagons.length < arraySize) {
        while (hexagons.length < arraySize) {
          print("we need to add stuff");
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
          fillNewArrayEdges();
          // The size has changed now, so reset the hexQ and hexR variables.
          hexQ = (hexagons.length / 2).ceil();
          hexR = (hexagons[0].length / 2).ceil();
        }
      } else {
        while (hexagons.length > arraySize) {
          hexagons.removeAt(hexagons.length - 1);
          hexagons.removeAt(0);
          for (int i = 0; i < hexagons[0].length; i++) {
            hexagons[i].removeAt(0);
            hexagons[i].removeAt(hexagons[i].length - 1);
          }
          // The size has changed now, so reset the hexQ and hexR variables.
          hexQ = (hexagons.length / 2).ceil();
          hexR = (hexagons[0].length / 2).ceil();
        }
      }
    } else {
      print("no change needed");
    }
  }

  fillNewArrayEdges() {
    List test = [];

    for (int qSock = 0; qSock < hexagons[0].length; qSock ++) {
      int qNew1 = qSock - 1 - hexQ + currentHexQ;
      int rNew1 = 0 - 1 - hexR + currentHexR;
      test.add([qNew1, rNew1]);
      int qNew2 = qSock - hexQ + currentHexQ - 1;
      int rNew2 = hexagons[0].length - 2 - hexR + currentHexR;
      test.add([qNew2, rNew2]);
    }

    for (int rSock = 0; rSock < hexagons.length; rSock ++) {
      int qNew1 = 0 - 1 - hexQ + currentHexQ;
      int rNew1 = rSock - 1 - hexR + currentHexR;
      test.add([qNew1, rNew1]);
      int qNew2 = hexagons.length - 2 - hexQ + currentHexQ;
      int rNew2 = rSock - 1 - hexR + currentHexR;
      test.add([qNew2, rNew2]);
    }

    if (test.isNotEmpty) {
      List hexToRetrieveUnique = [];
      for (int x = 0; x < test.length; x++) {
        bool noRepeat = true;
        List value1 = test[x];
        for (int y = x + 1; y < test.length; y++) {
          List value2 = test[y];
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
        socketServices.getHexagon(
            hexToRetrieveUnique[x][0], hexToRetrieveUnique[x][1]);
      }
    }
  }
}
