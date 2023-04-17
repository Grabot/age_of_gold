import 'package:age_of_gold/locator.dart';
import 'package:age_of_gold/services/auth_service_login.dart';
import 'package:age_of_gold/util/navigation_service.dart';
import 'package:age_of_gold/util/util.dart';
import 'package:age_of_gold/util/web_storage.dart';
import 'package:flutter/material.dart';
import '../age_of_gold.dart';
import 'login_screen.dart';
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

  @override
  void initState() {
    super.initState();
    String path = Uri.base.path;
    if (path == "/") {
      WidgetsFlutterBinding.ensureInitialized();
      SecureStorage _secureStorage = SecureStorage();
      _secureStorage.getAccessToken().then((accessToken) {
        if (accessToken != null && accessToken != "") {
          // Something is stored, check if the user can just
          // log in automatically using the access token
          AuthServiceLogin authService = AuthServiceLogin();
          authService.getTokenLogin(accessToken).then((loginResponse) {
            if (loginResponse.getResult()) {
              print("access token still valid!");
              goToGame(_navigationService, widget.game);
            } else if (!loginResponse.getResult()) {
              print("access token login debug: ${loginResponse.getMessage()}");
              setState(() {
                showLogin = true;
              });
            }
          }).onError((error, stackTrace) {
            showToastMessage(error.toString());
            setState(() {
              showLogin = true;
            });
          });
        } else {
          setState(() {
            showLogin = true;
          });
        }
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
