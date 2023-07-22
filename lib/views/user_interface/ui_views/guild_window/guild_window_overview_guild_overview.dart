import 'dart:typed_data';

import 'package:age_of_gold/age_of_gold.dart';
import 'package:age_of_gold/services/auth_service_guild.dart';
import 'package:age_of_gold/services/models/guild.dart';
import 'package:age_of_gold/services/models/guild_member.dart';
import 'package:age_of_gold/services/models/user.dart';
import 'package:age_of_gold/util/render_objects.dart';
import 'package:age_of_gold/util/util.dart';
import 'package:age_of_gold/views/user_interface/are_you_sure_box/are_you_sure_change_notifier.dart';
import 'package:flutter/material.dart';


class GuildWindowOverviewGuildOverview extends StatefulWidget {

  final AgeOfGold game;
  final bool normalMode;
  final double overviewHeight;
  final double overviewWidth;
  final double fontSize;
  final User? me;
  final Guild guild;
  final Function leaveGuild;

  const GuildWindowOverviewGuildOverview({
    required Key key,
    required this.game,
    required this.normalMode,
    required this.overviewHeight,
    required this.overviewWidth,
    required this.fontSize,
    required this.me,
    required this.guild,
    required this.leaveGuild,
  }) : super(key: key);

  @override
  GuildWindowOverviewGuildOverviewState createState() => GuildWindowOverviewGuildOverviewState();
}

class GuildWindowOverviewGuildOverviewState extends State<GuildWindowOverviewGuildOverview> {

  @override
  void initState() {
    super.initState();
  }


  @override
  void dispose() {
    super.dispose();
  }

  Offset? _tapPosition;
  void _showPopupMenu() {
    _storePosition();
    _showChatDetailPopupMenu();
  }

  void _showChatDetailPopupMenu() {
    final RenderBox overlay =
    Overlay.of(context).context.findRenderObject() as RenderBox;

    showMenu(
        context: context,
        items: [GuildSettingPopup(key: UniqueKey())],
        position: RelativeRect.fromRect(
            _tapPosition! & const Size(40, 40), Offset.zero & overlay.size))
        .then((int? delta) {
      if (delta == 0) {
        // Leave guild
        print("leaving guild");
        if (widget.me == null) {
          showToastMessage("something went wrong");
          return;
        }
        AreYouSureBoxChangeNotifier areYouSureBoxChangeNotifier = AreYouSureBoxChangeNotifier();
        areYouSureBoxChangeNotifier.setUserId(widget.me!.getId());
        areYouSureBoxChangeNotifier.setGuildId(widget.guild.getGuildId());
        areYouSureBoxChangeNotifier.setShowLogout(false);
        areYouSureBoxChangeNotifier.setShowLeaveGuild(true);
        areYouSureBoxChangeNotifier.setAreYouSureBoxVisible(true);
      } else if (delta == 1) {
        // change guild crest
        print("changing guild crest");
      }
      return;
    });
  }

  void _storePosition() {
    RenderBox box = guildSettingsKey.currentContext!.findRenderObject() as RenderBox;
    Offset position = box.localToGlobal(Offset.zero);
    position = position + const Offset(0, 50);
    _tapPosition = position;
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

  Widget guildMemberBox(GuildMember? guildMember, double boxSize, double fontSize) {
    double newFriendOptionWidth = 100;
    double sidePadding = 40;
    if (!widget.normalMode) {
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
    double crestTextSize = widget.overviewWidth - boxSize - newFriendOptionWidth - sidePadding - sidePadding;
    return Row(
        children: [
          SizedBox(width: sidePadding),
          avatarBox(boxSize, boxSize, guildMemberAvatar),
          SizedBox(
              width: crestTextSize,
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


  List<Widget> memberList(Guild guild) {
    List<Widget> members = [];
    for (GuildMember member in guild.getMembers()) {
      members.add(
          guildMemberBox(member, 70, widget.fontSize)
      );
    }

    return members;
  }

  GlobalKey guildSettingsKey = GlobalKey();
  Widget guildOverviewContent(Guild guild) {
    String guildName = guild.getGuildName();

    double crestWidth = 200;
    double crestHeight = 225;
    double membersTextHeight = 30;
    double totalPadding = 25;
    double invitePlayerHeight = 40;
    double remainingHeight = widget.overviewHeight - crestHeight - membersTextHeight - invitePlayerHeight - totalPadding;
    if (remainingHeight <= 100) {
      remainingHeight = 100;
    }
    return Column(
        children: [
          Row(
            children: [
              guildAvatarBox(
                crestWidth,
                crestHeight,
                guild.getGuildCrest()
              ),
              SizedBox(width: 20),
              Container(
                width: widget.overviewWidth - crestWidth-20,
                height: crestHeight-100,
                child: Column(
                  children: [
                    Row(
                      children: [
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
                      ]
                    ),
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            "Guild rank: ${guild.getGuildRank()}",
                            style: simpleTextStyle(widget.fontSize)
                        ),
                        Container(),
                      ]
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              "Guild score: 0",
                              style: simpleTextStyle(widget.fontSize)
                          ),
                          IconButton(
                              key: guildSettingsKey,
                              iconSize: 40.0,
                              icon: const Icon(Icons.settings),
                              color: Colors.orangeAccent.shade200,
                              tooltip: 'Settings',
                              onPressed: _showPopupMenu
                          ),
                          // ElevatedButton(
                          //   onPressed: () {
                          //     leaveGuild();
                          //   },
                          //   style: buttonStyle(true, Colors.red),
                          //   child: Container(
                          //     alignment: Alignment.center,
                          //     width: 60,
                          //     height: 30,
                          //     child: Text(
                          //       'Leave Guild',
                          //       style: simpleTextStyle((widget.fontSize/3)*2),
                          //     ),
                          //   ),
                          // ),
                        ]
                    )
                  ],
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
            width: widget.overviewWidth,
            height: remainingHeight,
            child: SingleChildScrollView(
              child: Column(
                children: memberList(guild),
              ),
            ),
          ),
        ]
    );
  }

  Widget guildOverview() {
    return SizedBox(
        height: widget.overviewHeight,
        child: SingleChildScrollView(
          child: guildOverviewContent(widget.guild),
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: FractionalOffset.center,
      child: guildOverview(),
    );
  }
}

class GuildSettingPopup extends PopupMenuEntry<int> {

  GuildSettingPopup({required Key key}) : super(key: key);

  @override
  bool represents(int? n) => n == 1 || n == -1;

  @override
  GuildSettingPopupState createState() => GuildSettingPopupState();

  @override
  double get height => 1;
}

class GuildSettingPopupState extends State<GuildSettingPopup> {
  @override
  Widget build(BuildContext context) {
    return getPopupItems(context);
  }
}

void buttonLeaveGuild(BuildContext context) {
  Navigator.pop<int>(context, 0);
}

void buttonChangeGuildCrest(BuildContext context) {
  Navigator.pop<int>(context, 1);
}

Widget getPopupItems(BuildContext context) {
  return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          child: TextButton(
              onPressed: () {
                buttonLeaveGuild(context);
              },
              child: Row(
                children:const [
                  Text(
                    'Leave guild',
                    textAlign: TextAlign.left,
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  )
                ] ,
              )
          ),
        ),
        Container(
          alignment: Alignment.centerLeft,
          child: TextButton(
              onPressed: () {
                buttonChangeGuildCrest(context);
              },
              child: Row(
                  children: const [
                    Text(
                      "Change guild crest",
                      textAlign: TextAlign.left,
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ]
              )
          ),
        ),
      ]
  );
}
