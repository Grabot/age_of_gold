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
              'miniMap': _miniMapBuilder
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

Widget _miniMapBuilder(BuildContext buildContext, AgeOfGold game) {
  return Center(
    child: Align(
      alignment: FractionalOffset.topRight,
      child: Container(
        width: 400,
        height: 100,
        color: Colors.orange,
        child: const Center(
          child: Text('Possible Flutter Minimap'),
        ),
      ),
    ),
  );
}

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Flame.device.setLandscape();
//
//   Flame.images.loadAll(<String>[
//   ]);
//
//   final game = AgeOfGold();
//
//   runApp(GameWidget(game: game));
// }
