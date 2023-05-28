import 'package:age_of_gold/age_of_gold.dart';
import 'package:age_of_gold/services/models/friend.dart';
import 'package:age_of_gold/services/models/user.dart';
import 'package:age_of_gold/services/settings.dart';
import 'package:age_of_gold/services/socket_services.dart';
import 'package:age_of_gold/util/countdown.dart';
import 'package:age_of_gold/util/render_objects.dart';
import 'package:age_of_gold/views/user_interface/ui_util/chat_messages.dart';
import 'package:age_of_gold/views/user_interface/ui_util/selected_tile_info.dart';
import 'package:age_of_gold/views/user_interface/ui_views/chat_box/chat_box_change_notifier.dart';
import 'package:age_of_gold/views/user_interface/ui_views/chat_window/chat_window_change_notifier.dart';
import 'package:age_of_gold/views/user_interface/ui_views/friend_window/friend_window_change_notifier.dart';
import 'package:age_of_gold/views/user_interface/ui_views/profile_box/profile_change_notifier.dart';
import 'package:flutter/material.dart';


class ProfileOverview extends StatefulWidget {

  final AgeOfGold game;

  const ProfileOverview({
    required Key key,
    required this.game
  }) : super(key: key);

  @override
  ProfileOverviewState createState() => ProfileOverviewState();
}

class ProfileOverviewState extends State<ProfileOverview> with TickerProviderStateMixin {

  late SelectedTileInfo selectedTileInfo;
  late ProfileChangeNotifier profileChangeNotifier;
  SocketServices socket = SocketServices();
  Settings settings = Settings();

  late AnimationController _controller;
  int levelClock = 0;
  bool canChangeTiles = true;

  int friendOverviewState = 0;
  int messageOverviewState = 0;

  bool unansweredFriendRequests = false;
  bool unreadMessages = false;

  @override
  void initState() {
    super.initState();
    selectedTileInfo = SelectedTileInfo();
    selectedTileInfo.addListener(selectedTileListener);

    profileChangeNotifier = ProfileChangeNotifier();
    profileChangeNotifier.addListener(profileChangeListener);
    settings.addListener(profileChangeListener);

    socket.addListener(socketListener);

    _controller = AnimationController(
        vsync: this,
        duration: Duration(
            seconds:
            levelClock)
    );
    _controller.forward();
    updateTimeLock();
    checkUnansweredFriendRequests();
    checkUnreadMessages();
  }

  checkUnansweredFriendRequests() {
    unansweredFriendRequests = false;
    if (Settings().getUser() != null) {
      User currentUser = Settings().getUser()!;
      for (Friend friend in currentUser.friends) {
        if (!friend.isAccepted() && friend.requested != null && friend.requested == false) {
          unansweredFriendRequests = true;
          break;
        }
      }
    }
  }

  checkUnreadMessages() {
    unreadMessages = ChatMessages().unreadPersonalMessages();
  }

  socketListener() {
    if (mounted) {
      checkUnansweredFriendRequests();
      checkUnreadMessages();
      updateTimeLock();
      friendOverviewState = 0;
      messageOverviewState = 0;
      setState(() {});
    }
  }

  updateTimeLock() {
    if (settings.getUser() != null) {
      DateTime timeLock = settings.getUser()!.getTileLock();
      if (timeLock.isAfter(DateTime.now())) {
        levelClock = timeLock.difference(DateTime.now()).inSeconds;
        _controller = AnimationController(
            vsync: this,
            duration: Duration(
                seconds:
                levelClock)
        );
        _controller.forward();
        _controller.addStatusListener((status) {
          if(status == AnimationStatus.completed) {
            setState(() {
              canChangeTiles = true;
            });
          }
        });
        canChangeTiles = false;
      }
    }
  }

  profileChangeListener() {
    if (mounted) {
      checkUnansweredFriendRequests();
      checkUnreadMessages();
      setState(() {});
    }
  }

  selectedTileListener() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  goToProfile() {
    if (!profileChangeNotifier.getProfileVisible()) {
      profileChangeNotifier.setProfileVisible(true);
    } else if (profileChangeNotifier.getProfileVisible()) {
      profileChangeNotifier.setProfileVisible(false);
    }
  }

  openFriendWindow() {
    FriendWindowChangeNotifier().setFriendWindowVisible(true);
  }

  Color overviewColour(int state) {
    if (state == 0) {
      return Colors.orange;
    } else if (state == 1) {
      return Colors.orangeAccent;
    } else {
      return Colors.orange.shade800;
    }
  }

  Widget tileTimeInformation() {
    if (canChangeTiles) {
      return Container();
    } else {
      return Countdown(
        key: UniqueKey(),
        animation: StepTween(
          begin: levelClock,
          end: 0,
        ).animate(_controller),
      );
    }
  }

  Widget getAvatar(double avatarSize) {
    return Container(
      child: settings.getAvatar() != null ? avatarBox(avatarSize, avatarSize, settings.getAvatar()!)
          : Image.asset(
        "assets/images/default_avatar.png",
        width: avatarSize,
        height: avatarSize,
      )
    );
  }

  Widget profileWidget(double profileOverviewWidth, double profileOverviewHeight) {
    return Row(
      children: [
        Container(
          width: profileOverviewWidth,
          height: profileOverviewHeight,
          color: Colors.black38,
          child: GestureDetector(
            onTap: () {
              goToProfile();
            },
            child: Row(
              children: [
                getAvatar(profileOverviewHeight),
                SizedBox(
                  width: profileOverviewWidth - profileOverviewHeight,
                  child: RichText(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      text: settings.getUser() != null ? settings.getUser()!.getUserName() : "",
                      style: const TextStyle(color: Colors.white, fontSize: 24),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ]
    );
  }

  Widget friendOverviewButton(double profileButtonSize) {
    return Container(
      child: Row(
        children: [
          SizedBox(width: 5),
          Tooltip(
            message: "Socials",
            child: InkWell(
              onHover: (value) {
                setState(() {
                  friendOverviewState = value ? 1 : 0;
                });
              },
              onTap: () {
                setState(() {
                  friendOverviewState = 2;
                });
                openFriendWindow();
              },
              child: Stack(
                children: [
                  Container(
                    width: profileButtonSize,
                    height: profileButtonSize,
                    child: ClipOval(
                      child: Material(
                        color: overviewColour(friendOverviewState),
                      )
                    ),
                  ),
                  Image.asset(
                    "assets/images/ui/icon/friend_icon_clean.png",
                    width: profileButtonSize,
                    height: profileButtonSize,
                  ),
                  unansweredFriendRequests ? Image.asset(
                    "assets/images/ui/icon/update_notification.png",
                    width: profileButtonSize,
                    height: profileButtonSize,
                  ) : Container(),
                ],
              ),
            ),
          ),
        ]
      ),
    );
  }

  showChatWindow() {
    ChatBoxChangeNotifier().setChatBoxVisible(false);
    ChatWindowChangeNotifier().setChatWindowVisible(true);
  }

  Widget messageOverviewButton(double messageButtonSize) {
    return Container(
      child: Row(
          children: [
            SizedBox(width: 5),
            Tooltip(
              message: "messages",
              child: InkWell(
                onHover: (value) {
                  setState(() {
                    messageOverviewState = value ? 1 : 0;
                  });
                },
                onTap: () {
                  setState(() {
                    messageOverviewState = 2;
                  });
                  showChatWindow();
                },
                child: Stack(
                  children: [
                    Container(
                      width: messageButtonSize,
                      height: messageButtonSize,
                      child: ClipOval(
                          child: Material(
                            color: overviewColour(messageOverviewState),
                          )
                      ),
                    ),
                    Image.asset(
                      "assets/images/ui/icon/message_icon_clean.png",
                      width: messageButtonSize,
                      height: messageButtonSize,
                    ),
                    unreadMessages ? Image.asset(
                      "assets/images/ui/icon/update_notification.png",
                      width: messageButtonSize,
                      height: messageButtonSize,
                    ) : Container(),
                  ],
                ),
              ),
            ),
          ]
      ),
    );
  }

  Widget profileOverviewNormal(double profileOverviewWidth, double profileOverviewHeight, double fontSize) {
    double profileAvatarHeight = 100;
    return Container(
      child: Column(
        children: [
          profileWidget(profileOverviewWidth, profileAvatarHeight),
          SizedBox(height: 10),
          friendOverviewButton(50),
          SizedBox(height: 10),
          messageOverviewButton(50)
        ]
      ),
    );
  }

  Widget profileOverviewMobile(double profileOverviewWidth, double profileOverviewHeight, double fontSize) {
    double statusBarPadding = MediaQuery.of(context).viewPadding.top;
    return Container(
      child: Column(
        children: [
          SizedBox(height: statusBarPadding),
          Row(
            children: [
              Column(
                children: [
                  profileWidget(profileOverviewWidth/2, profileOverviewHeight),
                ],
              ),
              SizedBox(width: 5),
              friendOverviewButton(30),
              SizedBox(width: 5),
              messageOverviewButton(30)
            ]
          ),
        ]
      ),
    );
  }

  bool normalMode = true;
  Widget tileBoxWidget() {
    double profileOverviewWidth = 350;
    double fontSize = 16;
    // We use the total height to hide the chatbox below
    // In NormalMode the height has the 2 buttons and some padding added.
    double profileOverviewHeight = 100;
    profileOverviewHeight += 50 * 2;
    profileOverviewHeight += 10 * 2;
    normalMode = true;
    if (MediaQuery.of(context).size.width <= 800) {
      profileOverviewWidth = MediaQuery.of(context).size.width;
      profileOverviewHeight = 50;
      normalMode = false;
    }

    return SingleChildScrollView(
      child: Container(
        width: profileOverviewWidth,
        height: profileOverviewHeight,
        child: Align(
          alignment: FractionalOffset.topLeft,
          child: normalMode
              ? profileOverviewNormal(profileOverviewWidth, profileOverviewHeight, fontSize)
              : profileOverviewMobile(profileOverviewWidth, profileOverviewHeight, fontSize)
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return tileBoxWidget();
  }
}

