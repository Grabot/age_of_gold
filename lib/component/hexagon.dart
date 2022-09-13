import 'dart:ui';

import 'package:age_of_gold/component/tile.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';

class Hexagon {

  // late int hexagonId;

  late int rotation;

  late Vector2 center;

  SpriteBatch? batchBase;
  SpriteBatch? batchBaseVariation1;
  SpriteBatch? batchBaseVariation2;
  SpriteBatch? batchBaseVariation3;
  SpriteBatch? batchBaseVariation4;
  SpriteBatch? batchBaseVariation5;
  SpriteBatch? batchBaseVariation6;
  SpriteBatch? batchBaseVariation7;
  SpriteBatch? batchBaseVariation8;
  SpriteBatch? batchBaseVariation9;
  SpriteBatch? batchBaseVariation10;
  SpriteBatch? batchBaseVariation11;

  List<Tile> hexagonTiles = [];

  late int hexQArray;
  late int hexRArray;
  // late int hexSArray;

  Hexagon? left;
  Hexagon? right;
  Hexagon? topLeft;
  Hexagon? topRight;
  Hexagon? bottomLeft;
  Hexagon? bottomRight;

  late int wrapQ = 0;
  late int wrapR = 0;

  Hexagon(this.center, this.rotation, this.hexQArray, this.hexRArray) {
    loadTextures();
  }

  loadTextures() {
    SpriteBatch.load('tile_variants/variant_1.png').then((SpriteBatch batch) {
      batchBase = batch;
      updateHexagon(0);
    });
    SpriteBatch.load('tile_variants/variant_2.png').then((SpriteBatch batch) {
      batchBaseVariation1 = batch;
      updateHexagon(0);
    });
    SpriteBatch.load('tile_variants/variant_3.png').then((SpriteBatch batch) {
      batchBaseVariation2 = batch;
      updateHexagon(0);
    });
    SpriteBatch.load('tile_variants/variant_4.png').then((SpriteBatch batch) {
      batchBaseVariation3 = batch;
      updateHexagon(0);
    });
    SpriteBatch.load('tile_variants/variant_5.png').then((SpriteBatch batch) {
      batchBaseVariation4 = batch;
      updateHexagon(0);
    });
    SpriteBatch.load('tile_variants/variant_6.png').then((SpriteBatch batch) {
      batchBaseVariation5 = batch;
      updateHexagon(0);
    });
    SpriteBatch.load('tile_variants/variant_7.png').then((SpriteBatch batch) {
      batchBaseVariation6 = batch;
      updateHexagon(0);
    });
    SpriteBatch.load('tile_variants/variant_8.png').then((SpriteBatch batch) {
      batchBaseVariation7 = batch;
      updateHexagon(0);
    });
    SpriteBatch.load('tile_variants/variant_9.png').then((SpriteBatch batch) {
      batchBaseVariation8 = batch;
      updateHexagon(0);
    });
    SpriteBatch.load('tile_variants/variant_10.png').then((SpriteBatch batch) {
      batchBaseVariation9 = batch;
      updateHexagon(0);
    });
    SpriteBatch.load('tile_variants/variant_11.png').then((SpriteBatch batch) {
      batchBaseVariation10 = batch;
      updateHexagon(0);
    });
    SpriteBatch.load('tile_variants/variant_12.png').then((SpriteBatch batch) {
      batchBaseVariation11 = batch;
      updateHexagon(0);
    });
  }

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
    if (batchBaseVariation2 != null) {
      batchBaseVariation2!.clear();
      for (Tile tile in hexagonTiles) {
        tile.updateBaseVariation2(batchBaseVariation2!, rotate);
      }
    }
    if (batchBaseVariation3 != null) {
      batchBaseVariation3!.clear();
      for (Tile tile in hexagonTiles) {
        tile.updateBaseVariation3(batchBaseVariation3!, rotate);
      }
    }
    if (batchBaseVariation4 != null) {
      batchBaseVariation4!.clear();
      for (Tile tile in hexagonTiles) {
        tile.updateBaseVariation4(batchBaseVariation4!, rotate);
      }
    }
    if (batchBaseVariation5 != null) {
      batchBaseVariation5!.clear();
      for (Tile tile in hexagonTiles) {
        tile.updateBaseVariation5(batchBaseVariation5!, rotate);
      }
    }
    if (batchBaseVariation6 != null) {
      batchBaseVariation6!.clear();
      for (Tile tile in hexagonTiles) {
        tile.updateBaseVariation6(batchBaseVariation6!, rotate);
      }
    }
    if (batchBaseVariation7 != null) {
      batchBaseVariation7!.clear();
      for (Tile tile in hexagonTiles) {
        tile.updateBaseVariation7(batchBaseVariation7!, rotate);
      }
    }
    if (batchBaseVariation8 != null) {
      batchBaseVariation8!.clear();
      for (Tile tile in hexagonTiles) {
        tile.updateBaseVariation8(batchBaseVariation8!, rotate);
      }
    }
    if (batchBaseVariation9 != null) {
      batchBaseVariation9!.clear();
      for (Tile tile in hexagonTiles) {
        tile.updateBaseVariation9(batchBaseVariation9!, rotate);
      }
    }
    if (batchBaseVariation10 != null) {
      batchBaseVariation10!.clear();
      for (Tile tile in hexagonTiles) {
        tile.updateBaseVariation10(batchBaseVariation10!, rotate);
      }
    }
    if (batchBaseVariation11 != null) {
      batchBaseVariation11!.clear();
      for (Tile tile in hexagonTiles) {
        tile.updateBaseVariation11(batchBaseVariation11!, rotate);
      }
    }
  }

  getPos(int rotate) {
    return center;
  }

  renderHexagon(Canvas canvas, int variation) {
    if (variation == 0) {
      if (batchBase != null) {
        batchBase!.render(canvas);
      }
    } else if (variation == 1) {
      if (batchBaseVariation1 != null) {
        batchBaseVariation1!.render(canvas);
      }
    } else if (variation == 2) {
      if (batchBaseVariation2 != null) {
        batchBaseVariation2!.render(canvas);
      }
    } else if (variation == 3) {
      if (batchBaseVariation3 != null) {
        batchBaseVariation3!.render(canvas);
      }
    } else if (variation == 4) {
      if (batchBaseVariation4 != null) {
        batchBaseVariation4!.render(canvas);
      }
    } else if (variation == 5) {
      if (batchBaseVariation5 != null) {
        batchBaseVariation5!.render(canvas);
      }
    } else if (variation == 6) {
      if (batchBaseVariation6 != null) {
        batchBaseVariation6!.render(canvas);
      }
    } else if (variation == 7) {
      if (batchBaseVariation7 != null) {
        batchBaseVariation7!.render(canvas);
      }
    } else if (variation == 8) {
      if (batchBaseVariation8 != null) {
        batchBaseVariation8!.render(canvas);
      }
    } else if (variation == 9) {
      if (batchBaseVariation9 != null) {
        batchBaseVariation9!.render(canvas);
      }
    } else if (variation == 10) {
      if (batchBaseVariation10 != null) {
        batchBaseVariation10!.render(canvas);
      }
    } else if (variation == 11) {
      if (batchBaseVariation11 != null) {
        batchBaseVariation11!.render(canvas);
      }
    }
  }

  String toString() {
    return "hex q: $hexQArray r: $hexRArray on pos: $center}";
  }


  Hexagon.fromJson(data) {

    loadTextures();

    center = Vector2(0, 0);
    rotation = 0;
    print("creating hexagon from json with q: ${data['q']} and r: ${data['r']}");
    hexQArray = data['q'];
    hexRArray = data['r'];
  }
}