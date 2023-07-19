import 'dart:typed_data';

import 'package:age_of_gold/age_of_gold.dart';
import 'package:age_of_gold/services/models/guild.dart';
import 'package:age_of_gold/services/models/guild_member.dart';
import 'package:age_of_gold/services/models/user.dart';
import 'package:age_of_gold/services/settings.dart';
import 'package:age_of_gold/util/render_objects.dart';
import 'package:age_of_gold/util/util.dart';
import 'package:age_of_gold/views/user_interface/ui_views/change_guild_crest_box/change_guild_crest_change_notifier.dart';
import 'package:age_of_gold/views/user_interface/ui_views/guild_window/guild_window_change_notifier.dart';
import 'package:age_of_gold/views/user_interface/ui_views/guild_window/guild_window_overview_no_guild_create.dart';
import 'package:age_of_gold/views/user_interface/ui_views/guild_window/guild_window_overview_no_guild_find.dart';
import 'package:age_of_gold/views/user_interface/ui_views/guild_window/guild_window_overview_no_guild_overview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class GuildWindowOverviewNoGuild extends StatefulWidget {

  final AgeOfGold game;
  final bool normalMode;
  final double overviewHeight;
  final double overviewWidth;
  final double fontSize;
  final Function createGuild;

  const GuildWindowOverviewNoGuild({
    required Key key,
    required this.game,
    required this.normalMode,
    required this.overviewHeight,
    required this.overviewWidth,
    required this.fontSize,
    required this.createGuild,
  }) : super(key: key);

  @override
  GuildWindowOverviewNoGuildState createState() => GuildWindowOverviewNoGuildState();
}

class GuildWindowOverviewNoGuildState extends State<GuildWindowOverviewNoGuild> {

  late ChangeGuildCrestChangeNotifier changeGuildCrestChangeNotifier;

  @override
  void initState() {
    changeGuildCrestChangeNotifier = ChangeGuildCrestChangeNotifier();
    super.initState();
  }


  @override
  void dispose() {
    super.dispose();
  }

  switchToOverview() {
    // We'll also change the guild crest to the default one. This is because nothing is created.
    changeGuildCrestChangeNotifier.setGuildCrest(null);
    changeGuildCrestChangeNotifier.setDefault(true);
    showGuildOverview = true;
    createGuildView = false;
    findGuildView = false;
    createGuildColour = 0;
    guildOverviewColour = 2;
    findGuildColour = 0;
  }

  switchToCreate() {
    showGuildOverview = false;
    createGuildView = true;
    findGuildView = false;
    guildOverviewColour = 0;
    createGuildColour = 2;
    findGuildColour = 0;
  }

  switchToFind() {
    // We'll also change the guild crest to the default one. This is because nothing is created.
    changeGuildCrestChangeNotifier.setGuildCrest(null);
    changeGuildCrestChangeNotifier.setDefault(true);
    showGuildOverview = false;
    createGuildView = false;
    findGuildView = true;
    guildOverviewColour = 0;
    createGuildColour = 0;
    findGuildColour = 2;
  }

  double iconSize = 40;
  int guildOverviewColour = 2;
  bool showGuildOverview = true;
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

  int createGuildColour = 0;
  bool createGuildView = false;
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

  int findGuildColour = 0;
  bool findGuildView = false;
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
              Row(
                children: [
                  Text(
                    "Find guild",
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

  UniqueKey guildWindowOverviewNoGuildOverviewKey = UniqueKey();
  UniqueKey guildWindowOverviewNoGuildCreateKey = UniqueKey();
  UniqueKey guildWindowOverviewNoGuildFindKey = UniqueKey();
  Widget overviewContent() {
    if (showGuildOverview) {
      return GuildWindowOverviewNoGuildOverview(
        key: guildWindowOverviewNoGuildOverviewKey,
        game: widget.game,
        normalMode: widget.normalMode,
        overviewHeight: widget.overviewHeight-iconSize,
        overviewWidth: widget.overviewWidth,
        fontSize: widget.fontSize,
      );
    } else if (createGuildView) {
      return GuildWindowOverviewNoGuildCreate(
          key: guildWindowOverviewNoGuildCreateKey,
          game: widget.game,
          normalMode: widget.normalMode,
          overviewHeight: widget.overviewHeight-iconSize,
          overviewWidth: widget.overviewWidth,
          fontSize: widget.fontSize,
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
