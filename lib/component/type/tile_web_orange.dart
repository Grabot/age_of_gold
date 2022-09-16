import 'package:age_of_gold/component/get_texture.dart';
import 'package:flame/sprite.dart';
import '../tile.dart';


// ffa800
class TileWebOrange extends Tile {
  TileWebOrange(super.q, super.r, super.tileType, super.tileQ, super.tileR);

  @override
  updateBaseTile(SpriteBatch baseBatch) {
    baseBatch.add(
        source: tileWebOrange1,
        offset: getPos(),
        scale: scaleX
    );
  }

  @override
  updateBaseVariation1(SpriteBatch variation1) {
    variation1.add(
        source: tileWebOrange2,
        offset: getPos(),
        scale: scaleX
    );
  }

  @override
  updateBaseVariation2(SpriteBatch variation2) {
    variation2.add(
        source: tileWebOrange3,
        offset: getPos(),
        scale: scaleX
    );
  }

  @override
  updateBaseVariation3(SpriteBatch variation3) {
    variation3.add(
        source: tileWebOrange4,
        offset: getPos(),
        scale: scaleX
    );
  }

  @override
  updateBaseVariation4(SpriteBatch variation4) {
    variation4.add(
        source: tileWebOrange5,
        offset: getPos(),
        scale: scaleX
    );
  }

  @override
  updateBaseVariation5(SpriteBatch variation5) {
    variation5.add(
        source: tileWebOrange6,
        offset: getPos(),
        scale: scaleX
    );
  }

  @override
  updateBaseVariation6(SpriteBatch variation6) {
    variation6.add(
        source: tileWebOrange7,
        offset: getPos(),
        scale: scaleX
    );
  }

  @override
  updateBaseVariation7(SpriteBatch variation7) {
    variation7.add(
        source: tileWebOrange8,
        offset: getPos(),
        scale: scaleX
    );
  }

  @override
  updateBaseVariation8(SpriteBatch variation8) {
    variation8.add(
        source: tileWebOrange9,
        offset: getPos(),
        scale: scaleX
    );
  }

  @override
  updateBaseVariation9(SpriteBatch variation9) {
    variation9.add(
        source: tileWebOrange10,
        offset: getPos(),
        scale: scaleX
    );
  }

  @override
  updateBaseVariation10(SpriteBatch variation10) {
    variation10.add(
        source: tileWebOrange11,
        offset: getPos(),
        scale: scaleX
    );
  }

  @override
  updateBaseVariation11(SpriteBatch variation11) {
    variation11.add(
        source: tileWebOrange12,
        offset: getPos(),
        scale: scaleX
    );
  }
}
