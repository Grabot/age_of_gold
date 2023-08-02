import 'package:age_of_gold/age_of_gold.dart';
import 'package:age_of_gold/services/models/guild.dart';
import 'package:age_of_gold/services/models/user.dart';
import 'package:age_of_gold/util/util.dart';
import 'package:age_of_gold/views/user_interface/ui_views/guild_window/guild_information.dart';
import 'package:age_of_gold/views/user_interface/ui_views/guild_window/guild_window_overview_change_ranks.dart';
import 'package:age_of_gold/views/user_interface/ui_views/guild_window/guild_window_overview_guild_new_members.dart';
import 'package:age_of_gold/views/user_interface/ui_views/guild_window/guild_window_overview_guild_overview.dart';
import 'package:flutter/material.dart';


class GuildWindowOverviewGuild extends StatefulWidget {

  final AgeOfGold game;
  final bool normalMode;
  final double overviewHeight;
  final double overviewWidth;
  final double fontSize;
  final User? me;
  final Guild guild;
  final GuildInformation guildInformation;
  final Function leaveGuild;

  const GuildWindowOverviewGuild({
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
  GuildWindowOverviewGuildState createState() => GuildWindowOverviewGuildState();
}

class GuildWindowOverviewGuildState extends State<GuildWindowOverviewGuild> {

  UniqueKey guildWindowOverviewGuildOverviewKey = UniqueKey();
  UniqueKey guildWindowOverviewGuildNewMembersKey = UniqueKey();
  UniqueKey guildWindowOverviewGuildChangeGuildRanksKey = UniqueKey();

  double iconSize = 40;
  int guildOverviewColour = 2;
  bool showGuildOverview = true;

  int newMembersColour = 0;
  bool newMembersView = false;

  int changeMemberRanksColour = 0;
  bool changeMemberView = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  switchToOverview() {
    showGuildOverview = true;
    newMembersView = false;
    changeMemberView = false;
    guildOverviewColour = 2;
    newMembersColour = 0;
    changeMemberRanksColour = 0;
  }

  switchToNewMembers() {
    showGuildOverview = false;
    newMembersView = true;
    changeMemberView = false;
    guildOverviewColour = 0;
    newMembersColour = 2;
    changeMemberRanksColour = 0;
  }

  switchToChangeGuildRanks() {
    print("switcing to guild ranks");
    showGuildOverview = false;
    newMembersView = false;
    changeMemberView = true;
    guildOverviewColour = 0;
    newMembersColour = 0;
    changeMemberRanksColour = 2;
  }

  Widget guildOverviewButton(double buttonWidth) {
    return InkWell(
      onTap: () {
        setState(() {
          switchToOverview();
        });
      },
      onHover: (hovering) {
        setState(() {
          if (hovering) {
            guildOverviewColour = 1;
          } else {
            if (showGuildOverview) {
              guildOverviewColour = 2;
            } else {
              guildOverviewColour = 0;
            }
          }
        });
      },
      child: Container(
        width: buttonWidth,
        height: iconSize,
        color: getDetailColour(guildOverviewColour),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(width: 1),
              Row(
                children: [
                  Text(
                    "Guild overview",
                    style: simpleTextStyle(
                      widget.fontSize,
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

  Widget changeRankMemberButton(double buttonWidth) {
    return InkWell(
      onTap: () {
        setState(() {
          switchToChangeGuildRanks();
        });
      },
      onHover: (hovering) {
        setState(() {
          if (hovering) {
            changeMemberRanksColour = 1;
          } else {
            if (changeMemberView) {
              changeMemberRanksColour = 2;
            } else {
              changeMemberRanksColour = 0;
            }
          }
        });
      },
      child: Container(
        width: buttonWidth,
        height: iconSize,
        color: getDetailColour(changeMemberRanksColour),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(width: 1),
              Row(
                children: [
                  Text(
                    "Change guild ranks",
                    style: simpleTextStyle(
                      widget.fontSize,
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

  Widget newMembersButton(double buttonWidth) {
    return InkWell(
      onTap: () {
        setState(() {
          switchToNewMembers();
        });
      },
      onHover: (hovering) {
        setState(() {
          if (hovering) {
            newMembersColour = 1;
          } else {
            if (newMembersView) {
              newMembersColour = 2;
            } else {
              newMembersColour = 0;
            }
          }
        });
      },
      child: Container(
        width: buttonWidth,
        height: iconSize,
        color: getDetailColour(newMembersColour),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(width: 1),
              Row(
                children: [
                  Text(
                    "New members",
                    style: simpleTextStyle(
                      widget.fontSize,
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

  Widget bottomButtons(bool isAdministrator) {
    if (isAdministrator) {
      return SizedBox(
        width: widget.overviewWidth,
        height: iconSize,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            guildOverviewButton(widget.overviewWidth / 3),
            newMembersButton(widget.overviewWidth / 3),
            changeRankMemberButton(widget.overviewWidth / 3),
          ]
        ),
      );
    } else {
      return SizedBox(
        width: widget.overviewWidth,
        height: iconSize,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            guildOverviewButton(widget.overviewWidth),
          ]
        ),
      );
    }
  }

  Widget guildOverviewContent() {
    if (showGuildOverview) {
      return GuildWindowOverviewGuildOverview(
        key: guildWindowOverviewGuildOverviewKey,
        game: widget.game,
        normalMode: widget.normalMode,
        overviewHeight: widget.overviewHeight-iconSize,
        overviewWidth: widget.overviewWidth,
        fontSize: widget.fontSize,
        me: widget.me,
        guild: widget.guild,
        guildInformation: widget.guildInformation,
        leaveGuild: widget.leaveGuild,
      );
    } else if (newMembersView) {
      return GuildWindowOverviewGuildNewMembers(
        key: guildWindowOverviewGuildNewMembersKey,
        game: widget.game,
        normalMode: widget.normalMode,
        overviewHeight: widget.overviewHeight-iconSize,
        overviewWidth: widget.overviewWidth,
        fontSize: widget.fontSize,
        me: widget.me,
        guild: widget.guild,
        guildInformation: widget.guildInformation,
      );
    } else {
      return GuildWindowOverviewChangeRanks(
          key: guildWindowOverviewGuildChangeGuildRanksKey,
          game: widget.game,
          normalMode: widget.normalMode,
          overviewHeight: widget.overviewHeight-iconSize,
          overviewWidth: widget.overviewWidth,
          fontSize: widget.fontSize,
          me: widget.me,
          guild: widget.guild,
          guildInformation: widget.guildInformation,
          leaveGuild: widget.leaveGuild
      );
    }
  }

  Widget guildOverview() {
    return SizedBox(
      height: widget.overviewHeight,
      child: SingleChildScrollView(
        child: Column(
            children: [
              guildOverviewContent(),
              bottomButtons(widget.guild.isAdministrator)
            ]
        ),
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
