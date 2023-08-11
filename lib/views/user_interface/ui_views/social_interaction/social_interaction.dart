import 'package:age_of_gold/age_of_gold.dart';
import 'package:age_of_gold/services/models/user.dart';
import 'package:age_of_gold/services/settings.dart';
import 'package:age_of_gold/services/socket_services.dart';
import 'package:age_of_gold/util/util.dart';
import 'package:age_of_gold/views/user_interface/ui_util/chat_messages.dart';
import 'package:age_of_gold/views/user_interface/ui_util/selected_tile_info.dart';
import 'package:age_of_gold/views/user_interface/ui_views/chat_box/chat_box_change_notifier.dart';
import 'package:age_of_gold/views/user_interface/ui_views/chat_window/chat_window_change_notifier.dart';
import 'package:age_of_gold/views/user_interface/ui_views/friend_window/friend_window_change_notifier.dart';
import 'package:age_of_gold/views/user_interface/ui_views/guild_window/guild_information.dart';
import 'package:age_of_gold/views/user_interface/ui_views/guild_window/guild_window_change_notifier.dart';
import 'package:age_of_gold/views/user_interface/ui_views/profile_box/profile_change_notifier.dart';
import 'package:flutter/material.dart';


class SocialInteraction extends StatefulWidget {

  final AgeOfGold game;

  const SocialInteraction({
    required Key key,
    required this.game
  }) : super(key: key);

  @override
  SocialInteractionState createState() => SocialInteractionState();
}

class SocialInteractionState extends State<SocialInteraction> with TickerProviderStateMixin {

  late SelectedTileInfo selectedTileInfo;
  late ProfileChangeNotifier profileChangeNotifier;
  late FriendWindowChangeNotifier friendWindowChangeNotifier;
  SocketServices socket = SocketServices();
  Settings settings = Settings();

  int levelClock = 0;
  bool canChangeTiles = true;

  int friendOverviewState = 0;
  int messageOverviewState = 0;
  int guildOverviewState = 0;

  bool unreadMessages = false;
  bool guildNotification = false;

  @override
  void initState() {
    super.initState();
    // TODO: Change to it's own change notifier?
    profileChangeNotifier = ProfileChangeNotifier();
    friendWindowChangeNotifier = FriendWindowChangeNotifier();
    profileChangeNotifier.addListener(socialInteractionListener);
    socket.addListener(socialInteractionListener);
  }

  @override
  void dispose() {
    super.dispose();
  }

  checkUnreadMessages() {
    unreadMessages = ChatMessages().unreadPersonalMessages();
  }

  checkGuildInformation() {
    guildNotification = false;
    // First check if the user does not have a guild yet, but he does have some invites
    // Second check if the user is in a guild and there are new member requests
    User? me = Settings().getUser();
    if (me != null) {
      if (me.getGuild() == null && me.guildInvites.isNotEmpty) {
        setState(() {
          guildNotification = true;
        });
      }
      if (me.getGuild() != null) {
        if (GuildInformation().requestedMembers.isNotEmpty) {
          setState(() {
            guildNotification = true;
          });
        }
      }
    }
  }

  socketListener() {
    if (mounted) {
      updateInteractions();
    }
  }

  updateInteractions() {
    setState(() {
      friendWindowChangeNotifier.checkUnansweredFriendRequests(Settings().getUser());
      checkUnreadMessages();
      checkGuildInformation();
    });
  }

  socialInteractionListener() {
    if (mounted) {
      updateInteractions();
    }
  }

  showFriendWindow() {
    FriendWindowChangeNotifier().setFriendWindowVisible(true);
  }

  showChatWindow() {
    ChatBoxChangeNotifier().setChatBoxVisible(false);
    ChatWindowChangeNotifier().setChatWindowVisible(true);
  }

  showGuildWindow() {
    print("pressed the guild button");
    GuildWindowChangeNotifier().setGuildWindowVisible(true);
  }

  Widget friendOverviewButton(double profileButtonSize) {
    return SizedBox(
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
                showFriendWindow();
              },
              child: Stack(
                children: [
                  SizedBox(
                    width: profileButtonSize,
                    height: profileButtonSize,
                    child: ClipOval(
                      child: Material(
                        color: overviewColour(friendOverviewState, Colors.orange, Colors.orangeAccent, Colors.orange.shade800),
                      )
                    ),
                  ),
                  Image.asset(
                    "assets/images/ui/icon/friend_icon_clean.png",
                    width: profileButtonSize,
                    height: profileButtonSize,
                  ),
                  friendWindowChangeNotifier.unansweredFriendRequests ? Image.asset(
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

  Widget messageOverviewButton(double messageButtonSize) {
    return SizedBox(
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
                    SizedBox(
                      width: messageButtonSize,
                      height: messageButtonSize,
                      child: ClipOval(
                          child: Material(
                            color: overviewColour(messageOverviewState, Colors.orange, Colors.orangeAccent, Colors.orange.shade800),
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

  Widget guildOverviewButton(double guildButtonSize) {
    bool inAGuild = false;
    User? me = Settings().getUser();
    if (me != null) {
      if (me.guild != null) {
        inAGuild = true;
      }
    }
    return SizedBox(
      child: Row(
          children: [
            SizedBox(width: 5),
            Tooltip(
              message: "guild",
              child: InkWell(
                onHover: (value) {
                  setState(() {
                    guildOverviewState = value ? 1 : 0;
                  });
                },
                onTap: () {
                  setState(() {
                    guildOverviewState = 2;
                  });
                  showGuildWindow();
                },
                child: Stack(
                  children: [
                    SizedBox(
                      width: guildButtonSize,
                      height: guildButtonSize,
                      child: ClipOval(
                          child: Material(
                            color: inAGuild
                                ? overviewColour(guildOverviewState, Colors.orange, Colors.orangeAccent, Colors.orange.shade800)
                                : overviewColour(guildOverviewState, Colors.grey, Colors.grey.shade400, Colors.grey.shade800)
                          )
                      ),
                    ),
                    Image.asset(
                      "assets/images/ui/icon/guild_icon_clean.png",
                      width: guildButtonSize,
                      height: guildButtonSize,
                    ),
                    guildNotification ? Image.asset(
                      "assets/images/ui/icon/update_notification.png",
                      width: guildButtonSize,
                      height: guildButtonSize,
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
          SizedBox(height: profileAvatarHeight),
          SizedBox(height: 10),
          friendOverviewButton(50),
          SizedBox(height: 10),
          messageOverviewButton(50),
          SizedBox(height: 10),
          guildOverviewButton(50)
        ]
      ),
    );
  }

  Widget profileOverviewMobile(double fontSize) {
    double statusBarPadding = MediaQuery.of(context).viewPadding.top;
    double totalWidth = MediaQuery.of(context).size.width;
    return Container(
      child: Column(
        children: [
          SizedBox(height: statusBarPadding+5),
          Row(
            children: [
              SizedBox(width: totalWidth/2),
              SizedBox(width: 5),
              friendOverviewButton(30),
              SizedBox(width: 5),
              messageOverviewButton(30),
              SizedBox(width: 5),
              guildOverviewButton(30)
            ]
          ),
        ]
      ),
    );
  }

  bool normalMode = true;
  Widget tileBoxWidget() {
    // button width + padding
    double profileOverviewWidth = 50 + 5;
    double fontSize = 16;
    // We use the total height to hide the chatbox below
    // In NormalMode the height has the 3 buttons and some padding added.
    double profileOverviewHeight = 100;
    profileOverviewHeight += 50;
    profileOverviewHeight += 10;
    profileOverviewHeight += 50;
    profileOverviewHeight += 10;
    profileOverviewHeight += 50;
    profileOverviewHeight += 10;
    normalMode = true;
    if (MediaQuery.of(context).size.width <= 800) {
      profileOverviewWidth = MediaQuery.of(context).size.width/2;
      profileOverviewWidth += 30;
      profileOverviewWidth += 10;
      profileOverviewWidth += 30;
      profileOverviewWidth += 10;
      profileOverviewWidth += 30;
      profileOverviewWidth += 10;

      double statusBarPadding = MediaQuery.of(context).viewPadding.top;
      profileOverviewHeight = statusBarPadding + 30;
      profileOverviewHeight += 5;

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
              : profileOverviewMobile(fontSize)
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return tileBoxWidget();
  }
}

