import 'dart:typed_data';

import 'package:age_of_gold/age_of_gold.dart';
import 'package:age_of_gold/services/auth_service_guild.dart';
import 'package:age_of_gold/services/models/guild.dart';
import 'package:age_of_gold/services/models/guild_member.dart';
import 'package:age_of_gold/services/models/user.dart';
import 'package:age_of_gold/util/render_objects.dart';
import 'package:age_of_gold/util/util.dart';
import 'package:age_of_gold/views/user_interface/ui_views/guild_window/guild_information.dart';
import 'package:flutter/material.dart';
import 'package:quiver/core.dart';


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

  List<GuildMember> shownGuildMembers = [];
  int myRankId = 4;

  @override
  void initState() {
    shownGuildMembers = widget.guild.getMembers();
    if (widget.me != null) {
      if (widget.me!.getGuild() != null) {
        myRankId = widget.me!.getGuild()!.getMyGuildRankId();
      }
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<DropdownMenuItem<GuildMemberRankData>> buildDropdownMenuItems(List rankData) {
    List<DropdownMenuItem<GuildMemberRankData>> items = [];
    for (GuildMemberRankData guildMemberRankData in rankData) {
      items.add(
        DropdownMenuItem(
          value: guildMemberRankData,
          child: Container(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Text(guildMemberRankData.name)
                ],
              ),
            ),
          ),
        ),
      );
    }
    return items;
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
    if (myRankId >= getRankId(newValue)) {
      showToastMessage("You can't change the rank to be higher or similar to yours.");
      return;
    }
    if (myRankId >= getRankId(guildMember.getGuildMemberRankName())) {
      showToastMessage("You can't change the rank of a member that has the same or higher rank as you.");
      return;
    }

    AuthServiceGuild().changeGuildMemberRank(
        guildMember.getGuildMemberId(),
        widget.guild.getGuildId(),
        getRankId(newValue)
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

  onChangeDropdownItem(GuildMember guildMember, GuildMemberRankData? newSelectedTile) {
    if (newSelectedTile != null) {
      setState(() {
        changeGuildMemberRank(guildMember, newSelectedTile.name);
      });
    }
  }

  Widget changeRankInteraction(GuildMember guildMember, double avatarBoxSize, double guildMemberOptionWidth, double fontSize, bool isMe) {
    GuildMemberRankData selectedRank = GuildMemberRankData(
        guildMember.getGuildMemberRankName(),
        getRankId(guildMember.getGuildMemberRankName())
    );
    if (isMe) {
      return Container();
    } else {
      return DropdownButton(
        value: selectedRank,
        items: buildDropdownMenuItems(GuildMemberRankData.getGuildMemberRanks()),
        onChanged: (GuildMemberRankData? newSelectedTile) {
          onChangeDropdownItem(guildMember, newSelectedTile);
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
    for (GuildMember member in shownGuildMembers) {
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
              const SizedBox(width: 20),
              SizedBox(
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
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            "Your guild rank: ${guild.getMyGuildRank()}",
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
          const SizedBox(height: 5),
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
          const SizedBox(height: 20),
          SizedBox(
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

class GuildMemberRankData {
  String name;
  int guildRankId;

  GuildMemberRankData(this.name, this.guildRankId);

  static List<GuildMemberRankData> getGuildMemberRanks() {
    return <GuildMemberRankData>[
      GuildMemberRankData("Guildmaster", 0),
      GuildMemberRankData("Officer", 1),
      GuildMemberRankData("Merchant", 2),
      GuildMemberRankData("Trader", 3),
    ];
  }

  @override
  bool operator == (Object other) =>
      other is GuildMemberRankData && name == other.name && guildRankId == other.guildRankId;

  @override
  int get hashCode => hash2(name.hashCode, guildRankId.hashCode);

}
