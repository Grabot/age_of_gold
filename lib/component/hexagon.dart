import 'dart:ui';

import 'package:age_of_gold/component/tile.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';

class Hexagon {

  late int rotation;

  late Vector2 center;

  late SpriteBatch batchBase;
  late SpriteBatch batchBaseVariation1;

  List<Tile> hexagonTiles = [];

  late int hexQArray;
  late int hexRArray;

  Hexagon(this.batchBase, this.batchBaseVariation1, this.center, this.rotation, this.hexQArray, this.hexRArray);

  addTileToHexagon(Tile tile) {
    hexagonTiles.add(tile);
  }

  // We sort it on the y axis, so they are drawn from the top down.
  sortTiles() {
    hexagonTiles.sort((a, b) => a.getPos(rotation).y.compareTo(b.getPos(rotation).y));
  }

  updateHexagon(int rotate, int variation) {
    batchBase.clear();
    for (Tile tile in hexagonTiles) {
      tile.updateBaseTile(batchBase, rotate);
    }
    batchBaseVariation1.clear();
    for (Tile tile in hexagonTiles) {
      tile.updateBaseVariation1(batchBaseVariation1, rotate);
    }
  }

  getPos(int rotate) {
    return center;
  }

  renderHexagon(Canvas canvas, int variation) {
    batchBase.render(canvas, blendMode: BlendMode.srcOver);
    if (variation == 1) {
      batchBaseVariation1.render(canvas, blendMode: BlendMode.srcOver);
    }
  }

  String toString() {
    return "hex q: $hexQArray r: $hexRArray on pos: $center}";
  }
}