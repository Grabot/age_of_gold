import 'package:age_of_gold/age_of_gold.dart';
import 'package:flutter/material.dart';

import '../../../../services/auth_service_social.dart';
import '../../../../services/models/friend.dart';
import '../../../../services/models/user.dart';
import '../../../../services/settings.dart';
import '../../../../util/render_objects.dart';
import '../../../../util/util.dart';
import '../../ui_util/chat_messages.dart';
import '../chat_window/chat_window_change_notifier.dart';
import 'user_box_change_notifier.dart';


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
  int? userViewingId;

  bool isMe = false;

  @override
  void initState() {
    userBoxChangeNotifier = UserBoxChangeNotifier();
    userBoxChangeNotifier.addListener(userBoxChangeListener);

    _focusUserBox.addListener(_onFocusChange);
    super.initState();
  }


  userBoxChangeListener() {
    if (mounted) {
      if (!showUser && userBoxChangeNotifier.getUserBoxVisible()) {
        userViewingId = userBoxChangeNotifier.getUser()!.getId();
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
    widget.game.windowFocus(_focusUserBox.hasFocus);
  }

  addFriend() {
    AuthServiceSocial().addFriend(userViewingId!).then((value) {
      if (value.getResult()) {
        User? currentUser = Settings().getUser();
        User newFriend = userBoxChangeNotifier.getUser()!;
        Friend friend = Friend(newFriend.getId(), false, true, 0, newFriend.getUserName());
        friend.setFriendAvatar(newFriend.getAvatar());
        if (value.getMessage() == "success") {
          if (currentUser != null) {
            friend.setRequested(true);
            currentUser.addFriend(friend);
            setState(() {
            });
          }
          showToastMessage("Friend request sent to ${friend.getFriendName()}");
        } else if (value.getMessage() == "request already sent") {
          showToastMessage("Friend request has already been sent to ${friend.getFriendName()}");
        } else if (value.getMessage() == "They are now friends") {
          setState(() {
            friend.setAccepted(true);
            friend.setRequested(false);
            currentUser!.addFriend(friend);
            showToastMessage("You are now friends with ${friend.getFriendName()}");
          });
        } else {
          showToastMessage(value.getMessage());
        }
      } else {
        showToastMessage("something went wrong");
      }
    }).onError((error, stackTrace) {
      showToastMessage(error.toString());
    });
  }

  sendMessage() {
    setState(() {
      if (userBoxChangeNotifier.getUser() != null) {
        goBack();
        ChatMessages chatMessages = ChatMessages();
        chatMessages.addChatRegion(
            userBoxChangeNotifier.getUser()!.getId(),
            userBoxChangeNotifier.getUser()!.getUserName(),
            0,
            false,
            true
        );
        chatMessages.setActiveChatTab("Personal");
        ChatWindowChangeNotifier().setChatWindowVisible(true);
      }
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

  Widget avatarOverviewNormal() {
    return Container(
      padding: const EdgeInsets.all(10),
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
                    style: const TextStyle(
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

  Widget avatarOverviewMobile() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          avatarBox(200, 200, userBoxChangeNotifier.getUser()!.getAvatar()!),
          Row(
            children: [
              Expanded(
                child: RichText(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: userBoxChangeNotifier.getUser()!.getUserName(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold
                        )
                      )
                    ]
                  )
                ),
              ),
            ]
          ),
        ],
      ),
    );
  }

  Widget messageUserButton(double buttonWidth, double buttonHeight, double fontSize) {
    return SizedBox(
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
    return SizedBox(
      width: buttonWidth,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: () {
          addFriend();
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
    return SizedBox(
      width: userSocialBoxWidth,
      child: Column(
        children: [
          messageUserButton(userSocialBoxWidth, 40, 16),
          const SizedBox(height: 10),
          addFriendButton(userSocialBoxWidth, 40, 16),
        ],
      ),
    );
  }

  Widget userSocialBoxMe(double userSocialBoxWidth) {
    return SizedBox(
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

  Widget userBoxNormal(double userBoxWidth, double userBoxHeight, double fontSize) {
    return Column(
      children: [
        userHeader(),
        avatarOverviewNormal(),
        Row(
          children: [
            !isMe ? userSocialBox(200) : userSocialBoxMe(200),
          ],
        )
      ],
    );
  }

  Widget userBoxMobile(double userBoxWidth, double userBoxHeight, double fontSize) {
    return Column(
      children: [
        userHeader(),
        avatarOverviewMobile(),
        !isMe ? userSocialBox(userBoxWidth) : userSocialBoxMe(userBoxWidth),
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
      padding: const EdgeInsets.only(left: 10, right: 10),
      width: width,
      height: height,
      color: Colors.grey,
      child: normalMode
          ? userBoxNormal(width, height, fontSize)
          : userBoxMobile(width, height, fontSize)
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: FractionalOffset.center,
      child: showUser ? userBox() : Container()
    );
  }
}
