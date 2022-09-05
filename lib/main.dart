import 'package:age_of_gold/user_interface/tile_box.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flame/flame.dart';
import 'age_of_gold.dart';
import 'dart:async';
import 'package:age_of_gold/user_interface/chat_box.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Flame.device.setLandscape();

  Flame.images.loadAll(<String>[]);


  FocusNode gameFocus = FocusNode();
  // final tileBox = TileBox(key: UniqueKey(), game: game);
  final game = AgeOfGold(gameFocus);
  runApp(
      MaterialApp(
        home: Scaffold(
          // appBar: AppBar(title: Text('Age of gold')),
          body: GameWidget(
            focusNode: gameFocus,
            game: game,
            overlayBuilderMap: const {
              'chatBox': _chatBoxBuilder,
              'tileBox': _tileBoxBuilder
            },
            initialActiveOverlays: const [
              'chatBox'
            ],
        ),
      ),
    )
  );

}

Widget _chatBoxBuilder(BuildContext buildContext, AgeOfGold game) {
  return ChatBox(key: UniqueKey(), game: game);
}

Widget _tileBoxBuilder(BuildContext buildContext, AgeOfGold game) {
  return TileBox(key: UniqueKey(), game: game);
}

