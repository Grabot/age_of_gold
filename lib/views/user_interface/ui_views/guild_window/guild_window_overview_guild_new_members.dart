import 'dart:typed_data';

import 'package:age_of_gold/age_of_gold.dart';
import 'package:age_of_gold/services/auth_service_guild.dart';
import 'package:age_of_gold/services/auth_service_social.dart';
import 'package:age_of_gold/services/models/guild.dart';
import 'package:age_of_gold/services/models/guild_member.dart';
import 'package:age_of_gold/services/models/user.dart';
import 'package:age_of_gold/util/render_objects.dart';
import 'package:age_of_gold/util/util.dart';
import 'package:age_of_gold/views/user_interface/ui_views/guild_window/guild_information.dart';
import 'package:age_of_gold/views/user_interface/ui_views/profile_box/profile_change_notifier.dart';
import 'package:flutter/material.dart';


class GuildWindowOverviewGuildNewMembers extends StatefulWidget {

  final AgeOfGold game;
  final bool normalMode;
  final double overviewHeight;
  final double overviewWidth;
  final double fontSize;
  final User? me;
  final Guild guild;
  final GuildInformation guildInformation;

  const GuildWindowOverviewGuildNewMembers({
    required Key key,
    required this.game,
    required this.normalMode,
    required this.overviewHeight,
    required this.overviewWidth,
    required this.fontSize,
    required this.me,
    required this.guild,
    required this.guildInformation,
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

  double newFriendWidth = 240;
  int denyRequestState = 0;

  @override
  void initState() {
    super.initState();
    newMembersInitialize();
  }

  newMembersInitialize() async {
    bool requests1 = await widget.guildInformation.getRequestedGuildSend(widget.guild.getGuildId(), false);
    bool requests2 = await widget.guildInformation.getRequestedGuildGot(widget.guild.getGuildId());
    if (requests1 || requests2) {
      setState(() {});
    }
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
      setState(() {
        foundNewMember = null;
      });
      return;
    }
    // First check if the user is already a member of the guild
    if (widget.guild.getMembers().any((element) => element.getGuildMemberId() == newMember.getId())) {
      showToastMessage("User ${newMember.getUserName()} is already a member of your guild!");
      setState(() {
        foundNewMember = null;
      });
      return;
    }
    // Check if the user is in the requestedMembers list
    if (widget.guildInformation.requestedMembers.any((element) => element.getId() == newMember.getId())) {
      acceptMemberToJoin(newMember);
      setState(() {
        foundNewMember = null;
      });
      return;
    }
    AuthServiceGuild().askNewMember(newMember.id, widget.guild.guildId).then((response) {
      if (response.getResult()) {
        showToastMessage("Request send to user ${newMember.getUserName()}");
        setState(() {
          widget.guildInformation.askedMembers.add(newMember);
        });
      } else {
        showToastMessage(response.getMessage());
      }
    });
  }

  acceptMemberToJoin(User newMember) {
    AuthServiceGuild().acceptGuildRequestUser(newMember.id, widget.guild.guildId).then((response) {
      if (response.getResult()) {
        widget.guild.removeGuildInvite(newMember);
        GuildMember guildMember = GuildMember(newMember.getId(), 3);
        guildMember.setGuildMemberName(newMember.getUserName());
        guildMember.setGuildMemberAvatar(newMember.getAvatar());
        guildMember.setRetrieved(true);
        guildMember.setGuildRank();
        widget.guild.addMember(guildMember);
        setState(() {
          widget.guildInformation.requestedMembers.removeWhere((element) => element.id == newMember.getId());
        });
        ProfileChangeNotifier().notify();
        showToastMessage("User ${newMember.getUserName()} is now a member of your guild!");
      } else {
        showToastMessage(response.getMessage());
      }
    });
  }

  cancelRequest(User cancelUser) {
    AuthServiceGuild().cancelRequestGuild(cancelUser.getId(), widget.guild.guildId).then((response) {
      if (response.getResult()) {
        widget.guildInformation.askedMembers.removeWhere((element) => element.id == cancelUser.getId());
        setState(() {
          showToastMessage("Request to user ${cancelUser.getUserName()} cancelled");
        });
      } else {
        showToastMessage(response.getMessage());
      }
    });
  }

  denyRequest(User denyUser) {
    AuthServiceGuild().cancelRequestUser(denyUser.getId(), widget.guild.guildId).then((response) {
      if (response.getResult()) {
        showToastMessage("Request of user ${denyUser.getUserName()} denied");
        setState(() {
          widget.guildInformation.requestedMembers.removeWhere((element) => element.getId() == denyUser.getId());
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
    if (widget.guildInformation.askedMembers.isEmpty) {
      return [];
    } else {
      List<Widget> askedMembersGuild = [];
      askedMembersGuild.add(membersRequestSendHeader());
      for (User askedMember in widget.guildInformation.askedMembers) {
        askedMembersGuild.add(
            newMemberInABox(
                askedMember,
                80,
                newFriendWidth,
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
    if (widget.guildInformation.requestedMembers.isEmpty) {
      return [];
    } else {
      List<Widget> requestedMembersGuild = [];
      requestedMembersGuild.add(membersRequestGotHeader());
      for (User requestedMember in widget.guildInformation.requestedMembers) {
        requestedMembersGuild.add(
            newMemberInABox(
                requestedMember,
                80,
                newFriendWidth,
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
    double rightPadding = 20;
    if (request) {
      return SizedBox(
        width: newFriendOptionWidth - rightPadding,
        height: 40,
        child: Row(
            children: [
              SizedBox(
                width: newFriendOptionWidth - rightPadding,
                height: 40,
                child: ElevatedButton(
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
                SizedBox(
                  width: newFriendOptionWidth - rightPadding - 45,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      acceptMemberToJoin(newMember);
                    },
                    style: buttonStyle(false, Colors.green),
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        "Accept request!",
                        style: simpleTextStyle(widget.fontSize),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 5),
                Tooltip(
                  message: "deny request",
                  child: InkWell(
                    onHover: (value) {
                      setState(() {
                        denyRequestState = value ? 1 : 0;
                      });
                    },
                    onTap: () {
                      setState(() {
                        denyRequestState = 2;
                      });
                      denyRequest(newMember);
                    },
                    child: addIcon(
                      40,
                      Icons.close,
                      overviewColour(denyRequestState, Colors.red, Colors.redAccent, Colors.red.shade800)
                    )
                  )
                ),
              ]
          ),
        );
      } else {
        return SizedBox(
          width: newFriendOptionWidth,
          height: 40,
          child: Row(
              children: [
                SizedBox(
                  width: newFriendOptionWidth - rightPadding,
                  height: 40,
                  child: ElevatedButton(
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
    double fontSizeBox = widget.fontSize;
    if (!widget.normalMode) {
      avatarBoxSize = avatarBoxSize / 1.2;
      fontSizeBox = fontSizeBox / 1.8;
    }

    if (foundNewMember != null) {
      return newMemberInABox(foundNewMember!, avatarBoxSize, newFriendWidth, fontSizeBox, true, true);
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
