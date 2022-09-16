import 'package:age_of_gold/component/get_texture.dart';
import 'package:flame/sprite.dart';
import '../tile.dart';


// 2450a4
class TileCeruleanBlue extends Tile {
  TileCeruleanBlue(super.q, super.r, super.tileType, super.tileQ, super.tileR);

  @override
  updateTile(List<SpriteBatch?> batches) {
    for (int variation = 0; variation < batches.length; variation++) {
      if (batches[variation] != null) {
        batches[variation]!.add(
            source: tileCeruleanBlue[variation],
            offset: getPos(),
            scale: scaleX
        );
      }
    }
  }
}
