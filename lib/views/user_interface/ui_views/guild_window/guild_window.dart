import 'dart:convert';
import 'dart:html';
import 'dart:math';
import 'dart:typed_data';

import 'package:age_of_gold/age_of_gold.dart';
import 'package:age_of_gold/services/auth_service_guild.dart';
import 'package:age_of_gold/services/auth_service_social.dart';
import 'package:age_of_gold/services/models/friend.dart';
import 'package:age_of_gold/services/models/guild.dart';
import 'package:age_of_gold/services/models/guild_member.dart';
import 'package:age_of_gold/services/models/user.dart';
import 'package:age_of_gold/services/settings.dart';
import 'package:age_of_gold/util/render_objects.dart';
import 'package:age_of_gold/util/util.dart';
import 'package:age_of_gold/views/user_interface/ui_views/change_guild_crest_box/change_guild_crest_change_notifier.dart';
import 'package:age_of_gold/views/user_interface/ui_views/guild_window/guild_window_change_notifier.dart';
import 'package:age_of_gold/views/user_interface/ui_views/guild_window/guild_window_overview.dart';
import 'package:age_of_gold/views/user_interface/ui_views/guild_window/guild_window_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class GuildWindow extends StatefulWidget {

  final AgeOfGold game;

  const GuildWindow({
    required Key key,
    required this.game
  }) : super(key: key);

  @override
  GuildWindowState createState() => GuildWindowState();
}

class GuildWindowState extends State<GuildWindow> {

  final FocusNode _focusGuildWindow = FocusNode();
  bool normalMode = true;

  late GuildWindowChangeNotifier guildWindowChangeNotifier;
  late ChangeGuildCrestChangeNotifier changeGuildCrestChangeNotifier;
  bool showGuildWindow = false;

  double guildWindowHeight = 0;
  double guildWindowWidth = 100;
  @override
  void initState() {
    guildWindowChangeNotifier = GuildWindowChangeNotifier();
    guildWindowChangeNotifier.addListener(guildWindowChangeListener);
    _focusGuildWindow.addListener(_onFocusChange);

    changeGuildCrestChangeNotifier = ChangeGuildCrestChangeNotifier();
    changeGuildCrestChangeNotifier.setDefault(true);
    changeGuildCrestChangeNotifier.setGuildCrest(null);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  goBack() {
    setState(() {
      GuildWindowChangeNotifier().setGuildWindowVisible(false);
    });
  }

  void _onFocusChange() {
    widget.game.guildWindowFocus(_focusGuildWindow.hasFocus);
  }

  guildWindowChangeListener() {
    if (mounted) {
      if (!showGuildWindow && guildWindowChangeNotifier.getGuildWindowVisible()) {
        User? me = Settings().getUser();
        if (me != null) {
          retrieveGuildMembers(me);
          setGuildCrest(me, changeGuildCrestChangeNotifier);
        }
        setState(() {
          showGuildWindow = true;
        });
      }
      else if (showGuildWindow && !guildWindowChangeNotifier.getGuildWindowVisible()) {
        // If the window is closed we go back to the default.
        // If a guild is created we still set it to default because it is for the creation tab
        changeGuildCrestChangeNotifier.setGuildCrest(null);
        changeGuildCrestChangeNotifier.setDefault(true);
        setState(() {
          showGuildWindow = false;
        });
      } else if (showGuildWindow && guildWindowChangeNotifier.getGuildWindowVisible()) {
        // window already visible, just update if needed
        setState(() {});
      }
    }
  }

  Widget guildWindowHeader(double headerWidth, double headerHeight, double fontSize) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(),
          SizedBox(
              height: headerHeight,
              child: Text(
                "Guild Window",
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

  Widget noGuildOverview() {
    String guildName = "Not part of a guild yet.";
    return Row(
      children: [
        guildAvatarBox(
            200,
            225,
            changeGuildCrestChangeNotifier.getGuildCrest()
        ),
        Expanded(
          child: RichText(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                  children: [
                    TextSpan(
                        text: guildName,
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
    );
  }


  Widget guildMemberInteraction(GuildMember? guildMember, double avatarBoxSize, double guildMemberOptionWidth, double fontSize) {
    return SizedBox(
      width: guildMemberOptionWidth,
      height: 40,
      child: Row(
          children: [
            InkWell(
                onTap: () {
                  setState(() {
                    // messageFriend(friend);
                    print("pressed the message button");
                  });
                },
                child: Tooltip(
                    message: 'Message guild member',
                    child: addIcon(40, Icons.message, Colors.green)
                )
            ),
            SizedBox(width: 10),
            InkWell(
              onTap: () {
                setState(() {
                  print("remove guild member button");
                  // cancelFriendRequest(friend);
                });
              },
              child: Tooltip(
                message: 'Remove guild member',
                child: addIcon(40, Icons.person_remove, Colors.red),
              ),
            ),
          ]
      ),
    );
  }


  Widget guildMemberBox(GuildMember? guildMember, double boxSize, double guildMemberBoxWindowWidth, double fontSize) {
    double newFriendOptionWidth = 100;
    double sidePadding = 40;
    if (!normalMode) {
      boxSize = boxSize / 1.2;
      fontSize = fontSize / 1.8;
      sidePadding = 10;
    }

    String guildMemberName = "";
    Uint8List? guildMemberAvatar;
    if (guildMember != null) {
      if (guildMember.getGuildMemberName() != null) {
        guildMemberName = guildMember.getGuildMemberName()!;
      }
      if (guildMember.getGuildMemberAvatar() != null) {
        guildMemberAvatar = guildMember.getGuildMemberAvatar();
      }
    }
    return Row(
      children: [
        SizedBox(width: sidePadding),
        avatarBox(boxSize, boxSize, guildMemberAvatar),
        SizedBox(
          width: guildMemberBoxWindowWidth - boxSize - newFriendOptionWidth - sidePadding - sidePadding,
          child: Text(
            guildMemberName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: Colors.white,
                fontSize: fontSize * 2
            )
          )
        ),
        guildMemberInteraction(guildMember, boxSize, newFriendOptionWidth, fontSize),
        SizedBox(width: sidePadding),
      ]
    );
  }

  Widget inAGuildOverview(Guild guild, double overViewWidth, double overviewHeight, double fontSize) {
    String guildName = guild.getGuildName();
    double crestWidth = 200;
    double crestHeight = 225;
    double membersTextHeight = 30;
    double totalPadding = 25;
    double invitePlayerHeight = 50;
    double remainingHeight = overviewHeight - crestHeight - membersTextHeight - invitePlayerHeight - totalPadding;
    return Column(
      children: [
        Row(
          children: [
            guildAvatarBox(
                crestWidth,
                crestHeight,
                guild.getGuildCrest()
            ),
            Expanded(
              child: RichText(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: guildName,
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
        SizedBox(height: 5),
        SizedBox(
          height: membersTextHeight,
          child: Row(
            children: [
              Text(
                "Members:",
                style: simpleTextStyle(20),
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        Container(
          width: overViewWidth,
          height: remainingHeight,
          color: Colors.yellow,
          child: SingleChildScrollView(
            child: Column(
              children: memberList(guild, overViewWidth, fontSize),
            ),
          ),
        ),
      ]
    );
  }

  List<Widget> memberList(Guild guild, double guildMemberWindowWidth, double fontSize) {
    List<Widget> members = [];
    for (GuildMember member in guild.getMembers()) {
      members.add(
          guildMemberBox(member, 70, guildMemberWindowWidth, fontSize)
      );
    }

    return members;
  }

  Widget guildAvatarOverview(double overViewWidth, double overviewHeight, double fontSize) {
    User? me = Settings().getUser();
    if (me == null || me.getGuild() == null) {
      return noGuildOverview();
    } else {
      return inAGuildOverview(me.getGuild()!, overViewWidth, overviewHeight, fontSize);
    }
  }

  UniqueKey guildWindowOverviewKey = UniqueKey();
  Widget mainGuildWindow(double guildWindowWidth, double overviewHeight, double fontSize) {
    return SizedBox(
      width: guildWindowWidth,
      height: overviewHeight,
      child: Column(
        children: [
          GuildWindowOverview(
            key: guildWindowOverviewKey,
            game: widget.game,
            normalMode: normalMode,
            overviewHeight: overviewHeight,
            overviewWidth: guildWindowWidth,
            fontSize: fontSize,
            changeGuildCrestChangeNotifier: changeGuildCrestChangeNotifier
          )
        ]
      ),
    );
  }

  Widget guildWindow(double guildWindowWidth, double guildWindowHeight, double fontSize) {
    double headerHeight = 40;
    double remainingHeight = guildWindowHeight - headerHeight;
    return Container(
        child: Column(
        children: [
          guildWindowHeader(guildWindowWidth, headerHeight, fontSize),
          mainGuildWindow(guildWindowWidth, remainingHeight, fontSize),
          // bottomButtons(guildWindowWidth, bottomBarHeight, fontSize)
        ]
      )
    );
  }

  Widget windowGuild(BuildContext context) {
    guildWindowHeight = MediaQuery.of(context).size.height * 0.8;
    double fontSize = 16;
    guildWindowWidth = 800;
    // We use the total height to hide the chatbox below
    normalMode = true;
    if (MediaQuery.of(context).size.width <= 800) {
      guildWindowWidth = MediaQuery.of(context).size.width;
      guildWindowHeight = MediaQuery.of(context).size.height - 250;
      normalMode = false;
      fontSize = 12;
    }

    return SingleChildScrollView(
      child: Container(
          width: guildWindowWidth,
          height: guildWindowHeight,
          color: Colors.cyan,
          child: guildWindow(guildWindowWidth, guildWindowHeight, fontSize)
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Align(
      alignment: FractionalOffset.center,
      child: showGuildWindow ? windowGuild(context) : Container()
    );
  }
}
