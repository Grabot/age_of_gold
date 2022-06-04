import 'dart:ui';

import 'package:age_of_gold/component/tile.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';

class Hexagon {

  late int hexagonId;

  late int rotation;

  late Vector2 center;

  SpriteBatch? batchBase;
  SpriteBatch? batchBaseVariation1;

  List<Tile> hexagonTiles = [];

  late int hexQArray;
  late int hexRArray;
  late int hexSArray;

  Hexagon(this.hexagonId, this.center, this.rotation, this.hexQArray, this.hexRArray) {
    SpriteBatch.load('flat_base.png').then((SpriteBatch batch) {
      batchBase = batch;
    });
    SpriteBatch.load('flat_variation_1.png').then((SpriteBatch batch) {
      batchBaseVariation1 = batch;
    });

    hexSArray = (hexQArray + hexRArray) * -1;
  }

  addTile(Tile tile) {
    hexagonTiles.add(tile);
    tile.hexagon = this;
  }

  // We sort it on the y axis, so they are drawn from the top down.
  sortTiles() {
    hexagonTiles.sort((a, b) => a.getPos(rotation).y.compareTo(b.getPos(rotation).y));
  }

  updateHexagon(int rotate) {
    if (batchBase != null) {
      batchBase!.clear();
      for (Tile tile in hexagonTiles) {
        tile.updateBaseTile(batchBase!, rotate);
      }
    }
    if (batchBaseVariation1 != null) {
      batchBaseVariation1!.clear();
      for (Tile tile in hexagonTiles) {
        tile.updateBaseVariation1(batchBaseVariation1!, rotate);
      }
    }
  }

  getPos(int rotate) {
    return center;
  }

  renderHexagon(Canvas canvas, int variation) {
    if (batchBase != null) {
      batchBase!.render(canvas, blendMode: BlendMode.srcOver);
    }
    if (variation == 1) {
      if (batchBaseVariation1 != null) {
        batchBaseVariation1!.render(canvas, blendMode: BlendMode.srcOver);
      }
    }
  }

  String toString() {
    return "hex q: $hexQArray r: $hexRArray on pos: $center}";
  }


  Hexagon.fromJson(data) {
    SpriteBatch.load('flat_base.png').then((SpriteBatch batch) {
      batchBase = batch;
      updateHexagon(0);
    });
    SpriteBatch.load('flat_variation_1.png').then((SpriteBatch batch) {
      batchBaseVariation1 = batch;
      updateHexagon(0);
    });
    hexagonId = data['id'];
    center = Vector2(0, 0);
    rotation = 0;
    print("creating hexagon from json with id: $hexagonId and q: ${data['q']} and r: ${data['r']}");
    hexQArray = data['q'];
    hexRArray = data['r'];
  }
}