import 'package:age_of_gold/age_of_gold.dart';
import 'package:age_of_gold/services/models/user.dart';
import 'package:age_of_gold/services/settings.dart';
import 'package:age_of_gold/util/util.dart';
import 'package:age_of_gold/views/user_interface/ui_views/change_guild_crest_box/change_guild_crest_change_notifier.dart';
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
  late ChangeGuildCrestChangeNotifier changeGuildCrestChangeNotifier;
  bool showGuildWindow = false;

  double guildWindowHeight = 0;
  double guildWindowWidth = 100;

  @override
  void initState() {
    guildWindowChangeNotifier = GuildWindowChangeNotifier();
    guildWindowChangeNotifier.addListener(guildWindowChangeListener);
    _focusGuildWindow.addListener(_onFocusChange);

    changeGuildCrestChangeNotifier = ChangeGuildCrestChangeNotifier();
    changeGuildCrestChangeNotifier.setDefault(true);
    changeGuildCrestChangeNotifier.setGuildCrest(null);
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
  guildWindowChangeListener() async {
    if (mounted) {
      if (!showGuildWindow && guildWindowChangeNotifier.getGuildWindowVisible()) {
        me = Settings().getUser();
        if (me != null) {
          setGuildCrest(me!, changeGuildCrestChangeNotifier);
          await retrieveGuildMembers(me!);
        }
        setState(() {
          showGuildWindow = true;
        });
      }
      else if (showGuildWindow && !guildWindowChangeNotifier.getGuildWindowVisible()) {
        // If the window is closed we go back to the default.
        // If a guild is created we still set it to default because it is for the creation tab
        changeGuildCrestChangeNotifier.setGuildCrest(null);
        changeGuildCrestChangeNotifier.setDefault(true);
        setState(() {
          showGuildWindow = false;
        });
      } else if (showGuildWindow && guildWindowChangeNotifier.getGuildWindowVisible()) {
        // window already visible, just update if needed
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

  UniqueKey guildWindowOverviewKey = UniqueKey();
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
            changeGuildCrestChangeNotifier: changeGuildCrestChangeNotifier
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
