import 'dart:async';
import 'package:age_of_gold/locator.dart';
import 'package:age_of_gold/services/settings.dart';
import 'package:age_of_gold/user_interface/chat_box.dart';
import 'package:age_of_gold/user_interface/user_profile.dart';
import 'package:age_of_gold/util/navigation_service.dart';
import 'package:age_of_gold/views/login_screen.dart';
import 'package:age_of_gold/user_interface/tile_box.dart';
import 'package:age_of_gold/constants/route_paths.dart' as routes;
import 'package:age_of_gold/views/home_page.dart';
import 'package:age_of_gold/views/world_access_page.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:url_strategy/url_strategy.dart';

import 'age_of_gold.dart';


Future<void> main() async {
  setPathUrlStrategy();
  setupLocator();
  WidgetsFlutterBinding.ensureInitialized();

  // initialize the settings singleton
  Settings();
  Flame.images.loadAll(<String>[]);

  FocusNode gameFocus = FocusNode();

  final game = AgeOfGold(gameFocus);

  Widget gameWidget = Scaffold(
    // appBar: appBarAgeOfGold(),
      body: GameWidget(
        focusNode: gameFocus,
        game: game,
        overlayBuilderMap: const {
          'chatBox': _chatBoxBuilder,
          'tileBox': _tileBoxBuilder,
          'userProfile': _userProfileBuilder
        },
        initialActiveOverlays: const [
          'chatBox',
          'tileBox',
          'userProfile'
        ],
      )
  );

  LoginScreen loginScreen = LoginScreen(key: UniqueKey(), game: game);
  Widget home = HomePage(key: UniqueKey(), game: game, loginScreen: loginScreen);
  Widget worldAccess = WorldAccess(key: UniqueKey(), game: game);

  runApp(
      MaterialApp(
      title: "Age of Gold",
      navigatorKey: locator<NavigationService>().navigatorKey,
      theme: ThemeData(
        // Define the default brightness and colors.
        brightness: Brightness.dark,
        primaryColor: Colors.lightBlue[800],
        // Define the default font family.
        fontFamily: 'Georgia',
      ),
      initialRoute: '/',
      routes: {
        routes.HomeRoute: (context) => home,
        routes.WorldAccessRoute: (context) => worldAccess,
        "/world": (context) => gameWidget,
      },
      onGenerateRoute: (settings) {
        print("on generate rout thingie");
        if (settings.name != null && settings.name!.startsWith(routes.WorldAccessRoute)) {
          return MaterialPageRoute(
              builder: (context) {
                return worldAccess;
              }
          );
        }
        switch (settings.name) {
          case routes.HomeRoute:
            print("case home");
            return MaterialPageRoute(
                builder: (context) => home);
          case routes.GameRoute:
            print("case game");
            return MaterialPageRoute(builder: (context) => gameWidget);
          default:
            print("case default");
            return MaterialPageRoute(
              builder: (context) =>
                  Scaffold(
                    body: Center(
                      child: Text('No path for ${settings.name}'),
                    ),
                  ),
            );
        }
      },
    )
  );
}

Widget _chatBoxBuilder(BuildContext buildContext, AgeOfGold game) {
  return ChatBox(key: UniqueKey(), game: game);
}

Widget _tileBoxBuilder(BuildContext buildContext, AgeOfGold game) {
  return TileBox(key: UniqueKey(), game: game);
}

Widget _userProfileBuilder(BuildContext buildContext, AgeOfGold game) {
  return UserProfile(key: UniqueKey(), game: game);
}