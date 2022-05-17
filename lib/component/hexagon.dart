import 'dart:ui';

import 'package:age_of_gold/component/tile.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';

class Hexagon {

  late int rotation;

  late Vector2 center;

  late SpriteBatch spriteBatch1;
  late SpriteBatch spriteBatch2;

  List<Tile> hexagonTiles = [];

  late int hexQArray;
  late int hexRArray;

  Hexagon(this.spriteBatch1, this.spriteBatch2, this.center, this.rotation, this.hexQArray, this.hexRArray);

  addTileToHexagon(Tile tile) {
    hexagonTiles.add(tile);
  }

  // We sort it on the y axis, so they are drawn from the top down.
  sortTiles() {
    hexagonTiles.sort((a, b) => a.getPos(rotation).y.compareTo(b.getPos(rotation).y));
  }

  updateHexagon(int rotate, int variation) {
    spriteBatch1.clear();
    for (Tile tile in hexagonTiles) {
      tile.updateTile(spriteBatch1, rotate, 0);
    }
    spriteBatch2.clear();
    for (Tile tile in hexagonTiles) {
      tile.updateTile(spriteBatch2, rotate, 1);
    }
  }

  getPos(int rotate) {
    return center;
  }

  renderHexagon(Canvas canvas, int variation) {
    if (variation == 0) {
      spriteBatch1.render(canvas, blendMode: BlendMode.srcOver);
    } else {
      spriteBatch2.render(canvas, blendMode: BlendMode.srcOver);
    }
  }

  String toString() {
    return "hex q: $hexQArray r: $hexRArray on pos: $center}";
  }
}