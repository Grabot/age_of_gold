import 'dart:async';

import 'package:age_of_gold/views/game_page.dart';
import 'package:age_of_gold/views/home_page.dart';
import 'package:age_of_gold/views/page_one.dart';
import 'package:age_of_gold/views/page_two.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Flame.images.loadAll(<String>[]);

  runApp(
      MaterialApp(
      initialRoute: '/',
      routes: {
        HomePage.route: (context) => HomePage(),
        PageOne.route: (context) => PageOne(),
        PageTwo.route: (context) => PageTwo(),
        "/world": (context) => gameWidget,
      },
    )
  );
}
