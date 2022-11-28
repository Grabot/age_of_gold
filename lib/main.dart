import 'dart:async';
import 'package:age_of_gold/services/settings.dart';
import 'package:age_of_gold/views/game_page.dart';
import 'package:age_of_gold/views/home_page.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:url_strategy/url_strategy.dart';


Future<void> main() async {
  setPathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();

  // initialize the settings singleton
  Settings();
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
      onGenerateRoute: (settings) {
        // URI test
        if (settings.name != null && settings.name!.startsWith("/world")) {
          String baseUrl = Uri.base.toString(); //get complete url
          String? accessToken = Uri.base.queryParameters["access_token"];
          String? refreshToken = Uri.base.queryParameters["refresh_token"];

          print("settings: ${settings.name}");
          print("base: $baseUrl");
          print("access token: $accessToken");
          print("refresh token: $refreshToken");
          return MaterialPageRoute(
              builder: (context) {
                return gameWidget;
              }
          );
        }
      },
    )
  );
}
