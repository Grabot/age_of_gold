import 'dart:convert';
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
import 'package:age_of_gold/views/user_interface/ui_views/profile_box/profile_change_notifier.dart';
import 'package:flutter/material.dart';


class GuildWindowOverviewNoGuildCreate extends StatefulWidget {

  final AgeOfGold game;
  final bool normalMode;
  final double overviewHeight;
  final double overviewWidth;
  final double fontSize;
  final Function createGuild;

  const GuildWindowOverviewNoGuildCreate({
    required Key key,
    required this.game,
    required this.normalMode,
    required this.overviewHeight,
    required this.overviewWidth,
    required this.fontSize,
    required this.createGuild,
  }) : super(key: key);

  @override
  GuildWindowOverviewNoGuildCreateState createState() => GuildWindowOverviewNoGuildCreateState();
}

class GuildWindowOverviewNoGuildCreateState extends State<GuildWindowOverviewNoGuildCreate> {

  late ChangeGuildCrestChangeNotifier changeGuildCrestChangeNotifier;

  final GlobalKey<FormState> createGuildKey = GlobalKey<FormState>();
  final TextEditingController createGuildController = TextEditingController();
  final FocusNode _focusCreateGuildChange = FocusNode();

  @override
  void initState() {
    changeGuildCrestChangeNotifier = ChangeGuildCrestChangeNotifier();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  changeGuildCrestAction() {
    changeGuildCrestChangeNotifier.setChangeGuildCrestVisible(true);
  }

  createGuildAction() {
    if (createGuildKey.currentState!.validate()) {
      String? newAvatarRegular;
      if (!changeGuildCrestChangeNotifier.getDefault()) {
        newAvatarRegular = base64Encode(changeGuildCrestChangeNotifier.getGuildCrest()!);
      }
      User? me = Settings().getUser();
      if (me != null) {
        String guildName = createGuildController.text;
        AuthServiceGuild().createGuild(me.getId(), guildName, newAvatarRegular).then((value) {
          if (value.getResult()) {
            int guildId = int.parse(value.getMessage());
            String guildName = createGuildController.text;
            Uint8List? guildCrest = changeGuildCrestChangeNotifier.getGuildCrest();
            Guild createdGuild = Guild(guildId, guildName, guildCrest);
            // You just created a guild, so you're the only member and you're admin.
            GuildMember guildMember = GuildMember(me.getId(), 0);
            guildMember.setGuildMemberName(me.getUserName());
            guildMember.setGuildMemberAvatar(me.getAvatar());
            guildMember.setRetrieved(true);
            createdGuild.addMember(guildMember);
            me.setGuild(createdGuild);
            widget.createGuild();
            ProfileChangeNotifier().notify();
          } else {
            showToastMessage(value.getMessage());
          }
        });
      }
    }
  }

  Widget createGuild() {
    double guildTextHeight = 30;
    double guildTextFieldHeight = 60;
    double smallPadding = 10;
    double crestHeight = 225;
    double createButtonHeight = 50;
    double remainingHeight = widget.overviewHeight - createButtonHeight - (smallPadding*3) - crestHeight - guildTextHeight - guildTextHeight - guildTextFieldHeight;
    return Column(
        children: [
          Row(
            children: [
              SizedBox(
                height: guildTextHeight,
                child: Text(
                    "Guild Name:",
                    style: TextStyle(color: Colors.white, fontSize: widget.fontSize)
                ),
              )
            ],
          ),
          Container(
            height: guildTextFieldHeight,
            child: Form(
              key: createGuildKey,
              child: TextFormField(
                controller: createGuildController,
                focusNode: _focusCreateGuildChange,
                validator: (val) {
                  return val == null || val.isEmpty
                      ? "Fill in a Guild Name"
                      : null;
                },
                decoration: const InputDecoration(
                  hintText: "Fill in a Guild Name",
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                ),
                style: TextStyle(
                    color: Colors.white, fontSize: widget.fontSize*2
                ),
              ),
            ),
          ),
          SizedBox(height: smallPadding),
          Row(
            children: [
              SizedBox(
                height: guildTextHeight,
                child: Text(
                    "Guild Crest",
                    style: TextStyle(color: Colors.white, fontSize: widget.fontSize)
                ),
              )
            ],
          ),
          Row(
            children: [
              guildAvatarBox(
                  200,
                  crestHeight,
                  changeGuildCrestChangeNotifier.getGuildCrest()
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  changeGuildCrestAction();
                },
                style: buttonStyle(true, Colors.blue),
                child: Container(
                  alignment: Alignment.center,
                  width: 200,
                  child: Text(
                    "Change crest image",
                    style: simpleTextStyle(widget.fontSize),
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: smallPadding*2),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  createGuildAction();
                },
                style: buttonStyle(true, Colors.blue),
                child: Container(
                  alignment: Alignment.center,
                  width: 200,
                  height: createButtonHeight,
                  child: Text(
                    "Create Guild",
                    style: simpleTextStyle(widget.fontSize),
                  ),
                ),
              )
            ],
          ),
          remainingHeight > 0 ? SizedBox(height: remainingHeight) : Container(),
        ]
    );
  }

  Widget createGuildView() {
    return SizedBox(
      height: widget.overviewHeight,
      child: SingleChildScrollView(
        child: createGuild(),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: FractionalOffset.center,
      child: createGuildView(),
    );
  }
}
