import 'dart:typed_data';

import 'package:age_of_gold/age_of_gold.dart';
import 'package:age_of_gold/services/auth_service_social.dart';
import 'package:age_of_gold/services/models/friend.dart';
import 'package:age_of_gold/services/models/user.dart';
import 'package:age_of_gold/util/render_objects.dart';
import 'package:age_of_gold/util/util.dart';
import 'package:age_of_gold/views/user_interface/ui_util/chat_messages.dart';
import 'package:age_of_gold/views/user_interface/ui_util/clear_ui.dart';
import 'package:age_of_gold/views/user_interface/ui_views/chat_window/chat_window_change_notifier.dart';
import 'package:age_of_gold/views/user_interface/ui_views/friend_window/friend_window_change_notifier.dart';
import 'package:age_of_gold/views/user_interface/ui_views/profile_box/profile_change_notifier.dart';
import 'package:flutter/material.dart';


class FriendWindowOverview extends StatefulWidget {

  final AgeOfGold game;
  final bool normalMode;
  final double friendWindowHeight;
  final double friendWindowWidth;
  final double fontSize;
  final User? me;
  final FriendWindowChangeNotifier friendWindowChangeNotifier;

  const FriendWindowOverview({
    required Key key,
    required this.game,
    required this.normalMode,
    required this.friendWindowHeight,
    required this.friendWindowWidth,
    required this.fontSize,
    required this.me,
    required this.friendWindowChangeNotifier,
  }) : super(key: key);

  @override
  FriendWindowOverviewState createState() => FriendWindowOverviewState();
}

class FriendWindowOverviewState extends State<FriendWindowOverview> {

  final FocusNode _focusFriendWindow = FocusNode();

  @override
  void initState() {
    _focusFriendWindow.addListener(_onFocusChange);
    if (widget.me != null) {
      widget.friendWindowChangeNotifier.checkAcceptedRetrieved(widget.me!);
    }
    widget.friendWindowChangeNotifier.addListener(friendOverviewChangeNotifier);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  friendOverviewChangeNotifier() {
    if (mounted) {
      if (widget.me != null) {
        widget.friendWindowChangeNotifier.checkAcceptedRetrieved(widget.me!);
      }
    }
  }

  void _onFocusChange() {
    widget.game.windowFocus(_focusFriendWindow.hasFocus);
  }

  messageFriend(Friend friend) {
    ClearUI().clearUserInterfaces();
    ChatMessages chatMessages = ChatMessages();
    chatMessages.addChatRegion(
        friend.getFriendId(),
        friend.getFriendName()!,
        friend.unreadMessages!,
        friend.isAccepted(),
        true
    );
    chatMessages.setActiveChatTab("Personal");
    ChatWindowChangeNotifier().setChatWindowVisible(true);
  }

  removeFriend(Friend friend) {
    print("cancel request!");
    AuthServiceSocial().denyRequest(friend.getFriendId()).then((value) {
      if (value.getResult()) {
        setState(() {
          if (widget.me != null) {
            widget.me!.removeFriend(friend.getFriendId());
            showToastMessage("${friend.getFriendName()} and you are no longer friends");
            widget.friendWindowChangeNotifier.checkUnansweredFriendRequests(widget.me);
            ProfileChangeNotifier().notify();
          }
        });
      } else {
        showToastMessage("something went wrong");
      }
    });
  }

  Widget friendInteraction(Friend friend, double avatarBoxSize, double newFriendOptionWidth, double fontSize) {
    return Container(
      width: newFriendOptionWidth,
      height: 40,
      child: Row(
          children: [
            InkWell(
                onTap: () {
                  setState(() {
                    messageFriend(friend);
                  });
                },
                child: Tooltip(
                    message: 'Message user',
                    child: addIcon(40, Icons.message, Colors.green)
                )
            ),
            SizedBox(width: 10),
            InkWell(
              onTap: () {
                setState(() {
                  removeFriend(friend);
                });
              },
              child: Tooltip(
                message: 'Remove friend',
                child: addIcon(40, Icons.person_remove, Colors.red),
              ),
            ),
          ]
      ),
    );
  }

  Widget friendBox(Friend friend, double avatarBoxSize, double addFriendWindowWidth, double fontSize) {
    double newFriendOptionWidth = 100;
    double sidePadding = 40;
    if (!widget.normalMode) {
      avatarBoxSize = avatarBoxSize / 1.2;
      fontSize = fontSize / 1.8;
      sidePadding = 10;
    }

    String friendName = "";
    if (friend.getFriendName() != null) {
      friendName = friend.getFriendName()!;
    }
    Uint8List? friendAvatar;
    if (friend.getFriendAvatar() != null) {
      friendAvatar = friend.getFriendAvatar()!;
    }
    return Row(
        children: [
          SizedBox(width: sidePadding),
          avatarBox(avatarBoxSize, avatarBoxSize, friendAvatar),
          SizedBox(
              width: addFriendWindowWidth - avatarBoxSize - newFriendOptionWidth - (2 * sidePadding),
              child: Text(
                  friendName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: fontSize * 2
                  )
              )
          ),
          friendInteraction(friend, avatarBoxSize, newFriendOptionWidth, fontSize),
          SizedBox(width: sidePadding),
        ]
    );
  }

  List<Widget> friendList(double friendWindowWidth) {
    List<Friend> befriended = [];
    if (widget.me != null) {
      befriended = widget.me!.getFriends();
    }

    List<Widget> friends = [];
    if (befriended.isNotEmpty) {
      befriended = befriended.where((friend) => friend.isAccepted()).toList();
      for (Friend friend in befriended) {
        friends.add(
            friendBox(friend, 70, friendWindowWidth, widget.fontSize)
        );
      }
    }

    return friends;
  }

  Widget friendOverview() {
    return SizedBox(
      width: widget.friendWindowWidth,
      height: widget.friendWindowHeight,
      child: SingleChildScrollView(
        child: Column(
          children: friendList(widget.friendWindowWidth),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: FractionalOffset.center,
        child: Column(
            children: [
              friendOverview(),
            ]
        )
    );
  }
}
