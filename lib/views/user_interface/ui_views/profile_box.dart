import 'package:age_of_gold/age_of_gold.dart';
import 'package:age_of_gold/constants/route_paths.dart' as routes;
import 'package:age_of_gold/locator.dart';
import 'package:age_of_gold/services/auth_service_login.dart';
import 'package:age_of_gold/services/auth_service_setting.dart';
import 'package:age_of_gold/services/models/user.dart';
import 'package:age_of_gold/services/settings.dart';
import 'package:age_of_gold/util/countdown.dart';
import 'package:age_of_gold/util/navigation_service.dart';
import 'package:age_of_gold/util/render_objects.dart';
import 'package:age_of_gold/util/util.dart';
import 'package:age_of_gold/views/user_interface/ui_function/user_interface_util/profile_change_notifier.dart';
import 'package:flutter/material.dart';


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

  // used to get the position and place the dropdown in the right spot
  GlobalKey settingsKey = GlobalKey();

  bool changeUserName = false;
  bool changePassword = false;
  final GlobalKey<FormState> userNameKey = GlobalKey<FormState>();
  final TextEditingController userNameController = TextEditingController();
  final FocusNode _focusUsernameChange = FocusNode();

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
    _focusUsernameChange.addListener(_onFocusUsernameChange);

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

  _onFocusUsernameChange() {
    widget.game.profileFocus(_focusUsernameChange.hasFocus);
  }

  _onFocusChange() {
    widget.game.profileFocus(_focusProfileBox.hasFocus);
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
    // normal mode is for desktop, mobile mode is for mobile.
    bool normalMode = true;
    double fontSize = 16;
    double width = 800;
    double height = (MediaQuery.of(context).size.height / 10) * 9;
    // When the width is smaller than this we assume it's mobile.
    if (MediaQuery.of(context).size.width <= 800) {
      width = MediaQuery.of(context).size.width - 50;
      height = MediaQuery.of(context).size.height - 250;
      fontSize = 10;
      normalMode = false;
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
                userInformationBox(width, fontSize, normalMode),
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

  userNameChange() {
    if (userNameKey.currentState!.validate()) {
      AuthServiceSetting().changeUserName(userNameController.text).then((response) {
        if (response.getResult()) {
          setState(() {
            String newUsername = response.getMessage();
            if (settings.getUser() != null) {
              settings.getUser()!.setUsername(newUsername);
              settings.notify();
            }
            setState(() {
              showToastMessage("Username changed!");
              changeUserName = false;
            });
          });
        } else {
          showToastMessage(response.getMessage());
        }
      });
    }
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
        "No user logged in",
        style: simpleTextStyle(fontSize),
      )
          : Text(
        "Profile Page",
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

  Widget sombodyLoggedInNormal(double width, double fontSize) {
    return Row(
      children: [
        profileAvatar(300, fontSize),
        Container(
          width: 500,
          child: Column(
            children: [
              tileTimeInformation(width, fontSize),
              SizedBox(height: 20),
              verifyEmailBox(width, fontSize),
              SizedBox(height: 20),
              goBackToTheWorld(width, fontSize),
              SizedBox(height: 20),
              logoutButton(width, fontSize),
              SizedBox(height: 120),
            ],
          ),
        ),
      ]
    );
  }

  Widget changeUserNameField(double avatarWidth, double fontSize) {
    return Container(
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.blueAccent)
      ),
      child: Container(
        margin: EdgeInsets.all(4),
        child: Column(
          children: [
            Container(
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Change username", style: simpleTextStyle(fontSize)),
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                        icon: const Icon(Icons.close),
                        color: Colors.orangeAccent.shade200,
                        tooltip: 'cancel',
                        onPressed: () {
                          setState(() {
                            changeUserName = false;
                          });
                        }
                    ),
                  ),
                ],
              ),
            ),
            Form(
              key: userNameKey,
              child: TextFormField(
                controller: userNameController,
                focusNode: _focusUsernameChange,
                validator: (val) {
                  return val == null || val.isEmpty
                      ? "Please enter a username if you want to change it"
                      : null;
                },
                decoration: const InputDecoration(
                  hintText: "New username",
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                ),
                style: TextStyle(color: Colors.white, fontSize: fontSize),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                userNameChange();
              },
              style: buttonStyle(false, Colors.blue),
              child: Container(
                alignment: Alignment.center,
                width: avatarWidth,
                height: 50,
                child: Text(
                  'Change username',
                  style: TextStyle(color: Colors.white, fontSize: fontSize),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget profileAvatar(double avatarWidth, double fontSize) {
    return Container(
        width: avatarWidth,
        child: Column(children: [
          settings.getAvatar() != null
              ? avatarBox(avatarWidth, avatarWidth, settings.getAvatar()!)
              : Container(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                settings.getUser()!.getUserName(),
                style: TextStyle(color: Colors.white, fontSize: 34),
              ),
              IconButton(
                  key: settingsKey,
                  iconSize: 40.0,
                  icon: const Icon(Icons.settings),
                  color: Colors.orangeAccent.shade200,
                  tooltip: 'Settings',
                  onPressed: _showPopupMenu
              )
            ],
          ),
          changeUserName ? changeUserNameField(avatarWidth, fontSize) : Container(),
        ]
      )
    );
  }

  Widget sombodyLoggedInMobile(double width, double fontSize) {
    double widthAvatar = 300;
    if (width < widthAvatar) {
      widthAvatar = width;
    }
    return Column(
      children: [
        profileAvatar(widthAvatar, fontSize),
        tileTimeInformation(width, fontSize),
        SizedBox(height: 20),
        verifyEmailBox(width, fontSize),
        SizedBox(height: 20),
        goBackToTheWorld(width, fontSize),
        SizedBox(height: 20),
        logoutButton(width, fontSize),
        SizedBox(height: 120),
      ],
    );
  }

  Widget normalModeProfile(double width, double fontSize) {
    return Container(
        child: settings.getUser() != null
            ? sombodyLoggedInNormal(width, fontSize)
            : nobodyLoggedIn(width, fontSize)
    );
  }

  Widget mobileModeProfile(double width, double fontSize) {
    return Container(
        child: settings.getUser() != null
            ? sombodyLoggedInMobile(width, fontSize)
            : nobodyLoggedIn(width, fontSize)
    );
  }

  Widget userInformationBox(double width, double fontSize, bool normalMode) {
    if (normalMode) {
      return normalModeProfile(width, fontSize);
    } else {
      return mobileModeProfile(width, fontSize);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: FractionalOffset.center,
      child: showProfile ? profile() : Container(),
    );
  }

  changeProfilePicture() {
    print("change profile picture");
  }

  showChangeUsername() {
    setState(() {
      changeUserName = true;
    });
  }

  showChangePassword() {
    setState(() {
      changePassword = true;  // TODO: add this
    });
  }

  Offset? _tapPosition;

  void _showPopupMenu() {
    _storePosition();
    _showChatDetailPopupMenu();
  }

  void _showChatDetailPopupMenu() {
    final RenderBox overlay =
    Overlay.of(context).context.findRenderObject() as RenderBox;

    showMenu(
        context: context,
        items: [SettingPopup(key: UniqueKey())],
        position: RelativeRect.fromRect(
            _tapPosition! & const Size(40, 40), Offset.zero & overlay.size))
        .then((int? delta) {
      if (delta == 0) {
        // change profile picture
        changeProfilePicture();
      } else if (delta == 1) {
        // change username
        showChangeUsername();
      } else if (delta == 2) {
        // change password
        showChangePassword();
      } else if (delta == 3) {
        // logout user
        logoutUser(settings, _navigationService);
      }
      return;
    });
  }

  void _storePosition() {
    RenderBox box = settingsKey.currentContext!.findRenderObject() as RenderBox;
    Offset position = box.localToGlobal(Offset.zero);
    position = position + const Offset(0, 50);
    _tapPosition = position;
  }
}

class SettingPopup extends PopupMenuEntry<int> {

  SettingPopup({required Key key}) : super(key: key);

  @override
  bool represents(int? n) => n == 1 || n == -1;

  @override
  SettingPopupState createState() => SettingPopupState();

  @override
  double get height => 1;
}

class SettingPopupState extends State<SettingPopup> {
  @override
  Widget build(BuildContext context) {
    return getPopupItems(context);
  }
}

void buttonChangeProfile(BuildContext context) {
  Navigator.pop<int>(context, 0);
}

void buttonChangeUsername(BuildContext context) {
  Navigator.pop<int>(context, 1);
}

void buttonChangePassword(BuildContext context) {
  Navigator.pop<int>(context, 2);
}

void buttonLogout(BuildContext context) {
  Navigator.pop<int>(context, 3);
}

Widget getPopupItems(BuildContext context) {
  return Column(
    children: [
      Container(
        alignment: Alignment.centerLeft,
        child: TextButton(
            onPressed: () {
              buttonChangeProfile(context);
            },
            child: Row(
              children:const [
                Text(
                  'Change profile picture',
                  textAlign: TextAlign.left,
                  style: TextStyle(color: Colors.white, fontSize: 14),
                )
              ] ,
            )
        ),
      ),
      Container(
        alignment: Alignment.centerLeft,
        child: TextButton(
            onPressed: () {
              buttonChangeUsername(context);
            },
            child: Row(
              children: const [
                Text(
                  "Change username",
                  textAlign: TextAlign.left,
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ]
            )
        ),
      ),
      Container(
        alignment: Alignment.centerLeft,
        child: TextButton(
            onPressed: () {
              buttonChangeUsername(context);
            },
            child: Row(
                children: const [
                  Text(
                    "Change password",
                    textAlign: TextAlign.left,
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ]
            )
        ),
      ),
      Container(
        alignment: Alignment.centerLeft,
        child: TextButton(
            onPressed: () {
              buttonLogout(context);
            },
            child: Row(
              children: const [
                Text(
                  "Logout",
                  textAlign: TextAlign.left,
                  style: TextStyle(color: Colors.white, fontSize: 14),
                )
              ],
            )
        ),
      ),
    ]
  );
}
