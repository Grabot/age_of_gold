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
        1000,
            (_) => List.filled(1000, null, growable: true),
        growable: true);
    hexagons = List.generate(
        250,
            (_) => List.filled(250, null, growable: true),
        growable: true);

    retrieveHexagons();
  }

  factory HexagonList() {
    return _instance;
  }

  retrieveHexagons() {
    print("going to retrieve a hexagon");
    for (int q = -10; q < 10; q++) {
      for (int r = -10; r < 10; r++) {
        int s = (q + r) * -1;
        socketServices.getHexagon(q, r, s);
      }
    }
  }

  socketListener() {
    print("socket listener");
  }
}