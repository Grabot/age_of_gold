import 'package:age_of_gold/locator.dart';
import 'package:age_of_gold/services/auth_service_login.dart';
import 'package:age_of_gold/services/settings.dart';
import 'package:age_of_gold/util/countdown.dart';
import 'package:age_of_gold/util/navigation_service.dart';
import 'package:age_of_gold/util/web_storage.dart';
import 'package:flutter/material.dart';
import 'package:age_of_gold/constants/route_paths.dart' as routes;
import '../age_of_gold.dart';
import '../services/models/user.dart';
import '../util/util.dart';


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

  // String userName = "";
  User? currentUser;

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
        currentUser = settings.getUser();
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
    AuthServiceLogin authService = AuthServiceLogin();
    authService.getTokenLogin(accessToken).then((loginResponse) {
      if (loginResponse.getResult()) {
        setState(() {
          currentUser = settings.getUser();
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

  verifyEmail() {
    AuthServiceLogin authService = AuthServiceLogin();
    // Check if the token from the mail is still valid.
    authService.emailVerificationSend().then((sendEmailResponse) {
      if (sendEmailResponse.getResult()) {
        showToastMessage("verification email send!");
      } else {
        showToastMessage("Something went wrong");
      }
    });
  }

  Widget verifyEmailButton() {
    return Container(
      margin: EdgeInsets.only(top: 20),
      child: ElevatedButton(
        onPressed: () {
          verifyEmail();
        },
        style: buttonStyle(),
        child: Container(
          alignment: Alignment.center,
          width: 400,
          height: 50,
          child: Text(
            'Verify email',
            style: simpleTextStyle(30),
          ),
        ),
      ),
    );
  }

  Widget logoutButton() {
    return Container(
      margin: EdgeInsets.only(top: 20),
      child: ElevatedButton(
        onPressed: () {
          logoutUser(settings, _navigationService);
        },
        style: buttonStyle(),
        child: Container(
          alignment: Alignment.center,
          width: 400,
          height: 50,
          child: Text(
            'Log out',
            style: simpleTextStyle(30),
          ),
        ),
      ),
    );
  }

  Widget goBackToTheWorld() {
    return Container(
      margin: EdgeInsets.only(top: 20),
      child: ElevatedButton(
        onPressed: () {
        },
        style: buttonStyle(),
        child: Container(
          alignment: Alignment.center,
          width: 400,
          height: 50,
          child: Text(
            'Go back to the world',
            style: simpleTextStyle(30),
          ),
        ),
      ),
    );
  }

  Widget userVerified() {
    return Container(
      child: Text(
        'email verified',
        style: simpleTextStyle(30),
      )
    );
  }

  Widget verifyEmailBox() {
    return Container(
        child: settings.getUser()!.isVerified()
            ? userVerified()
            : verifyEmailButton()
    );
  }

  Widget profileHeader() {
    return Container(
      child: settings.getUser() == null
          ? Text("loading")
          : Text("Profile Page of ${settings.getUser()!.getUserName()}"),
    );
  }

  Widget userInformationBox() {
    return Container(
      child: settings.getUser() == null
          ? Container()
          : Column(
        children: [
          tileTimeInformation(),
          SizedBox(height: 20),
          verifyEmailBox(),
          SizedBox(height: 20),
          logoutButton(),
          SizedBox(height: 20),
          goBackToTheWorld(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Container(
          child: Column(
            children:
            [
              SizedBox(height: 20),
              profileHeader(),
              SizedBox(height: 20),
              userInformationBox(),
            ]
          ),
        ),
      ),
    );
  }
}
