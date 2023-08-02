import 'dart:typed_data';

import 'package:age_of_gold/age_of_gold.dart';
import 'package:age_of_gold/services/auth_service_guild.dart';
import 'package:age_of_gold/services/models/guild.dart';
import 'package:age_of_gold/services/models/guild_member.dart';
import 'package:age_of_gold/services/models/user.dart';
import 'package:age_of_gold/util/render_objects.dart';
import 'package:age_of_gold/util/util.dart';
import 'package:age_of_gold/views/user_interface/ui_util/chat_messages.dart';
import 'package:age_of_gold/views/user_interface/ui_util/clear_ui.dart';
import 'package:age_of_gold/views/user_interface/ui_views/are_you_sure_box/are_you_sure_change_notifier.dart';
import 'package:age_of_gold/views/user_interface/ui_views/change_guild_crest_box/change_guild_crest_change_notifier.dart';
import 'package:age_of_gold/views/user_interface/ui_views/chat_window/chat_window_change_notifier.dart';
import 'package:age_of_gold/views/user_interface/ui_views/guild_window/guild_information.dart';
import 'package:flutter/material.dart';


class GuildWindowOverviewChangeRanks extends StatefulWidget {

  final AgeOfGold game;
  final bool normalMode;
  final double overviewHeight;
  final double overviewWidth;
  final double fontSize;
  final User? me;
  final Guild guild;
  final GuildInformation guildInformation;
  final Function leaveGuild;

  const GuildWindowOverviewChangeRanks({
    required Key key,
    required this.game,
    required this.normalMode,
    required this.overviewHeight,
    required this.overviewWidth,
    required this.fontSize,
    required this.me,
    required this.guild,
    required this.guildInformation,
    required this.leaveGuild,
  }) : super(key: key);

  @override
  GuildWindowOverviewChangeRanksState createState() => GuildWindowOverviewChangeRanksState();
}

class GuildWindowOverviewChangeRanksState extends State<GuildWindowOverviewChangeRanks> {

  GlobalKey guildSettingsKey = GlobalKey();

  final FocusNode _focusGuildMembersSearch = FocusNode();
  final TextEditingController searchGuildMembersController = TextEditingController();
  bool searchModeMembers = false;

  List<GuildMember>? shownGuildMembers;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  changedSearch(String typedText) {
    if (typedText.isNotEmpty) {
      shownGuildMembers = widget.guild.getMembers()
          .where((element) => element.getGuildMemberName().toLowerCase()
          .contains(typedText.toLowerCase()))
          .toList();
    } else {
      shownGuildMembers = widget.guild.getMembers();
    }
    setState(() {});
  }

  changeGuildMemberRank(GuildMember guildMember, String newValue) {
    if (newValue == guildMember.getGuildMemberRankName()) {
      return;
    }
    AuthServiceGuild().changeGuildMemberRank(
        guildMember.getGuildMemberId(),
        widget.guild.getGuildId(),
        guildMember.getRankId(newValue)
    ).then((value) {
      if (value.getResult()) {
        showToastMessage("Rank of member ${guildMember.getGuildMemberName()} changed to $newValue");
        setState(() {
          guildMember.setGuildMemberRankName(newValue);
        });
      } else {
        showToastMessage(value.getMessage());
      }
    });
  }

  Widget changeRankInteraction(GuildMember guildMember, double avatarBoxSize, double guildMemberOptionWidth, double fontSize, bool isMe) {
    if (isMe) {
      return Container();
    } else {
      return DropdownButton<String>(
        value: guildMember.getGuildMemberRankName(),
        items: <String>['Guildmaster', 'Officer', 'Merchant', 'Trader']
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: TextStyle(fontSize: fontSize),
            ),
          );
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null) {
            changeGuildMemberRank(guildMember, newValue);
          }
        },
      );
    }
  }

  Widget guildMemberBox(GuildMember guildMember, double boxSize, double fontSize) {
    double changeRankOptionWidth = 200;
    double sidePadding = 40;
    if (!widget.normalMode) {
      boxSize = boxSize / 1.2;
      fontSize = fontSize / 1.8;
      sidePadding = 10;
    }

    bool isMe = false;
    if (widget.me != null) {
      if (widget.me!.getId() == guildMember.getGuildMemberId()) {
        isMe = true;
      }
    }

    String guildMemberName = guildMember.getGuildMemberName();
    Uint8List? guildMemberAvatar = guildMember.getGuildMemberAvatar();

    double crestTextSize = widget.overviewWidth - boxSize - sidePadding - changeRankOptionWidth - sidePadding;
    return Container(
      color: isMe ? Colors.blue : Colors.transparent,
      child: Row(
          children: [
            SizedBox(width: sidePadding),
            avatarBox(boxSize, boxSize, guildMemberAvatar),
            Column(
              children: [
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
                SizedBox(
                    width: crestTextSize,
                    child: Text(
                        guildMember.getGuildMemberRankName(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: fontSize
                        )
                    )
                )
              ],
            ),
            changeRankInteraction(guildMember, boxSize, changeRankOptionWidth, fontSize, isMe),
            SizedBox(width: sidePadding),
          ]
      ),
    );
  }

  List<Widget> memberList(Guild guild) {
    List<Widget> members = [];
    List<GuildMember> guildMembers = guild.getMembers();
    if (shownGuildMembers != null) {
      guildMembers = shownGuildMembers!;
    }
    for (GuildMember member in guildMembers) {
      members.add(
          guildMemberBox(member, 70, widget.fontSize)
      );
    }

    return members;
  }

  resetSearch(Guild guild) {
    searchGuildMembersController.text = "";
    searchModeMembers = false;
    setState(() {
      shownGuildMembers = guild.getMembers();
    });
  }

  Widget searchGuildMembersField(double searchFieldWidth, double fontSize) {
    if (searchModeMembers) {
      return SizedBox(
        width: searchFieldWidth,
        height: 50,
        child: TextFormField(
          onTap: () {
            if (!_focusGuildMembersSearch.hasFocus) {
              _focusGuildMembersSearch.requestFocus();
            }
          },
          focusNode: _focusGuildMembersSearch,
          controller: searchGuildMembersController,
          textAlign: TextAlign.center,
          style: simpleTextStyle(fontSize),
          onChanged: (text) {
            changedSearch(text);
          },
          decoration: textFieldInputDecoration("Search for your guild member"),
        ),
      );
    } else {
      return Container();
    }
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
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            "Your guild rank: ${guild.getGuildRank()}",
                            style: simpleTextStyle(widget.fontSize)
                        ),
                        Container(),
                      ]
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                height: membersTextHeight,
                width: 200,
                child: Row(
                  children: [
                    Text(
                      "Members:",
                      style: simpleTextStyle(20),
                    ),
                  ],
                ),
              ),
              searchGuildMembersField(widget.overviewWidth - 250, widget.fontSize),
              GestureDetector(
                onTap: () {
                  searchModeMembers = !searchModeMembers;
                  if (searchModeMembers) {
                    _focusGuildMembersSearch.requestFocus();
                  } else {
                    resetSearch(widget.guild);
                  }
                  setState(() {});
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
            ]
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

  Widget guildMemberRanksChanging() {
    return Container();
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
