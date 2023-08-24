import 'dart:typed_data';

import 'package:age_of_gold/age_of_gold.dart';
import 'package:age_of_gold/services/auth_service_guild.dart';
import 'package:age_of_gold/services/models/guild.dart';
import 'package:age_of_gold/services/models/guild_member.dart';
import 'package:age_of_gold/services/models/user.dart';
import 'package:age_of_gold/util/render_objects.dart';
import 'package:age_of_gold/util/util.dart';
import 'package:age_of_gold/views/user_interface/ui_util/chat_messages.dart';
import 'package:age_of_gold/views/user_interface/ui_util/clear_ui.dart';
import 'package:age_of_gold/views/user_interface/ui_views/are_you_sure_box/are_you_sure_change_notifier.dart';
import 'package:age_of_gold/views/user_interface/ui_views/change_guild_crest_box/change_guild_crest_change_notifier.dart';
import 'package:age_of_gold/views/user_interface/ui_views/chat_window/chat_window_change_notifier.dart';
import 'package:age_of_gold/views/user_interface/ui_views/guild_window/guild_information.dart';
import 'package:age_of_gold/views/user_interface/ui_views/guild_window/guild_window_overview_change_ranks.dart';
import 'package:flutter/material.dart';


class GuildWindowOverviewGuildOverview extends StatefulWidget {

  final AgeOfGold game;
  final bool normalMode;
  final double overviewHeight;
  final double overviewWidth;
  final double fontSize;
  final User? me;
  final Guild guild;
  final GuildInformation guildInformation;
  final Function leaveGuild;

  const GuildWindowOverviewGuildOverview({
    required Key key,
    required this.game,
    required this.normalMode,
    required this.overviewHeight,
    required this.overviewWidth,
    required this.fontSize,
    required this.me,
    required this.guild,
    required this.guildInformation,
    required this.leaveGuild,
  }) : super(key: key);

  @override
  GuildWindowOverviewGuildOverviewState createState() => GuildWindowOverviewGuildOverviewState();
}

class GuildWindowOverviewGuildOverviewState extends State<GuildWindowOverviewGuildOverview> {

  GlobalKey guildSettingsKey = GlobalKey();

  final FocusNode _focusGuildMembersSearch = FocusNode();
  final TextEditingController searchGuildMembersController = TextEditingController();
  bool searchModeMembers = false;

  List<GuildMember>? shownGuildMembers;
  int myRankId = 4;

  @override
  void initState() {
    if (widget.me != null) {
      if (widget.me!.getGuild() != null) {
        myRankId = widget.me!.getGuild()!.getMyGuildRankId();
      }
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Offset? _tapPosition;
  void _showPopupMenu() {
    _storePosition();
    _showChatDetailPopupMenu();
  }

  void _showChatDetailPopupMenu() {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    showMenu(
        context: context,
        items: [GuildSettingPopup(
            key: UniqueKey(),
            isAdministrator: widget.guild.isAdministrator
        )],
        position: RelativeRect.fromRect(
            _tapPosition! & const Size(40, 40), Offset.zero & overlay.size))
        .then((int? delta) {
      if (delta == 0) {
        leaveGuildOption();
      } else if (delta == 1) {
        // change guild crest
        changeGuildCrest();
      }
      return;
    });
  }

  leaveGuildOption() {
    if (widget.me == null) {
      showToastMessage("something went wrong");
      return;
    }
    AreYouSureBoxChangeNotifier areYouSureBoxChangeNotifier = AreYouSureBoxChangeNotifier();
    areYouSureBoxChangeNotifier.setUserId(widget.me!.getId());
    areYouSureBoxChangeNotifier.setGuildId(widget.guild.getGuildId());
    areYouSureBoxChangeNotifier.setShowLogout(false);
    areYouSureBoxChangeNotifier.setShowLeaveGuild(true);
    areYouSureBoxChangeNotifier.setAreYouSureBoxVisible(true);
  }

  changeGuildCrest() {
    ChangeGuildCrestChangeNotifier changeGuildCrestChangeNotifier = ChangeGuildCrestChangeNotifier();
    changeGuildCrestChangeNotifier.setGuildCrest(widget.guildInformation.getGuildCrest());
    changeGuildCrestChangeNotifier.setDefault(widget.guildInformation.getCrestIsDefault());
    changeGuildCrestChangeNotifier.setCreateCrest(false);
    changeGuildCrestChangeNotifier.setChangeGuildCrestVisible(true);
  }

  messageFriend(GuildMember guildMember) {
    ClearUI().clearUserInterfaces();
    ChatMessages chatMessages = ChatMessages();
    // If the guildmember is a friend than the `addChatRegion` function will find that chat.
    chatMessages.addChatRegion(
        guildMember.getGuildMemberId(),
        guildMember.getGuildMemberName(),
        0,
        false,
        true
    );
    chatMessages.setActiveChatTab("Personal");
    ChatWindowChangeNotifier().setChatWindowVisible(true);
  }

  removeGuildMember(GuildMember guildMember) {
    if (myRankId >= getRankId(guildMember.getGuildMemberRankName())) {
      showToastMessage("you can't remove a member with the same or higher rank as you");
      return;
    }
    AuthServiceGuild().removeMember(guildMember.getGuildMemberId(), widget.guild.getGuildId()).then((value) {
      if (value.getResult()) {
        widget.guild.getMembers().removeWhere((element) => element.getGuildMemberId() == guildMember.getGuildMemberId());
        setState(() {
          showToastMessage("member ${guildMember.getGuildMemberName()} removed from the Guild");
        });
      } else {
        showToastMessage(value.getMessage());
      }
    });
  }

  void _storePosition() {
    RenderBox box = guildSettingsKey.currentContext!.findRenderObject() as RenderBox;
    Offset position = box.localToGlobal(Offset.zero);
    position = position + const Offset(0, 50);
    _tapPosition = position;
  }

  changedSearch(String typedText) {
    if (typedText.isNotEmpty) {
      shownGuildMembers = widget.guild.getMembers()
          .where((element) => element.getGuildMemberName().toLowerCase()
          .contains(typedText.toLowerCase()))
          .toList();
    } else {
      shownGuildMembers = widget.guild.getMembers();
    }
    setState(() {});
  }

  Widget guildMemberInteraction(GuildMember guildMember, double avatarBoxSize, double guildMemberOptionWidth, double fontSize, bool isMe) {
    bool canRemove = true;
    if (myRankId >= getRankId(guildMember.getGuildMemberRankName())) {
      canRemove = false;
    }
    if (isMe) {
      return Container();
    } else {
      return SizedBox(
        width: guildMemberOptionWidth,
        height: 40,
        child: Row(
            children: [
              InkWell(
                  onTap: () {
                    setState(() {
                      messageFriend(guildMember);
                    });
                  },
                  child: Tooltip(
                      message: 'Message guild member',
                      child: addIcon(40, Icons.message, Colors.green)
                  )
              ),
              widget.guild.isAdministrator && canRemove ? const SizedBox(width: 10) : Container(),
              widget.guild.isAdministrator && canRemove ? InkWell(
                onTap: () {
                  setState(() {
                    removeGuildMember(guildMember);
                  });
                },
                child: Tooltip(
                  message: 'Remove guild member',
                  child: addIcon(40, Icons.person_remove, Colors.red),
                ),
              ) : Container(),
            ]
        ),
      );
    }
  }

  Widget guildMemberBox(GuildMember guildMember, double boxSize, double fontSize) {
    double newFriendOptionWidth = 100;
    double sidePadding = 40;
    if (!widget.normalMode) {
      boxSize = boxSize / 1.2;
      fontSize = fontSize / 1.8;
      sidePadding = 10;
    }
    if (!widget.guild.isAdministrator) {
      newFriendOptionWidth = 40;
    }
    bool isMe = false;
    if (widget.me != null) {
      if (widget.me!.getId() == guildMember.getGuildMemberId()) {
        isMe = true;
        newFriendOptionWidth = 0;
      }
    }

    String guildMemberName = guildMember.getGuildMemberName();
    Uint8List? guildMemberAvatar = guildMember.getGuildMemberAvatar();

    double crestTextSize = widget.overviewWidth - boxSize - newFriendOptionWidth - sidePadding - sidePadding;
    return Container(
      color: isMe ? Colors.blue : Colors.transparent,
      child: Row(
          children: [
            SizedBox(width: sidePadding),
            avatarBox(boxSize, boxSize, guildMemberAvatar),
            Column(
              children: [
                SizedBox(
                  width: crestTextSize,
                  child: Text(
                    guildMemberName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: fontSize * 2
                    )
                  )
                ),
                SizedBox(
                    width: crestTextSize,
                    child: Text(
                        guildMember.getGuildMemberRankName(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: fontSize
                        )
                    )
                )
              ],
            ),
            guildMemberInteraction(guildMember, boxSize, newFriendOptionWidth, fontSize, isMe),
            SizedBox(width: sidePadding),
          ]
      ),
    );
  }

  List<Widget> memberList(Guild guild) {
    List<Widget> members = [];
    List<GuildMember> guildMembers = guild.getMembers();
    if (shownGuildMembers != null) {
      guildMembers = shownGuildMembers!;
    }
    for (GuildMember member in guildMembers) {
      members.add(
          guildMemberBox(member, 70, widget.fontSize)
      );
    }

    return members;
  }

  resetSearch(Guild guild) {
    searchGuildMembersController.text = "";
    searchModeMembers = false;
    setState(() {
      shownGuildMembers = guild.getMembers();
    });
  }

  Widget searchGuildMembersField(double searchFieldWidth, double fontSize) {
    if (searchModeMembers) {
      return SizedBox(
        width: searchFieldWidth,
        height: 50,
        child: TextFormField(
          onTap: () {
            if (!_focusGuildMembersSearch.hasFocus) {
              _focusGuildMembersSearch.requestFocus();
            }
          },
          focusNode: _focusGuildMembersSearch,
          controller: searchGuildMembersController,
          textAlign: TextAlign.center,
          style: simpleTextStyle(fontSize),
          onChanged: (text) {
            changedSearch(text);
          },
          decoration: textFieldInputDecoration("Search for your guild member"),
        ),
      );
    } else {
      return Container();
    }
  }

  Widget guildOverviewContent(Guild guild) {
    String guildName = guild.getGuildName();

    double crestWidth = 200;
    double crestHeight = 225;
    double membersTextHeight = 30;
    double totalPadding = 25;
    double invitePlayerHeight = 40;
    double remainingHeight = widget.overviewHeight - crestHeight - membersTextHeight - invitePlayerHeight - totalPadding;
    if (remainingHeight <= 100) {
      remainingHeight = 100;
    }
    return Column(
        children: [
          Row(
            children: [
              guildAvatarBox(
                crestWidth,
                crestHeight,
                guild.getGuildCrest()
              ),
              SizedBox(width: 20),
              Container(
                width: widget.overviewWidth - crestWidth-20,
                height: crestHeight-100,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: RichText(
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: guildName,
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
                      ]
                    ),
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            "Your guild rank: ${guild.getMyGuildRank()}",
                            style: simpleTextStyle(widget.fontSize)
                        ),
                        Container(),
                      ]
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              "Guild score: ${guild.getGuildScore()}",
                              style: simpleTextStyle(widget.fontSize)
                          ),
                          IconButton(
                              key: guildSettingsKey,
                              iconSize: 40.0,
                              icon: const Icon(Icons.settings),
                              color: Colors.orangeAccent.shade200,
                              tooltip: 'Settings',
                              onPressed: _showPopupMenu
                          ),
                        ]
                    )
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                height: membersTextHeight,
                width: 200,
                child: Row(
                  children: [
                    Text(
                      "Members:",
                      style: simpleTextStyle(20),
                    ),
                  ],
                ),
              ),
              searchGuildMembersField(widget.overviewWidth - 250, widget.fontSize),
              GestureDetector(
                onTap: () {
                  searchModeMembers = !searchModeMembers;
                  if (searchModeMembers) {
                    _focusGuildMembersSearch.requestFocus();
                  } else {
                    resetSearch(widget.guild);
                  }
                  setState(() {});
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
            ]
          ),
          SizedBox(height: 20),
          Container(
            width: widget.overviewWidth,
            height: remainingHeight,
            child: SingleChildScrollView(
              child: Column(
                children: memberList(guild),
              ),
            ),
          ),
        ]
    );
  }

  Widget guildMemberRanksChanging() {
    return GuildWindowOverviewChangeRanks(
        key: UniqueKey(),
        game: widget.game,
        normalMode: widget.normalMode,
        overviewHeight: widget.overviewHeight,
        overviewWidth: widget.overviewWidth,
        fontSize: widget.fontSize,
        me: widget.me,
        guild: widget.guild,
        guildInformation: widget.guildInformation,
        leaveGuild: widget.leaveGuild
    );
  }

  Widget guildOverview() {
    return SizedBox(
        height: widget.overviewHeight,
        child: SingleChildScrollView(
          child: guildOverviewContent(widget.guild),
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: FractionalOffset.center,
      child: guildOverview(),
    );
  }
}

class GuildSettingPopup extends PopupMenuEntry<int> {

  final bool isAdministrator;

  const GuildSettingPopup({
    required Key key,
    required this.isAdministrator,
  }) : super(key: key);

  @override
  bool represents(int? n) => n == 1 || n == -1;

  @override
  GuildSettingPopupState createState() => GuildSettingPopupState();

  @override
  double get height => 1;
}

class GuildSettingPopupState extends State<GuildSettingPopup> {
  @override
  Widget build(BuildContext context) {
    return getPopupItems(context, widget.isAdministrator);
  }
}

void buttonLeaveGuild(BuildContext context) {
  Navigator.pop<int>(context, 0);
}

void buttonChangeGuildCrest(BuildContext context) {
  Navigator.pop<int>(context, 1);
}

Widget getPopupItems(BuildContext context, bool isAdministrator) {
  return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          child: TextButton(
              onPressed: () {
                buttonLeaveGuild(context);
              },
              child: Row(
                children:const [
                  Text(
                    'Leave guild',
                    textAlign: TextAlign.left,
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  )
                ] ,
              )
          ),
        ),
        isAdministrator ? Container(
          alignment: Alignment.centerLeft,
          child: TextButton(
              onPressed: () {
                buttonChangeGuildCrest(context);
              },
              child: Row(
                  children: const [
                    Text(
                      "Change guild crest",
                      textAlign: TextAlign.left,
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ]
              )
          ),
        ) : Container(),
      ]
  );
}
