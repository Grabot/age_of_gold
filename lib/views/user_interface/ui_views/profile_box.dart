import 'package:age_of_gold/age_of_gold.dart';
import 'package:age_of_gold/locator.dart';
import 'package:age_of_gold/services/auth_service_login.dart';
import 'package:age_of_gold/services/models/user.dart';
import 'package:age_of_gold/services/settings.dart';
import 'package:age_of_gold/util/countdown.dart';
import 'package:age_of_gold/util/navigation_service.dart';
import 'package:age_of_gold/util/util.dart';
import 'package:age_of_gold/views/user_interface/ui_function/user_interface_util/profile_change_notifier.dart';
import 'package:flutter/material.dart';
import 'package:age_of_gold/constants/route_paths.dart' as routes;


class ProfileBox extends StatefulWidget {

  final AgeOfGold game;

  const ProfileBox({
    required Key key,
    required this.game
  }) : super(key: key);

  @override
  ProfileBoxState createState() => ProfileBoxState();
}

class ProfileBoxState extends State<ProfileBox> with TickerProviderStateMixin {

  // Used if any text fields are added to the profile.
  final FocusNode _focusProfileBox = FocusNode();
  late ProfileChangeNotifier profileChangeNotifier;

  final NavigationService _navigationService = locator<NavigationService>();

  Settings settings = Settings();

  User? currentUser;

  late AnimationController _controller;
  int levelClock = 0;
  bool canChangeTiles = true;

  bool showProfile = false;

  @override
  void initState() {
    profileChangeNotifier = ProfileChangeNotifier();
    profileChangeNotifier.addListener(profileChangeListener);

    currentUser = settings.getUser();
    _controller = AnimationController(
        vsync: this,
        duration: Duration(
            seconds:
            levelClock)
    );
    _controller.forward();
    updateTimeLock();

    _focusProfileBox.addListener(_onFocusChange);

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  profileChangeListener() {
    if (mounted) {
      if (!showProfile && profileChangeNotifier.getProfileVisible()) {
        setState(() {
          showProfile = true;
        });
      }
      if (showProfile && !profileChangeNotifier.getProfileVisible()) {
        setState(() {
          showProfile = false;
        });
      }
    }
  }

  void _onFocusChange() {
    widget.game.chatBoxFocus(_focusProfileBox.hasFocus);
  }

  updateTimeLock() {
    if (currentUser != null) {
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

  Widget profile() {
    double fontSize = 16;
    double width = 800;
    double height = (MediaQuery.of(context).size.height / 10) * 9;
    // When the width is smaller than this we assume it's mobile.
    if (MediaQuery.of(context).size.width <= 800) {
      width = MediaQuery.of(context).size.width - 50;
      height = MediaQuery.of(context).size.height - 250;
      fontSize = 10;
    }

    return Container(
      width: width,
      height: height,
      color: Colors.grey,
      child: SingleChildScrollView(
          child: Column(
              children:
              [
                SizedBox(height: 20),
                profileHeader(width, fontSize),
                SizedBox(height: 20),
                userInformationBox(width, fontSize),
              ]
          )
      ),
    );
  }

  Widget tileTimeInformation(double width, double fontSize) {
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

  Widget verifyEmailButton(double width, double fontSize) {
    return Container(
      margin: EdgeInsets.only(top: 20),
      child: ElevatedButton(
        onPressed: () {
          verifyEmail();
        },
        style: buttonStyle(false, Colors.blue),
        child: Container(
          alignment: Alignment.center,
          width: 400,
          height: 50,
          child: Text(
            'Verify email',
            style: simpleTextStyle(fontSize),
          ),
        ),
      ),
    );
  }

  Widget logoutButton(double width, double fontSize) {
    return Container(
      margin: EdgeInsets.only(top: 20),
      child: ElevatedButton(
        onPressed: () {
          logoutUser(settings, _navigationService);
        },
        style: buttonStyle(false, Colors.blue),
        child: Container(
          alignment: Alignment.center,
          width: 400,
          height: 50,
          child: Text(
            'Log out',
            style: simpleTextStyle(fontSize),
          ),
        ),
      ),
    );
  }

  goBack() {
    setState(() {
      showProfile = false;
    });
  }

  Widget goBackToTheWorld(double width, double fontSize) {
    return Container(
      margin: EdgeInsets.only(top: 20),
      child: ElevatedButton(
        onPressed: () {
          goBack();
        },
        style: buttonStyle(false, Colors.blue),
        child: Container(
          alignment: Alignment.center,
          width: 400,
          height: 50,
          child: Text(
            'Go back to the world',
            style: simpleTextStyle(fontSize),
          ),
        ),
      ),
    );
  }

  Widget userVerified(double width, double fontSize) {
    return Container(
        child: Text(
          'email verified!',
          style: simpleTextStyle(fontSize),
        )
    );
  }

  Widget verifyEmailBox(double width, double fontSize) {
    return Container(
        child: settings.getUser()!.isVerified()
            ? userVerified(width, fontSize)
            : verifyEmailButton(width, fontSize)
    );
  }

  Widget profileHeader(double width, double fontSize) {
    return Container(
      child: settings.getUser() == null
          ? Text(
        "no user logged in",
        style: simpleTextStyle(fontSize),
      )
          : Text(
        "Profile Page of ${settings.getUser()!.getUserName()}",
        style: simpleTextStyle(fontSize)
      ),
    );
  }

  Widget nobodyLoggedIn(double width, double fontSize) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(top: 20),
          child: ElevatedButton(
            onPressed: () {
              _navigationService.navigateTo(routes.HomeRoute, arguments: {'message': "Checked out the world and ready to register!"});
            },
            style: buttonStyle(false, Colors.blue),
            child: Container(
              alignment: Alignment.center,
              width: 400,
              height: 50,
              child: Text(
                'Go to log in screen',
                style: simpleTextStyle(fontSize),
              ),
            ),
          ),
        ),
        goBackToTheWorld(width, fontSize),
      ],
    );
  }

  Widget userInformationBox(double width, double fontSize) {
    return Container(
      child: settings.getUser() == null
          ? nobodyLoggedIn(width, fontSize)
          : Column(
        children: [
          tileTimeInformation(width, fontSize),
          SizedBox(height: 20),
          verifyEmailBox(width, fontSize),
          SizedBox(height: 20),
          goBackToTheWorld(width, fontSize),
          SizedBox(height: 20),
          logoutButton(width, fontSize),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: FractionalOffset.center,
      child: showProfile ? profile() : Container(),
    );
  }
}