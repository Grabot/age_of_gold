import 'package:age_of_gold/age_of_gold.dart';
import 'package:age_of_gold/services/settings.dart';
import 'package:age_of_gold/services/socket_services.dart';
import 'package:age_of_gold/util/countdown.dart';
import 'package:age_of_gold/util/render_objects.dart';
import 'package:age_of_gold/views/user_interface/ui_util/selected_tile_info.dart';
import 'package:age_of_gold/views/user_interface/ui_views/profile_box/profile_change_notifier.dart';
import 'package:flutter/material.dart';


class ProfileOverview extends StatefulWidget {

  final AgeOfGold game;

  const ProfileOverview({
    required Key key,
    required this.game
  }) : super(key: key);

  @override
  ProfileOverviewState createState() => ProfileOverviewState();
}

class ProfileOverviewState extends State<ProfileOverview> with TickerProviderStateMixin {

  late SelectedTileInfo selectedTileInfo;
  late ProfileChangeNotifier profileChangeNotifier;
  SocketServices socket = SocketServices();
  Settings settings = Settings();

  late AnimationController _controller;
  int levelClock = 0;
  bool canChangeTiles = true;

  @override
  void initState() {
    super.initState();
    selectedTileInfo = SelectedTileInfo();
    selectedTileInfo.addListener(selectedTileListener);

    profileChangeNotifier = ProfileChangeNotifier();
    profileChangeNotifier.addListener(profileChangeListener);
    settings.addListener(profileChangeListener);

    socket.addListener(socketListener);

    _controller = AnimationController(
        vsync: this,
        duration: Duration(
            seconds:
            levelClock)
    );
    _controller.forward();
    updateTimeLock();
  }

  socketListener() {
    if (mounted) {
      updateTimeLock();
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

  profileChangeListener() {
    if (mounted) {
      setState(() {});
    }
  }

  selectedTileListener() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  goToProfile() {
    if (!profileChangeNotifier.getProfileVisible()) {
      profileChangeNotifier.setProfileVisible(true);
    } else if (profileChangeNotifier.getProfileVisible()) {
      profileChangeNotifier.setProfileVisible(false);
    }
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

  Widget getAvatar(double avatarSize) {
    return Container(
      child: settings.getAvatar() != null ? avatarBox(avatarSize, avatarSize, settings.getAvatar()!)
          : Image.asset(
        "assets/images/default_avatar.png",
        width: 100,
        height: 100,
      )
    );
  }

  Widget profileWidget(double profileOverviewWidth, double profileOverviewHeight) {
    return Row(
      children: [
        Container(
          width: profileOverviewWidth,
          height: profileOverviewHeight,
          color: Colors.black38,
          child: GestureDetector(
            onTap: () {
              goToProfile();
            },
            child: Row(
              children: [
                getAvatar(profileOverviewHeight),
                SizedBox(
                  width: profileOverviewWidth - profileOverviewHeight,
                  child: RichText(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      text: settings.getUser() != null ? settings.getUser()!.getUserName() : "",
                      style: const TextStyle(color: Colors.white, fontSize: 24),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ]
    );
  }

  Widget profileSettingButtons(double profileButtonSize) {
    return Container(
      margin: EdgeInsets.all(profileButtonSize/3),
      child: Row(
        children: [
          SizedBox(
            width: profileButtonSize,
            height: profileButtonSize,
            child: ClipOval(
              child: Material(
                color: Colors.orange,
                child: InkWell(
                  splashColor: Colors.orangeAccent,
                  onTap: () {
                    print("pressed the friends button");
                  },
                  child: Icon(Icons.people),
                ),
              ),
            ),
          )
        ]
      ),
    );
  }

  Widget profileOverviewNormal(double profileOverviewWidth, double profileOverviewHeight, double fontSize) {
    return Column(
      children: [
        profileWidget(profileOverviewWidth, profileOverviewHeight),
        profileSettingButtons(40)
      ]
    );
  }

  Widget profileOverviewMobile(double profileOverviewWidth, double profileOverviewHeight, double fontSize) {
    return Row(
        children: [
          profileWidget(profileOverviewWidth/2, profileOverviewHeight),
          profileSettingButtons(30)
        ]
    );
  }

  bool normalMode = true;
  Widget tileBoxWidget() {
    double profileOverviewWidth = 350;
    double fontSize = 16;
    // We use the total height to hide the chatbox below
    double profileOverviewHeight = 100;
    normalMode = true;
    if (MediaQuery.of(context).size.width <= 800) {
      profileOverviewWidth = MediaQuery.of(context).size.width;
      profileOverviewHeight = 50;
      normalMode = false;
    }

    return Align(
      alignment: FractionalOffset.topLeft,
      child: normalMode
          ? profileOverviewNormal(profileOverviewWidth, profileOverviewHeight, fontSize)
          : profileOverviewMobile(profileOverviewWidth, profileOverviewHeight, fontSize)
    );
  }

  @override
  Widget build(BuildContext context) {
    return tileBoxWidget();
  }
}

