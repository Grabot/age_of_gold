import 'package:age_of_gold/locator.dart';
import 'package:age_of_gold/services/auth_service.dart';
import 'package:age_of_gold/services/settings.dart';
import 'package:age_of_gold/util/navigation_service.dart';
import 'package:age_of_gold/util/web_storage.dart';
import 'package:flutter/material.dart';
import 'package:age_of_gold/constants/route_paths.dart' as routes;
import '../age_of_gold.dart';


class ProfilePage extends StatefulWidget {

  final AgeOfGold game;

  const ProfilePage({
    Key? key,
    required this.game
  }) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  final NavigationService _navigationService = locator<NavigationService>();

  bool showLogin = false;

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    Settings settings = Settings();
    if (settings.getUser() == null) {
      // User was not found, maybe not logged in?! or refreshed?!
      // Find accessToken to quickly fix this.
      String accessToken = settings.getAccessToken();
      if (accessToken != "") {
        logIn(accessToken);
      } else {
        // Also no accessToken found in settings. Check the storage.
        SecureStorage secureStorage = SecureStorage();
        secureStorage.getAccessToken().then((accessToken) {
          if (accessToken == null || accessToken == "") {
            // No accessToken found. No user logged in. Navigate to home page.
            print("No accessToken found. No user logged in. Navigate to home page.");
            _navigationService.navigateTo(routes.HomeRoute, arguments: {'message': "Log in not found. Please log back in"});
          } else {
            logIn(accessToken);
          }
        });
      }
    }
    super.initState();
  }

  logIn(String accessToken) {
    AuthService authService = AuthService();
    authService.getTokenLogin(accessToken).then((loginResponse) {
      if (loginResponse.getResult()) {
        print("successfully logged in!");
        setState(() {});
      } else if (!loginResponse.getResult()) {
        print("access token login debug: ${loginResponse.getMessage()}");
        _navigationService.navigateTo(routes.HomeRoute, arguments: {'message': "Log in not found. Please log back in"});
      }
    }).onError((error, stackTrace) {
      _navigationService.navigateTo(routes.HomeRoute, arguments: {'message': "Log in not found. Please log back in"});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          child: Text("Profile Page"),
        ),
      ),
    );
  }
}
