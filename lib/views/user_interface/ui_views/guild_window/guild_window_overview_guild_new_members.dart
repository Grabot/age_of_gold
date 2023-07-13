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


class GuildWindowOverviewGuildNewMembers extends StatefulWidget {

  final AgeOfGold game;
  final bool normalMode;
  final double overviewHeight;
  final double overviewWidth;
  final double fontSize;
  final Guild guild;

  const GuildWindowOverviewGuildNewMembers({
    required Key key,
    required this.game,
    required this.normalMode,
    required this.overviewHeight,
    required this.overviewWidth,
    required this.fontSize,
    required this.guild
  }) : super(key: key);

  @override
  GuildWindowOverviewGuildNewMembersState createState() => GuildWindowOverviewGuildNewMembersState();
}

class GuildWindowOverviewGuildNewMembersState extends State<GuildWindowOverviewGuildNewMembers> {

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

  Widget newMembersGuildContent(Guild guild) {

    double crestHeight = 225;
    double backToOverviewHeight = 40;
    double remainingHeight = widget.overviewHeight - crestHeight - backToOverviewHeight;

    // TODO: Fix functionality
    return Column(
      children: [
        Row(
          children: [
            guildAvatarBox(
                200,
                225,
                guild.getGuildCrest()
            ),
            Expanded(
              child: RichText(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                      children: [
                        TextSpan(
                            text: guild.getGuildName(),
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
                            // key: addFriendKey,
                            child: TextFormField(
                              onTap: () {
                                // if (!_focusGuildWindow.hasFocus) {
                                //   _focusGuildWindow.requestFocus();
                                // }
                              },
                              validator: (val) {
                                return val == null || val.isEmpty
                                    ? "Please enter the name of a friend to add"
                                    : null;
                              },
                              onFieldSubmitted: (value) {
                                print("pressed search for guild member");
                              },
                              // focusNode: _focusAdd,
                              // controller: addController,
                              textAlign: TextAlign.center,
                              style: simpleTextStyle(widget.fontSize),
                              decoration: textFieldInputDecoration("Search for new members for your guild"),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            print("pressed search for guild member");
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
                  // friendBox(possibleNewFriend, 120, addFriendWindowWidth, fontSize),
                ]
            ),
          ),
        ),
      ],
    );
  }

  Widget newMembersGuild() {
    return SizedBox(
        height: widget.overviewHeight,
        child: SingleChildScrollView(
          child: newMembersGuildContent(widget.guild),
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: FractionalOffset.center,
      child: newMembersGuild(),
    );
  }
}
