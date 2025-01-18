import 'dart:async';
import 'dart:ui';
import 'package:age_of_gold/age_of_gold.dart';
import 'package:flutter/foundation.dart';
import 'package:age_of_gold/constants/route_paths.dart' as routes;
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:url_strategy/url_strategy.dart';

import 'locator.dart';
import 'services/settings.dart';
import 'util/navigation_service.dart';
import 'views/delete_account_page.dart';
import 'views/delete_page.dart';
import 'views/email_verification_page.dart';
import 'views/password_reset_page.dart';
import 'views/privacy_page.dart';
import 'views/terms_page.dart';
import 'views/user_interface/ui_views/are_you_sure_box/are_you_sure_box.dart';
import 'views/user_interface/ui_views/change_avatar_box/change_avatar_box.dart';
import 'views/user_interface/ui_views/change_guild_crest_box/change_guild_crest_box.dart';
import 'views/user_interface/ui_views/chat_box/chat_box.dart';
import 'views/user_interface/ui_views/chat_window/chat_window.dart';
import 'views/user_interface/ui_views/friend_window/friend_window.dart';
import 'views/user_interface/ui_views/guild_window/guild_window.dart';
import 'views/user_interface/ui_views/loading_box/loading_box.dart';
import 'views/user_interface/ui_views/login_view/login_window.dart';
import 'views/user_interface/ui_views/map_coordinates/map_coordinates.dart';
import 'views/user_interface/ui_views/map_coordintes_window/map_coordinates_window.dart';
import 'views/user_interface/ui_views/social_interaction/social_interaction.dart';
import 'views/user_interface/ui_views/web_view/web_view_box.dart';
import 'views/user_interface/ui_views/profile_box/profile_box.dart';
import 'views/user_interface/ui_views/profile_overview/profile_overview.dart';
import 'views/user_interface/ui_views/tile_box/tile_box.dart';
import 'views/user_interface/ui_views/user_box/user_box.dart';
import 'views/user_interface/ui_views/zoom_widget/zoom_widget.dart';
import 'views/world_access_page.dart';


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
      body: GameWidget(
        focusNode: gameFocus,
        game: game,
        overlayBuilderMap: const {
          'mapCoordinates': _mapCoordinatesBoxBuilder,
          'zoomWidget': _zoomWidgetBoxBuilder,
          'chatBox': _chatBoxBuilder,
          'loginWindow': _loginWindowBuilder,
          'mapCoordinatesWindow': _mapCoordinatesWindowBuilder,
          'tileBox': _tileBoxBuilder,
          'profileBox': _profileBoxBuilder,
          'socialInteraction': _socialInteractionBuilder,
          'profileOverview': _profileOverviewBuilder,
          'changeAvatar': _changeAvatarBoxBuilder,
          'chatWindow': _chatWindowBuilder,
          'friendWindow': _friendWindowBuilder,
          'userBox': _userBoxBuilder,
          'guildWindow': _guildWindowBoxBuilder,
          'changeGuildCrest': _changeGuildCrestBoxBuilder,
          'areYouSureBox': _areYouSureBoxBuilder,
          'webviewBox': _webViewBoxBuilder,
          'loadingBox': _loadingBoxBuilder,
        },
        initialActiveOverlays: const [
          'mapCoordinates',
          'zoomWidget',
          'chatBox',
          'loginWindow',
          'mapCoordinatesWindow',
          'tileBox',
          'profileBox',
          'socialInteraction',
          'profileOverview',
          'changeAvatar',
          'chatWindow',
          'friendWindow',
          'userBox',
          'guildWindow',
          'changeGuildCrest',
          'areYouSureBox',
          'webviewBox',
          'loadingBox',
        ],
      )
  );

  Widget worldAccess = WorldAccess(key: UniqueKey(), game: game);
  Widget emailVerification = EmailVerification(key: UniqueKey(), game: game);
  Widget passwordReset = PasswordReset(key: UniqueKey(), game: game);
  Widget privacy = PrivacyPage(key: UniqueKey());
  Widget terms = TermsPage(key: UniqueKey());
  Widget delete = DeletePage(key: UniqueKey());
  Widget deleteAccount = DeleteAccountPage(key: UniqueKey());

  runApp(
      OKToast(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
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
            routes.HomeRoute: (context) => gameWidget,
            routes.WorldAccessRoute: (context) => worldAccess,
            routes.EmailVerificationRoute: (context) => emailVerification,
            routes.PasswordResetRoute: (context) => passwordReset,
            routes.PrivacyRoute: (context) => privacy,
            routes.TermsRoute: (context) => terms,
            routes.DeleteRoute: (context) => delete,
            routes.DeleteAccountRoute: (context) => deleteAccount,
          },
          scrollBehavior: MyCustomScrollBehavior(),
          onGenerateRoute: (settings) {
            if (settings.name != null && settings.name!.startsWith(routes.WorldAccessRoute)) {
              return MaterialPageRoute(
                  builder: (context) {
                    return worldAccess;
                  }
              );
            } else if (settings.name!.startsWith(routes.EmailVerificationRoute)) {
              return MaterialPageRoute(
                  builder: (context) {
                    return emailVerification;
                  }
              );
            } else if (settings.name!.startsWith(routes.PasswordResetRoute)) {
              return MaterialPageRoute(
                  builder: (context) {
                    return passwordReset;
                  }
              );
            } else if (settings.name!.startsWith(routes.PrivacyRoute)) {
              return MaterialPageRoute(
                  builder: (context) {
                    return privacy;
                  }
              );
            } else if (settings.name!.startsWith(routes.TermsRoute)) {
              return MaterialPageRoute(
                  builder: (context) {
                    return terms;
                  }
              );
            } else if (settings.name!.startsWith(routes.DeleteRoute)) {
              return MaterialPageRoute(
                  builder: (context) {
                    return delete;
                  }
              );
            } else if (settings.name!.startsWith(routes.DeleteAccountRoute)) {
              return MaterialPageRoute(
                  builder: (context) {
                    return deleteAccount;
                  }
              );
            } else {
              return MaterialPageRoute(
                  builder: (context) {
                    return gameWidget;
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

Widget _loginWindowBuilder(BuildContext buildContext, AgeOfGold game) {
  return LoginWindow(key: UniqueKey(), game: game);
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

Widget _socialInteractionBuilder(BuildContext buildContext, AgeOfGold game) {
  return SocialInteraction(key: UniqueKey(), game: game);
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

Widget _webViewBoxBuilder(BuildContext buildContext, AgeOfGold game) {
  if (kIsWeb) {
    // If we are on the web, we can't use the web view
    // But we don't need to.
    // We load the LoadingBox to avoid initialization errors
    // But this view should never be opened in the web.
    return LoadingBox(key: UniqueKey(), game: game);
  }
  return WebViewBox(key: UniqueKey(), game: game);
}

Widget _areYouSureBoxBuilder(BuildContext buildContext, AgeOfGold game) {
  return AreYouSureBox(key: UniqueKey(), game: game);
}

Widget _mapCoordinatesBoxBuilder(BuildContext buildContext, AgeOfGold game) {
  return MapCoordinates(key: UniqueKey(), game: game);
}

Widget _zoomWidgetBoxBuilder(BuildContext buildContext, AgeOfGold game) {
  return ZoomWidget(key: UniqueKey(), game: game);
}

Widget _mapCoordinatesWindowBuilder(BuildContext buildContext, AgeOfGold game) {
  return MapCoordinatesWindow(key: UniqueKey(), game: game);
}

Widget _chatWindowBuilder(BuildContext buildContext, AgeOfGold game) {
  return ChatWindow(key: UniqueKey(), game: game);
}

Widget _friendWindowBuilder(BuildContext buildContext, AgeOfGold game) {
  return FriendWindow(key: UniqueKey(), game: game);
}

Widget _guildWindowBoxBuilder(BuildContext buildContext, AgeOfGold game) {
  return GuildWindow(key: UniqueKey(), game: game);
}

Widget _changeGuildCrestBoxBuilder(BuildContext buildContext, AgeOfGold game) {
  return ChangeGuildCrestBox(key: UniqueKey(), game: game);
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
  };
}
