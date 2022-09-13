import 'package:age_of_gold/component/get_texture.dart';
import 'package:flame/sprite.dart';
import '../tile.dart';


// 00a368
class TileGreenHaze extends Tile {
  TileGreenHaze(super.q, super.r, super.tileType, super.tileQ, super.tileR);

  @override
  updateBaseTile(SpriteBatch baseBatch, int rotate) {
    baseBatch.add(
        source: tileGreenHaze1,
        offset: getPos(rotate),
        scale: scaleX
    );
  }

  @override
  updateBaseVariation1(SpriteBatch variation1, int rotate) {
    variation1.add(
        source: tileGreenHaze2,
        offset: getPos(rotate),
        scale: scaleX
    );
  }

  @override
  updateBaseVariation2(SpriteBatch variation2, int rotate) {
    variation2.add(
        source: tileGreenHaze3,
        offset: getPos(rotate),
        scale: scaleX
    );
  }

  @override
  updateBaseVariation3(SpriteBatch variation3, int rotate) {
    variation3.add(
        source: tileGreenHaze4,
        offset: getPos(rotate),
        scale: scaleX
    );
  }

  @override
  updateBaseVariation4(SpriteBatch variation4, int rotate) {
    variation4.add(
        source: tileGreenHaze5,
        offset: getPos(rotate),
        scale: scaleX
    );
  }

  @override
  updateBaseVariation5(SpriteBatch variation5, int rotate) {
    variation5.add(
        source: tileGreenHaze6,
        offset: getPos(rotate),
        scale: scaleX
    );
  }

  @override
  updateBaseVariation6(SpriteBatch variation6, int rotate) {
    variation6.add(
        source: tileGreenHaze7,
        offset: getPos(rotate),
        scale: scaleX
    );
  }

  @override
  updateBaseVariation7(SpriteBatch variation7, int rotate) {
    variation7.add(
        source: tileGreenHaze8,
        offset: getPos(rotate),
        scale: scaleX
    );
  }

  @override
  updateBaseVariation8(SpriteBatch variation8, int rotate) {
    variation8.add(
        source: tileGreenHaze9,
        offset: getPos(rotate),
        scale: scaleX
    );
  }

  @override
  updateBaseVariation9(SpriteBatch variation9, int rotate) {
    variation9.add(
        source: tileGreenHaze10,
        offset: getPos(rotate),
        scale: scaleX
    );
  }

  @override
  updateBaseVariation10(SpriteBatch variation10, int rotate) {
    variation10.add(
        source: tileGreenHaze11,
        offset: getPos(rotate),
        scale: scaleX
    );
  }

  @override
  updateBaseVariation11(SpriteBatch variation11, int rotate) {
    variation11.add(
        source: tileGreenHaze12,
        offset: getPos(rotate),
        scale: scaleX
    );
  }
}
