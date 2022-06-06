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

  HexagonList._internal() {

    socketServices = SocketServices();
    socketServices.setHexagonList(this);
    socketServices.addListener(socketListener);
    List<List<int>> worldDetail = worldDetailSmall;
    tiles = List.generate(
        100,
            (_) => List.filled(100, null, growable: true),
        growable: true);
    hexagons = List.generate(
        25,
            (_) => List.filled(25, null, growable: true),
        growable: true);

    retrieveHexagons();
  }

  factory HexagonList() {
    return _instance;
  }

  retrieveHexagons() {
    print("going to retrieve a hexagon");
    socketServices.getHexagon(0, 0, 0);
    socketServices.getHexagon(1, 0, -1);
    socketServices.getHexagon(1, -1, 0);
    socketServices.getHexagon(0, -1, 1);
    socketServices.getHexagon(0, 1, -1);
    socketServices.getHexagon(-1, 1, 0);
    socketServices.getHexagon(-1, 0, 1);
  }

  socketListener() {
    print("socket listener");
  }
}