import 'package:age_of_gold/component/hexagon.dart';
import 'package:age_of_gold/component/tile.dart';
import 'package:age_of_gold/component/type/grass_tile.dart';
import 'package:age_of_gold/util/socket_services.dart';
import 'package:flame/components.dart';

import '../component/type/dirt_tile.dart';
import '../component/type/water_tile.dart';
import '../world/map_details/map_details_small.dart';

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

  int qHexOffset = 0;
  int rHexOffset = 0;

  int tileQ = 0;
  int tileR = 0;

  HexagonList._internal() {

    List<List<int>> worldDetail = worldDetailSmall;
    tiles = List.generate(
        1000,
            (_) => List.filled(1000, null, growable: true),
        growable: true);
    hexagons = List.generate(
        24,
            (_) => List.filled(24, null, growable: true),
        growable: true);

    tileQ = (tiles.length / 2).ceil();
    tileR = (tiles[0].length / 2).ceil();
  }

  factory HexagonList() {
    return _instance;
  }

  setSocketService(SocketServices socketServices) {
    this.socketServices = socketServices;
  }

  retrieveHexagons() {
    // // Start from the center and retrieve the hexagon outwards
    // // socketServices.getHexagon(0, 0, 0);
    int tileQ = (hexagons.length / 2).ceil();
    int tileR = (hexagons[0].length / 2).ceil();
    int q = 0;
    int r = 0;

    bool done = false;
    socketServices.getHexagon(q, r);
    for (int cycle = 0; cycle < hexagons.length * 2; cycle+=2) {
      for (int first = 1; first < cycle; first++) {
        q -= 1;
        socketServices.getHexagon(q, r);
      }

      for (int second = 1; second < cycle; second++) {
        r -= 1;
        socketServices.getHexagon(q, r);
      }

      if (q == -tileQ && r == -tileR) {
        done = true;
      }

      for (int third = 1; third < cycle + 1; third++) {
        q += 1;
        socketServices.getHexagon(q, r);
        if (done && q == (tileQ - 1)) {
          return;
        }
      }

      for (int fourth = 1; fourth < cycle + 1; fourth++) {
        r += 1;
        socketServices.getHexagon(q, r);
      }
    }

    print("test");
    // }
    // for (int q = 0; q < hexagons.length; q++) {
    //   int qNew = q - tileQ;
    //   int rBegin = 0 - tileR;
    //   int rEnd = hexagons[0].length - 1 - tileR;
    //
    //   socketServices.getHexagonsR(rBegin, rEnd, qNew);
    // }
  }

  Tile? getTileFromCoordinates(int q, int r) {
    int qTile = tileQ + q - currentQ;
    int rTile = tileR + r - currentR;
    return tiles[qTile][rTile];
  }
}