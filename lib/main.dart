import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flame/flame.dart';
import 'age_of_gold.dart';
import 'dart:async';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.setLandscape();

  Flame.images.loadAll(<String>[
  ]);

  final game = AgeOfGold();

  runApp(GameWidget(game: game));
}
