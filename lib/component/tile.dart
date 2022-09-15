import 'dart:math';

import 'package:age_of_gold/component/hexagon.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/sprite.dart';

import '../util/global.dart';
import '../util/util.dart';

class Tile {

  late Vector2 position;
  late int q;
  late int r;
  late int tileType;

  // If the map is wrapped around the q will reflect the position accurately
  // But we still save the wrapped Q to show the user and to use it to change.
  late int tileQ;
  late int tileR;

  double scaleX = 1;
  double scaleY = 1.05;

  Hexagon? hexagon;

  // We assume the condition r + s + q = 0 is true.
  Tile(this.q, this.r, this.tileType, this.tileQ, this.tileR) {
    setPosition();
  }

  setHexagon(Hexagon hexagonTile) {
    hexagon = hexagonTile;
  }

  Vector2 getPos(int rotate) {
    if (rotate == 0) {
      return Vector2(position.x, position.y);
    } else if (rotate == 1) {
      return Vector2(-position.y * 2, position.x / 2);
    } else if (rotate == 2) {
      return Vector2(-position.x, -position.y);
    } else {
      return Vector2(position.y * 2, -position.x / 2);
    }
  }

  // size = 16.
  // flat
  // width = 2 * size
  // height = sqrt(3) * size / 2   divided by 2 to give the isometric view
  // point
  // width = sqrt(3) * size
  // height = 2 * size / 2   divided by 2 to give the isometric view
  Vector2 getSize(int rotate) {
    if (rotate == 0 || rotate == 2) {
      return Vector2(2 * xSize, sqrt(3) * ySize);
      // return Vector2(128, 56);
    } else {
      return Vector2(sqrt(3) * xSize, 2 * ySize);
      // return Vector2(111, 64);
    }
  }

  int getTileType() {
    return tileType;
  }

  updateBaseTile(SpriteBatch baseBatch, int rotate) {

  }

  updateBaseVariation1(SpriteBatch batchVariation1, int rotate) {

  }

  updateBaseVariation2(SpriteBatch batchVariation2, int rotate) {

  }

  updateBaseVariation3(SpriteBatch batchVariation3, int rotate) {

  }

  updateBaseVariation4(SpriteBatch batchVariation4, int rotate) {

  }

  updateBaseVariation5(SpriteBatch batchVariation5, int rotate) {

  }

  updateBaseVariation6(SpriteBatch batchVariation6, int rotate) {

  }

  updateBaseVariation7(SpriteBatch batchVariation7, int rotate) {

  }

  updateBaseVariation8(SpriteBatch batchVariation8, int rotate) {

  }

  updateBaseVariation9(SpriteBatch batchVariation9, int rotate) {

  }

  updateBaseVariation10(SpriteBatch batchVariation10, int rotate) {

  }

  updateBaseVariation11(SpriteBatch batchVariation11, int rotate) {

  }

  setPosition() {
    position = getTilePosition(q, r);
  }

  Tile.fromJson(data) {
    tileType = data["type"];

    q = data['q'];
    r = data['r'];

    tileQ = data["q"];
    tileR = data["r"];

    position = Vector2(0, 0);
  }
}