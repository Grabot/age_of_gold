import 'package:age_of_gold/component/get_texture.dart';
import 'package:flame/sprite.dart';
import '../tile.dart';


// d4d7d9
class TileIron extends Tile {
  TileIron(super.q, super.r, super.tileType, super.tileQ, super.tileR);

  @override
  updateBaseTile(SpriteBatch baseBatch, int rotate) {
    baseBatch.add(
        source: tileIron1,
        offset: getPos(rotate),
        scale: scaleX
    );
  }

  @override
  updateBaseVariation1(SpriteBatch variation1, int rotate) {
    variation1.add(
        source: tileIron2,
        offset: getPos(rotate),
        scale: scaleX
    );
  }

  @override
  updateBaseVariation2(SpriteBatch variation2, int rotate) {
    variation2.add(
        source: tileIron3,
        offset: getPos(rotate),
        scale: scaleX
    );
  }

  @override
  updateBaseVariation3(SpriteBatch variation3, int rotate) {
    variation3.add(
        source: tileIron4,
        offset: getPos(rotate),
        scale: scaleX
    );
  }

  @override
  updateBaseVariation4(SpriteBatch variation4, int rotate) {
    variation4.add(
        source: tileIron5,
        offset: getPos(rotate),
        scale: scaleX
    );
  }

  @override
  updateBaseVariation5(SpriteBatch variation5, int rotate) {
    variation5.add(
        source: tileIron6,
        offset: getPos(rotate),
        scale: scaleX
    );
  }

  @override
  updateBaseVariation6(SpriteBatch variation6, int rotate) {
    variation6.add(
        source: tileIron7,
        offset: getPos(rotate),
        scale: scaleX
    );
  }

  @override
  updateBaseVariation7(SpriteBatch variation7, int rotate) {
    variation7.add(
        source: tileIron8,
        offset: getPos(rotate),
        scale: scaleX
    );
  }

  @override
  updateBaseVariation8(SpriteBatch variation8, int rotate) {
    variation8.add(
        source: tileIron9,
        offset: getPos(rotate),
        scale: scaleX
    );
  }

  @override
  updateBaseVariation9(SpriteBatch variation9, int rotate) {
    variation9.add(
        source: tileIron10,
        offset: getPos(rotate),
        scale: scaleX
    );
  }

  @override
  updateBaseVariation10(SpriteBatch variation10, int rotate) {
    variation10.add(
        source: tileIron11,
        offset: getPos(rotate),
        scale: scaleX
    );
  }

  @override
  updateBaseVariation11(SpriteBatch variation11, int rotate) {
    variation11.add(
        source: tileIron12,
        offset: getPos(rotate),
        scale: scaleX
    );
  }
}
