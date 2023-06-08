import 'package:age_of_gold/age_of_gold.dart';
import 'package:age_of_gold/services/auth_service_social.dart';
import 'package:age_of_gold/services/models/friend.dart';
import 'package:age_of_gold/services/models/user.dart';
import 'package:age_of_gold/services/settings.dart';
import 'package:age_of_gold/services/socket_services.dart';
import 'package:age_of_gold/util/render_objects.dart';
import 'package:age_of_gold/util/util.dart';
import 'package:age_of_gold/views/user_interface/ui_util/chat_messages.dart';
import 'package:age_of_gold/views/user_interface/ui_util/clear_ui.dart';
import 'package:age_of_gold/views/user_interface/ui_views/chat_window/chat_window_change_notifier.dart';
import 'package:age_of_gold/views/user_interface/ui_views/friend_window/friend_window_change_notifier.dart';
import 'package:age_of_gold/views/user_interface/ui_views/profile_box/profile_change_notifier.dart';
import 'package:flutter/material.dart';


class FriendWindow extends StatefulWidget {

  final AgeOfGold game;

  const FriendWindow({
    required Key key,
    required this.game
  }) : super(key: key);

  @override
  FriendWindowState createState() => FriendWindowState();
}

class FriendWindowState extends State<FriendWindow> {

  final FocusNode _focusFriendWindow = FocusNode();
  bool showFriendWindow = false;
  bool socialView = true;
  bool addFriendView = false;

  bool normalMode = true;

  late FriendWindowChangeNotifier friendWindowChangeNotifier;

  final FocusNode _focusAdd = FocusNode();
  TextEditingController addController = TextEditingController();
  final GlobalKey<FormState> addFriendKey = GlobalKey<FormState>();

  Friend? possibleNewFriend;
  bool nothingFound = false;

  int detailAddFriendColour = 0;
  int detailRequestColour = 0;
  int detailFriendColour = 2;

  SocketServices socket = SocketServices();

  bool unansweredFriendRequests = false;

  String headerText = "Social";

  @override
  void initState() {
    friendWindowChangeNotifier = FriendWindowChangeNotifier();
    friendWindowChangeNotifier.addListener(friendWindowChangeListener);

    _focusFriendWindow.addListener(_onFocusChange);
    _focusAdd.addListener(_onFocusAddFriendChange);

    socket.checkFriends();
    socket.addListener(socketListener);
    checkUnansweredFriendRequests();
    super.initState();
  }

  socketListener() {
    if (mounted) {
      checkUnansweredFriendRequests();
      setState(() {});
    }
  }

  checkUnansweredFriendRequests() {
    unansweredFriendRequests = false;
    if (Settings().getUser() != null) {
      User currentUser = Settings().getUser()!;
      for (Friend friend in currentUser.friends) {
        if (!friend.isAccepted() && friend.requested != null && friend.requested == false) {
          unansweredFriendRequests = true;
          break;
        }
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  _onFocusAddFriendChange() {
    widget.game.profileFocus(_focusAdd.hasFocus);
  }

  friendWindowChangeListener() {
    if (mounted) {
      if (!showFriendWindow && friendWindowChangeNotifier.getFriendWindowVisible()) {
        socialView = true;
        addFriendView = false;
        headerText = "Friend List";
        // If the user has no friends to show yet, we show the request view
        User? me = Settings().getUser();
        if (me != null && me.friends.isNotEmpty) {
          if (me.friends.every((friend) => !friend.isAccepted())) {
            headerText = "Friend Requests";
            socialView = false;
            addFriendView = false;
            detailAddFriendColour = 0;
            detailRequestColour = 2;
            detailFriendColour = 0;
          }
        }
        setState(() {
          showFriendWindow = true;
        });
      }
      if (showFriendWindow && !friendWindowChangeNotifier.getFriendWindowVisible()) {
        setState(() {
          headerText = "Social";
          showFriendWindow = false;
          socialView = true;
          addFriendView = false;
          detailAddFriendColour = 0;
          detailRequestColour = 0;
          detailFriendColour = 2;
          possibleNewFriend = null;
          addController.text = "";
        });
      }
    }
  }

  void _onFocusChange() {
    widget.game.friendWindowFocus(_focusFriendWindow.hasFocus);
  }

  goBack() {
    setState(() {
      if (addFriendView) {
        addFriendView = false;
      } else {
        FriendWindowChangeNotifier().setFriendWindowVisible(false);
      }
    });
  }

  searchForFriend(String possibleFriend) {
    print("searching for friend $possibleFriend");
    AuthServiceSocial().searchPossibleFriend(possibleFriend).then((value) {
      print("search result $value");
      if (value != null) {
        print("found friend");
        nothingFound = false;
        setState(() {
          possibleNewFriend = Friend(false, null, value);
        });
      } else {
        setState(() {
          nothingFound = true;
        });
      }
    });
  }

  cancelFriendRequest(Friend friend) {
    print("cancel request!");
    AuthServiceSocial().denyRequest(friend.getUser()!.getUserName()).then((value) {
      if (value.getResult()) {
        setState(() {
          User? currentUser = Settings().getUser();
          if (currentUser != null) {
            currentUser.removeFriend(friend.getUser()!.getUserName());
          }
        });
      } else {
        showToastMessage("something went wrong");
      }
    });
  }

  addFriend(Friend friend) {
    AuthServiceSocial().addFriend(friend.getUser()!.getUserName()).then((value) {
      if (value.getResult()) {
        User? currentUser = Settings().getUser();
        if (value.getMessage() == "success") {
          if (currentUser != null) {
            friend.setRequested(true);
            currentUser.addFriend(friend);
            checkUnansweredFriendRequests();
            setState(() {
              headerText = "Friend Requests";
              socialView = false;
              addFriendView = false;
              detailRequestColour = 2;
              detailFriendColour = 0;
              detailAddFriendColour = 0;
              possibleNewFriend = null;
              addController.text = "";
            });
          }
          showToastMessage("Friend request sent to ${friend.getUser()!.getUserName()}");
        } else if (value.getMessage() == "request already sent") {
          showToastMessage("Friend request has already been sent to ${friend.getUser()!.getUserName()}");
        } else if (value.getMessage() == "They are now friends") {
          setState(() {
            friend.setAccepted(true);
            friend.setRequested(false);
            currentUser!.addFriend(friend);
            checkUnansweredFriendRequests();
            socialView = true;
            addFriendView = false;
            headerText = "Friend List";
            detailRequestColour = 0;
            detailFriendColour = 2;
            detailAddFriendColour = 0;
            showToastMessage("You are now friends with ${friend.getUser()!.getUserName()}");
            ProfileChangeNotifier profileChangeNotifier = ProfileChangeNotifier();
            profileChangeNotifier.setProfileVisible(false);
            profileChangeNotifier.notify();
          });
        } else {
          showToastMessage(value.getMessage());
        }
      } else {
        showToastMessage("something went wrong");
      }
    }).onError((error, stackTrace) {
      showToastMessage(error.toString());
    });
  }

  acceptRequest(Friend friend) {
    AuthServiceSocial().acceptRequest(friend.getUser()!.getUserName()).then((value) {
      if (value.getResult()) {
        setState(() {
          friend.setAccepted(true);
          checkUnansweredFriendRequests();
          socialView = true;
          addFriendView = false;
          headerText = "Friend List";
          detailRequestColour = 0;
          detailFriendColour = 2;
          detailAddFriendColour = 0;
        });
        showToastMessage("You are now friends with ${friend.getUser()!.getUserName()}");
        ProfileChangeNotifier profileChangeNotifier = ProfileChangeNotifier();
        profileChangeNotifier.setProfileVisible(false);
        profileChangeNotifier.notify();
      } else {
        showToastMessage("something went wrong");
      }
    }).onError((error, stackTrace) {
      showToastMessage(error.toString());
    });
  }

  messageFriend(Friend friend) {
    ClearUI().clearUserInterfaces();
    ChatMessages chatMessages = ChatMessages();
    chatMessages.addChatRegion(
        friend.getUser()!.getUserName(),
        friend.getUser()!.getId(),
        friend.unreadMessages!,
        friend.isAccepted()
    );
    chatMessages.setActiveChatTab("Personal");
    ChatWindowChangeNotifier().setChatWindowVisible(true);
  }

  Widget friendWindowHeader(double headerWidth, double headerHeight, double fontSize) {
    if (addFriendView) {
      headerText = "Add Friend";
    }
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(),
          SizedBox(
              height: headerHeight,
              child: Text(
                headerText,
                style: simpleTextStyle(fontSize),
              )
          ),
          SizedBox(
            height: headerHeight,
            child: IconButton(
              icon: const Icon(Icons.close),
              color: Colors.orangeAccent.shade200,
              tooltip: 'cancel',
              onPressed: () {
                goBack();
              }
            ),
          ),
        ]
    );
  }

  Widget receivedOrRequested(double friendWindowWidth, double fontSize, bool requested) {
    if (requested) {
      return Container(
        width: friendWindowWidth,
        height: 30,
        child: Text(
            "Send requests",
            style: TextStyle(
                color: Colors.white,
                fontSize: fontSize * 1.5
            )
        ),
      );
    } else {
      return Container(
        width: friendWindowWidth,
        height: 30,
        child: Text(
            "Received requests",
            style: TextStyle(
                color: Colors.white,
                fontSize: fontSize * 1.5
            )
        ),
      );
    }
  }

  Widget requestBox(double friendWindowWidth, double requestBoxHeight, double fontSize) {
    List<Friend> befriended = [];
    if (Settings().getUser() != null) {
      befriended = Settings().getUser()!.getFriends();
    }
    if (befriended.isNotEmpty) {
      List<Friend> requestedFriends = befriended.where((friend) => !friend.isAccepted() && friend.requested == true).toList();
      List<Friend> gotRequestedFriends = befriended.where((friend) => !friend.isAccepted() && friend.requested == false).toList();
      if (requestedFriends.isNotEmpty && gotRequestedFriends.isNotEmpty) {
        return Column(
          children: [
            receivedOrRequested(friendWindowWidth, fontSize, false),
            SizedBox(
              height: requestBoxHeight/2 - 30,
              child: SingleChildScrollView(
                child: Column(
                  children: friendList(friendWindowWidth, fontSize, false),
                ),
              ),
            ),
            receivedOrRequested(friendWindowWidth, fontSize, true),
            SizedBox(
              height: requestBoxHeight/2 - 30,
              child: SingleChildScrollView(
                child: Column(
                  children: friendList(friendWindowWidth, fontSize, true),
                ),
              ),
            ),
          ],
        );
      } else if ((requestedFriends.isEmpty && gotRequestedFriends.isNotEmpty)
          || (requestedFriends.isNotEmpty && gotRequestedFriends.isEmpty)) {
        return Column(
          children: [
            receivedOrRequested(friendWindowWidth, fontSize, requestedFriends.isNotEmpty),
            SizedBox(
              height: requestBoxHeight - 30,
              child: SingleChildScrollView(
                child: Column(
                  children: friendList(friendWindowWidth, fontSize, requestedFriends.isNotEmpty),
                ),
              ),
            ),
          ]
        );
      }
      return Container(height: requestBoxHeight);
    }
    return Container(height: requestBoxHeight);
  }

  Widget friendRequestWindow(double friendWindowWidth, double friendWindowHeight, double fontSize) {
    double iconSize = 50;
    if (!normalMode) {
      iconSize = 30;
    }
    return Column(
      children: [
        SizedBox(
          width: friendWindowWidth,
          height: friendWindowHeight - iconSize,
          child: SingleChildScrollView(
            child: Column(
              children: [
                requestBox(friendWindowWidth, friendWindowHeight - iconSize, fontSize),
              ]
            ),
          ),
        ),
        SizedBox(
          width: friendWindowWidth,
          height: iconSize,
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                friendListButton(friendWindowWidth / 3, fontSize, iconSize),
                friendRequestButton(friendWindowWidth / 3, fontSize, iconSize),
                addFriendButton(friendWindowWidth / 3, fontSize, iconSize),
              ]
          ),
        )
      ],
    );
  }

  Widget addIcon(double profileButtonSize, IconData icon, Color iconColour) {
    return SizedBox(
      width: profileButtonSize,
      height: profileButtonSize,
      child: ClipOval(
        child: Material(
          color: iconColour,
          child: Icon(icon)
        ),
      ),
    );
  }

  Color getDetailColour(int detailColour) {
    if (detailColour == 0) {
      return Colors.cyan.shade600;
    } else if (detailColour == 1) {
      return Colors.cyan.shade700;
    } else {
      return Colors.cyan.shade300;
    }
  }

  Widget addFriendButton(double addFriendButtonWidth, double fontSize, double iconSize) {
    return InkWell(
      onTap: () {
        setState(() {
          addFriendView = true;
          headerText = "Add Friend";
          detailAddFriendColour = 2;
          detailFriendColour = 0;
          detailRequestColour = 0;
        });
      },
      onHover: (hovering) {
        setState(() {
          if (hovering) {
            detailAddFriendColour = 1;
          } else {
            if (addFriendView) {
              detailAddFriendColour = 2;
            } else {
              detailAddFriendColour = 0;
            }
          }
        });
      },
      child: Container(
        width: addFriendButtonWidth,
        height: iconSize,
        color: getDetailColour(detailAddFriendColour),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(width: 1),
              Row(
                children: [
                  addIcon(iconSize, Icons.add, Colors.orange),
                  SizedBox(width: 5),
                  Text(
                    "Add new friend",
                    style: simpleTextStyle(
                      fontSize,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 1),
            ]
        ),
      ),
    );
  }

  Widget friendListButton(double friendListWidth, double fontSize, double iconSize) {
    return InkWell(
      onTap: () {
        setState(() {
          headerText = "Friend List";
          detailFriendColour = 2;
          socialView = true;
          addFriendView = false;
          detailAddFriendColour = 0;
          detailRequestColour = 0;
        });
      },
      onHover: (hovering) {
        setState(() {
          if (hovering) {
            detailFriendColour = 1;
          } else {
            if (socialView && !addFriendView) {
              detailFriendColour = 2;
            } else {
              detailFriendColour = 0;
            }
          }
        });
      },
      child: Container(
        width: friendListWidth,
        height: iconSize,
        color: getDetailColour(detailFriendColour),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(width: 1),
              Row(
                children: [
                  addIcon(iconSize, Icons.people, Colors.orange),
                  SizedBox(width: 5),
                  Text(
                    "Friend list",
                    style: simpleTextStyle(
                      fontSize,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 1),
            ]
        ),
      ),
    );
  }

  Widget friendRequestButton(double friendRequestWidth, double fontSize, double iconSize) {
    return InkWell(
      onTap: () {
        setState(() {
          headerText = "Friend Requests";
          detailRequestColour = 2;
          socialView = false;
          addFriendView = false;
          detailAddFriendColour = 0;
          detailFriendColour = 0;
        });
      },
      onHover: (hovering) {
        setState(() {
          if (hovering) {
            detailRequestColour = 1;
          } else {
            if (!socialView && !addFriendView) {
              detailRequestColour = 2;
            } else {
              detailRequestColour = 0;
            }
          }
        });
      },
      child: Container(
        width: friendRequestWidth,
        height: iconSize,
        color: getDetailColour(detailRequestColour),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(width: 1),
              Stack(
                children: [
                  Row(
                    children: [
                      addIcon(iconSize, Icons.person_add_alt_1, Colors.orange),
                      SizedBox(width: 5),
                      Text(
                        "Friend Requests",
                        style: simpleTextStyle(
                          fontSize,
                        ),
                      ),
                    ],
                  ),
                  unansweredFriendRequests ? Image.asset(
                    "assets/images/ui/icon/update_notification.png",
                    width: iconSize,
                    height: iconSize,
                  ) : Container(),
                ]
              ),
              SizedBox(width: 1),
            ]
        ),
      ),
    );
  }

  List<Widget> friendList(double friendWindowWidth, double fontSize, bool? requested) {
    List<Friend> befriended = [];
    if (Settings().getUser() != null) {
      befriended = Settings().getUser()!.getFriends();
    }

    List<Widget> friends = [];
    if (befriended.isNotEmpty) {
      if (requested == null) {
        befriended = befriended.where((friend) => friend.isAccepted()).toList();
      } else {
        befriended = befriended.where((friend) => !friend.isAccepted() && friend.requested == requested).toList();
      }
      for (Friend friend in befriended) {
        friends.add(
            friendBox(friend, 70, friendWindowWidth, fontSize)
        );
      }
    }

    return friends;
  }

  Widget socialWindow(double friendWindowWidth, double friendWindowHeight, double fontSize) {
    double iconSize = 50;
    if (!normalMode) {
      iconSize = 30;
    }
    return Column(
      children: [
        SizedBox(
          width: friendWindowWidth,
          height: friendWindowHeight - iconSize,
          child: SingleChildScrollView(
            child: Column(
              children: friendList(friendWindowWidth, fontSize, null),
            ),
          ),
        ),
        SizedBox(
          width: friendWindowWidth,
          height: iconSize,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              friendListButton(friendWindowWidth / 3, fontSize, iconSize),
              friendRequestButton(friendWindowWidth / 3, fontSize, iconSize),
              addFriendButton(friendWindowWidth / 3, fontSize, iconSize),
            ]
          ),
        )
      ],
    );
  }

  Widget friendInteraction(Friend friend, double avatarBoxSize, double newFriendOptionWidth, double fontSize) {
    if (friend.isAccepted()) {
      // friend is a true friend
      return Container(
        width: newFriendOptionWidth,
        height: 40,
        child: Row(
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    messageFriend(friend);
                  });
                },
                child: Tooltip(
                  message: 'Message user',
                  child: addIcon(40, Icons.message, Colors.green)
                )
              ),
              SizedBox(width: 10),
              InkWell(
                onTap: () {
                  setState(() {
                    cancelFriendRequest(friend);
                  });
                },
                child: Tooltip(
                  message: 'Remove friend',
                  child: addIcon(40, Icons.person_remove, Colors.red),
                ),
              ),
            ]
        ),
      );
    } else if (friend.isRequested() == null) {
      return Container(
          width: newFriendOptionWidth,
          height: 40,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                addFriend(friend);
              });
            },
            child: Text(
              "Add!",
              style: simpleTextStyle(
                fontSize,
              ),
            ),
          )
      );
    } else if (friend.isRequested()!) {
      // friend has requested you
      return Container(
        width: newFriendOptionWidth,
        height: 40,
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              cancelFriendRequest(friend);
            });
          },
          child: Text(
            "Cancel",
            style: simpleTextStyle(
              fontSize,
            ),
          ),
        )
      );
    } else if (!friend.isRequested()!) {
      // you have requested friend
      return Container(
        width: newFriendOptionWidth,
        height: 40,
        child: Row(
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  acceptRequest(friend);
                });
              },
              child: Tooltip(
                message: 'Accept request',
                child: addIcon(40, Icons.check, Colors.green)
              ),
            ),
            SizedBox(width: 10),
            InkWell(
              onTap: () {
                setState(() {
                  cancelFriendRequest(friend);
                });
              },
              child: Tooltip(
                message: 'Deny request',
                child: addIcon(40, Icons.close, Colors.red),
              ),
            ),
          ]
        ),
      );
    }
    return Container();
  }

  Widget friendBox(Friend? newFriendOption, double avatarBoxSize, double addFriendWindowWidth, double fontSize) {
    double newFriendOptionWidth = 100;
    double sidePadding = 40;
    if (!normalMode) {
      avatarBoxSize = avatarBoxSize / 1.2;
      fontSize = fontSize / 1.8;
      sidePadding = 10;
    }
    if (newFriendOption != null) {
      return Row(
        children: [
          SizedBox(width: sidePadding),
          avatarBox(avatarBoxSize, avatarBoxSize, newFriendOption.getUser()!.getAvatar()!),
          Container(
            width: addFriendWindowWidth - avatarBoxSize - newFriendOptionWidth - sidePadding - sidePadding,
            child: Text(
                newFriendOption.getUser()!.getUserName(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize * 2
              )
            )
          ),
          friendInteraction(newFriendOption, avatarBoxSize, newFriendOptionWidth, fontSize),
          SizedBox(width: sidePadding),
        ]
      );
    } else {
      if (nothingFound) {
        return Text(
          "No friend found with that name",
          style: simpleTextStyle(fontSize),
        );
      } else {
        return Container();
      }
    }
  }

  Widget addFriendWindow(double addFriendWindowWidth, double addFriendWindowHeight, double fontSize) {
    double iconSize = 50;
    if (!normalMode) {
      iconSize = 30;
    }
    return Column(
      children: [
        SizedBox(
          width: addFriendWindowWidth,
          height: addFriendWindowHeight - iconSize,
          child: SingleChildScrollView(
            child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(width: 10),
                      SizedBox(
                        width: addFriendWindowWidth - 150,
                        height: 50,
                        child: Form(
                          key: addFriendKey,
                          child: TextFormField(
                            onTap: () {
                              if (!_focusAdd.hasFocus) {
                                _focusAdd.requestFocus();
                              }
                            },
                            validator: (val) {
                              return val == null || val.isEmpty
                                  ? "Please enter the name of a friend to add"
                                  : null;
                            },
                            onFieldSubmitted: (value) {
                              searchForFriend(value);
                            },
                            focusNode: _focusAdd,
                            controller: addController,
                            textAlign: TextAlign.center,
                            style: simpleTextStyle(fontSize),
                            decoration: textFieldInputDecoration("Search for your friends"),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          searchForFriend(addController.text);
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
                  friendBox(possibleNewFriend, 120, addFriendWindowWidth, fontSize),
                ]
            ),
          ),
        ),
        SizedBox(
          width: addFriendWindowWidth,
          height: iconSize,
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                friendListButton(addFriendWindowWidth / 3, fontSize, iconSize),
                friendRequestButton(addFriendWindowWidth / 3, fontSize, iconSize),
                addFriendButton(addFriendWindowWidth / 3, fontSize, iconSize),
              ]
          ),
        )
      ],
    );
  }

  Widget friendWindowNormal(double friendWindowWidth, double friendWindowHeight, double fontSize) {
    double headerHeight = 40;
    return Container(
      child: Column(
        children: [
          friendWindowHeader(friendWindowWidth, headerHeight, fontSize),
          if (addFriendView) // Show the add friend view if the bool is active, otherwise show either the friend list or friend request list
              addFriendWindow(friendWindowWidth, friendWindowHeight - headerHeight, fontSize)
          else
              socialView
                  ? socialWindow(friendWindowWidth, friendWindowHeight - headerHeight, fontSize)
                  : friendRequestWindow(friendWindowWidth, friendWindowHeight - headerHeight, fontSize),
        ],
      )
    );
  }

  Widget friendWindow(BuildContext context) {
    double friendWindowHeight = MediaQuery.of(context).size.height * 0.8;
    double fontSize = 16;
    double friendWindowWidth = 800;
    // We use the total height to hide the chatbox below
    normalMode = true;
    if (MediaQuery.of(context).size.width <= 800) {
      friendWindowWidth = MediaQuery.of(context).size.width;
      normalMode = false;
      fontSize = 12;
    }
    return SingleChildScrollView(
      child: Container(
        width: friendWindowWidth,
        height: friendWindowHeight,
        color: Colors.cyan,
        child: friendWindowNormal(friendWindowWidth, friendWindowHeight, fontSize)
      ),
    );
  }

  Widget build(BuildContext context) {
    return Align(
      alignment: FractionalOffset.center,
      child: showFriendWindow ? friendWindow(context) : Container()
    );
  }
}
