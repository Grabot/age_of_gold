import 'package:age_of_gold/component/hexagon.dart';
import 'package:age_of_gold/component/tile.dart';
import 'package:age_of_gold/util/tile_positions.dart';
import 'package:flame/components.dart';

import '../world/map_details/map_details_small.dart';

class HexagonList {
  static final HexagonList _instance = HexagonList._internal();

  late List<List<Tile?>> tiles;
  late List<List<Hexagon?>> hexagons;
  int radius = 4;

  HexagonList._internal() {

    List<List<int>> worldDetail = worldDetailSmall;
    tiles = List.generate(
        worldDetail.length,
            (_) => List.filled(worldDetail[0].length, null),
        growable: false);

    hexagons = List.generate(
        tiles.length~/radius,
            (_) => List.filled(tiles[0].length~/radius, null),
        growable: false);

    getTileDetails(worldDetail);
    getHexagons(tiles, 0, this);
  }

  factory HexagonList() {
    return _instance;
  }

  getTileDetails(List<List<int>> worldDetail) {

    Tile tile = Tile(0, 0, 0, 0);
    int qArray = (tiles.length / 2).ceil();
    int rArray = (tiles[0].length / 2).ceil();
    tiles[qArray][rArray] = tile;
  }
}