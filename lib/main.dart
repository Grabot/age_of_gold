import 'dart:async';
import 'package:age_of_gold/services/settings.dart';
import 'package:age_of_gold/user_interface/login_screen.dart';
import 'package:age_of_gold/views/game_page.dart';
import 'package:age_of_gold/views/home_page.dart';
import 'package:age_of_gold/views/world_access_page.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:url_strategy/url_strategy.dart';


Future<void> main() async {
  setPathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();

  // initialize the settings singleton
  Settings();
  Flame.images.loadAll(<String>[]);

  LoginScreen loginScreen = LoginScreen(key: UniqueKey(), game: game);
  Widget home = HomePage(key: UniqueKey(), game: game, loginScreen: loginScreen);
  Widget worldAccess = WorldAccess(key: UniqueKey(), game: game);

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
        HomePage.route: (context) => home,
        WorldAccess.route: (context) => worldAccess,
        "/world": (context) => gameWidget,
      },
      onGenerateRoute: (settings) {
        // URI test
        if (settings.name != null && settings.name!.startsWith(WorldAccess.route)) {
          return MaterialPageRoute(
              builder: (context) {
                return worldAccess;
              }
          );
        }
      },
    )
  );
}
