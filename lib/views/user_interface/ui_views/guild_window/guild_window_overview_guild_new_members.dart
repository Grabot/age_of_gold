import 'dart:typed_data';

import 'package:age_of_gold/age_of_gold.dart';
import 'package:age_of_gold/services/auth_service_guild.dart';
import 'package:age_of_gold/services/auth_service_social.dart';
import 'package:age_of_gold/services/models/guild.dart';
import 'package:age_of_gold/services/models/guild_member.dart';
import 'package:age_of_gold/services/models/user.dart';
import 'package:age_of_gold/util/render_objects.dart';
import 'package:age_of_gold/util/util.dart';
import 'package:flutter/material.dart';


class GuildWindowOverviewGuildNewMembers extends StatefulWidget {

  final AgeOfGold game;
  final bool normalMode;
  final double overviewHeight;
  final double overviewWidth;
  final double fontSize;
  final User? me;
  final Guild guild;

  const GuildWindowOverviewGuildNewMembers({
    required Key key,
    required this.game,
    required this.normalMode,
    required this.overviewHeight,
    required this.overviewWidth,
    required this.fontSize,
    required this.me,
    required this.guild
  }) : super(key: key);

  @override
  GuildWindowOverviewGuildNewMembersState createState() => GuildWindowOverviewGuildNewMembersState();
}

class GuildWindowOverviewGuildNewMembersState extends State<GuildWindowOverviewGuildNewMembers> {

  final FocusNode _focusNewMembersWindow = FocusNode();
  TextEditingController newMembersController = TextEditingController();
  final GlobalKey<FormState> newMembersKey = GlobalKey<FormState>();

  bool nothingFound = false;
  User? foundNewMember;

  List<User> askedMembers = [];
  List<User> requestedMembers = [];

  @override
  void initState() {
    super.initState();
    AuthServiceGuild().getRequestedGuildSend(widget.guild.getGuildId()).then((response) {
      if (response != null) {
        setState(() {
          requestedMembers = response;
        });
      } else {
        print("no requests");
      }
    });
    AuthServiceGuild().getRequestedGuildGot(widget.guild.getGuildId()).then((response) {
      if (response != null) {
        setState(() {
          askedMembers = response;
        });
      } else {
        print("no requests");
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  findNewMemberAction() {
    if (newMembersKey.currentState!.validate()) {
      AuthServiceSocial().searchPossibleFriend(newMembersController.text).then((value) {
        if (value != null) {
          setState(() {
            foundNewMember = value;
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
    if (widget.me != null && widget.me!.getId() == newMember.getId()) {
      showToastMessage("You are already a member of your guild!");
      return;
    }
    // First check if the user is already a member of the guild
    if (widget.guild.getMembers().any((element) => element.getGuildMemberId() == newMember.getId())) {
      showToastMessage("User ${newMember.getUserName()} is already a member of your guild!");
      return;
    }
    AuthServiceGuild().askNewMember(newMember.id, widget.guild.guildId).then((response) {
      if (response.getResult()) {
        showToastMessage("Request send to user ${newMember.getUserName()}");
        setState(() {
          askedMembers.add(newMember);
        });
      } else {
        showToastMessage(response.getMessage());
      }
    });
  }

  acceptMemberToJoin(User newMember) {
    AuthServiceGuild().acceptGuildRequestUser(newMember.id, widget.guild.guildId).then((response) {
      if (response.getResult()) {
        GuildMember guildMember = GuildMember(newMember.getId(), 4);
        guildMember.setGuildMemberName(newMember.getUserName());
        guildMember.setGuildMemberAvatar(newMember.getAvatar());
        guildMember.setRetrieved(true);
        widget.guild.addMember(guildMember);
        setState(() {
          requestedMembers.removeWhere((element) => element.id == newMember.getId());
        });
        showToastMessage("User ${newMember.getUserName()} is now a member of your guild!");
      } else {
        showToastMessage(response.getMessage());
      }
    });
  }

  cancelRequest(User cancelUser) {
    AuthServiceGuild().cancelRequestGuild(cancelUser.getId(), widget.guild.guildId).then((response) {
      if (response.getResult()) {
        askedMembers.removeWhere((element) => element.id == cancelUser.getId());
        setState(() {
          showToastMessage("Request to user ${cancelUser.getUserName()} cancelled");
        });
      } else {
        showToastMessage(response.getMessage());
      }
    });
  }

  Widget membersRequestSendHeader() {
    return SizedBox(
      width: widget.overviewWidth,
      height: 40,
      child: Row(
        children: [
          Text(
            "Pending requests send to users: ",
            style: simpleTextStyle(widget.fontSize),
          )
        ],
      ),
    );
  }

  Widget membersRequestGotHeader() {
    return SizedBox(
      width: widget.overviewWidth,
      height: 40,
      child: Row(
        children: [
          Text(
            "Pending requests from users: ",
            style: simpleTextStyle(widget.fontSize),
          )
        ],
      ),
    );
  }

  List<Widget> memberRequestsSendBox() {
    if (askedMembers.isEmpty) {
      return [];
    } else {
      List<Widget> askedMembersGuild = [];
      askedMembersGuild.add(membersRequestSendHeader());
      for (User askedMember in askedMembers) {
        askedMembersGuild.add(
            newMemberInABox(
                askedMember,
                80,
                200,
                widget.fontSize,
                false,
                true
            )
        );
      }
      return askedMembersGuild;
    }
  }

  List<Widget> memberRequestsGotBox() {
    if (requestedMembers.isEmpty) {
      return [];
    } else {
      List<Widget> requestedMembersGuild = [];
      requestedMembersGuild.add(membersRequestGotHeader());
      for (User requestedMember in requestedMembers) {
        requestedMembersGuild.add(
            newMemberInABox(
                requestedMember,
                80,
                200,
                widget.fontSize,
                false,
                false
            )
        );
      }
      return requestedMembersGuild;
    }
  }

  Widget newMemberInteraction(User newMember, double newFriendOptionWidth, double fontSize, bool request, bool send) {
    if (request) {
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
    } else {
      if (!send) {
        return SizedBox(
          width: newFriendOptionWidth,
          height: 40,
          child: Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    acceptMemberToJoin(newMember);
                  },
                  style: buttonStyle(false, Colors.blue),
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      "Accept request!",
                      style: simpleTextStyle(widget.fontSize),
                    ),
                  ),
                )
              ]
          ),
        );
      } else {
        return SizedBox(
          width: newFriendOptionWidth,
          height: 40,
          child: Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    cancelRequest(newMember);
                  },
                  style: buttonStyle(false, Colors.blue),
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      "Cancel request",
                      style: simpleTextStyle(widget.fontSize),
                    ),
                  ),
                )
              ]
          ),
        );
      }
    }
  }

  Widget newMemberInABox(User newMember, double avatarBoxSize, double newFriendOptionWidth, double fontSizeBox, bool request, bool send) {
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
          newMemberInteraction(newMember, newFriendOptionWidth, fontSizeBox, request, send),
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
      return newMemberInABox(foundNewMember!, avatarBoxSize, newFriendOptionWidth, fontSizeBox, true, true);
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
                    children: memberRequestsGotBox()
                  ),
                  Column(
                    children: memberRequestsSendBox()
                  ),
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
