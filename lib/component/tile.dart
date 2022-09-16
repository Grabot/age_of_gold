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

  Vector2 getPos() {
    return Vector2(position.x, position.y);
  }

  // size = 16.
  // flat
  // width = 2 * size
  // height = sqrt(3) * size / 2   divided by 2 to give the isometric view
  // point
  // width = sqrt(3) * size
  // height = 2 * size / 2   divided by 2 to give the isometric view
  Vector2 getSize() {
    return Vector2(2 * xSize, sqrt(3) * ySize);
  }

  int getTileType() {
    return tileType;
  }

  updateBaseTile(SpriteBatch baseBatch) {

  }

  updateBaseVariation1(SpriteBatch batchVariation1) {

  }

  updateBaseVariation2(SpriteBatch batchVariation2) {

  }

  updateBaseVariation3(SpriteBatch batchVariation3) {

  }

  updateBaseVariation4(SpriteBatch batchVariation4) {

  }

  updateBaseVariation5(SpriteBatch batchVariation5) {

  }

  updateBaseVariation6(SpriteBatch batchVariation6) {

  }

  updateBaseVariation7(SpriteBatch batchVariation7) {

  }

  updateBaseVariation8(SpriteBatch batchVariation8) {

  }

  updateBaseVariation9(SpriteBatch batchVariation9) {

  }

  updateBaseVariation10(SpriteBatch batchVariation10) {

  }

  updateBaseVariation11(SpriteBatch batchVariation11) {

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