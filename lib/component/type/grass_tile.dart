
import 'package:age_of_gold/component/get_texture.dart';
import 'package:flame/sprite.dart';

import '../tile.dart';

class GrassTile extends Tile {

  GrassTile(super.q, super.r, super.tileType, super.tileQ, super.tileR);

  @override
  updateBaseTile(SpriteBatch baseBatch, int rotate) {
    baseBatch.add(
        source: flatSmallGrass1,
        offset: getPos(rotate),
        scale: scaleX
    );
  }
}
