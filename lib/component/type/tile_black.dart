import 'package:age_of_gold/component/get_texture.dart';
import 'package:flame/sprite.dart';
import '../tile.dart';


// 000000
class TileBlack extends Tile {
  TileBlack(super.q, super.r, super.tileType, super.tileQ, super.tileR);

  @override
  updateBaseTile(SpriteBatch baseBatch) {
    baseBatch.add(
        source: tileBlack1,
        offset: getPos(),
        scale: scaleX
    );
  }

  @override
  updateBaseVariation1(SpriteBatch variation1) {
    variation1.add(
        source: tileBlack2,
        offset: getPos(),
        scale: scaleX
    );
  }

  @override
  updateBaseVariation2(SpriteBatch variation2) {
    variation2.add(
        source: tileBlack3,
        offset: getPos(),
        scale: scaleX
    );
  }

  @override
  updateBaseVariation3(SpriteBatch variation3) {
    variation3.add(
        source: tileBlack4,
        offset: getPos(),
        scale: scaleX
    );
  }

  @override
  updateBaseVariation4(SpriteBatch variation4) {
    variation4.add(
        source: tileBlack5,
        offset: getPos(),
        scale: scaleX
    );
  }

  @override
  updateBaseVariation5(SpriteBatch variation5) {
    variation5.add(
        source: tileBlack6,
        offset: getPos(),
        scale: scaleX
    );
  }

  @override
  updateBaseVariation6(SpriteBatch variation6) {
    variation6.add(
        source: tileBlack7,
        offset: getPos(),
        scale: scaleX
    );
  }

  @override
  updateBaseVariation7(SpriteBatch variation7) {
    variation7.add(
        source: tileBlack8,
        offset: getPos(),
        scale: scaleX
    );
  }

  @override
  updateBaseVariation8(SpriteBatch variation8) {
    variation8.add(
        source: tileBlack9,
        offset: getPos(),
        scale: scaleX
    );
  }

  @override
  updateBaseVariation9(SpriteBatch variation9) {
    variation9.add(
        source: tileBlack10,
        offset: getPos(),
        scale: scaleX
    );
  }

  @override
  updateBaseVariation10(SpriteBatch variation10) {
    variation10.add(
        source: tileBlack11,
        offset: getPos(),
        scale: scaleX
    );
  }

  @override
  updateBaseVariation11(SpriteBatch variation11) {
    variation11.add(
        source: tileBlack12,
        offset: getPos(),
        scale: scaleX
    );
  }
}
