import 'package:age_of_gold/age_of_gold.dart';
import 'package:age_of_gold/util/render_objects.dart';
import 'package:age_of_gold/util/util.dart';
import 'package:age_of_gold/views/user_interface/ui_function/user_interface_util/user_box_change_notifier.dart';
import 'package:flutter/material.dart';


class SendMessageBox extends StatefulWidget {

  final AgeOfGold game;

  const SendMessageBox({
    required Key key,
    required this.game
  }) : super(key: key);

  @override
  SendMessageBoxState createState() => SendMessageBoxState();
}

class SendMessageBoxState extends State<SendMessageBox> with TickerProviderStateMixin {

  final FocusNode _focusSendMessage = FocusNode();
  bool showSendMessageBox = false;

  late UserBoxChangeNotifier userBoxChangeNotifier;
  @override
  void initState() {
    userBoxChangeNotifier = UserBoxChangeNotifier();
    userBoxChangeNotifier.addListener(userBoxChangeListener);

    _focusSendMessage.addListener(_onFocusChange);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  userBoxChangeListener() {
    if (mounted) {
      if (!showSendMessageBox && userBoxChangeNotifier.getUserBoxVisible()) {
        setState(() {
          showSendMessageBox = true;
        });
      }
      if (showSendMessageBox && !userBoxChangeNotifier.getUserBoxVisible()) {
        setState(() {
          showSendMessageBox = false;
        });
      }
    }
  }

  void _onFocusChange() {
    widget.game.userBoxFocus(_focusSendMessage.hasFocus);
  }

  Widget sendMessageNormal(double userBoxWidth, double userBoxHeight, double fontSize) {
    return Container();
  }

  Widget sendMessageMobile(double userBoxWidth, double userBoxHeight, double fontSize) {
    return Container();
  }

  Widget sendMessageBox() {
    // normal mode is for desktop, mobile mode is for mobile.
    bool normalMode = true;
    double fontSize = 16;
    double width = 800;
    double height = (MediaQuery.of(context).size.height / 10) * 8;
    // When the width is smaller than this we assume it's mobile.
    if (MediaQuery.of(context).size.width <= 800) {
      width = MediaQuery.of(context).size.width - 50;
      fontSize = 10;
      normalMode = false;
    }

    return Container(
      padding: EdgeInsets.only(left: 10, right: 10),
      width: 700,
      height: 540,
      color: Colors.blue,
      child: normalMode
          ? sendMessageNormal(width, height, fontSize)
          : sendMessageMobile(width, height, fontSize)
    );
  }

  Widget build(BuildContext context) {
    return Align(
      alignment: FractionalOffset.center,
      child: showSendMessageBox ? sendMessageBox() : Container()
    );
  }
}
