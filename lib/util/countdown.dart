import 'package:flutter/material.dart';


class Countdown extends AnimatedWidget {
  Countdown({required Key key, required this.animation}) : super(key: key, listenable: animation);
  Animation<int> animation;

  @override
  build(BuildContext context) {
    Duration clockTimer = Duration(seconds: animation.value);

    String timerText =
        '${clockTimer.inMinutes.remainder(60).toString()}:${clockTimer.inSeconds.remainder(60).toString().padLeft(2, '0')}';

    return Text(
      "Tile lock\n$timerText\nremaining",
      style: const TextStyle(
        fontSize: 20,
        color: Colors.white54,
      ),
    );
  }
}
