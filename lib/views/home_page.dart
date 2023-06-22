import 'package:age_of_gold/locator.dart';
import 'package:age_of_gold/services/auth_service_login.dart';
import 'package:age_of_gold/services/models/login_response.dart';
import 'package:age_of_gold/util/navigation_service.dart';
import 'package:age_of_gold/util/util.dart';
import 'package:age_of_gold/util/web_storage.dart';
import 'package:flutter/material.dart';
import '../age_of_gold.dart';
import 'login_screen.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:age_of_gold/constants/route_paths.dart' as routes;


class HomePage extends StatefulWidget {

  final AgeOfGold game;
  final LoginScreen loginScreen;

  const HomePage({
    Key? key,
    required this.game,
    required this.loginScreen
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final NavigationService _navigationService = locator<NavigationService>();

  bool showLogin = false;

  Future<bool> accessTokenLogin(String accessToken) async {
    try {
      LoginResponse loginResponse = await AuthServiceLogin().getTokenLogin(accessToken);
      if (loginResponse.getResult()) {
        print("access token still valid!");
        return true;
      } else if (!loginResponse.getResult()) {
        print("access token NOT valid!");
      }
    } catch(error) {
      showToastMessage(error.toString());
    }
    return false;
  }

  Future<bool> refreshTokenLogin(String accessToken, String refreshToken) async {
    try {
      LoginResponse loginResponse = await AuthServiceLogin().getRefresh(accessToken, refreshToken);
      if (loginResponse.getResult()) {
        print("access token still valid!");
        return true;
      } else if (!loginResponse.getResult()) {
        print("access token NOT valid!");
      }
    } catch(error) {
      showToastMessage(error.toString());
    }
    return false;
  }

  loginCheck(String path) async {
    SecureStorage _secureStorage = SecureStorage();
    String? accessToken = await _secureStorage.getAccessToken();
    int current = (DateTime.now().millisecondsSinceEpoch / 1000).round();

    if (accessToken != null && accessToken != "") {
      int expiration = Jwt.parseJwt(accessToken)['exp'];
      if ((expiration - current) > 0) {
        // token valid! Attempt to login with it.
        bool accessTokenSuccessful = await accessTokenLogin(accessToken);
        if (accessTokenSuccessful) {
          // Go to the game, unless you're already there.
          if (path != routes.GameRoute) {
            goToGame(_navigationService, widget.game);
          }
          return;
        }
      }

      // If there is an access token but it is not valid we might be able to refresh the tokens.
      String? refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken != null && refreshToken != "") {
        int expirationRefresh = Jwt.parseJwt(refreshToken)['exp'];
        if ((expirationRefresh - current) > 0) {
          // refresh token valid! Attempt to refresh tokens and login with it.
          bool refreshTokenSuccessful = await refreshTokenLogin(accessToken, refreshToken);
          if (refreshTokenSuccessful) {
            if (path != routes.GameRoute) {
              goToGame(_navigationService, widget.game);
            }
            return;
          }
        }
      }
    }

    setState(() {
      showLogin = true;
    });
  }

  @override
  void initState() {
    super.initState();
    String path = Uri.base.path;
    if (path == routes.HomeRoute || path == routes.GameRoute) {
      WidgetsFlutterBinding.ensureInitialized();
      WidgetsBinding.instance.addPostFrameCallback((_){
        loginCheck(path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          child: showLogin ? widget.loginScreen : Container()
        ),
      ),
    );
  }
}
