import 'package:age_of_gold/age_of_gold.dart';
import 'package:age_of_gold/util/util.dart';
import 'package:age_of_gold/views/user_interface/ui_views/friend_window/friend_window_change_notifier.dart';
import 'package:flutter/material.dart';


class FriendWindow extends StatefulWidget {

  final AgeOfGold game;

  const FriendWindow({
    required Key key,
    required this.game
  }) : super(key: key);

  @override
  FriendWindowState createState() => FriendWindowState();
}

class FriendWindowState extends State<FriendWindow> {

  final FocusNode _focusFriendWindow = FocusNode();
  bool showFriendWindow = false;
  bool socialView = false;

  bool normalMode = true;

  late FriendWindowChangeNotifier friendWindowChangeNotifier;

  @override
  void initState() {
    friendWindowChangeNotifier = FriendWindowChangeNotifier();
    friendWindowChangeNotifier.addListener(friendWindowChangeListener);

    _focusFriendWindow.addListener(_onFocusChange);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  friendWindowChangeListener() {
    if (mounted) {
      if (!showFriendWindow && friendWindowChangeNotifier.getFriendWindowVisible()) {
        setState(() {
          showFriendWindow = true;
        });
      }
      if (showFriendWindow && !friendWindowChangeNotifier.getFriendWindowVisible()) {
        setState(() {
          showFriendWindow = false;
        });
      }
    }
  }

  void _onFocusChange() {
    widget.game.friendWindowFocus(_focusFriendWindow.hasFocus);
  }

  goBack() {
    setState(() {
      FriendWindowChangeNotifier().setFriendWindowVisible(false);
    });
  }

  Widget friendWindowHeader(double headerWidth, double headerHeight, double fontSize) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(),
          SizedBox(
              height: headerHeight,
              child: Text(
                "Social",
                style: simpleTextStyle(fontSize),
              )
          ),
          SizedBox(
            height: headerHeight,
            child: IconButton(
              icon: const Icon(Icons.close),
              color: Colors.orangeAccent.shade200,
              tooltip: 'cancel',
              onPressed: () {
                goBack();
              }
            ),
          ),
        ]
    );
  }

  Widget friendRequestWindow() {
    return Container();
  }

  Widget socialWindow() {
    return Container();
  }

  Widget friendWindowNormal(double friendWindowWidth, double friendWindowHeight, double fontSize) {
    double headerHeight = 40;
    return Container(
      child: Column(
        children: [
          friendWindowHeader(friendWindowWidth, headerHeight, fontSize),
          socialView ? socialWindow() : friendRequestWindow(),
        ],
      )
    );
  }

  Widget friendWindow(BuildContext context) {
    double friendWindowHeight = MediaQuery.of(context).size.height * 0.8;
    double fontSize = 16;
    double friendWindowWidth = 800;
    // We use the total height to hide the chatbox below
    normalMode = true;
    if (MediaQuery.of(context).size.width <= 800) {
      friendWindowWidth = MediaQuery.of(context).size.width;
      normalMode = false;
    }
    return Container(
      width: friendWindowWidth,
      height: friendWindowHeight,
      color: Colors.cyan,
      child: friendWindowNormal(friendWindowWidth, friendWindowHeight, fontSize)
    );
  }

  Widget build(BuildContext context) {
    return Align(
      alignment: FractionalOffset.center,
      child: showFriendWindow ? friendWindow(context) : Container()
    );
  }
}
