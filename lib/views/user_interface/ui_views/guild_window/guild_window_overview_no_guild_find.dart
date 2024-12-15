import 'dart:typed_data';
import 'package:age_of_gold/age_of_gold.dart';
import 'package:flutter/material.dart';

import '../../../../services/auth_service_guild.dart';
import '../../../../services/models/guild.dart';
import '../../../../services/models/user.dart';
import '../../../../util/render_objects.dart';
import '../../../../util/util.dart';
import '../profile_box/profile_change_notifier.dart';
import 'guild_information.dart';


class GuildWindowOverviewNoGuildFind extends StatefulWidget {

  final AgeOfGold game;
  final bool normalMode;
  final double overviewHeight;
  final double overviewWidth;
  final double fontSize;
  final User? me;
  final GuildInformation guildInformation;
  final Function createGuild;

  const GuildWindowOverviewNoGuildFind({
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
  GuildWindowOverviewNoGuildFindState createState() => GuildWindowOverviewNoGuildFindState();
}

class GuildWindowOverviewNoGuildFindState extends State<GuildWindowOverviewNoGuildFind> {

  final FocusNode _focusFindGuild = FocusNode();
  TextEditingController findGuildController = TextEditingController();
  final GlobalKey<FormState> findGuildKey = GlobalKey<FormState>();

  bool nothingFound = false;
  Guild? foundGuild;

  double newGuildWidth = 240;
  int denyRequestState = 0;

  @override
  void initState() {
    _focusFindGuild.addListener(_onFocusFindGuild);
    newMembersInitialize();
    super.initState();
  }

  newMembersInitialize() async {
    bool requests1 = await widget.guildInformation.getRequestedUserSend();
    bool requests2 = await widget.guildInformation.getRequestedUserGot(false);
    if (requests1 || requests2) {
      setState(() {});
    }
  }


  @override
  void dispose() {
    super.dispose();
  }

  _onFocusFindGuild() {
    widget.game.windowFocus(_focusFindGuild.hasFocus);
  }

  findGuildAction() {
    if (findGuildKey.currentState!.validate()) {
      AuthServiceGuild().searchGuild(findGuildController.text).then((response) {
        if (response != null) {
          nothingFound = false;
          setState(() {
            foundGuild = response;
          });
        } else {
          setState(() {
            foundGuild = null;
            nothingFound = true;
          });
        }
      });
    }
  }

  requestToJoinGuild(Guild guildRequested) {
    if (widget.guildInformation.guildsGotRequests.any((element) => element.getGuildId() == guildRequested.getGuildId())) {
      acceptRequest(guildRequested);
      setState(() {
        foundGuild = null;
      });
      return;
    }
    AuthServiceGuild().requestToJoin(guildRequested.guildId).then((response) {
      if (response.getResult()) {
        showToastMessage("Requested to join guild ${guildRequested.guildName}");
        setState(() {
          widget.guildInformation.guildsSendRequests.add(guildRequested);
        });
      } else {
        showToastMessage(response.getMessage());
      }
    });
  }

  cancelRequest(Guild guildToCancel) {
    if (widget.me == null) {
      showToastMessage("something went wrong");
      return;
    }
    AuthServiceGuild().cancelRequestUser(widget.me!.getId(), guildToCancel.guildId).then((response) {
      if (response.getResult()) {
        showToastMessage("Request for guild ${guildToCancel.getGuildName()} cancelled");
        if (widget.me != null) {
          widget.me!.guildInvites.removeWhere((element) => element.getGuildId() == guildToCancel.guildId);
        }
        setState(() {
          widget.guildInformation.guildsSendRequests.removeWhere((element) => element.guildId == guildToCancel.guildId);
        });
      } else {
        showToastMessage(response.getMessage());
      }
    });
  }

  acceptRequest(Guild guildToAccept) {
    AuthServiceGuild().acceptGuildRequestGuild(guildToAccept.guildId).then((response) {
      if (response != null) {
        Guild newGuild = response;
        if (widget.me == null) {
          showToastMessage("something went wrong");
        } else {
          widget.me!.setGuild(newGuild);
          ProfileChangeNotifier().notify();
          widget.createGuild();
        }
      } else {
        showToastMessage("Something went wrong");
      }
    });
  }

  denyRequest(Guild denyGuild) {
    if (widget.me == null) {
      showToastMessage("something went wrong");
      return;
    }
    AuthServiceGuild().cancelRequestGuild(widget.me!.getId(), denyGuild.guildId).then((response) {
      if (response.getResult()) {
        showToastMessage("Request for guild ${denyGuild.getGuildName()} denied");
        if (widget.me != null) {
          widget.me!.guildInvites.removeWhere((element) => element.getGuildId() == denyGuild.guildId);
        }
        setState(() {
          widget.guildInformation.guildsGotRequests.removeWhere((element) => element.guildId == denyGuild.guildId);
        });
        GuildInformation().notify();
        ProfileChangeNotifier().notify();
      } else {
        showToastMessage(response.getMessage());
      }
    });
  }

  Widget guildInteraction(Guild guild, double newFriendOptionWidth, double fontSize, bool request, bool send) {
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
                    requestToJoinGuild(guild);
                  },
                  style: buttonStyle(false, Colors.blue),
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      "Request to join guild",
                      style: simpleTextStyle(widget.fontSize),
                    ),
                  ),
                ),
              )
            ]
        ),
      );
    } else {
      if (send) {
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
                      cancelRequest(guild);
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
      } else {
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
                    acceptRequest(guild);
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
              const SizedBox(width: 5),
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
                    denyRequest(guild);
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
      }
    }
  }

  Widget requestedGuildsSendHeader() {
    return SizedBox(
      width: widget.overviewWidth,
      height: 40,
      child: Row(
        children: [
          Text(
            "Your pending requests: ",
            style: simpleTextStyle(widget.fontSize),
          )
        ],
      ),
    );
  }

  Widget requestedGuildsGotHeader() {
    return SizedBox(
      width: widget.overviewWidth,
      height: 40,
      child: Row(
        children: [
          Text(
            "Guild requests: ",
            style: simpleTextStyle(widget.fontSize),
          )
        ],
      ),
    );
  }

  List<Widget> requestedGuildBox(List<Guild> guilds, bool send) {
    if (guilds.isEmpty) {
      return [];
    } else {
      List<Widget> requestedGuilds = [];
      if (send) {
        requestedGuilds.add(requestedGuildsSendHeader());
      } else {
        requestedGuilds.add(requestedGuildsGotHeader());
      }
      for (Guild requestedGuild in guilds) {
        requestedGuilds.add(
            guildInABox(
              requestedGuild,
              80,
              newGuildWidth,
              widget.fontSize,
              false,
              send
            )
        );
      }
      return requestedGuilds;
    }
  }

  Widget guildBox(double avatarBoxSize) {
    double fontSizeBox = widget.fontSize;
    if (!widget.normalMode) {
      avatarBoxSize = avatarBoxSize / 1.2;
      fontSizeBox = fontSizeBox / 1.8;
    }

    if (foundGuild != null) {
      return guildInABox(foundGuild!, avatarBoxSize, newGuildWidth, fontSizeBox, true, true);
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

  Widget guildInABox(Guild guild, double avatarBoxSize, double newFriendOptionWidth, double fontSizeBox, bool request, bool send) {
    String guildName = guild.getGuildName();
    Uint8List? guildCrest = guild.getGuildCrest();
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
          guildInteraction(guild, newFriendOptionWidth, fontSizeBox, request, send),
        ]
    );
  }

  Widget findGuildTopContentNormal() {
    return Row(
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
              text: const TextSpan(
                  children: [
                    TextSpan(
                        text: "Find a guild to join!",
                        style: TextStyle(
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
    );
  }

  Widget findGuildTopContentMobile() {
    return Column(
      children: [
        guildAvatarBox(
            200,
            225,
            null
        ),
        SizedBox(
          height: 50,
          child: Column(
            children: [
              Expanded(
                child: RichText(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  text: const TextSpan(
                      children: [
                        TextSpan(
                            text: "Find a guild to join!",
                            style: TextStyle(
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
        ),
      ],
    );
  }

  Widget findGuildContent() {
    double crestHeight = 225;
    double backToOverviewHeight = 40;
    double remainingHeight = widget.overviewHeight - crestHeight - backToOverviewHeight;

    return Column(
      children: [
        widget.normalMode
            ? findGuildTopContentNormal()
            : findGuildTopContentMobile(),
        SizedBox(
          width: widget.overviewWidth,
          height: remainingHeight,
          child: SingleChildScrollView(
            child: Column(
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 10),
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
                        const SizedBox(width: 10),
                      ]
                  ),
                  const SizedBox(height: 40),
                  guildBox(120),
                  Column(
                    children: requestedGuildBox(widget.guildInformation.guildsGotRequests, false),
                  ),
                  Column(
                    children: requestedGuildBox(widget.guildInformation.guildsSendRequests, true),
                  ),
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
