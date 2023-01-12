import 'package:age_of_gold/locator.dart';
import 'package:age_of_gold/services/auth_service.dart';
import 'package:age_of_gold/services/settings.dart';
import 'package:age_of_gold/util/countdown.dart';
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

class _ProfilePageState extends State<ProfilePage> with TickerProviderStateMixin {

  final NavigationService _navigationService = locator<NavigationService>();

  bool showLogin = false;

  Settings settings = Settings();

  String userName = "";

  late AnimationController _controller;
  int levelClock = 0;
  bool canChangeTiles = true;

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
    } else {
      setState(() {
        userName = settings.getUser()!.getUserName();
      });
    }
    super.initState();
    _controller = AnimationController(
        vsync: this,
        duration: Duration(
            seconds:
            levelClock)
    );
    _controller.forward();
    updateTimeLock();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  updateTimeLock() {
    if (settings.getUser() != null) {
      DateTime timeLock = settings.getUser()!.getTileLock();
      if (timeLock.isAfter(DateTime.now())) {
        levelClock = timeLock.difference(DateTime.now()).inSeconds;
        _controller = AnimationController(
            vsync: this,
            duration: Duration(
                seconds:
                levelClock)
        );
        _controller.forward();
        _controller.addStatusListener((status) {
          if(status == AnimationStatus.completed) {
            setState(() {
              canChangeTiles = true;
            });
          }
        });
        canChangeTiles = false;
      }
    }
  }

  logIn(String accessToken) {
    AuthService authService = AuthService();
    authService.getTokenLogin(accessToken).then((loginResponse) {
      if (loginResponse.getResult()) {
        setState(() {
          userName = Settings().getUser()!.getUserName();
        });
      } else if (!loginResponse.getResult()) {
        print("access token login debug: ${loginResponse.getMessage()}");
        _navigationService.navigateTo(routes.HomeRoute, arguments: {'message': "Log in not found. Please log back in"});
      }
    }).onError((error, stackTrace) {
      _navigationService.navigateTo(routes.HomeRoute, arguments: {'message': "Log in not found. Please log back in"});
    });
  }

  Widget tileTimeInformation() {
    if (canChangeTiles) {
      return Container();
    } else {
      return Countdown(
        key: UniqueKey(),
        animation: StepTween(
          begin: levelClock,
          end: 0,
        ).animate(_controller),
      );
    }
  }

  Widget logoutButton() {
    return Container(
      margin: EdgeInsets.only(top: 20),
      child: ElevatedButton(
        onPressed: () {
          settings.logout();
          SecureStorage().logout().then((value) {
            _navigationService.navigateTo(routes.HomeRoute, arguments: {'message': "Logged out"});
          });
        },
        child: Text("Log out"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          child: Column(
            children:
            [
              Text("Profile Page of $userName"),
              SizedBox(height: 20),
              tileTimeInformation(),
              SizedBox(height: 20),
              logoutButton()
            ]
          ),
        ),
      ),
    );
  }
}
