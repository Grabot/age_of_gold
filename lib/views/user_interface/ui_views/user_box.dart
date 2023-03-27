import 'package:age_of_gold/age_of_gold.dart';
import 'package:age_of_gold/views/user_interface/ui_function/user_interface_util/user_box_change_notifier.dart';
import 'package:flutter/material.dart';


class UserBox extends StatefulWidget {

  final AgeOfGold game;

  const UserBox({
    required Key key,
    required this.game
  }) : super(key: key);

  @override
  UserBoxState createState() => UserBoxState();
}

class UserBoxState extends State<UserBox> with TickerProviderStateMixin {

  final FocusNode _focusUserBox = FocusNode();
  bool showUser = false;

  late UserBoxChangeNotifier userBoxChangeNotifier;
  @override
  void initState() {
    userBoxChangeNotifier = UserBoxChangeNotifier();
    userBoxChangeNotifier.addListener(userBoxChangeListener);

    _focusUserBox.addListener(_onFocusChange);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  userBoxChangeListener() {
    if (mounted) {
      if (!showUser && userBoxChangeNotifier.getUserBoxVisible()) {
        setState(() {
          showUser = true;
        });
      }
      if (showUser && !userBoxChangeNotifier.getUserBoxVisible()) {
        setState(() {
          showUser = false;
        });
      }
    }
  }

  void _onFocusChange() {
    widget.game.userBoxFocus(_focusUserBox.hasFocus);
  }

  Widget userBox() {
    return Container(
      width: 540,
      height: 540,
      color: Colors.black,
    );
  }

  Widget build(BuildContext context) {
    return Align(
      alignment: FractionalOffset.center,
      child: showUser ? userBox() : Container()
    );
  }
}
