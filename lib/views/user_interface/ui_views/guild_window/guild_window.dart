import 'dart:convert';
import 'dart:typed_data';

import 'package:age_of_gold/age_of_gold.dart';
import 'package:age_of_gold/services/auth_service_social.dart';
import 'package:age_of_gold/services/models/friend.dart';
import 'package:age_of_gold/services/models/user.dart';
import 'package:age_of_gold/services/settings.dart';
import 'package:age_of_gold/services/socket_services.dart';
import 'package:age_of_gold/util/render_objects.dart';
import 'package:age_of_gold/util/util.dart';
import 'package:age_of_gold/views/user_interface/ui_util/chat_messages.dart';
import 'package:age_of_gold/views/user_interface/ui_util/clear_ui.dart';
import 'package:age_of_gold/views/user_interface/ui_views/chat_window/chat_window_change_notifier.dart';
import 'package:age_of_gold/views/user_interface/ui_views/friend_window/friend_window_change_notifier.dart';
import 'package:age_of_gold/views/user_interface/ui_views/guild_window/guild_window_change_notifier.dart';
import 'package:age_of_gold/views/user_interface/ui_views/profile_box/profile_change_notifier.dart';
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

  bool normalMode = true;

  late GuildWindowChangeNotifier guildWindowChangeNotifier;
  bool showGuildWindow = false;

  @override
  void initState() {
    guildWindowChangeNotifier = GuildWindowChangeNotifier();
    guildWindowChangeNotifier.addListener(guildWindowChangeListener);
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

  guildWindowChangeListener() {
    if (mounted) {
      if (!showGuildWindow && guildWindowChangeNotifier.getGuildWindowVisible()) {
        setState(() {
          showGuildWindow = true;
        });
      }
      if (showGuildWindow && !guildWindowChangeNotifier.getGuildWindowVisible()) {
        setState(() {
          showGuildWindow = false;
        });
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

  Widget friendWindowNormal(double friendWindowWidth, double friendWindowHeight, double fontSize) {
    double headerHeight = 40;
    return Container(
        child: Column(
        children: [
          guildWindowHeader(friendWindowWidth, headerHeight, fontSize),
        ]
      )
    );
  }

  Widget guildWindow(BuildContext context) {
    double friendWindowHeight = MediaQuery.of(context).size.height * 0.8;
    double fontSize = 16;
    double friendWindowWidth = 800;
    // We use the total height to hide the chatbox below
    normalMode = true;
    if (MediaQuery.of(context).size.width <= 800) {
      friendWindowWidth = MediaQuery.of(context).size.width;
      normalMode = false;
      fontSize = 12;
    }
    return SingleChildScrollView(
      child: Container(
          width: friendWindowWidth,
          height: friendWindowHeight,
          color: Colors.cyan,
          child: friendWindowNormal(friendWindowWidth, friendWindowHeight, fontSize)
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: FractionalOffset.center,
      child: showGuildWindow ? guildWindow(context) : Container()
    );
  }
}
