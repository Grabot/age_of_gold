import 'dart:async';

import 'package:age_of_gold/constants/route_paths.dart' as routes;
import 'package:age_of_gold/locator.dart';
import 'package:age_of_gold/services/settings.dart';
import 'package:age_of_gold/util/navigation_service.dart';
import 'package:age_of_gold/views/email_verification_page.dart';
import 'package:age_of_gold/views/home_page.dart';
import 'package:age_of_gold/views/login_screen.dart';
import 'package:age_of_gold/views/password_reset_page.dart';
import 'package:age_of_gold/views/user_interface/ui_views/change_avatar_box.dart';
import 'package:age_of_gold/views/world_access_page.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:url_strategy/url_strategy.dart';

import 'age_of_gold.dart';
import 'views/user_interface/ui_views/chat_box.dart';
import 'views/user_interface/ui_views/chat_window.dart';
import 'views/user_interface/ui_views/loading_box.dart';
import 'views/user_interface/ui_views/profile_box.dart';
import 'views/user_interface/ui_views/profile_overview.dart';
import 'views/user_interface/ui_views/tile_box.dart';
import 'views/user_interface/ui_views/user_box.dart';


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
          'profileBox': _profileBoxBuilder,
          'profileOverview': _profileOverviewBuilder,
          'userBox': _userBoxBuilder,
          'changeAvatar': _changeAvatarBoxBuilder,
          'loadingBox': _loadingBoxBuilder,
          'chatWindow': _chatWindowBuilder,
        },
        initialActiveOverlays: const [
          'chatBox',
          'tileBox',
          'profileBox',
          'profileOverview',
          'userBox',
          'changeAvatar',
          'loadingBox',
          'chatWindow',
        ],
      )
  );

  LoginScreen loginScreen = LoginScreen(key: UniqueKey(), game: game);
  Widget home = HomePage(key: UniqueKey(), game: game, loginScreen: loginScreen);
  Widget worldAccess = WorldAccess(key: UniqueKey(), game: game);
  Widget passwordReset = PasswordReset(key: UniqueKey(), game: game);
  Widget emailVerification = EmailVerification(key: UniqueKey(), game: game);

  runApp(
      OKToast(
        child: MaterialApp(
          title: "Age of Gold",
          navigatorKey: locator<NavigationService>().navigatorKey,
          theme: ThemeData(
            // Define the default brightness and colors.
            brightness: Brightness.dark,
            primaryColor: Colors.lightBlue,
            // Define the default font family.
            fontFamily: 'Georgia',
          ),
          initialRoute: '/',
          routes: {
            routes.HomeRoute: (context) => home,
            routes.WorldAccessRoute: (context) => worldAccess,
            routes.GameRoute: (context) => gameWidget,
            routes.PasswordResetRoute: (context) => passwordReset,
            routes.EmailVerificationRoute: (context) => emailVerification
          },
          onGenerateRoute: (settings) {
            if (settings.name != null && settings.name!.startsWith(routes.WorldAccessRoute)) {
              return MaterialPageRoute(
                  builder: (context) {
                    return worldAccess;
                  }
              );
            } else if (settings.name!.startsWith(routes.GameRoute)) {
              return MaterialPageRoute(
                  builder: (context) {
                    return gameWidget;
                  }
              );
            } else if (settings.name!.startsWith(routes.PasswordResetRoute)) {
              return MaterialPageRoute(
                  builder: (context) {
                    return passwordReset;
                  }
              );
            } else if (settings.name!.startsWith(routes.EmailVerificationRoute)) {
              return MaterialPageRoute(
                  builder: (context) {
                    return emailVerification;
                  }
              );
            } else {
              return MaterialPageRoute(
                  builder: (context) {
                    return home;
                  }
              );
            }
          },
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

Widget _profileBoxBuilder(BuildContext buildContext, AgeOfGold game) {
  return ProfileBox(key: UniqueKey(), game: game);
}

Widget _profileOverviewBuilder(BuildContext buildContext, AgeOfGold game) {
  return ProfileOverview(key: UniqueKey(), game: game);
}

Widget _userBoxBuilder(BuildContext buildContext, AgeOfGold game) {
  return UserBox(key: UniqueKey(), game: game);
}

Widget _changeAvatarBoxBuilder(BuildContext buildContext, AgeOfGold game) {
  return ChangeAvatarBox(key: UniqueKey(), game: game);
}

Widget _loadingBoxBuilder(BuildContext buildContext, AgeOfGold game) {
  return LoadingBox(key: UniqueKey(), game: game);
}

Widget _chatWindowBuilder(BuildContext buildContext, AgeOfGold game) {
  return ChatWindow(key: UniqueKey(), game: game);
}