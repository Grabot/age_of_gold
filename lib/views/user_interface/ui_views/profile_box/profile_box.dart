import 'package:age_of_gold/age_of_gold.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../services/auth_service_login.dart';
import '../../../../services/auth_service_setting.dart';
import '../../../../services/models/user.dart';
import '../../../../services/settings.dart';
import '../../../../util/countdown.dart';
import '../../../../util/render_objects.dart';
import '../../../../util/util.dart';
import '../are_you_sure_box/are_you_sure_change_notifier.dart';
import '../change_avatar_box/change_avatar_change_notifier.dart';
import '../login_view/login_window_change_notifier.dart';
import 'profile_change_notifier.dart';


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
  late ProfileChangeNotifier profileChangeNotifier;

  Settings settings = Settings();

  late AnimationController _controller;
  int levelClock = 0;
  bool canChangeTiles = true;

  bool showProfile = false;

  // used to get the position and place the dropdown in the right spot
  GlobalKey settingsKey = GlobalKey();
  GlobalKey cancelKey = GlobalKey();

  bool changeUserName = false;
  final GlobalKey<FormState> userNameKey = GlobalKey<FormState>();
  final TextEditingController userNameController = TextEditingController();
  final FocusNode _focusUsernameChange = FocusNode();

  bool changePassword = false;
  final GlobalKey<FormState> passwordKey = GlobalKey<FormState>();
  final TextEditingController passwordController = TextEditingController();
  final FocusNode _focusPasswordChange = FocusNode();

  @override
  void initState() {
    profileChangeNotifier = ProfileChangeNotifier();
    profileChangeNotifier.addListener(profileChangeListener);

    _controller = AnimationController(
        vsync: this,
        duration: Duration(
            seconds:
            levelClock)
    );
    _controller.forward();
    updateTimeLock();

    settings.addListener(settingsChangeListener);
    _focusUsernameChange.addListener(_onFocusChangeUsername);
    _focusPasswordChange.addListener(_onFocusChangePassword);

    setState(() {

    });
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
        updateTimeLock();
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

  _onFocusChangeUsername() {
    widget.game.windowFocus(_focusUsernameChange.hasFocus);
  }

  _onFocusChangePassword() {
    widget.game.windowFocus(_focusPasswordChange.hasFocus);
  }

  settingsChangeListener() {
    if (mounted) {
      setState(() {});
    }
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

  Widget otherPlatformInfo(double width, double fontSize) {
    return Container(
      margin: const EdgeInsets.all(20),
      width: width,
      child: Row(
        children: [
          Expanded(
              child: Text.rich(
                  TextSpan(
                    text: kIsWeb
                        ? "Also try Hex Place on Android or IOS!"
                        : "Also try Hex Place in your browser on hexplace.eu",
                    style: TextStyle(
                        fontSize: fontSize*1.5
                    ),
                  )
              )
          ),
        ],
      ),
    );
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
    double headerHeight = 40;

    return Container(
      width: width,
      height: height,
      color: Colors.cyan,
      child: SingleChildScrollView(
        child: Column(
            children:
            [
              profileHeader(width, headerHeight, fontSize),
              const SizedBox(height: 20),
              userInformationBox(width, fontSize, normalMode),
              otherPlatformInfo(width, fontSize),
            ]
        ),
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

  goBack() {
    setState(() {
      profileChangeNotifier.setProfileVisible(false);
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

  passwordChange() {
    if (passwordKey.currentState!.validate()) {
      AuthServiceSetting().changePassword(passwordController.text).then((response) {
        if (response.getResult()) {
          setState(() {
            setState(() {
              showToastMessage("password changed!");
              changePassword = false;
            });
          });
        } else {
          showToastMessage(response.getMessage());
        }
      });
    }
  }

  Widget userVerified(double width, double fontSize) {
    return Container(
        child: Text(
          'email verified!',
          style: simpleTextStyle(fontSize),
        )
    );
  }

  // Widget verifyEmailBox(double width, double fontSize) {
  //   return Container(
  //       child: settings.getUser()!.isVerified()
  //           ? userVerified(width, fontSize)
  //           : verifyEmailButton(width, fontSize)
  //   );
  // }

  Widget profileHeader(double headerWidth, double headerHeight, double fontSize) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          margin: const EdgeInsets.all(20),
          child: settings.getUser() == null
              ? Text(
            "No user logged in",
            style: simpleTextStyle(fontSize*1.5),
          )
            : Text(
            "Profile Page",
            style: simpleTextStyle(fontSize*1.5)
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          color: Colors.orangeAccent.shade200,
          tooltip: 'cancel',
          onPressed: () {
            setState(() {
              goBack();
            });
          }
        ),
      ]
    );
  }

  Widget nobodyLoggedIn(double width, double fontSize) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 20),
          child: ElevatedButton(
            onPressed: () {
              showProfile = false;
              LoginWindowChangeNotifier().setLoginWindowVisible(true);
              goBack();
            },
            style: buttonStyle(false, Colors.blue),
            child: Container(
              alignment: Alignment.center,
              width: 400,
              height: 50,
              child: Text(
                'Go to log in screen',
                style: simpleTextStyle(fontSize*1.5),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget somebodyLoggedInNormal(double width, double fontSize) {
    return Row(
      children: [
        profileAvatar(300, fontSize),
        SizedBox(
          width: 500,
          child: Column(
            children: [
              tileTimeInformation(width, fontSize),
              // const SizedBox(height: 20),
              // verifyEmailBox(width, fontSize),
            ],
          ),
        ),
      ]
    );
  }

  Widget changeUserNameField(double avatarWidth, double fontSize) {
    return Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.blueAccent)
      ),
      child: Container(
        margin: const EdgeInsets.all(4),
        child: Column(
          children: [
            SizedBox(
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
                scrollPadding: const EdgeInsets.only(bottom: 120),
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

  Widget changePasswordField(double avatarWidth, double fontSize) {
    return Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.blueAccent)
      ),
      child: Container(
        margin: const EdgeInsets.all(4),
        child: Column(
          children: [
            SizedBox(
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Change password", style: simpleTextStyle(fontSize)),
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                        icon: const Icon(Icons.close),
                        color: Colors.orangeAccent.shade200,
                        tooltip: 'cancel',
                        onPressed: () {
                          setState(() {
                            changePassword = false;
                          });
                        }
                    ),
                  ),
                ],
              ),
            ),
            Form(
              key: passwordKey,
              child: TextFormField(
                controller: passwordController,
                focusNode: _focusPasswordChange,
                validator: (val) {
                  return val == null || val.isEmpty
                      ? "fill in new password"
                      : null;
                },
                scrollPadding: const EdgeInsets.only(bottom: 120),
                decoration: const InputDecoration(
                  hintText: "New password",
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                ),
                obscureText: true,
                autofillHints: const [AutofillHints.newPassword],
                style: TextStyle(color: Colors.white, fontSize: fontSize),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                passwordChange();
              },
              style: buttonStyle(false, Colors.blue),
              child: Container(
                alignment: Alignment.center,
                width: avatarWidth,
                height: 50,
                child: Text(
                  'Change password',
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
    return SizedBox(
        width: avatarWidth,
        child: Column(
            children: [
          settings.getAvatar() != null
              ? avatarBox(avatarWidth-40, avatarWidth-40, settings.getAvatar()!)
              : Container(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: RichText(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    text: settings.getUser()!.getUserName(),
                    style: const TextStyle(color: Colors.white, fontSize: 34),
                  ),
                ),
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
          changePassword ? changePasswordField(avatarWidth, fontSize) : Container(),
        ]
      )
    );
  }

  Widget somebodyLoggedInMobile(double width, double fontSize) {
    double widthAvatar = 300;
    if (width < widthAvatar) {
      widthAvatar = width;
    }
    return Column(
      children: [
        profileAvatar(widthAvatar, fontSize),
        tileTimeInformation(width, fontSize),
        // const SizedBox(height: 20),
        // verifyEmailBox(width, fontSize),
      ],
    );
  }

  Widget normalModeProfile(double width, double fontSize) {
    return Container(
        child: settings.getUser() != null
            ? somebodyLoggedInNormal(width, fontSize)
            : nobodyLoggedIn(width, fontSize)
    );
  }

  Widget mobileModeProfile(double width, double fontSize) {
    return Container(
        child: settings.getUser() != null
            ? somebodyLoggedInMobile(width, fontSize)
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

  showChangeUsername() {
    setState(() {
      changeUserName = true;
      changePassword = false;
    });
  }

  showChangePassword() {
    setState(() {
      changePassword = true;
      changeUserName = false;
    });
  }

  showChangeAvatar() {
    setState(() {
      ChangeAvatarChangeNotifier().setAvatar(settings.getAvatar()!);
      ChangeAvatarChangeNotifier().setChangeAvatarVisible(true);
      changePassword = false;
      changeUserName = false;
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

    User? me = settings.getUser();
    bool isOrigin = false;
    if (me != null) {
      isOrigin = me.origin;
    }
    showMenu(
        context: context,
        items: [SettingPopup(key: UniqueKey(), showPasswordChange: isOrigin)],
        position: RelativeRect.fromRect(
            _tapPosition! & const Size(40, 40), Offset.zero & overlay.size))
        .then((int? delta) {
      if (delta == 0) {
        // change avatar
        showChangeAvatar();
      } else if (delta == 1) {
        // change username
        showChangeUsername();
      } else if (delta == 2) {
        // change password
        showChangePassword();
      } else if (delta == 3) {
        // logout user
        AreYouSureBoxChangeNotifier areYouSureBoxChangeNotifier = AreYouSureBoxChangeNotifier();
        areYouSureBoxChangeNotifier.setShowDelete(false);
        areYouSureBoxChangeNotifier.setShowLogout(true);
        areYouSureBoxChangeNotifier.setShowLeaveGuild(false);
        areYouSureBoxChangeNotifier.setAreYouSureBoxVisible(true);
      } else if (delta == 4) {
        AreYouSureBoxChangeNotifier areYouSureBoxChangeNotifier = AreYouSureBoxChangeNotifier();
        areYouSureBoxChangeNotifier.setShowDelete(true);
        areYouSureBoxChangeNotifier.setShowLogout(false);
        areYouSureBoxChangeNotifier.setShowLeaveGuild(false);
        areYouSureBoxChangeNotifier.setAreYouSureBoxVisible(true);
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

  final bool showPasswordChange;

  const SettingPopup({
    required Key key,
    required this.showPasswordChange
  }) : super(key: key);

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
    return getPopupItems(context, widget.showPasswordChange);
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
void buttonDeleteAccount(BuildContext context) {
  Navigator.pop<int>(context, 4);
}

Widget getPopupItems(BuildContext context, bool showPasswordChange) {
  return Column(
    children: [
      Container(
        alignment: Alignment.centerLeft,
        child: TextButton(
            onPressed: () {
              buttonChangeProfile(context);
            },
            child: const Row(
              children:[
                Text(
                  'Change avatar',
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
            child: const Row(
              children: [
                Text(
                  "Change username",
                  textAlign: TextAlign.left,
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ]
            )
        ),
      ),
      showPasswordChange ? Container(
        alignment: Alignment.centerLeft,
        child: TextButton(
            onPressed: () {
              buttonChangePassword(context);
            },
            child: const Row(
              children: [
                Text(
                  "Change password",
                  textAlign: TextAlign.left,
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ]
          )
        ),
      ) : Container(),
      Container(
        alignment: Alignment.centerLeft,
        child: TextButton(
            onPressed: () {
              buttonLogout(context);
            },
            child: const Row(
              children: [
                Text(
                  "Logout",
                  textAlign: TextAlign.left,
                  style: TextStyle(color: Colors.white, fontSize: 14),
                )
              ],
            )
        ),
      ),
      Container(
        alignment: Alignment.centerLeft,
        child: TextButton(
            onPressed: () {
              buttonDeleteAccount(context);
            },
            child: const Row(
              children: [
                Text(
                  "Delete account",
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
