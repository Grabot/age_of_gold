import 'dart:typed_data';

import 'package:age_of_gold/age_of_gold.dart';
import 'package:age_of_gold/services/auth_service_guild.dart';
import 'package:age_of_gold/services/auth_service_social.dart';
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

  final FocusNode _focusNewMembersWindow = FocusNode();
  TextEditingController newMembersController = TextEditingController();
  final GlobalKey<FormState> newMembersKey = GlobalKey<FormState>();

  bool nothingFound = false;
  User? foundNewMember;

  List<User> askedMembers = [];
  List<User> requestedMembers = [];

  @override
  void initState() {
    changeGuildCrestChangeNotifier = ChangeGuildCrestChangeNotifier();
    super.initState();
    // AuthServiceGuild().getRequestedReceivedGuilds(widget.guild.getGuildId()).then((response) {
    //   if (response != null) {
    //     setState(() {
    //       askedMembers = response;
    //     });
    //   } else {
    //     print("no requests");
    //   }
    // });
    // AuthServiceGuild().getRequestedReceivedGuilds(widget.guild.getGuildId()).then((response) {
    //   if (response != null) {
    //     setState(() {
    //       askedMembers = response;
    //     });
    //   } else {
    //     print("no requests");
    //   }
    // });
  }

  @override
  void dispose() {
    super.dispose();
  }

  findNewMemberAction() {
    print("pressed search for new guilds");
    if (newMembersKey.currentState!.validate()) {
      AuthServiceSocial().searchPossibleFriend(newMembersController.text).then((value) {
        print("search result $value");
        if (value != null) {
          setState(() {
            foundNewMember = value;
            print("found friend");
          });
        } else {
          setState(() {
            foundNewMember = null;
            nothingFound = true;
          });
        }
      });
    }
  }

  askNewMemberToJoin(User newMember) {
    AuthServiceGuild().askNewMember(newMember.id).then((response) {
      if (response.getResult()) {
        showToastMessage("Request send to user");
        setState(() {
          askedMembers.add(newMember);
          print("new member is asked to join");
        });
      } else {
        showToastMessage(response.getMessage());
      }
    });
  }

  Widget newMembersRequestsHeader() {
    return Container(
      width: widget.overviewWidth,
      height: 40,
      child: Row(
        children: [
          Text(
            "Pending requests: ",
            style: simpleTextStyle(widget.fontSize),
          )
        ],
      ),
    );
  }

  List<Widget> requestedGuildBox() {
    if (askedMembers.isEmpty) {
      return [];
    } else {
      List<Widget> requestedMembers = [];
      requestedMembers.add(newMembersRequestsHeader());
      for (User requestedMember in askedMembers) {
        requestedMembers.add(
            newMemberInABox(
                requestedMember,
                80,
                200,
                widget.fontSize
            )
        );
      }
      return requestedMembers;
    }
  }

  Widget newMemberInteraction(User newMember, double newFriendOptionWidth, double fontSize) {
    return SizedBox(
      width: newFriendOptionWidth,
      height: 40,
      child: Row(
          children: [
            ElevatedButton(
              onPressed: () {
                askNewMemberToJoin(newMember);
              },
              style: buttonStyle(false, Colors.blue),
              child: Container(
                alignment: Alignment.center,
                child: Text(
                  "Ask to join guild",
                  style: simpleTextStyle(widget.fontSize),
                ),
              ),
            )
          ]
      ),
    );
  }

  Widget newMemberInABox(User newMember, double avatarBoxSize, double newFriendOptionWidth, double fontSizeBox) {
    String userName = newMember.getUserName();
    Uint8List? memberAvatar = newMember.getAvatar();
    return Row(
        children: [
          avatarBox(avatarBoxSize, avatarBoxSize, memberAvatar),
          SizedBox(
              width: widget.overviewWidth - avatarBoxSize - newFriendOptionWidth,
              child: Text(
                  userName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: fontSizeBox * 2
                  )
              )
          ),
          newMemberInteraction(newMember, newFriendOptionWidth, fontSizeBox),
        ]
    );
  }

  Widget newMemberBox(double avatarBoxSize) {
    double newFriendOptionWidth = 200;
    double fontSizeBox = widget.fontSize;
    if (!widget.normalMode) {
      avatarBoxSize = avatarBoxSize / 1.2;
      fontSizeBox = fontSizeBox / 1.8;
    }

    if (foundNewMember != null) {
      return newMemberInABox(foundNewMember!, avatarBoxSize, newFriendOptionWidth, fontSizeBox);
    } else {
      if (nothingFound) {
        return Text(
          "No user found with that name",
          style: simpleTextStyle(fontSizeBox),
        );
      } else {
        return Container();
      }
    }
  }

  Widget newMembersGuildContent(Guild guild) {

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
                            key: newMembersKey,
                            child: TextFormField(
                              onTap: () {
                                if (!_focusNewMembersWindow.hasFocus) {
                                  _focusNewMembersWindow.requestFocus();
                                }
                              },
                              validator: (val) {
                                return val == null || val.isEmpty
                                    ? "Please enter the name of a friend to add"
                                    : null;
                              },
                              onFieldSubmitted: (value) {
                                findNewMemberAction();
                              },
                              focusNode: _focusNewMembersWindow,
                              controller: newMembersController,
                              textAlign: TextAlign.center,
                              style: simpleTextStyle(widget.fontSize),
                              decoration: textFieldInputDecoration("Search for new members for your guild"),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            findNewMemberAction();
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
                  newMemberBox(120),
                  Column(
                    children: requestedGuildBox()
                  )
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
