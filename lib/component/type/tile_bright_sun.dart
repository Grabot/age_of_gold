import 'package:age_of_gold/component/get_texture.dart';
import 'package:flame/sprite.dart';
import '../tile.dart';


// ffd635
class TileBrightSun extends Tile {
  TileBrightSun(super.q, super.r, super.tileType, super.tileQ, super.tileR);

  @override
  updateBaseTile(SpriteBatch baseBatch) {
    baseBatch.add(
        source: tileBrightSun1,
        offset: getPos(),
        scale: scaleX
    );
  }

  @override
  updateBaseVariation1(SpriteBatch variation1) {
    variation1.add(
        source: tileBrightSun2,
        offset: getPos(),
        scale: scaleX
    );
  }

  @override
  updateBaseVariation2(SpriteBatch variation2) {
    variation2.add(
        source: tileBrightSun3,
        offset: getPos(),
        scale: scaleX
    );
  }

  @override
  updateBaseVariation3(SpriteBatch variation3) {
    variation3.add(
        source: tileBrightSun4,
        offset: getPos(),
        scale: scaleX
    );
  }

  @override
  updateBaseVariation4(SpriteBatch variation4) {
    variation4.add(
        source: tileBrightSun5,
        offset: getPos(),
        scale: scaleX
    );
  }

  @override
  updateBaseVariation5(SpriteBatch variation5) {
    variation5.add(
        source: tileBrightSun6,
        offset: getPos(),
        scale: scaleX
    );
  }

  @override
  updateBaseVariation6(SpriteBatch variation6) {
    variation6.add(
        source: tileBrightSun7,
        offset: getPos(),
        scale: scaleX
    );
  }

  @override
  updateBaseVariation7(SpriteBatch variation7) {
    variation7.add(
        source: tileBrightSun8,
        offset: getPos(),
        scale: scaleX
    );
  }

  @override
  updateBaseVariation8(SpriteBatch variation8) {
    variation8.add(
        source: tileBrightSun9,
        offset: getPos(),
        scale: scaleX
    );
  }

  @override
  updateBaseVariation9(SpriteBatch variation9) {
    variation9.add(
        source: tileBrightSun10,
        offset: getPos(),
        scale: scaleX
    );
  }

  @override
  updateBaseVariation10(SpriteBatch variation10) {
    variation10.add(
        source: tileBrightSun11,
        offset: getPos(),
        scale: scaleX
    );
  }

  @override
  updateBaseVariation11(SpriteBatch variation11) {
    variation11.add(
        source: tileBrightSun12,
        offset: getPos(),
        scale: scaleX
    );
  }
}
