import 'package:age_of_gold/age_of_gold.dart';
import 'package:age_of_gold/services/models/user.dart';
import 'package:age_of_gold/util/util.dart';
import 'package:age_of_gold/views/user_interface/ui_views/change_guild_crest_box/change_guild_crest_change_notifier.dart';
import 'package:age_of_gold/views/user_interface/ui_views/guild_window/guild_information.dart';
import 'package:age_of_gold/views/user_interface/ui_views/guild_window/guild_window_overview_no_guild_create.dart';
import 'package:age_of_gold/views/user_interface/ui_views/guild_window/guild_window_overview_no_guild_find.dart';
import 'package:age_of_gold/views/user_interface/ui_views/guild_window/guild_window_overview_no_guild_overview.dart';
import 'package:flutter/material.dart';


class GuildWindowOverviewNoGuild extends StatefulWidget {

  final AgeOfGold game;
  final bool normalMode;
  final double overviewHeight;
  final double overviewWidth;
  final double fontSize;
  final User? me;
  final GuildInformation guildInformation;
  final Function createGuild;

  const GuildWindowOverviewNoGuild({
    required Key key,
    required this.game,
    required this.normalMode,
    required this.overviewHeight,
    required this.overviewWidth,
    required this.fontSize,
    required this.me,
    required this.guildInformation,
    required this.createGuild,
  }) : super(key: key);

  @override
  GuildWindowOverviewNoGuildState createState() => GuildWindowOverviewNoGuildState();
}

class GuildWindowOverviewNoGuildState extends State<GuildWindowOverviewNoGuild> {

  UniqueKey guildWindowOverviewNoGuildOverviewKey = UniqueKey();
  UniqueKey guildWindowOverviewNoGuildCreateKey = UniqueKey();
  UniqueKey guildWindowOverviewNoGuildFindKey = UniqueKey();

  double iconSize = 40;
  int guildOverviewColour = 2;
  bool showGuildOverview = true;

  int createGuildColour = 0;
  bool createGuildView = false;

  int findGuildColour = 0;
  bool findGuildView = false;

  bool unansweredGuildRequests = false;

  @override
  void initState() {
    super.initState();
    checkGuildInformation();
  }

  checkGuildInformation() {
    unansweredGuildRequests = false;
    // First check if the user does not have a guild yet, but he does have some invites
    // Second check if the user is in a guild and there are new member requests
    if (widget.me != null) {
      if (widget.me!.getGuild() == null && widget.me!.guildInvites.isNotEmpty) {
        setState(() {
          unansweredGuildRequests = true;
        });
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  switchToOverview() {
    // We'll also change the guild crest to the default one. This is because nothing is created.
    widget.guildInformation.setGuildCrest(null);
    widget.guildInformation.setCrestIsDefault(true);
    showGuildOverview = true;
    createGuildView = false;
    findGuildView = false;
    createGuildColour = 0;
    guildOverviewColour = 2;
    findGuildColour = 0;
    checkGuildInformation();
  }

  switchToCreate() {
    showGuildOverview = false;
    createGuildView = true;
    findGuildView = false;
    guildOverviewColour = 0;
    createGuildColour = 2;
    findGuildColour = 0;
    checkGuildInformation();
  }

  switchToFind() {
    // We'll also change the guild crest to the default one. This is because nothing is created.
    widget.guildInformation.setGuildCrest(null);
    widget.guildInformation.setCrestIsDefault(true);
    showGuildOverview = false;
    createGuildView = false;
    findGuildView = true;
    guildOverviewColour = 0;
    createGuildColour = 0;
    findGuildColour = 2;
    checkGuildInformation();
  }

  Widget guildOverviewButton() {
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
        width: widget.overviewWidth/3,
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

  Widget createGuildButton() {
    return InkWell(
      onTap: () {
        setState(() {
          switchToCreate();
        });
      },
      onHover: (hovering) {
        setState(() {
          if (hovering) {
            createGuildColour = 1;
          } else {
            if (createGuildView) {
              createGuildColour = 2;
            } else {
              createGuildColour = 0;
            }
          }
        });
      },
      child: Container(
        width: widget.overviewWidth/3,
        height: iconSize,
        color: getDetailColour(createGuildColour),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(width: 1),
              Row(
                children: [
                  Text(
                    "Create guild",
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

  Widget findGuildButton() {
    return InkWell(
      onTap: () {
        setState(() {
          switchToFind();
        });
      },
      onHover: (hovering) {
        setState(() {
          if (hovering) {
            findGuildColour = 1;
          } else {
            if (findGuildView) {
              findGuildColour = 2;
            } else {
              findGuildColour = 0;
            }
          }
        });
      },
      child: Container(
        width: widget.overviewWidth/3,
        height: iconSize,
        color: getDetailColour(findGuildColour),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(width: 1),
              Stack(
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 12,
                        height: 50,
                      ),
                      Text(
                        "Find guild",
                        style: simpleTextStyle(
                          widget.fontSize,
                        ),
                      ),
                    ],
                  ),
                  unansweredGuildRequests ? Image.asset(
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

  Widget bottomButtons() {
    return SizedBox(
      width: widget.overviewWidth,
      height: iconSize,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            guildOverviewButton(),
            createGuildButton(),
            findGuildButton(),
          ]
      ),
    );
  }

  Widget overviewContent() {
    if (showGuildOverview) {
      return GuildWindowOverviewNoGuildOverview(
        key: guildWindowOverviewNoGuildOverviewKey,
        game: widget.game,
        normalMode: widget.normalMode,
        overviewHeight: widget.overviewHeight-iconSize,
        overviewWidth: widget.overviewWidth,
        fontSize: widget.fontSize,
        guildInformation: widget.guildInformation,
      );
    } else if (createGuildView) {
      return GuildWindowOverviewNoGuildCreate(
          key: guildWindowOverviewNoGuildCreateKey,
          game: widget.game,
          normalMode: widget.normalMode,
          overviewHeight: widget.overviewHeight-iconSize,
          overviewWidth: widget.overviewWidth,
          fontSize: widget.fontSize,
          me: widget.me,
          guildInformation: widget.guildInformation,
          createGuild: widget.createGuild,
      );
    } else {
      return GuildWindowOverviewNoGuildFind(
        key: guildWindowOverviewNoGuildFindKey,
        game: widget.game,
        normalMode: widget.normalMode,
        overviewHeight: widget.overviewHeight-iconSize,
        overviewWidth: widget.overviewWidth,
        fontSize: widget.fontSize,
        me: widget.me,
        guildInformation: widget.guildInformation,
        createGuild: widget.createGuild,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: FractionalOffset.center,
        child: Column(
          children: [
            overviewContent(),
            bottomButtons()
          ]
        )
    );
  }
}
