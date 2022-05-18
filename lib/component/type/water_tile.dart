
import 'package:flame/sprite.dart';

import '../get_texture.dart';
import '../tile.dart';

class WaterTile extends Tile {

  WaterTile(super.q, super.r, super.s, super.tileType);

  @override
  updateBaseTile(SpriteBatch baseBatch, int rotate) {
    print("update water");
    baseBatch.add(
        source: flatSmallWater1,
        offset: getPos(rotate),
        scale: scaleX
    );
  }

  @override
  updateBaseVariation1(SpriteBatch baseBatch, int rotate) {
    print("add variation water");
    baseBatch.add(
        source: flatSmallWater2,
        offset: getPos(rotate),
        scale: scaleX
    );
  }
}
