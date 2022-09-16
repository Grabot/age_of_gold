import 'package:age_of_gold/component/get_texture.dart';
import 'package:flame/sprite.dart';
import '../tile.dart';


// b44ac0
class TileAmethyst extends Tile {

  TileAmethyst(super.q, super.r, super.tileType, super.tileQ, super.tileR);

  @override
  updateBaseTile(SpriteBatch baseBatch) {
    baseBatch.add(
        source: tileAmethyst1,
        offset: getPos(),
        scale: scaleX
    );
  }

  @override
  updateBaseVariation1(SpriteBatch variation1) {
    variation1.add(
        source: tileAmethyst2,
        offset: getPos(),
        scale: scaleX
    );
  }

  @override
  updateBaseVariation2(SpriteBatch variation2) {
    variation2.add(
        source: tileAmethyst3,
        offset: getPos(),
        scale: scaleX
    );
  }

  @override
  updateBaseVariation3(SpriteBatch variation3) {
    variation3.add(
        source: tileAmethyst4,
        offset: getPos(),
        scale: scaleX
    );
  }

  @override
  updateBaseVariation4(SpriteBatch variation4) {
    variation4.add(
        source: tileAmethyst5,
        offset: getPos(),
        scale: scaleX
    );
  }

  @override
  updateBaseVariation5(SpriteBatch variation5) {
    variation5.add(
        source: tileAmethyst6,
        offset: getPos(),
        scale: scaleX
    );
  }

  @override
  updateBaseVariation6(SpriteBatch variation6) {
    variation6.add(
        source: tileAmethyst7,
        offset: getPos(),
        scale: scaleX
    );
  }

  @override
  updateBaseVariation7(SpriteBatch variation7) {
    variation7.add(
        source: tileAmethyst8,
        offset: getPos(),
        scale: scaleX
    );
  }

  @override
  updateBaseVariation8(SpriteBatch variation8) {
    variation8.add(
        source: tileAmethyst9,
        offset: getPos(),
        scale: scaleX
    );
  }

  @override
  updateBaseVariation9(SpriteBatch variation9) {
    variation9.add(
        source: tileAmethyst10,
        offset: getPos(),
        scale: scaleX
    );
  }

  @override
  updateBaseVariation10(SpriteBatch variation10) {
    variation10.add(
        source: tileAmethyst11,
        offset: getPos(),
        scale: scaleX
    );
  }

  @override
  updateBaseVariation11(SpriteBatch variation11) {
    variation11.add(
        source: tileAmethyst12,
        offset: getPos(),
        scale: scaleX
    );
  }
}
