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
import 'package:age_of_gold/views/user_interface/ui_views/guild_window/guild_window_overview_guild.dart';
import 'package:age_of_gold/views/user_interface/ui_views/guild_window/guild_window_overview_no_guild.dart';
import 'package:age_of_gold/views/user_interface/ui_views/guild_window/guild_window_util.dart';
import 'package:flutter/material.dart';


class GuildWindowOverview extends StatefulWidget {

  final AgeOfGold game;
  final bool normalMode;
  final double overviewHeight;
  final double overviewWidth;
  final double fontSize;
  final ChangeGuildCrestChangeNotifier changeGuildCrestChangeNotifier;

  const GuildWindowOverview({
    required Key key,
    required this.game,
    required this.normalMode,
    required this.overviewHeight,
    required this.overviewWidth,
    required this.fontSize,
    required this.changeGuildCrestChangeNotifier,
  }) : super(key: key);

  @override
  GuildWindowOverviewState createState() => GuildWindowOverviewState();
}

class GuildWindowOverviewState extends State<GuildWindowOverview> {

  final FocusNode _focusGuildWindow = FocusNode();

  bool invitePlayerView = false;
  int invitePlayerColour = 0;

  @override
  void initState() {
    _focusGuildWindow.addListener(_onFocusChange);
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

  leaveGuild() {
    print("pressed the leave guild button");
    // The information should be set on the "user" object so just refresh the state
    setState(() {});
  }

  createGuild() async {
    User? me = Settings().getUser();
    if (me != null) {
      setGuildCrest(me, widget.changeGuildCrestChangeNotifier);
      await retrieveGuildMembers(me);
    }
    setState(() {});
  }

  UniqueKey guildWindowOverviewNoGuildKey = UniqueKey();
  UniqueKey guildWindowOverviewGuildKey = UniqueKey();
  Widget guildAvatarOverview() {
    User? me = Settings().getUser();
    if (me == null || me.getGuild() == null) {
      return GuildWindowOverviewNoGuild(
          key: guildWindowOverviewNoGuildKey,
          game: widget.game,
          normalMode: widget.normalMode,
          overviewHeight: widget.overviewHeight,
          overviewWidth: widget.overviewWidth,
          fontSize: widget.fontSize,
          createGuild: createGuild,
      );
    } else {
      return GuildWindowOverviewGuild(
          key: guildWindowOverviewGuildKey,
          game: widget.game,
          normalMode: widget.normalMode,
          overviewHeight: widget.overviewHeight,
          overviewWidth: widget.overviewWidth,
          fontSize: widget.fontSize,
          guild: me.getGuild()!,
          leaveGuild: leaveGuild,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: FractionalOffset.center,
        child: Column(
          children: [
            guildAvatarOverview(),
          ]
        )
    );
  }
}
