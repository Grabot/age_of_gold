import 'package:flame/components.dart';
import 'package:age_of_gold/game/game.dart';

class CounterComponent extends PositionComponent
    with HasGameReference<AgeOfGold> {
  CounterComponent({required super.position}) : super(anchor: Anchor.center);

  late final TextComponent text;

  @override
  Future<void> onLoad() async {
    await add(
      text = TextComponent(
        anchor: Anchor.center,
        textRenderer: TextPaint(style: game.textStyle),
      ),
    );
  }

  @override
  void update(double dt) {
    text.text = game.l10n.counterText(game.counter);
  }
}
