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
  late List<List<Hexagon?>> hexagons;
  late SocketServices socketServices;
  int radius = 4;

  HexagonList._internal() {

    socketServices = SocketServices();
    socketServices.setHexagonList(this);
    socketServices.addListener(socketListener);
    List<List<int>> worldDetail = worldDetailSmall;
    tiles = List.generate(
        1000,
            (_) => List.filled(1000, null),
        growable: false);

    hexagons = List.generate(
        250,
            (_) => List.filled(250, null),
        growable: false);

    retrieveHexagons();
    // getHexagons(tiles, 0, this);
  }

  factory HexagonList() {
    return _instance;
  }

  retrieveHexagons() {
    print("going to retrieve a hexagon");
    socketServices.getHexagon(0, 0, 0);
  }

  socketListener() {
    print("socket listener");
  }
}