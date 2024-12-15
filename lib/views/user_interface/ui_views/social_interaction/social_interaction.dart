import 'package:age_of_gold/age_of_gold.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../services/models/user.dart';
import '../../../../services/settings.dart';
import '../../../../services/socket_services.dart';
import '../../../../util/util.dart';
import '../../ui_util/chat_messages.dart';
import '../../ui_util/selected_tile_info.dart';
import '../chat_box/chat_box_change_notifier.dart';
import '../chat_window/chat_window_change_notifier.dart';
import '../friend_window/friend_window_change_notifier.dart';
import '../guild_window/guild_information.dart';
import '../guild_window/guild_window_change_notifier.dart';
import '../map_coordintes_window/map_coordinates_change_notifier.dart';
import '../profile_box/profile_change_notifier.dart';
import '../zoom_widget/zoom_widget_change_notifier.dart';


class SocialInteraction extends StatefulWidget {

  final AgeOfGold game;

  const SocialInteraction({
    required Key key,
    required this.game
  }) : super(key: key);

  @override
  SocialInteractionState createState() => SocialInteractionState();
}

class SocialInteractionState extends State<SocialInteraction> with TickerProviderStateMixin {

  late SelectedTileInfo selectedTileInfo;
  late ProfileChangeNotifier profileChangeNotifier;
  late FriendWindowChangeNotifier friendWindowChangeNotifier;
  SocketServices socket = SocketServices();
  Settings settings = Settings();

  int levelClock = 0;
  bool canChangeTiles = true;

  int rotateClockwiseOverviewState = 0;
  int rotateCounterClockwiseOverviewState = 0;
  int zoomOverviewState = 0;
  int mapCoordinateOverviewState = 0;
  int friendOverviewState = 0;
  int messageOverviewState = 0;
  int guildOverviewState = 0;

  bool unreadMessages = false;
  bool guildNotification = false;

  @override
  void initState() {
    super.initState();
    profileChangeNotifier = ProfileChangeNotifier();
    friendWindowChangeNotifier = FriendWindowChangeNotifier();
    profileChangeNotifier.addListener(socialInteractionListener);
    socket.addListener(socialInteractionListener);
  }

  checkUnreadMessages() {
    unreadMessages = ChatMessages().unreadPersonalMessages();
  }

  checkGuildInformation() {
    guildNotification = false;
    // First check if the user does not have a guild yet, but he does have some invites
    // Second check if the user is in a guild and there are new member requests
    User? me = Settings().getUser();
    if (me != null) {
      if (me.getGuild() == null && me.guildInvites.isNotEmpty) {
        setState(() {
          guildNotification = true;
        });
      }
      if (me.getGuild() != null) {
        if (GuildInformation().requestedMembers.isNotEmpty) {
          setState(() {
            guildNotification = true;
          });
        }
      }
    }
  }

  socketListener() {
    if (mounted) {
      updateInteractions();
    }
  }

  updateInteractions() {
    setState(() {
      friendWindowChangeNotifier.checkUnansweredFriendRequests(Settings().getUser());
      checkUnreadMessages();
      checkGuildInformation();
    });
  }

  socialInteractionListener() {
    if (mounted) {
      updateInteractions();
    }
  }

  rotateClockwise() {
    int currentRotation = settings.getRotation();
    currentRotation -= 1;
    if (currentRotation < 0) {
      currentRotation += 12;
    }
    settings.setRotation(currentRotation);
    widget.game.rotateWorld(currentRotation);
  }

  rotateCounterClockwise() {
    int currentRotation = settings.getRotation();
    currentRotation += 1;
    if (currentRotation >= 12) {
      currentRotation -= 12;
    }
    settings.setRotation(currentRotation);
    widget.game.rotateWorld(currentRotation);
  }

  showZoomWindow() {
    ZoomWidgetChangeNotifier().setZoomWidgetVisible(true);
  }

  showMapCoordinatesWindow() {
    MapCoordinatesWindowChangeNotifier().setMapCoordinatesVisible(true);
  }

  showFriendWindow() {
    FriendWindowChangeNotifier().setFriendWindowVisible(true);
  }

  showChatWindow() {
    ChatBoxChangeNotifier().setChatBoxVisible(false);
    ChatWindowChangeNotifier().setChatWindowVisible(true);
  }

  showGuildWindow() {
    GuildWindowChangeNotifier().setGuildWindowVisible(true);
  }

  Widget rotateCounterClockwiseButton(double counterClockwiseButtonSize) {
    return SizedBox(
      child: Row(
          children: [
            const SizedBox(width: 5),
            Tooltip(
              message: "Rotate right",
              child: InkWell(
                onHover: (value) {
                  setState(() {
                    rotateCounterClockwiseOverviewState = value ? 1 : 0;
                  });
                },
                onTap: () {
                  setState(() {
                    rotateCounterClockwiseOverviewState = 2;
                    rotateCounterClockwise();
                    Future.delayed(const Duration(milliseconds: 500), () {
                      setState(() {
                        rotateCounterClockwiseOverviewState = 0;
                      });
                    });
                  });
                },
                child: Stack(
                  children: [
                    SizedBox(
                      width: counterClockwiseButtonSize,
                      height: counterClockwiseButtonSize,
                      child: ClipOval(
                          child: Material(
                            color: overviewColour(rotateCounterClockwiseOverviewState, Colors.orange, Colors.orangeAccent, Colors.orange.shade800),
                          )
                      ),
                    ),
                    SizedBox(
                      width: counterClockwiseButtonSize,
                      height: counterClockwiseButtonSize,
                      child: Icon(
                        size: (counterClockwiseButtonSize/5) * 3,
                        Icons.rotate_right,
                        color: Colors.white,
                        shadows: const <Shadow>[Shadow(color: Colors.black, blurRadius: 3.0)],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ]
      ),
    );
  }

  Widget rotateClockwiseButton(double clockwiseButtonSize) {
    return SizedBox(
      child: Row(
          children: [
            const SizedBox(width: 5),
            Tooltip(
              message: "Rotate left",
              child: InkWell(
                onHover: (value) {
                  setState(() {
                    rotateClockwiseOverviewState = value ? 1 : 0;
                  });
                },
                onTap: () {
                  setState(() {
                    rotateClockwiseOverviewState = 2;
                    rotateClockwise();
                    Future.delayed(const Duration(milliseconds: 500), () {
                      setState(() {
                        rotateClockwiseOverviewState = 0;
                      });
                    });
                  });
                },
                child: Stack(
                  children: [
                    SizedBox(
                      width: clockwiseButtonSize,
                      height: clockwiseButtonSize,
                      child: ClipOval(
                          child: Material(
                            color: overviewColour(rotateClockwiseOverviewState, Colors.orange, Colors.orangeAccent, Colors.orange.shade800),
                          )
                      ),
                    ),
                    SizedBox(
                      width: clockwiseButtonSize,
                      height: clockwiseButtonSize,
                      child: Icon(
                        size: (clockwiseButtonSize/5) * 3,
                        Icons.rotate_left,
                        color: Colors.white,
                        shadows: const <Shadow>[Shadow(color: Colors.black, blurRadius: 3.0)],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ]
      ),
    );
  }

  Widget zoomButton(double zoomButtonSize) {
    return SizedBox(
      child: Row(
          children: [
            const SizedBox(width: 5),
            Tooltip(
              message: "Zoom in or out",
              child: InkWell(
                onHover: (value) {
                  setState(() {
                    zoomOverviewState = value ? 1 : 0;
                  });
                },
                onTap: () {
                  setState(() {
                    zoomOverviewState = 2;
                    showZoomWindow();
                    Future.delayed(const Duration(milliseconds: 500), () {
                      setState(() {
                        zoomOverviewState = 0;
                      });
                    });
                  });
                },
                child: Stack(
                  children: [
                    SizedBox(
                      width: zoomButtonSize,
                      height: zoomButtonSize,
                      child: ClipOval(
                          child: Material(
                            color: overviewColour(zoomOverviewState, Colors.orange, Colors.orangeAccent, Colors.orange.shade800),
                          )
                      ),
                    ),
                    SizedBox(
                      width: zoomButtonSize,
                      height: zoomButtonSize,
                      child: Icon(
                        size: (zoomButtonSize/5) * 3,
                        Icons.zoom_in,
                        color: Colors.white,
                        shadows: const <Shadow>[Shadow(color: Colors.black, blurRadius: 3.0)],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ]
      ),
    );
  }

  Widget mapCoordinatesButton(double mapCoordinateButtonSize) {
    return SizedBox(
      child: Row(
          children: [
            const SizedBox(width: 5),
            Tooltip(
              message: "Jump to coordinates",
              child: InkWell(
                onHover: (value) {
                  setState(() {
                    mapCoordinateOverviewState = value ? 1 : 0;
                  });
                },
                onTap: () {
                  setState(() {
                    mapCoordinateOverviewState = 2;
                    showMapCoordinatesWindow();
                    Future.delayed(const Duration(milliseconds: 500), () {
                      setState(() {
                        mapCoordinateOverviewState = 0;
                      });
                    });
                  });
                },
                child: Stack(
                  children: [
                    SizedBox(
                      width: mapCoordinateButtonSize,
                      height: mapCoordinateButtonSize,
                      child: ClipOval(
                          child: Material(
                            color: overviewColour(mapCoordinateOverviewState, Colors.orange, Colors.orangeAccent, Colors.orange.shade800),
                          )
                      ),
                    ),
                    SizedBox(
                      width: mapCoordinateButtonSize,
                      height: mapCoordinateButtonSize,
                      child: Icon(
                        size: (mapCoordinateButtonSize/5) * 3,
                        Icons.location_on,
                        color: Colors.white,
                        shadows: const <Shadow>[Shadow(color: Colors.black, blurRadius: 3.0)],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ]
      ),
    );
  }

  Widget friendOverviewButton(double profileButtonSize) {
    return SizedBox(
      child: Row(
        children: [
          const SizedBox(width: 5),
          Tooltip(
            message: "Socials",
            child: InkWell(
              onHover: (value) {
                setState(() {
                  friendOverviewState = value ? 1 : 0;
                });
              },
              onTap: () {
                setState(() {
                  friendOverviewState = 2;
                  showFriendWindow();
                  Future.delayed(const Duration(milliseconds: 500), () {
                    setState(() {
                      friendOverviewState = 0;
                    });
                  });
                });
              },
              child: Stack(
                children: [
                  SizedBox(
                    width: profileButtonSize,
                    height: profileButtonSize,
                    child: ClipOval(
                      child: Material(
                        color: overviewColour(friendOverviewState, Colors.orange, Colors.orangeAccent, Colors.orange.shade800),
                      )
                    ),
                  ),
                  Image.asset(
                    "assets/images/ui/icon/friend_icon_clean.png",
                    width: profileButtonSize,
                    height: profileButtonSize,
                  ),
                  friendWindowChangeNotifier.unansweredFriendRequests ? Image.asset(
                    "assets/images/ui/icon/update_notification.png",
                    width: profileButtonSize,
                    height: profileButtonSize,
                  ) : Container(),
                ],
              ),
            ),
          ),
        ]
      ),
    );
  }

  Widget messageOverviewButton(double messageButtonSize) {
    return SizedBox(
      child: Row(
          children: [
            const SizedBox(width: 5),
            Tooltip(
              message: "messages",
              child: InkWell(
                onHover: (value) {
                  setState(() {
                    messageOverviewState = value ? 1 : 0;
                  });
                },
                onTap: () {
                  setState(() {
                    messageOverviewState = 2;
                    showChatWindow();
                    Future.delayed(const Duration(milliseconds: 500), () {
                      setState(() {
                        messageOverviewState = 0;
                      });
                    });
                  });
                },
                child: Stack(
                  children: [
                    SizedBox(
                      width: messageButtonSize,
                      height: messageButtonSize,
                      child: ClipOval(
                          child: Material(
                            color: overviewColour(messageOverviewState, Colors.orange, Colors.orangeAccent, Colors.orange.shade800),
                          )
                      ),
                    ),
                    Image.asset(
                      "assets/images/ui/icon/message_icon_clean.png",
                      width: messageButtonSize,
                      height: messageButtonSize,
                    ),
                    unreadMessages ? Image.asset(
                      "assets/images/ui/icon/update_notification.png",
                      width: messageButtonSize,
                      height: messageButtonSize,
                    ) : Container(),
                  ],
                ),
              ),
            ),
          ]
      ),
    );
  }

  Widget guildOverviewButton(double guildButtonSize) {
    bool inAGuild = false;
    User? me = Settings().getUser();
    if (me != null) {
      if (me.guild != null) {
        inAGuild = true;
      }
    }
    return SizedBox(
      child: Row(
          children: [
            const SizedBox(width: 5),
            Tooltip(
              message: "guild",
              child: InkWell(
                onHover: (value) {
                  setState(() {
                    guildOverviewState = value ? 1 : 0;
                  });
                },
                onTap: () {
                  setState(() {
                    guildOverviewState = 2;
                    showGuildWindow();
                    Future.delayed(const Duration(milliseconds: 500), () {
                      setState(() {
                        guildOverviewState = 0;
                      });
                    });
                  });
                },
                child: Stack(
                  children: [
                    SizedBox(
                      width: guildButtonSize,
                      height: guildButtonSize,
                      child: ClipOval(
                          child: Material(
                            color: inAGuild
                                ? overviewColour(guildOverviewState, Colors.orange, Colors.orangeAccent, Colors.orange.shade800)
                                : overviewColour(guildOverviewState, Colors.grey, Colors.grey.shade400, Colors.grey.shade800)
                          )
                      ),
                    ),
                    Image.asset(
                      "assets/images/ui/icon/guild_icon_clean.png",
                      width: guildButtonSize,
                      height: guildButtonSize,
                    ),
                    guildNotification ? Image.asset(
                      "assets/images/ui/icon/update_notification.png",
                      width: guildButtonSize,
                      height: guildButtonSize,
                    ) : Container(),
                  ],
                ),
              ),
            ),
          ]
      ),
    );
  }

  Widget profileOverviewNormal(double profileOverviewHeight, double fontSize) {
    double statusBarPadding = MediaQuery.of(context).viewPadding.top;
    double profileAvatarHeight = 100 + statusBarPadding;
    bool showSocials = true;
    if (Settings().getUser() == null || !kIsWeb) {
      // Don't show social buttons when not logged in or on mobile
      showSocials = false;
    }
    return SizedBox(
      child: Row(
        children: [
          Column(
              children: [
                SizedBox(height: profileAvatarHeight),
                const SizedBox(height: 10),
                mapCoordinatesButton(50),
                const SizedBox(height: 10),
                rotateCounterClockwiseButton(50),
                const SizedBox(height: 10),
                rotateClockwiseButton(50),
                const SizedBox(height: 10),
                zoomButton(50),
              ]
          ),
          SizedBox(width: 5),
          showSocials ? Column(
            children: [
              SizedBox(height: profileAvatarHeight),
              const SizedBox(height: 10),
              friendOverviewButton(50),
              const SizedBox(height: 10),
              messageOverviewButton(50),
              const SizedBox(height: 10),
              guildOverviewButton(50)
            ]
          ) : Container(),
        ],
      ),
    );
  }

  Widget profileOverviewMobile(double fontSize) {
    bool showSocials = true;
    if (Settings().getUser() == null || !kIsWeb) {
      // Don't show social buttons when not logged in or on mobile
      showSocials = false;
    }
    double statusBarPadding = MediaQuery.of(context).viewPadding.top;
    double totalWidth = MediaQuery.of(context).size.width;
    return SizedBox(
      width: totalWidth/2,
      child: Column(
        children: [
          SizedBox(height: statusBarPadding+5),
          Row(
              children: [
                const SizedBox(width: 5),
                mapCoordinatesButton(30),
                const SizedBox(width: 5),
                rotateCounterClockwiseButton(30),
                const SizedBox(width: 5),
                rotateClockwiseButton(30),
                const SizedBox(width: 5),
                zoomButton(30),
              ]
          ),
          const SizedBox(height: 5),
          showSocials ? Row(
            children: [
              const SizedBox(width: 5),
              friendOverviewButton(30),
              const SizedBox(width: 5),
              messageOverviewButton(30),
              const SizedBox(width: 5),
              guildOverviewButton(30)
            ]
          ) : Container(),
        ]
      ),
    );
  }

  bool normalMode = true;
  Widget tileBoxWidget() {
    // button width + padding
    double profileOverviewWidth = 50 + 5;
    double fontSize = 16;
    // We use the total height to hide the chatbox below
    // In NormalMode the height has the 4 buttons and some padding added.
    double profileOverviewHeight = 100;
    profileOverviewHeight += 50;
    profileOverviewHeight += 10;
    profileOverviewHeight += 50;
    profileOverviewHeight += 10;
    profileOverviewHeight += 50;
    profileOverviewHeight += 10;
    profileOverviewHeight += 50;
    profileOverviewHeight += 10;
    normalMode = true;
    double statusBarPadding = MediaQuery.of(context).viewPadding.top;

    bool showSocials = true;
    if (Settings().getUser() == null || !kIsWeb) {
      // Don't show social buttons when not logged in or on mobile
      showSocials = false;
    }
    if (MediaQuery.of(context).size.width <= 800 && (MediaQuery.of(context).size.width < MediaQuery.of(context).size.height)) {
      profileOverviewWidth = MediaQuery.of(context).size.width/2;
      profileOverviewWidth += 30;
      profileOverviewWidth += 10;
      profileOverviewWidth += 30;
      profileOverviewWidth += 10;
      profileOverviewWidth += 30;
      profileOverviewWidth += 10;
      profileOverviewWidth += 30;
      profileOverviewWidth += 10;

      profileOverviewHeight = (30 * 2) + statusBarPadding + (5 * 2);

      normalMode = false;
      if (!showSocials) {
        // No user logged in so there is 1 row less visible.
        profileOverviewHeight = (15 * 2) + statusBarPadding + (5 * 2);
      }
    } else {
      if (!showSocials) {
        profileOverviewWidth = 25 + 5;
      }
    }

    profileOverviewWidth = (profileOverviewWidth * 2) + 5;
    profileOverviewHeight += statusBarPadding;

    return SingleChildScrollView(
      child: SizedBox(
        width: profileOverviewWidth,
        height: profileOverviewHeight,
        child: Align(
          alignment: normalMode ? FractionalOffset.topLeft : FractionalOffset.topRight,
          child: normalMode
              ? profileOverviewNormal(profileOverviewHeight, fontSize)
              : profileOverviewMobile(fontSize)
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return tileBoxWidget();
  }
}

