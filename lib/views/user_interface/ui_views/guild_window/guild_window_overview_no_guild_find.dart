import 'dart:typed_data';

import 'package:age_of_gold/age_of_gold.dart';
import 'package:age_of_gold/services/auth_service_guild.dart';
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

  final FocusNode _focusFindGuild = FocusNode();
  TextEditingController findGuildController = TextEditingController();
  final GlobalKey<FormState> findGuildKey = GlobalKey<FormState>();

  bool nothingFound = false;
  Guild? foundGuild;

  @override
  void initState() {
    changeGuildCrestChangeNotifier = ChangeGuildCrestChangeNotifier();
    _focusFindGuild.addListener(_onFocusFindGuild);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _onFocusFindGuild() {
    widget.game.guildWindowFocus(_focusFindGuild.hasFocus);
  }

  findGuildAction() {
    print("pressed search for new guilds");
    if (findGuildKey.currentState!.validate()) {
      AuthServiceGuild().searchGuild(findGuildController.text).then((response) {
        if (response != null) {
          nothingFound = false;
          setState(() {
            foundGuild = response;
          });
        } else {
          setState(() {
            nothingFound = true;
          });
        }
      });
    }
  }

  requestToJoinGuild() {

  }

  Widget guildInteraction(double newFriendOptionWidth, double fontSize) {
    return Container(
      width: newFriendOptionWidth,
      height: 40,
      child: Row(
          children: [
            ElevatedButton(
              onPressed: () {
                requestToJoinGuild();
              },
              style: buttonStyle(false, Colors.blue),
              child: Container(
                alignment: Alignment.center,
                child: Text(
                  "Request to join guild",
                  style: simpleTextStyle(widget.fontSize),
                ),
              ),
            )
          ]
      ),
    );
  }

  Widget guildBox(double avatarBoxSize) {
    double newFriendOptionWidth = 200;
    double sidePadding = 40;
    double fontSizeBox = widget.fontSize;
    if (!widget.normalMode) {
      avatarBoxSize = avatarBoxSize / 1.2;
      fontSizeBox = fontSizeBox / 1.8;
      sidePadding = 10;
    }

    if (foundGuild != null) {
      String guildName = foundGuild!.getGuildName();
      Uint8List? guildCrest = foundGuild!.getGuildCrest();
      return Row(
          children: [
            guildAvatarBox(
                avatarBoxSize,
                avatarBoxSize * 1.125,
                guildCrest
            ),
            SizedBox(
                width: widget.overviewWidth - avatarBoxSize - newFriendOptionWidth,
                child: Text(
                    guildName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: fontSizeBox * 2
                    )
                )
            ),
            guildInteraction(newFriendOptionWidth, fontSizeBox),
          ]
      );
    } else {
      if (nothingFound) {
        return Text(
          "No guild found with that name",
          style: simpleTextStyle(fontSizeBox),
        );
      } else {
        return Container();
      }
    }
  }

  Widget findGuildContent() {
    double crestHeight = 225;
    double backToOverviewHeight = 40;
    double remainingHeight = widget.overviewHeight - crestHeight - backToOverviewHeight;

    return Column(
      children: [
        Row(
          children: [
            guildAvatarBox(
                200,
                225,
                null
            ),
            Expanded(
              child: RichText(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                      children: [
                        TextSpan(
                            text: "Find a guild to join!",
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
          ],
        ),
        SizedBox(
          width: widget.overviewWidth,
          height: remainingHeight,
          child: SingleChildScrollView(
            child: Column(
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(width: 10),
                        SizedBox(
                          width: widget.overviewWidth - 150,
                          height: 50,
                          child: Form(
                            key: findGuildKey,
                            child: TextFormField(
                              onTap: () {
                                if (!_focusFindGuild.hasFocus) {
                                  _focusFindGuild.requestFocus();
                                }
                              },
                              validator: (val) {
                                return val == null || val.isEmpty
                                    ? "Please enter the name of a guild that you might want to join"
                                    : null;
                              },
                              onFieldSubmitted: (value) {
                                findGuildAction();
                              },
                              focusNode: _focusFindGuild,
                              controller: findGuildController,
                              textAlign: TextAlign.center,
                              style: simpleTextStyle(widget.fontSize),
                              decoration: textFieldInputDecoration("Search for a new guild to join!"),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            findGuildAction();
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
                        SizedBox(width: 10),
                      ]
                  ),
                  SizedBox(height: 40),
                  guildBox(120),
                ]
            ),
          ),
        ),
      ],
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
