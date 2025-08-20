import 'package:audioplayers/audioplayers.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:age_of_gold/game/game.dart';
import 'package:age_of_gold/gen/assets.gen.dart';

class TappingBehavior extends Behavior<Unicorn>
    with TapCallbacks, HasGameReference<AgeOfGold> {
  @override
  bool containsLocalPoint(Vector2 point) {
    return parent.containsLocalPoint(point);
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (parent.isAnimationPlaying()) {
      return;
    }
    game.counter++;
    parent.playAnimation();

    game.effectPlayer.play(AssetSource(Assets.audio.effect));
  }
}
