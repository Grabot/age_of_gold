import 'package:age_of_gold/age_of_gold.dart';
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

  Widget friendWindow(BuildContext context) {
    double friendWindowHeight = MediaQuery.of(context).size.height * 0.8;
    return Container(
      width: 1500,
      height: friendWindowHeight,
      color: Colors.cyan,
    );
  }

  Widget build(BuildContext context) {
    return Align(
      alignment: FractionalOffset.center,
      child: showFriendWindow ? friendWindow(context) : Container()
    );
  }
}
