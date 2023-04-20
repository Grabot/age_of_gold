import 'package:age_of_gold/age_of_gold.dart';
import 'package:age_of_gold/util/render_objects.dart';
import 'package:age_of_gold/util/util.dart';
import 'package:age_of_gold/views/user_interface/ui_function/user_interface_util/send_message_box_change_notifier.dart';
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

  late SendMessageBoxChangeNotifier sendMessageBoxChangeNotifier;
  @override
  void initState() {
    sendMessageBoxChangeNotifier = SendMessageBoxChangeNotifier();
    sendMessageBoxChangeNotifier.addListener(sendMessageBoxChangeListener);

    _focusSendMessage.addListener(_onFocusChange);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  sendMessageBoxChangeListener() {
    if (mounted) {
      if (!showSendMessageBox && sendMessageBoxChangeNotifier.getSendMessageBoxVisible()) {
        setState(() {
          showSendMessageBox = true;
        });
      }
      if (showSendMessageBox && !sendMessageBoxChangeNotifier.getSendMessageBoxVisible()) {
        setState(() {
          showSendMessageBox = false;
        });
      }
    }
  }

  void _onFocusChange() {
    widget.game.userBoxFocus(_focusSendMessage.hasFocus);
  }

  goBack() {
    setState(() {
      sendMessageBoxChangeNotifier.setSendMessageBoxVisible(false);
    });
  }

  Widget sendMessageHeader(double userBoxWidth, double userBoxHeight, double fontSize) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Create New Message",
          style: simpleTextStyle(fontSize),
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
      ],
    );
  }

  Widget toUserDetail(double userBoxWidth, double userBoxHeight, double fontSize) {
    print("going to create a user detail thing with user ${sendMessageBoxChangeNotifier.toUser!.userName}");
    return Row(
      children: [
        Text(
          "To: ",
          style: simpleTextStyle(fontSize)
        ),
        Expanded(
          child: RichText(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              text: sendMessageBoxChangeNotifier.toUser!.userName,
              style: simpleTextStyle(fontSize)
            )
          ),
        ),
      ]
    );
  }

  Widget sendMessageNormal(double userBoxWidth, double userBoxHeight, double fontSize) {
    return Column(
      children: [
        sendMessageHeader(userBoxWidth, userBoxHeight, fontSize),
        toUserDetail(userBoxWidth, userBoxHeight, fontSize),
        Divider(
          color: Colors.white,
          height: 36,
        ),
        // TODO: Add subject and message box, together with the send button
      ],
    );
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
      width: width,
      height: height,
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
