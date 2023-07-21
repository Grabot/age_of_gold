import 'dart:typed_data';

import 'package:age_of_gold/age_of_gold.dart';
import 'package:age_of_gold/services/auth_service_guild.dart';
import 'package:age_of_gold/services/models/guild.dart';
import 'package:age_of_gold/services/models/guild_member.dart';
import 'package:age_of_gold/services/models/user.dart';
import 'package:age_of_gold/util/render_objects.dart';
import 'package:age_of_gold/util/util.dart';
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

  leaveGuild() {
    AuthServiceGuild().leaveGuild().then((value) {
      if (value.getResult()) {
        print("leave guild success");
        if (widget.me != null && widget.me!.guild != null) {
          widget.me!.guild = null;
          widget.leaveGuild();
        } else {
          showToastMessage("an error occured");
        }
      } else {
        showToastMessage(value.getMessage());
      }
    });
  }

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
                    SizedBox(height: 20),
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
                    SizedBox(height: 20),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              "Guild score: 0",
                              style: simpleTextStyle(widget.fontSize)
                          ),
                          ElevatedButton(
                            onPressed: () {
                              leaveGuild();
                            },
                            style: buttonStyle(true, Colors.red),
                            child: Container(
                              alignment: Alignment.center,
                              width: 60,
                              height: 30,
                              child: Text(
                                'Leave Guild',
                                style: simpleTextStyle((widget.fontSize/3)*2),
                              ),
                            ),
                          ),
                          Container(),
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
