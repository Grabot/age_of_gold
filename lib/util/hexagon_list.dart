import 'package:age_of_gold/component/hexagon.dart';
import 'package:age_of_gold/component/tile.dart';
import 'package:age_of_gold/component/type/grass_tile.dart';
import 'package:age_of_gold/util/tile_positions.dart';
import 'package:flame/components.dart';

import '../component/type/dirt_tile.dart';
import '../component/type/water_tile.dart';
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

    for (int q = -(tiles.length/2).ceil(); q < (tiles.length/2).floor(); q++) {
      for (int r = -(tiles[0].length / 2).ceil(); r <
          (tiles[0].length / 2).floor(); r++) {
        int s = (q + r) * -1;
        int qArray = q + (tiles.length / 2).ceil();
        int rArray = r + (tiles[0].length / 2).ceil();
        if (worldDetail[qArray][rArray] == 0) {
          WaterTile tile = WaterTile(q, r, s, 0);
          tiles[qArray][rArray] = tile;
        } else if (worldDetail[qArray][rArray] == 1) {
          DirtTile tile = DirtTile(q, r, s, 1);
          tiles[qArray][rArray] = tile;
        } else if (worldDetail[qArray][rArray] == 2) {
          GrassTile tile = GrassTile(q, r, s, 2);
          tiles[qArray][rArray] = tile;
        }
      }
    }
  }
}