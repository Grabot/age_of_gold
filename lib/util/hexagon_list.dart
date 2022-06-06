import 'package:age_of_gold/component/hexagon.dart';
import 'package:age_of_gold/component/tile.dart';
import 'package:age_of_gold/component/type/grass_tile.dart';
import 'package:age_of_gold/util/socket_services.dart';
import 'package:age_of_gold/util/tile_positions.dart';
import 'package:flame/components.dart';

import '../component/type/dirt_tile.dart';
import '../component/type/water_tile.dart';
import '../world/map_details/map_details_small.dart';

class HexagonList {
  static final HexagonList _instance = HexagonList._internal();

  late List<List<Tile?>> tiles;
  late List<Hexagon?> hexagons;
  late SocketServices socketServices;

  int currentQ = 0;
  int currentR = 0;

  int qOffset = 0;
  int rOffset = 0;

  HexagonList._internal() {

    socketServices = SocketServices();
    socketServices.setHexagonList(this);
    socketServices.addListener(socketListener);
    List<List<int>> worldDetail = worldDetailSmall;
    tiles = List.generate(
        1000,
            (_) => List.filled(1000, null, growable: true),
        growable: true);
    // TODO: Find a better way to store hexagons?
    hexagons = List.filled(250, null, growable: true);

    retrieveHexagons();
    // getHexagons(tiles, 0, this);
  }

  factory HexagonList() {
    return _instance;
  }

  retrieveHexagons() {
    print("going to retrieve a hexagon");
    socketServices.getHexagon(0, 0, 0);
    socketServices.getHexagon(9, -4, -5);
    socketServices.getHexagon(4, 5, -9);
    socketServices.getHexagon(-5, 9, -4);
    socketServices.getHexagon(5, -9, 4);
    socketServices.getHexagon(-4, -5, 9);
    socketServices.getHexagon(-9, 4, 5);
  }

  socketListener() {
    print("socket listener");
  }
}