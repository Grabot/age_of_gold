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

  int hexQ = 0;
  int hexR = 0;

  HexagonList._internal() {
    tiles = List.generate(360, (_) => List.filled(360, null, growable: true),
        growable: true);
    hexagons = List.generate(12, (_) => List.filled(12, null, growable: true),
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
    socketServices.getHexagon(q, r, this);
    for (int cycle = 0; cycle < hexagons.length * 2; cycle += 2) {
      for (int first = 1; first < cycle; first++) {
        q -= 1;
        socketServices.getHexagon(q, r, this);
      }

      for (int second = 1; second < cycle; second++) {
        r -= 1;
        socketServices.getHexagon(q, r, this);
      }

      if (q == -hexQ && r == -hexR) {
        done = true;
      }

      for (int third = 1; third < cycle + 1; third++) {
        q += 1;
        socketServices.getHexagon(q, r, this);
        if (done && q == (hexQ - 1)) {
          return;
        }
      }

      for (int fourth = 1; fourth < cycle + 1; fourth++) {
        r += 1;
        socketServices.getHexagon(q, r, this);
      }
    }
  }

  Tile? getTileFromCoordinates(int q, int r) {
    int qTile = tileQ + q - currentQ;
    int rTile = tileR + r - currentR;
    return tiles[qTile][rTile];
  }
}
