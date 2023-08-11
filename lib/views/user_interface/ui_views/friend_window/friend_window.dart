import 'package:age_of_gold/age_of_gold.dart';
import 'package:age_of_gold/services/models/friend.dart';
import 'package:age_of_gold/services/models/user.dart';
import 'package:age_of_gold/services/settings.dart';
import 'package:age_of_gold/services/socket_services.dart';
import 'package:age_of_gold/util/util.dart';
import 'package:age_of_gold/views/user_interface/ui_views/friend_window/friend_window_change_notifier.dart';
import 'package:age_of_gold/views/user_interface/ui_views/friend_window/friend_window_find_friend.dart';
import 'package:age_of_gold/views/user_interface/ui_views/friend_window/friend_window_friend_requests.dart';
import 'package:age_of_gold/views/user_interface/ui_views/friend_window/friend_window_overview.dart';
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
  bool normalMode = true;

  late FriendWindowChangeNotifier friendWindowChangeNotifier;

  final FocusNode _focusAdd = FocusNode();
  TextEditingController addController = TextEditingController();
  final GlobalKey<FormState> addFriendKey = GlobalKey<FormState>();

  double iconSize = 40;

  SocketServices socket = SocketServices();

  bool unansweredFriendRequests = false;

  int friendOverviewColour = 2;
  int friendRequestsColour = 0;
  int findFriendColour = 0;

  bool showFriendOverview = true;
  bool friendRequestsView = true;
  bool findFriendView = true;

  User? me;

  UniqueKey friendWindowOverviewKey = UniqueKey();

  @override
  void initState() {
    friendWindowChangeNotifier = FriendWindowChangeNotifier();
    friendWindowChangeNotifier.addListener(friendWindowChangeListener);

    _focusFriendWindow.addListener(_onFocusChange);
    _focusAdd.addListener(_onFocusAddFriendChange);

    socket.checkFriends();
    socket.addListener(socketListener);
    super.initState();
  }

  socketListener() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  _onFocusAddFriendChange() {
    widget.game.profileFocus(_focusAdd.hasFocus);
  }

  void _onFocusChange() {
    widget.game.friendWindowFocus(_focusFriendWindow.hasFocus);
  }

  friendWindowChangeListener() {
    if (mounted) {
      me = Settings().getUser();
      if (!showFriendWindow && friendWindowChangeNotifier.getFriendWindowVisible()) {
        showFriendWindow = true;
      }
      if (showFriendWindow && !friendWindowChangeNotifier.getFriendWindowVisible()) {
        showFriendWindow = false;
      }
      setState(() {});
    }
  }

  goBack() {
    setState(() {
      if (findFriendView || friendRequestsView) {
        switchToOverview();
      } else {
        FriendWindowChangeNotifier().setFriendWindowVisible(false);
      }
    });
  }

  switchToOverview() {
    showFriendOverview = true;
    friendRequestsView = false;
    findFriendView = false;
    friendOverviewColour = 2;
    friendRequestsColour = 0;
    findFriendColour = 0;
  }

  switchToFriendRequest() {
    showFriendOverview = false;
    friendRequestsView = true;
    findFriendView = false;
    friendOverviewColour = 0;
    friendRequestsColour = 2;
    findFriendColour = 0;
  }

  switchToFindFriend() {
    showFriendOverview = false;
    friendRequestsView = false;
    findFriendView = true;
    friendOverviewColour = 0;
    friendRequestsColour = 0;
    findFriendColour = 2;
  }


  Widget friendWindowHeader(double headerWidth, double headerHeight, double fontSize) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(),
          SizedBox(
              height: headerHeight,
              child: Text(
                friendWindowChangeNotifier.getHeaderText(),
                style: simpleTextStyle(fontSize),
              )
          ),
          SizedBox(
            height: headerHeight,
            child: IconButton(
              icon: const Icon(Icons.close),
              color: Colors.orangeAccent.shade200,
              tooltip: 'cancel',
              onPressed: () {
                goBack();
              }
            ),
          ),
        ]
    );
  }

  Widget friendOverviewButton(double buttonWidth, double fontSize) {
    return InkWell(
      onTap: () {
        setState(() {
          switchToOverview();
        });
      },
      onHover: (hovering) {
        setState(() {
          if (hovering) {
            friendOverviewColour = 1;
          } else {
            if (showFriendOverview) {
              friendOverviewColour = 2;
            } else {
              friendOverviewColour = 0;
            }
          }
        });
      },
      child: Container(
        width: buttonWidth,
        height: iconSize,
        color: getDetailColour(friendOverviewColour),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(width: 1),
              Row(
                children: [
                  addIcon(iconSize, Icons.people, Colors.orange),
                  SizedBox(width: 5),
                  Text(
                    "Friend list",
                    style: simpleTextStyle(
                      fontSize,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 1),
            ]
        ),
      ),
    );
  }

  Widget friendRequestsButton(double buttonWidth, double fontSize) {
    return InkWell(
      onTap: () {
        setState(() {
          switchToFriendRequest();
        });
      },
      onHover: (hovering) {
        setState(() {
          if (hovering) {
            friendRequestsColour = 1;
          } else {
            if (friendRequestsView) {
              friendRequestsColour = 2;
            } else {
              friendRequestsColour = 0;
            }
          }
        });
      },
      child: Container(
        width: buttonWidth,
        height: iconSize,
        color: getDetailColour(friendRequestsColour),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(width: 1),
              Stack(
                  children: [
                    Row(
                      children: [
                        addIcon(iconSize, Icons.person_add_alt_1, Colors.orange),
                        SizedBox(width: 5),
                        Text(
                          "Friend Requests",
                          style: simpleTextStyle(
                            fontSize,
                          ),
                        ),
                      ],
                    ),
                    unansweredFriendRequests ? Image.asset(
                      "assets/images/ui/icon/update_notification.png",
                      width: iconSize,
                      height: iconSize,
                    ) : Container(),
                  ]
              ),
              SizedBox(width: 1),
            ]
        ),
      ),
    );
  }

  Widget findFriendButton(double buttonWidth, double fontSize) {
    return InkWell(
      onTap: () {
        setState(() {
          switchToFindFriend();
        });
      },
      onHover: (hovering) {
        setState(() {
          if (hovering) {
            findFriendColour = 1;
          } else {
            if (findFriendView) {
              findFriendColour = 2;
            } else {
              findFriendColour = 0;
            }
          }
        });
      },
      child: Container(
        width: buttonWidth,
        height: iconSize,
        color: getDetailColour(findFriendColour),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(width: 1),
              Row(
                children: [
                  addIcon(iconSize, Icons.add, Colors.orange),
                  SizedBox(width: 5),
                  Text(
                    "Add new friend",
                    style: simpleTextStyle(
                      fontSize,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 1),
            ]
        ),
      ),
    );
  }

  Widget bottomButtons(double friendWindowWidth, double fontSize) {
    return SizedBox(
      width: friendWindowWidth,
      height: iconSize,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            friendOverviewButton(friendWindowWidth / 3, fontSize),
            friendRequestsButton(friendWindowWidth / 3, fontSize),
            findFriendButton(friendWindowWidth / 3, fontSize),
          ]
      ),
    );
  }

  Widget mainFriendWindow(double guildWindowWidth, double overviewHeight, double fontSize) {
    if (showFriendOverview) {
      return SizedBox(
        width: guildWindowWidth,
        height: overviewHeight,
        child: Column(
            children: [
              FriendWindowOverview(
                key: friendWindowOverviewKey,
                game: widget.game,
                normalMode: normalMode,
                friendWindowHeight: overviewHeight,
                friendWindowWidth: guildWindowWidth,
                fontSize: fontSize,
                me: me,
              )
            ]
        ),
      );
    } else if (friendRequestsView) {
      return SizedBox(
        width: guildWindowWidth,
        height: overviewHeight,
        child: Column(
            children: [
              FriendWindowFriendRequests(
                key: friendWindowOverviewKey,
                game: widget.game,
                normalMode: normalMode,
                friendWindowHeight: overviewHeight,
                friendWindowWidth: guildWindowWidth,
                fontSize: fontSize,
                me: me,
              )
            ]
        ),
      );
    } else {
      return SizedBox(
        width: guildWindowWidth,
        height: overviewHeight,
        child: Column(
            children: [
              FriendWindowFindFriend(
                key: friendWindowOverviewKey,
                game: widget.game,
                normalMode: normalMode,
                friendWindowHeight: overviewHeight,
                friendWindowWidth: guildWindowWidth,
                fontSize: fontSize,
                me: me,
              )
            ]
        ),
      );
    }
  }

  Widget friendWindowNormal(double friendWindowWidth, double friendWindowHeight, double fontSize) {
    double headerHeight = 40;
    double remainingHeight = friendWindowHeight - headerHeight - iconSize;
    return Container(
      child: Column(
        children: [
          friendWindowHeader(friendWindowWidth, headerHeight, fontSize),
          mainFriendWindow(friendWindowWidth, remainingHeight, fontSize),
          bottomButtons(friendWindowWidth, fontSize)
        ],
      )
    );
  }

  Widget friendWindow(BuildContext context) {
    double friendWindowHeight = MediaQuery.of(context).size.height * 0.8;
    double fontSize = 16;
    double friendWindowWidth = 800;
    // We use the total height to hide the chatbox below
    normalMode = true;
    if (MediaQuery.of(context).size.width <= 800) {
      friendWindowWidth = MediaQuery.of(context).size.width;
      normalMode = false;
      fontSize = 12;
    }
    return SingleChildScrollView(
      child: Container(
        width: friendWindowWidth,
        height: friendWindowHeight,
        color: Colors.cyan,
        child: friendWindowNormal(friendWindowWidth, friendWindowHeight, fontSize)
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: FractionalOffset.center,
      child: showFriendWindow ? friendWindow(context) : Container()
    );
  }
}
