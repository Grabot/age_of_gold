import 'dart:ui';
import 'package:age_of_gold/component/hexagon.dart';
import 'package:age_of_gold/component/tile.dart';
import 'package:age_of_gold/util/hexagon_list.dart';
import 'package:flame/sprite.dart';
import '../component/tile.dart';
import 'global.dart';

// Future getHexagons(List<List<Tile?>> tiles, int rotate, HexagonList hexagonList) async {

  // TODO: Possibly outdated
  // int qRot = 0;
  // int rRot = 0;
  // int sRot = 0;
  //
  // int hexQ = qRot + (hexagonList.hexagons.length / 2).ceil();
  // int hexR = rRot + (hexagonList.hexagons[0].length / 2).ceil();
  //
  // Hexagon hexagon = createHexagon(hexQ, hexR, tiles, qRot, rRot, sRot, rotate);
  // hexagon.updateHexagon(0);
  // hexagonList.hexagons[hexQ][hexR] = hexagon;
// }


// Hexagon createHexagon(int hexQ, int hexR, List<List<Tile?>> tiles, int q, int r, int s, int rotate) {
//
//   // TODO: Possibly outdated
//   int qArray = q + (tiles.length / 2).ceil();
//   int rArray = r + (tiles[0].length / 2).ceil();
//   Tile? centerTile = tiles[qArray][rArray];
//   int sArray = centerTile!.s;
//
//   Hexagon hexagon = Hexagon(0, centerTile.getPos(rotate), rotate, hexQ, hexR);
//   for (int qTile = -radius; qTile <= radius; qTile++) {
//     for (int rTile = -radius; rTile <= radius; rTile++) {
//
//       if (((qArray + qTile) < tiles.length && (rArray + rTile) < tiles[0].length)
//           && ((qArray + qTile) >= 0 && (rArray + rTile) >= 0)) {
//
//         Tile? tile = tiles[qArray + qTile][rArray + rTile];
//
//         if (tile != null) {
//           if ((sArray - tile.s) >= -radius && (sArray - tile.s) <= radius) {
//             hexagon.addTile(tile);
//             tile.setHexagon(hexagon);
//           }
//         }
//       }
//     }
//   }
//   return hexagon;
// }
