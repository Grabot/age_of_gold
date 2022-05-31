import 'dart:math';
import 'dart:ui';
import 'package:age_of_gold/component/hexagon.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/sprite.dart';

import 'get_texture.dart';

class Tile {

  double xSize = 17;
  double ySize = 8;

  late Vector2 position;
  late int q;
  late int r;
  late int s;
  late int tileType;

  double scaleX = 1;
  double scaleY = 1.05;

  Hexagon? hexagon;

  // We assume the condition r + s + q = 0 is true.
  Tile(this.q, this.r, this.s, this.tileType) {
    double xPos = xSize * 3 / 2 * q - xSize;
    double yTr1 = ySize * (sqrt(3) / 2 * q);
    yTr1 *= -1; // The y axis gets positive going down, so we flip it.
    double yTr2 = ySize * (sqrt(3) * r);
    yTr2 *= -1; // The y axis gets positive going down, so we flip it.
    double yPos = yTr1 + yTr2 - ySize;
    position = Vector2(xPos, yPos);
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
}