import 'dart:typed_data';
import 'package:age_of_gold/age_of_gold.dart';
import 'package:flutter/material.dart';

import '../../../../services/auth_service_social.dart';
import '../../../../services/models/friend.dart';
import '../../../../services/models/user.dart';
import '../../../../util/render_objects.dart';
import '../../../../util/util.dart';
import '../profile_box/profile_change_notifier.dart';
import 'friend_window_change_notifier.dart';


class FriendWindowFriendRequests extends StatefulWidget {

  final AgeOfGold game;
  final bool normalMode;
  final double friendWindowHeight;
  final double friendWindowWidth;
  final double fontSize;
  final User? me;
  final FriendWindowChangeNotifier friendWindowChangeNotifier;

  const FriendWindowFriendRequests({
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
  FriendWindowFriendRequestsState createState() => FriendWindowFriendRequestsState();
}

class FriendWindowFriendRequestsState extends State<FriendWindowFriendRequests> {

  final FocusNode _focusFriendWindow = FocusNode();

  @override
  void initState() {
    _focusFriendWindow.addListener(_onFocusChange);
    super.initState();
    widget.friendWindowChangeNotifier.addListener(friendRequestChangeNotifier);
    if (widget.me != null) {
      widget.friendWindowChangeNotifier.checkRequestedRetrieved(widget.me!);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  friendRequestChangeNotifier() {
    if (mounted) {
      setState(() {
        widget.friendWindowChangeNotifier.checkRequestedRetrieved(widget.me!);
      });
    }
  }

  void _onFocusChange() {
    widget.game.windowFocus(_focusFriendWindow.hasFocus);
  }

  cancelFriendRequest(Friend friend) {
    AuthServiceSocial().denyRequest(friend.getFriendId()).then((value) {
      if (value.getResult()) {
        setState(() {
          if (widget.me != null) {
            widget.me!.removeFriend(friend.getFriendId());
            showToastMessage("friend request denied");
            widget.friendWindowChangeNotifier.checkUnansweredFriendRequests(widget.me);
            ProfileChangeNotifier().notify();
          }
        });
      } else {
        showToastMessage("something went wrong");
      }
    });
  }

  acceptRequest(Friend friend) {
    AuthServiceSocial().acceptRequest(friend.getFriendId()).then((value) {
      if (value.getResult()) {
        setState(() {
          friend.setAccepted(true);
          widget.friendWindowChangeNotifier.checkUnansweredFriendRequests(widget.me);
        });
        showToastMessage("You are now friends with ${friend.getFriendName()!}");
        ProfileChangeNotifier profileChangeNotifier = ProfileChangeNotifier();
        profileChangeNotifier.setProfileVisible(false);
        profileChangeNotifier.notify();
      } else {
        showToastMessage("something went wrong");
      }
    }).onError((error, stackTrace) {
      showToastMessage(error.toString());
    });
  }

  Widget receivedOrRequested(double friendWindowWidth, double fontSize, bool requested) {
    if (requested) {
      return SizedBox(
        width: friendWindowWidth,
        height: 30,
        child: Text(
            "Send requests",
            style: TextStyle(
                color: Colors.white,
                fontSize: fontSize * 1.5
            )
        ),
      );
    } else {
      return SizedBox(
        width: friendWindowWidth,
        height: 30,
        child: Text(
            "Received requests",
            style: TextStyle(
                color: Colors.white,
                fontSize: fontSize * 1.5
            )
        ),
      );
    }
  }

  Widget friendInteraction(Friend friend, double avatarBoxSize, double newFriendOptionWidth, double fontSize) {

    if (friend.isRequested()!) {
      // friend has requested you
      return SizedBox(
          width: newFriendOptionWidth,
          height: 40,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                cancelFriendRequest(friend);
              });
            },
            child: Text(
              "Cancel",
              style: simpleTextStyle(
                fontSize,
              ),
            ),
          )
      );
    } else if (!friend.isRequested()!) {
      // you have requested friend
      return SizedBox(
        width: newFriendOptionWidth,
        height: 40,
        child: Row(
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    acceptRequest(friend);
                  });
                },
                child: Tooltip(
                    message: 'Accept request',
                    child: addIcon(40, Icons.check, Colors.green)
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                onTap: () {
                  setState(() {
                    cancelFriendRequest(friend);
                  });
                },
                child: Tooltip(
                  message: 'Deny request',
                  child: addIcon(40, Icons.close, Colors.red),
                ),
              ),
            ]
        ),
      );
    }
    return Container();
  }

  Widget friendBox(Friend friend, double avatarBoxSize, double addFriendWindowWidth, double fontSize) {
    double friendOptionWidth = 100;
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
              width: addFriendWindowWidth - avatarBoxSize - friendOptionWidth - sidePadding - sidePadding,
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
          friendInteraction(friend, avatarBoxSize, friendOptionWidth, fontSize),
          SizedBox(width: sidePadding),
        ]
    );
  }

  List<Widget> friendList(double friendWindowWidth, double fontSize, bool? requested) {
    List<Friend> befriended = [];
    if (widget.me != null) {
      befriended = widget.me!.getFriends();
    }

    List<Widget> friends = [];
    if (befriended.isNotEmpty) {
      if (requested == null) {
        befriended = befriended.where((friend) => friend.isAccepted()).toList();
      } else {
        befriended = befriended.where((friend) => !friend.isAccepted() && friend.requested == requested).toList();
      }
      for (Friend friend in befriended) {
        friends.add(
            friendBox(friend, 70, friendWindowWidth, fontSize)
        );
      }
    }

    return friends;
  }

  Widget requestBox(double friendWindowWidth, double requestBoxHeight, double fontSize) {
    List<Friend> befriended = [];
    if (widget.me != null) {
      befriended = widget.me!.getFriends();
    }
    if (befriended.isNotEmpty) {
      List<Friend> requestedFriends = befriended.where((friend) => !friend.isAccepted() && friend.requested == true).toList();
      List<Friend> gotRequestedFriends = befriended.where((friend) => !friend.isAccepted() && friend.requested == false).toList();
      if (requestedFriends.isNotEmpty && gotRequestedFriends.isNotEmpty) {
        return Column(
          children: [
            receivedOrRequested(friendWindowWidth, fontSize, false),
            SizedBox(
              height: requestBoxHeight/2 - 30,
              child: SingleChildScrollView(
                child: Column(
                  children: friendList(friendWindowWidth, fontSize, false),
                ),
              ),
            ),
            receivedOrRequested(friendWindowWidth, fontSize, true),
            SizedBox(
              height: requestBoxHeight/2 - 30,
              child: SingleChildScrollView(
                child: Column(
                  children: friendList(friendWindowWidth, fontSize, true),
                ),
              ),
            ),
          ],
        );
      } else if ((requestedFriends.isEmpty && gotRequestedFriends.isNotEmpty)
          || (requestedFriends.isNotEmpty && gotRequestedFriends.isEmpty)) {
        return Column(
            children: [
              receivedOrRequested(friendWindowWidth, fontSize, requestedFriends.isNotEmpty),
              SizedBox(
                height: requestBoxHeight - 30,
                child: SingleChildScrollView(
                  child: Column(
                    children: friendList(friendWindowWidth, fontSize, requestedFriends.isNotEmpty),
                  ),
                ),
              ),
            ]
        );
      }
      return Container(height: requestBoxHeight);
    }
    return Container(height: requestBoxHeight);
  }

  Widget friendRequestWindow() {
    return SizedBox(
      width: widget.friendWindowWidth,
      height: widget.friendWindowHeight,
      child: SingleChildScrollView(
        child: Column(
          children: [
            requestBox(widget.friendWindowWidth, widget.friendWindowHeight, widget.fontSize),
          ]
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
              friendRequestWindow(),
            ]
        )
    );
  }
}
