import 'dart:typed_data';

import 'package:age_of_gold/age_of_gold.dart';
import 'package:age_of_gold/services/auth_service_social.dart';
import 'package:age_of_gold/services/models/friend.dart';
import 'package:age_of_gold/services/models/user.dart';
import 'package:age_of_gold/util/render_objects.dart';
import 'package:age_of_gold/util/util.dart';
import 'package:age_of_gold/views/user_interface/ui_views/friend_window/friend_window_change_notifier.dart';
import 'package:age_of_gold/views/user_interface/ui_views/profile_box/profile_change_notifier.dart';
import 'package:flutter/material.dart';


class FriendWindowFindFriend extends StatefulWidget {

  final AgeOfGold game;
  final bool normalMode;
  final double friendWindowHeight;
  final double friendWindowWidth;
  final double fontSize;
  final User? me;
  final FriendWindowChangeNotifier friendWindowChangeNotifier;

  const FriendWindowFindFriend({
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
  FriendWindowFindFriendState createState() => FriendWindowFindFriendState();
}

class FriendWindowFindFriendState extends State<FriendWindowFindFriend> {

  final FocusNode _focusAdd = FocusNode();
  TextEditingController addController = TextEditingController();
  final GlobalKey<FormState> addFriendKey = GlobalKey<FormState>();

  double iconSize = 40;

  Friend? possibleNewFriend;
  bool nothingFound = false;

  @override
  void initState() {
    _focusAdd.addListener(_onFocusChange);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onFocusChange() {
    widget.game.windowFocus(_focusAdd.hasFocus);
  }

  searchForFriend(String possibleFriend) {
    print("searching for friend $possibleFriend");
    AuthServiceSocial().searchPossibleFriend(possibleFriend).then((value) {
      print("search result $value");
      if (value != null) {
        print("found friend");
        nothingFound = false;
        User newFriend = value;
        setState(() {
          possibleNewFriend = Friend(newFriend.getId(), false, null, 0, value.getUserName());
          possibleNewFriend!.setFriendAvatar(newFriend.getAvatar());
        });
      } else {
        setState(() {
          nothingFound = true;
        });
      }
    });
  }

  addFriend(Friend friend) {
    AuthServiceSocial().addFriend(friend.getFriendId()).then((value) {
      if (value.getResult()) {
        if (value.getMessage() == "success") {
          if (widget.me != null) {
            friend.setRequested(true);
            widget.me!.addFriend(friend);
            widget.friendWindowChangeNotifier.checkUnansweredFriendRequests(widget.me);
            ProfileChangeNotifier().notify();
            setState(() {
              possibleNewFriend = null;
              addController.text = "";
            });
          }
          showToastMessage("Friend request sent to ${friend.getFriendName()!}");
        } else if (value.getMessage() == "request already sent") {
          showToastMessage("Friend request has already been sent to ${friend.getFriendName()!}");
        } else if (value.getMessage() == "They are now friends") {
          setState(() {
            friend.setAccepted(true);
            friend.setRequested(false);
            widget.me!.addFriend(friend);
            widget.friendWindowChangeNotifier.checkUnansweredFriendRequests(widget.me);
            showToastMessage("You are now friends with ${friend.getFriendName()!}");
            ProfileChangeNotifier profileChangeNotifier = ProfileChangeNotifier();
            profileChangeNotifier.setProfileVisible(false);
            profileChangeNotifier.notify();
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

  Widget friendInteraction(Friend friend, double avatarBoxSize, double newFriendOptionWidth, double fontSize) {
    return SizedBox(
        width: newFriendOptionWidth,
        height: 40,
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              addFriend(friend);
            });
          },
          child: Text(
            "Add!",
            style: simpleTextStyle(
              fontSize,
            ),
          ),
        )
    );
  }

  Widget friendBox(Friend? newFriendOption, double avatarBoxSize, double addFriendWindowWidth, double fontSize) {
    double newFriendOptionWidth = 100;
    double sidePadding = 40;
    if (!widget.normalMode) {
      avatarBoxSize = avatarBoxSize / 1.2;
      fontSize = fontSize / 1.8;
      sidePadding = 10;
    }

    if (newFriendOption != null) {

      String friendName = "";
      if (newFriendOption.getFriendName() != null) {
        friendName = newFriendOption.getFriendName()!;
      }
      Uint8List? friendAvatar;
      if (newFriendOption.getFriendAvatar() != null) {
        friendAvatar = newFriendOption.getFriendAvatar()!;
      }
      return Row(
          children: [
            SizedBox(width: sidePadding),
            avatarBox(avatarBoxSize, avatarBoxSize, friendAvatar),
            SizedBox(
                width: addFriendWindowWidth - avatarBoxSize - newFriendOptionWidth - sidePadding - sidePadding,
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
            friendInteraction(newFriendOption, avatarBoxSize, newFriendOptionWidth, fontSize),
            SizedBox(width: sidePadding),
          ]
      );
    } else {
      if (nothingFound) {
        return Text(
          "No friend found with that name",
          style: simpleTextStyle(fontSize),
        );
      } else {
        return Container();
      }
    }
  }

  Widget newFriendWindow(double addFriendWindowWidth, double addFriendWindowHeight, double fontSize) {
    return Column(
      children: [
        SizedBox(
          width: widget.friendWindowWidth,
          height: widget.friendWindowHeight,
          child: SingleChildScrollView(
            child: Column(
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 10),
                        SizedBox(
                          width: addFriendWindowWidth - 150,
                          height: 50,
                          child: Form(
                            key: addFriendKey,
                            child: TextFormField(
                              onTap: () {
                                if (!_focusAdd.hasFocus) {
                                  _focusAdd.requestFocus();
                                }
                              },
                              validator: (val) {
                                return val == null || val.isEmpty
                                    ? "Please enter the name of a friend to add"
                                    : null;
                              },
                              onFieldSubmitted: (value) {
                                searchForFriend(value);
                              },
                              focusNode: _focusAdd,
                              controller: addController,
                              textAlign: TextAlign.center,
                              style: simpleTextStyle(fontSize),
                              decoration: textFieldInputDecoration("Search for your friends"),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            searchForFriend(addController.text);
                          },
                          child: Container(
                              height: 50,
                              width: 50,
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: const Icon(
                                Icons.search,
                                color: Colors.white,
                              )
                          ),
                        ),
                        const SizedBox(width: 10),
                      ]
                  ),
                  const SizedBox(height: 40),
                  friendBox(possibleNewFriend, 120, addFriendWindowWidth, fontSize),
                ]
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: FractionalOffset.center,
        child: Column(
            children: [
              newFriendWindow(widget.friendWindowWidth, widget.friendWindowHeight, widget.fontSize),
            ]
        )
    );
  }
}
