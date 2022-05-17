import 'dart:ui';
import 'package:age_of_gold/component/hexagon.dart';
import 'package:age_of_gold/component/tile.dart';
import 'package:age_of_gold/util/hexagon_list.dart';
import 'package:flame/sprite.dart';
import '../component/tile.dart';

Future getHexagons(List<List<Tile?>> tiles, int rotate, HexagonList hexagonList) async {

  int qRot = 0;
  int rRot = 0;
  int sRot = 0;

  int hexQ = qRot + (hexagonList.hexagons.length / 2).ceil();
  int hexR = rRot + (hexagonList.hexagons[0].length / 2).ceil();

  SpriteBatch batch_1 = await SpriteBatch.load('flat_1.png');
  SpriteBatch batch_2 = await SpriteBatch.load('flat_2.png');

  Hexagon hexagon = createHexagon(hexQ, hexR,
      tiles, qRot, rRot, sRot, hexagonList.radius, rotate, batch_1, batch_2);
  hexagon.updateHexagon(0, 0);
  hexagonList.hexagons[hexQ][hexR] = hexagon;
}


Hexagon createHexagon(int hexQ, int hexR, List<List<Tile?>> tiles, int q, int r, int s, int radius, int rotate, SpriteBatch batch1, SpriteBatch batch2) {
  int qArray = q + (tiles.length / 2).ceil();
  int rArray = r + (tiles[0].length / 2).ceil();
  Tile? centerTile = tiles[qArray][rArray];
  int sArray = centerTile!.s;

  Hexagon hexagon = Hexagon(batch1, batch2, centerTile.getPos(rotate), rotate, hexQ, hexR);
  for (int qTile = -radius; qTile <= radius; qTile++) {
    for (int rTile = -radius; rTile <= radius; rTile++) {

      if (((qArray + qTile) < tiles.length && (rArray + rTile) < tiles[0].length)
          && ((qArray + qTile) >= 0 && (rArray + rTile) >= 0)) {

        Tile? tile = tiles[qArray + qTile][rArray + rTile];

        if (tile != null) {
          if ((sArray - tile.s) >= -radius && (sArray - tile.s) <= radius) {
            hexagon.addTileToHexagon(tile);
            tile.setHexagon(hexagon);
          }
        }
      }
    }
  }
  return hexagon;
}
