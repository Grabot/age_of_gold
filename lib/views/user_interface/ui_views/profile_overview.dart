import 'dart:convert';

import 'package:age_of_gold/age_of_gold.dart';
import 'package:age_of_gold/services/settings.dart';
import 'package:age_of_gold/services/socket_services.dart';
import 'package:age_of_gold/util/countdown.dart';
import 'package:age_of_gold/views/user_interface/ui_function/user_interface_util/profile_change_notifier.dart';
import 'package:age_of_gold/views/user_interface/ui_function/user_interface_util/selected_tile_info.dart';
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

  Widget getAvatar() {
    return Container(
        decoration: BoxDecoration(
          border: Border.all(
              color: Colors.black,
              width: 2
          ),
        ),
        child: settings.getAvatar() != null ? Image.memory(
            base64Decode(settings.getAvatar()!),
            gaplessPlayback: true,
            width: 70,
            height: 70
        ) : Image.asset(
          "assets/images/default_avatar.png",
          width: 70,
          height: 70,
        )
    );
  }

  Widget profileWidget(double tileBoxWidth) {
    return Container(
      width: tileBoxWidth,
      height: 100,
      color: Colors.orange,
      child: GestureDetector(
        onTap: () {
          goToProfile();
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(width: 5),
            getAvatar(),
            SizedBox(width: 5),
            SizedBox(
              width: 130,
              child: Text(
                socket.getUserName(),
                style: const TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            SizedBox(width: 10),
            SizedBox(
                width: 100,
                child: tileTimeInformation()
            ),
            SizedBox(width: 20),
          ],
        ),
      ),
    );
  }

  Widget tileBoxWidget() {
    double profileOverviewWidth = 350;
    return Align(
      alignment: FractionalOffset.topLeft,
      child: profileWidget(profileOverviewWidth),
    );
  }

  @override
  Widget build(BuildContext context) {
    return tileBoxWidget();
  }
}

