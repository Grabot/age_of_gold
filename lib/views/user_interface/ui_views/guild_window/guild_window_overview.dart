import 'package:age_of_gold/age_of_gold.dart';
import 'package:age_of_gold/services/models/user.dart';
import 'package:age_of_gold/views/user_interface/ui_views/change_guild_crest_box/change_guild_crest_change_notifier.dart';
import 'package:age_of_gold/views/user_interface/ui_views/guild_window/guild_information.dart';
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
  final User? me;
  final GuildInformation guildInformation;

  const GuildWindowOverview({
    required Key key,
    required this.game,
    required this.normalMode,
    required this.overviewHeight,
    required this.overviewWidth,
    required this.fontSize,
    required this.me,
    required this.guildInformation,
  }) : super(key: key);

  @override
  GuildWindowOverviewState createState() => GuildWindowOverviewState();
}

class GuildWindowOverviewState extends State<GuildWindowOverview> {

  final FocusNode _focusGuildWindow = FocusNode();

  bool invitePlayerView = false;
  int invitePlayerColour = 0;

  UniqueKey guildWindowOverviewNoGuildKey = UniqueKey();
  UniqueKey guildWindowOverviewGuildKey = UniqueKey();

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

  createGuild() {
    if (widget.me != null) {
      setGuildCrest(widget.me!, widget.guildInformation);
      retrieveGuildMembers(widget.me!);
    }
    setState(() {});
  }

  Widget guildAvatarOverview() {
    if (widget.me == null || widget.me!.getGuild() == null) {
      return GuildWindowOverviewNoGuild(
          key: guildWindowOverviewNoGuildKey,
          game: widget.game,
          normalMode: widget.normalMode,
          overviewHeight: widget.overviewHeight,
          overviewWidth: widget.overviewWidth,
          fontSize: widget.fontSize,
          me: widget.me,
          guildInformation: widget.guildInformation,
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
          me: widget.me,
          guild: widget.me!.getGuild()!,
          guildInformation: widget.guildInformation,
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
