import 'package:age_of_gold/age_of_gold.dart';
import 'package:age_of_gold/services/settings.dart';
import 'package:age_of_gold/util/render_objects.dart';
import 'package:age_of_gold/util/util.dart';
import 'package:age_of_gold/views/user_interface/ui_function/user_interface_util/chat_box_change_notifier.dart';
import 'package:age_of_gold/views/user_interface/ui_function/user_interface_util/send_message_box_change_notifier.dart';
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

  bool isMe = false;

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
        if (Settings().getUser()!.getUserName() == userBoxChangeNotifier.getUser()!.getUserName()) {
          isMe = true;
        } else {
          isMe = false;
        }
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

  goBack() {
    setState(() {
      userBoxChangeNotifier.setUserBoxVisible(false);
    });
  }

  void _onFocusChange() {
    widget.game.userBoxFocus(_focusUserBox.hasFocus);
  }

  sendMessage() {
    print("send message");
    setState(() {
      SendMessageBoxChangeNotifier().setToUser(userBoxChangeNotifier.getUser());
      SendMessageBoxChangeNotifier().setSendMessageBoxVisible(true);
    });
  }

  whisperUser() {
    setState(() {
      ChatBoxChangeNotifier chatBoxChangeNotifier = ChatBoxChangeNotifier();
      chatBoxChangeNotifier.setChatUser(userBoxChangeNotifier.getUser()!.getUserName());
      chatBoxChangeNotifier.setChatBoxVisible(true);
    });
  }

  Widget userHeader() {
    return Align(
      alignment: Alignment.topRight,
      child: IconButton(
        icon: const Icon(Icons.close),
        color: Colors.orangeAccent.shade200,
        tooltip: 'cancel',
        onPressed: () {
          goBack();
        }
      ),
    );
  }

  Widget avatarOverview() {
    return Container(
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          avatarBox(200, 200, userBoxChangeNotifier.getUser()!.getAvatar()!),
          Expanded(
            child: RichText(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: userBoxChangeNotifier.getUser()!.getUserName(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold
                    )
                  )
                ]
              )
            ),
          ),
        ],
      ),
    );
  }

  Widget whisperUserButton(double buttonWidth, double buttonHeight, double fontSize) {
    return Container(
      width: buttonWidth,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: () {
          whisperUser();
        },
        style: buttonStyle(false, Colors.blue),
        child: Container(
          alignment: Alignment.center,
          child: Text(
            'Whisper user',
            style: simpleTextStyle(fontSize),
          ),
        ),
      ),
    );
  }

  Widget messageUserButton(double buttonWidth, double buttonHeight, double fontSize) {
    return Container(
      width: buttonWidth,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: () {
          sendMessage();
        },
        style: buttonStyle(false, Colors.blue),
        child: Container(
          alignment: Alignment.center,
          child: Text(
            'Message user',
            style: simpleTextStyle(fontSize),
          ),
        ),
      ),
    );
  }

  Widget addFriendButton(double buttonWidth, double buttonHeight, double fontSize) {
    return Container(
      width: buttonWidth,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: () {
          print("add friend! :)");
        },
        style: buttonStyle(false, Colors.blue),
        child: Container(
          alignment: Alignment.center,
          child: Text(
            'Add friend',
            style: simpleTextStyle(fontSize),
          ),
        ),
      ),
    );
  }

  Widget userSocialBox(double userSocialBoxWidth) {
    return Container(
      width: userSocialBoxWidth,
      child: Column(
        children: [
          whisperUserButton(userSocialBoxWidth, 40, 16),
          SizedBox(height: 10),
          messageUserButton(userSocialBoxWidth, 40, 16),
          SizedBox(height: 10),
          addFriendButton(userSocialBoxWidth, 40, 16),
        ],
      ),
    );
  }

  Widget userSocialBoxMe(double userSocialBoxWidth) {
    return Container(
      width: userSocialBoxWidth,
      child: Align(
        alignment: Alignment.center,
        child: Text(
          "This is You!",
          style: simpleTextStyle(16),
        ),
      ),
    );
  }

  Widget scoreBox() {
    return Container(
      padding: EdgeInsets.all(30),
      child: Column(
        children: [
          Text("Score: 0")
        ],
      ),
    );
  }

  Widget userBoxNormal(double userBoxWidth, double userBoxHeight, double fontSize) {
    return Column(
      children: [
        userHeader(),
        avatarOverview(),
        Row(
          children: [
            !isMe ? userSocialBox(200) : userSocialBoxMe(200),
            scoreBox(),
          ],
        )
      ],
    );
  }

  Widget userBoxMobile(double userBoxWidth, double userBoxHeight, double fontSize) {
    return Column(
      children: [
        userHeader(),
        avatarOverview(),
        !isMe ? userSocialBox(userBoxWidth) : userSocialBoxMe(userBoxWidth),
        scoreBox(),
      ],
    );
  }

  Widget userBox() {
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
      color: Colors.grey,
      child: normalMode
          ? userBoxNormal(width, height, fontSize)
          : userBoxMobile(width, height, fontSize)
    );
  }

  Widget build(BuildContext context) {
    return Align(
      alignment: FractionalOffset.center,
      child: showUser ? userBox() : Container()
    );
  }
}
