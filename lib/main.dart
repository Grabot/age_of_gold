import 'dart:async';
import 'package:age_of_gold/views/game_page.dart';
import 'package:age_of_gold/views/home_page.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:url_strategy/url_strategy.dart';


Future<void> main() async {
  setPathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();

  Flame.images.loadAll(<String>[]);

  runApp(
      MaterialApp(
      theme: ThemeData(
        // Define the default brightness and colors.
        brightness: Brightness.dark,
        primaryColor: Colors.lightBlue[800],
        // Define the default font family.
        fontFamily: 'Georgia',
      ),
      initialRoute: '/',
      routes: {
        HomePage.route: (context) => HomePage(key: UniqueKey(), game: game),
        "/world": (context) => gameWidget,
      },
    )
  );
}
