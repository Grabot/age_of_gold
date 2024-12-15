import 'dart:convert';
import 'dart:typed_data';
import 'package:age_of_gold/age_of_gold.dart';
import 'package:flutter/material.dart';

import '../../../../services/auth_service_guild.dart';
import '../../../../services/models/guild.dart';
import '../../../../services/models/guild_member.dart';
import '../../../../services/models/user.dart';
import '../../../../util/render_objects.dart';
import '../../../../util/util.dart';
import '../change_guild_crest_box/change_guild_crest_change_notifier.dart';
import '../profile_box/profile_change_notifier.dart';
import 'guild_information.dart';


class GuildWindowOverviewNoGuildCreate extends StatefulWidget {

  final AgeOfGold game;
  final bool normalMode;
  final double overviewHeight;
  final double overviewWidth;
  final double fontSize;
  final User? me;
  final GuildInformation guildInformation;
  final Function createGuild;

  const GuildWindowOverviewNoGuildCreate({
    required Key key,
    required this.game,
    required this.normalMode,
    required this.overviewHeight,
    required this.overviewWidth,
    required this.fontSize,
    required this.me,
    required this.guildInformation,
    required this.createGuild,
  }) : super(key: key);

  @override
  GuildWindowOverviewNoGuildCreateState createState() => GuildWindowOverviewNoGuildCreateState();
}

class GuildWindowOverviewNoGuildCreateState extends State<GuildWindowOverviewNoGuildCreate> {

  final GlobalKey<FormState> createGuildKey = GlobalKey<FormState>();
  final TextEditingController createGuildController = TextEditingController();
  final FocusNode _focusCreateGuildChange = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  changeGuildCrestAction() {
    ChangeGuildCrestChangeNotifier changeGuildCrestChangeNotifier = ChangeGuildCrestChangeNotifier();
    changeGuildCrestChangeNotifier.setGuildCrest(widget.guildInformation.getGuildCrest());
    changeGuildCrestChangeNotifier.setDefault(widget.guildInformation.getCrestIsDefault());
    changeGuildCrestChangeNotifier.setCreateCrest(true);
    changeGuildCrestChangeNotifier.setChangeGuildCrestVisible(true);
  }

  createGuildAction() {
    if (createGuildKey.currentState!.validate()) {
      String? newAvatarRegular;
      if (!widget.guildInformation.getCrestIsDefault()) {
        newAvatarRegular = base64Encode(widget.guildInformation.getGuildCrest()!);
      }
      if (widget.me != null) {
        String guildName = createGuildController.text;
        AuthServiceGuild().createGuild(widget.me!.getId(), guildName, newAvatarRegular).then((value) {
          if (value.getResult()) {
            int guildId = int.parse(value.getMessage());
            String guildName = createGuildController.text;
            Uint8List? guildCrest = widget.guildInformation.getGuildCrest();
            Guild createdGuild = Guild(guildId, guildName, 0, guildCrest);
            // You just created a guild, so you're the only member and you're guild master.
            GuildMember guildMember = GuildMember(widget.me!.getId(), 0);
            guildMember.setGuildMemberName(widget.me!.getUserName());
            guildMember.setGuildMemberAvatar(widget.me!.getAvatar());
            guildMember.setRetrieved(true);
            createdGuild.addMember(guildMember);
            widget.me!.setGuild(createdGuild);
            widget.createGuild();
            ProfileChangeNotifier().notify();
          } else {
            showToastMessage(value.getMessage());
          }
        });
      }
    }
  }

  Widget createGuildOptionsNormal(double crestHeight) {
    return Row(
      children: [
        guildAvatarBox(
            200,
            crestHeight,
            widget.guildInformation.getGuildCrest()
        ),
        const SizedBox(width: 10),
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
    );
  }

  Widget createGuildOptionsMobile(double crestHeight) {
    return Column(
      children: [
        guildAvatarBox(
            200,
            crestHeight,
            widget.guildInformation.getGuildCrest()
        ),
        const SizedBox(width: 10),
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
    );
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
          SizedBox(
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
          widget.normalMode
              ? createGuildOptionsNormal(crestHeight)
              : createGuildOptionsMobile(crestHeight),
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
