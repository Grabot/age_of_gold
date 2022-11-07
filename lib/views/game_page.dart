
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../age_of_gold.dart';
import '../user_interface/chat_box.dart';
import '../user_interface/login_screen.dart';
import '../user_interface/tile_box.dart';

FocusNode gameFocus = FocusNode();

final game = AgeOfGold(gameFocus);

Widget gameWidget = Scaffold(
    body: GameWidget(
      focusNode: gameFocus,
      game: game,
      overlayBuilderMap: const {
        'chatBox': _chatBoxBuilder,
        'tileBox': _tileBoxBuilder
      },
      initialActiveOverlays: const [
        'chatBox',
        'tileBox'
      ],
    )
);


Widget _chatBoxBuilder(BuildContext buildContext, AgeOfGold game) {
  return ChatBox(key: UniqueKey(), game: game);
}

Widget _tileBoxBuilder(BuildContext buildContext, AgeOfGold game) {
  return TileBox(key: UniqueKey(), game: game);
}
