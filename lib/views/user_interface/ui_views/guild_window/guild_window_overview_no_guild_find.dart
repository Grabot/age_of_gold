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
import 'package:flutter/material.dart';


class GuildWindowOverviewNoGuildFind extends StatefulWidget {

  final AgeOfGold game;
  final bool normalMode;
  final double overviewHeight;
  final double overviewWidth;
  final double fontSize;

  const GuildWindowOverviewNoGuildFind({
    required Key key,
    required this.game,
    required this.normalMode,
    required this.overviewHeight,
    required this.overviewWidth,
    required this.fontSize,
  }) : super(key: key);

  @override
  GuildWindowOverviewNoGuildFindState createState() => GuildWindowOverviewNoGuildFindState();
}

class GuildWindowOverviewNoGuildFindState extends State<GuildWindowOverviewNoGuildFind> {

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

  Widget findGuildContent() {
    double remainingHeight = widget.overviewHeight;
    return Column(
      children: [
        Container(), // TODO: Add find guild content
        remainingHeight > 0 ? SizedBox(height: widget.overviewHeight-225) : Container(),
      ]
    );
  }

  Widget findGuild() {
    return SizedBox(
        height: widget.overviewHeight,
        child: SingleChildScrollView(
          child: findGuildContent(),
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: FractionalOffset.center,
      child: findGuild(),
    );
  }
}
