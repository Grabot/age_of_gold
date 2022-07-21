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
        8,
            (_) => List.filled(8, null, growable: true),
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
    // socketServices.getHexagon(0, 0, 0);
    int tileQ = (hexagons.length / 2).ceil();
    int tileR = (hexagons[0].length / 2).ceil();
    for (int q = 0; q < hexagons.length; q++) {
      for (int r = 0; r < hexagons[0].length; r++) {
        int q_2 = q - tileQ;
        int r_2 = r - tileR;
        socketServices.getHexagon(q_2, r_2);
      }
    }
  }

  Tile? getTileFromCoordinates(int q, int r) {
    int qTile = tileQ + q - currentQ;
    int rTile = tileR + r - currentR;
    return tiles[qTile][rTile];
  }
}