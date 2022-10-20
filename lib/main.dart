import 'package:age_of_gold/user_interface/login_screen.dart';
import 'package:age_of_gold/user_interface/tile_box.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flame/flame.dart';
import 'age_of_gold.dart';
import 'dart:async';
import 'package:age_of_gold/user_interface/chat_box.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Flame.images.loadAll(<String>[]);


  FocusNode gameFocus = FocusNode();

  final game = AgeOfGold(gameFocus);
  runApp(
      MaterialApp(
        home: Scaffold(
          appBar: appBarAgeOfGold(),
          body: GameWidget(
            focusNode: gameFocus,
            game: game,
            overlayBuilderMap: const {
              'chatBox': _chatBoxBuilder,
              'tileBox': _tileBoxBuilder,
              'loginScreen': _userLoginSignupBuilder
            },
            initialActiveOverlays: const [
              'chatBox',
              'tileBox',
              'loginScreen'
            ],
        ),
      ),
    )
  );
}

AppBar appBarAgeOfGold() {
  return AppBar(
    toolbarHeight: 80,
    title: const Text('Age of gold'),
    elevation: 0,
    backgroundColor: Colors.orange,
    flexibleSpace: Container(
      color: Colors.orange,
    ),
    actions: <Widget>[
      Container(
          width: 100,
          child: Column(
            children: [
              const SizedBox(height: 10),
              IconButton(
                icon: const Icon(Icons.account_circle_rounded),
                onPressed: () {
                  print("pressed this");
                },
              ),
              const Text("not logged in")
            ],
          )
      ),
    ],
  );
}

Widget _chatBoxBuilder(BuildContext buildContext, AgeOfGold game) {
  return ChatBox(key: UniqueKey(), game: game);
}

Widget _tileBoxBuilder(BuildContext buildContext, AgeOfGold game) {
  return TileBox(key: UniqueKey(), game: game);
}

Widget _userLoginSignupBuilder(BuildContext buildContext, AgeOfGold game) {
  return LoginScreen(key: UniqueKey(), game: game);
}