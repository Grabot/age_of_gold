import 'package:age_of_gold/age_of_gold.dart';
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
  bool showUser = true;

  @override
  void initState() {
    _focusUserBox.addListener(_onFocusChange);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
