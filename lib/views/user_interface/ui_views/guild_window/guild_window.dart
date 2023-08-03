import 'package:age_of_gold/age_of_gold.dart';
import 'package:age_of_gold/services/models/user.dart';
import 'package:age_of_gold/services/settings.dart';
import 'package:age_of_gold/util/util.dart';
import 'package:age_of_gold/views/user_interface/ui_views/change_guild_crest_box/change_guild_crest_change_notifier.dart';
import 'package:age_of_gold/views/user_interface/ui_views/guild_window/guild_information.dart';
import 'package:age_of_gold/views/user_interface/ui_views/guild_window/guild_window_change_notifier.dart';
import 'package:age_of_gold/views/user_interface/ui_views/guild_window/guild_window_overview.dart';
import 'package:age_of_gold/views/user_interface/ui_views/guild_window/guild_window_util.dart';
import 'package:flutter/material.dart';


class GuildWindow extends StatefulWidget {

  final AgeOfGold game;

  const GuildWindow({
    required Key key,
    required this.game
  }) : super(key: key);

  @override
  GuildWindowState createState() => GuildWindowState();
}

class GuildWindowState extends State<GuildWindow> {

  final FocusNode _focusGuildWindow = FocusNode();
  bool normalMode = true;

  late GuildWindowChangeNotifier guildWindowChangeNotifier;
  late GuildInformation guildInformation;
  bool showGuildWindow = false;

  double guildWindowHeight = 0;
  double guildWindowWidth = 100;

  UniqueKey guildWindowOverviewKey = UniqueKey();

  @override
  void initState() {
    guildWindowChangeNotifier = GuildWindowChangeNotifier();
    guildWindowChangeNotifier.addListener(guildWindowChangeListener);
    _focusGuildWindow.addListener(_onFocusChange);

    guildInformation = GuildInformation();
    guildInformation.setCrestIsDefault(true);
    guildInformation.setGuildCrest(null);
    guildInformation.addListener(guildWindowChangeListener);
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

  User? me;
  guildWindowChangeListener() {
    if (mounted) {
      me = Settings().getUser();
      if (!showGuildWindow && guildWindowChangeNotifier.getGuildWindowVisible()) {
        if (me != null) {
          retrieveGuildMembers(me!);
          setGuildCrest(me!, guildInformation);
        }
        setState(() {
          showGuildWindow = true;
        });
      }
      else if (showGuildWindow && !guildWindowChangeNotifier.getGuildWindowVisible()) {
        // If the window is closed we go back to the default.
        // If a guild is created we still set it to default because it is for the creation tab
        guildInformation.setGuildCrest(null);
        guildInformation.setCrestIsDefault(true);
        setState(() {
          showGuildWindow = false;
        });
      } else if (showGuildWindow && guildWindowChangeNotifier.getGuildWindowVisible()) {
        // window already visible, just update if needed
        if (me != null) {
          retrieveGuildMembers(me!);
        }
        setState(() {});
      }
    }
  }

  Widget guildWindowHeader(double headerWidth, double headerHeight, double fontSize) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(),
          SizedBox(
              height: headerHeight,
              child: Text(
                "Guild Window",
                style: simpleTextStyle(fontSize),
              )
          ),
          SizedBox(
            height: headerHeight,
            child: IconButton(
                icon: const Icon(Icons.close),
                color: Colors.orangeAccent.shade200,
                tooltip: 'cancel',
                onPressed: () {
                  goBack();
                }
            ),
          ),
        ]
    );
  }

  Widget mainGuildWindow(double guildWindowWidth, double overviewHeight, double fontSize) {
    return SizedBox(
      width: guildWindowWidth,
      height: overviewHeight,
      child: Column(
        children: [
          GuildWindowOverview(
            key: guildWindowOverviewKey,
            game: widget.game,
            normalMode: normalMode,
            overviewHeight: overviewHeight,
            overviewWidth: guildWindowWidth,
            fontSize: fontSize,
            me: me,
            guildInformation: guildInformation
          )
        ]
      ),
    );
  }

  Widget guildWindow(double guildWindowWidth, double guildWindowHeight, double fontSize) {
    double headerHeight = 40;
    double remainingHeight = guildWindowHeight - headerHeight;
    return Container(
        child: Column(
        children: [
          guildWindowHeader(guildWindowWidth, headerHeight, fontSize),
          mainGuildWindow(guildWindowWidth, remainingHeight, fontSize),
          // bottomButtons(guildWindowWidth, bottomBarHeight, fontSize)
        ]
      )
    );
  }

  Widget windowGuild(BuildContext context) {
    guildWindowHeight = MediaQuery.of(context).size.height * 0.8;
    double fontSize = 16;
    guildWindowWidth = 800;
    // We use the total height to hide the chatbox below
    normalMode = true;
    if (MediaQuery.of(context).size.width <= 800) {
      guildWindowWidth = MediaQuery.of(context).size.width;
      guildWindowHeight = MediaQuery.of(context).size.height - 250;
      normalMode = false;
      fontSize = 12;
    }

    return SingleChildScrollView(
      child: Container(
          width: guildWindowWidth,
          height: guildWindowHeight,
          color: Colors.cyan,
          child: guildWindow(guildWindowWidth, guildWindowHeight, fontSize)
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Align(
      alignment: FractionalOffset.center,
      child: showGuildWindow ? windowGuild(context) : Container()
    );
  }
}
