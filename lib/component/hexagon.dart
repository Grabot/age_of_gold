import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/sprite.dart';

import '../constants/global.dart';
import '../services/settings.dart';
import '../util/util.dart';
import 'tile.dart';

class Hexagon {

  late Vector2 center;

  SpriteBatch? flatTop;
  SpriteBatch? pointTop;

  List<Tile> hexagonTiles = [];

  late int hexQArray;
  late int hexRArray;
  late int q;
  late int r;
  // late int hexSArray;

  Hexagon? left;
  Hexagon? right;
  Hexagon? topLeft;
  Hexagon? topRight;
  Hexagon? bottomLeft;
  Hexagon? bottomRight;

  late int wrapQ = 0;
  late int wrapR = 0;

  bool retrieved = false;
  bool setToRetrieve = false;
  bool visible = false;

  Hexagon(this.hexQArray, this.hexRArray) {
    // In case the map wraps around, these variables have original hex values
    q = hexQArray;
    r = hexRArray;
    loadTextures();
    // calculate the center point by determining which tile is in the center
    setPosition(Settings().getRotation());

    retrieved = false;
    setToRetrieve = false;
    // This is to determine whether or not the hex is visible in the screen
    // This flag is only set if the render determines that it is in the screen
    visible = false;
  }

  int texturesLoaded = 0;
  loadTextures() {
    SpriteBatch.load('tile_variants/flat_top.png').then((SpriteBatch batch) {
      flatTop = batch;
      texturesLoaded += 1;
      if (texturesLoaded == 2) {
        updateHexagon(Settings().getRotation());
      }
    });
    SpriteBatch.load('tile_variants/point_top.png').then((SpriteBatch batch) {
      pointTop = batch;
      texturesLoaded += 1;
      if (texturesLoaded == 2) {
        updateHexagon(Settings().getRotation());
      }
    });
  }

  // setRotation(int rotation) {
  //   this.rotation = rotation;
  // }
  // getRotation() {
  //   return rotation;
  // }

  setWrapQ(int wrapQ) {
    this.wrapQ = wrapQ;
  }

  int getWrapQ() {
    return wrapQ;
  }

  setWrapR(int wrapR) {
    this.wrapR = wrapR;
  }

  int getWrapR() {
    return wrapR;
  }

  addTile(Tile tile) {
    hexagonTiles.add(tile);
    tile.hexagon = this;
  }

  // We sort it on the y axis, so they are drawn from the top down.
  sortTiles() {
    hexagonTiles.sort((a, b) => a.getPos().y.compareTo(b.getPos().y));
  }

  updateHexagon(int rotation) {
    if (flatTop != null) {
      flatTop!.clear();
    }
    if (pointTop != null) {
      pointTop!.clear();
    }
    for (Tile tile in hexagonTiles) {
      if (rotation % 2 == 0) {
        tile.updateTile(flatTop, rotation);
      } else {
        tile.updateTile(pointTop, rotation);
      }
    }
  }

  getPos() {
    return center;
  }

  renderHexagon(Canvas canvas, rotation) {
    if (rotation % 2 == 0) {
      if (flatTop != null) {
        flatTop!.render(canvas);
      }
    } else {
      if (pointTop != null) {
        pointTop!.render(canvas);
      }
    }
  }

  @override
  String toString() {
    return "hex q: $hexQArray r: $hexRArray on pos: $center}";
  }

  setPosition(int rotation) {
    // calculate the center point by determining which tile is in the center
    int tileQ = convertHexToTileQ(hexQArray, hexRArray);
    int tileR = convertHexToTileR(hexQArray, hexRArray);

    // TODO: check? Is this it?
    center = getTilePosition(tileQ, tileR, rotation);
  }

  Hexagon.fromJson(data) {

    loadTextures();

    center = Vector2(0, 0);

    hexQArray = data['q'];
    hexRArray = data['r'];
    // In case the map wraps around, these variables have original hex values
    q = data['q'];
    r = data['r'];

    if (data.containsKey("wraparound")) {
      setWrapQ(data["wraparound"]["q"]);
      setWrapR(data["wraparound"]["r"]);
      if (getWrapQ() != 0) {
        hexQArray += (mapSize * 2 + 1) * getWrapQ();
      }
      if (getWrapR() != 0) {
        hexRArray += (mapSize * 2 + 1) * getWrapR();
      }
    }
    setPosition(Settings().getRotation());
    retrieved = true;
    setToRetrieve = true;
  }
}