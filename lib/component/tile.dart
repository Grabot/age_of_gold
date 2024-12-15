import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/sprite.dart';
import '../services/settings.dart';
import '../util/util.dart';
import 'get_texture.dart';
import 'hexagon.dart';


class Tile {

  late Vector2 tilePosition;
  late int q;
  late int r;
  late int tileType;
  // String? lastChangedBy;
  // DateTime? lastChangedTime;

  // If the map is wrapped around the q will reflect the position accurately
  // But we still save the wrapped Q to show the user and to use it to change.
  // example: the center tile (0, 0) will be saved in tileQ and tileR
  // But q and r might have higher values if the map is wrapped around
  late int tileQ;
  late int tileR;

  double scaleX = 1;

  Hexagon? hexagon;

  Tile(this.q, this.r, this.tileType, this.tileQ, this.tileR) {
    setPosition(Settings().getRotation());
  }

  setHexagon(Hexagon hexagonTile) {
    hexagon = hexagonTile;
  }

  Vector2 getPos() {
    return Vector2(tilePosition.x, tilePosition.y);
  }

  int getTileType() {
    return tileType;
  }

  setTileType(int tileType) {
    this.tileType = tileType;
  }

  updateTile(SpriteBatch? batches, int rotation) {
    int variant = 0;
    if (rotation % 2 == 1) {
      variant = 1;
    }
    if (batches != null) {
      batches.add(
          source: tileTextures[tileType][variant],
          offset: getPos(),
          scale: scaleX
      );
    }
  }

  setPosition(rotation) {
    tilePosition = getTilePosition(q, r, rotation);
  }

  Tile.fromJson(data) {
    tileType = data["type"];

    q = data['q'];
    r = data['r'];

    tileQ = data["q"];
    tileR = data["r"];

    tilePosition = Vector2(0, 0);
  }
}