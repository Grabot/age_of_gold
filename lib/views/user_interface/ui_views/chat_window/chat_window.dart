import 'package:age_of_gold/age_of_gold.dart';
import 'package:age_of_gold/services/auth_service_world.dart';
import 'package:age_of_gold/services/socket_services.dart';
import 'package:age_of_gold/util/util.dart';
import 'package:age_of_gold/views/user_interface/ui_util/chat_messages.dart';
import 'package:age_of_gold/views/user_interface/ui_util/clear_ui.dart';
import 'package:age_of_gold/views/user_interface/ui_util/message_util.dart';
import 'package:age_of_gold/views/user_interface/ui_views/chat_box/chat_box_change_notifier.dart';
import 'package:age_of_gold/views/user_interface/ui_views/chat_window/chat_window_change_notifier.dart';
import 'package:age_of_gold/views/user_interface/ui_views/user_box/user_box_change_notifier.dart';
import 'package:flutter/material.dart';


class ChatWindow extends StatefulWidget {

  final AgeOfGold game;

  const ChatWindow({
    required Key key,
    required this.game
  }) : super(key: key);

  @override
  ChatWindowState createState() => ChatWindowState();
}

class ChatWindowState extends State<ChatWindow> {

  final FocusNode _focusChatWindow = FocusNode();
  bool showChatWindow = false;
  late ChatMessages chatMessages;

  final GlobalKey<FormState> _chatFormKey = GlobalKey<FormState>();
  TextEditingController chatFieldController = TextEditingController();

  SocketServices socket = SocketServices();
  late ChatWindowChangeNotifier chatWindowChangeNotifier;
  var messageScrollController = ScrollController();

  bool isWorld = false;
  bool isEvent = false;

  bool hasPersonalChats = false;

  bool hasGroupChats = false;

  final FocusNode _focusSearch = FocusNode();
  final TextEditingController searchController = TextEditingController();
  bool searchActive = false;
  List<ChatData> shownChatData = [];

  // Only used with mobile mode
  bool normalMode = false;
  bool selectionScreen = false;

  @override
  void initState() {
    chatWindowChangeNotifier = ChatWindowChangeNotifier();
    chatWindowChangeNotifier.addListener(chatWindowChangeListener);

    chatMessages = ChatMessages();
    chatMessages.addListener(newMessageListener);
    socket.checkMessages(chatMessages);
    socket.addListener(socketListener);

    _focusChatWindow.addListener(_onFocusChange);
    _focusSearch.addListener(_onFocusChangeSearch);
    super.initState();
  }

  newMessageListener() {
    if (mounted) {
      setState(() {});
    }
  }

  socketListener() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  chatWindowChangeListener() {
    if (mounted) {
      if (!showChatWindow && chatWindowChangeNotifier.getChatWindowVisible()) {
        setState(() {
          hasPersonalChats = false;
          showChatWindow = true;
          setChatWindowActive();
        });
      }
      if (showChatWindow && !chatWindowChangeNotifier.getChatWindowVisible()) {
        setState(() {
          resetSearch();
          showChatWindow = false;
          chatMessages.setChatWindowActive(false);
        });
      }
    }
  }

  setChatWindowActive() {
    chatMessages.setChatWindowActive(true);
    if (chatMessages.getActivateChatWindowTab() == "") {
      chatMessages.setActivateChatWindowTab("World");
      isWorld = true;
      isEvent = false;
    } if (chatMessages.getActivateChatWindowTab() == "World") {
      isWorld = true;
      isEvent = false;
    } else if (chatMessages.getActivateChatWindowTab() == "Events") {
      isWorld = false;
      isEvent = true;
    } else if (chatMessages.getActivateChatWindowTab() == "Personal") {
      // Find the user that was currently active in the chatbox.
      for (ChatData chatData in chatMessages.regions) {
        if (chatData.name == chatMessages.getMessageUser()) {
          isEvent = false;
          isWorld = false;
          chatMessages.setSelectedChatData(chatData);
          chatMessages.setActivateChatWindowTab("Personal");
          break;
        }
      }
    }
    if (chatMessages.regions[0].name != "No Chats Found!") {
      hasPersonalChats = true;
      shownChatData = chatMessages.regions;
    }
  }

  void _onFocusChange() {
    widget.game.chatWindowFocus(_focusChatWindow.hasFocus);
  }

  void _onFocusChangeSearch() {
    widget.game.chatWindowFocus(_focusSearch.hasFocus);
  }

  goBack() {
    setState(() {
      selectionScreen = false;
      chatWindowChangeNotifier.setChatWindowVisible(false);
    });
  }

  Widget chatWindowHeader(double headerWidth, double headerHeight, double fontSize) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          !normalMode && !selectionScreen
              ? IconButton(
              icon: const Icon(Icons.arrow_back),
              color: Colors.orangeAccent.shade200,
              tooltip: 'go to chat selection',
              onPressed: () {
                setState(() {
                  selectionScreen = true;
                });
              }
          ) : Container(),
          SizedBox(
            height: headerHeight,
            child: Text(
              "Chat window",
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

  pressedWorldChat() {
    setState(() {
      chatMessages.setActivateChatWindowTab("World");
      ChatBoxChangeNotifier().setActiveTab("World");
      chatMessages.setSelectedChatData(null);
      chatMessages.setMessageUser(null);
      isEvent = false;
      isWorld = true;
      selectionScreen = false;
    });
  }

  pressedEventsChats() {
    setState(() {
      chatMessages.setActivateChatWindowTab("Events");
      ChatBoxChangeNotifier().setActiveTab("Events");
      chatMessages.setSelectedChatData(null);
      chatMessages.setMessageUser(null);
      isEvent = true;
      isWorld = false;
      selectionScreen = false;
    });
  }

  Widget worldChatButton(double chatPickWidth, double worldChatButtonHeight, fontSize) {
    MaterialColor buttonColour = Colors.blue;
    if (isWorld) {
      buttonColour = Colors.green;
    }
    return ElevatedButton(
      onPressed: () {
        pressedWorldChat();
      },
      style: buttonStyle(false, buttonColour),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            child: Image.asset(
              "assets/images/ui/icon/globe_icon_no_colour.png",
            ),
          ),
          Expanded(
            child: Container(
              alignment: Alignment.center,
              height: worldChatButtonHeight,
              child: Text(
                'World Chat',
                style: simpleTextStyle(fontSize),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget eventsButton(double chatPickWidth, double eventsButtonHeight, fontSize) {
    MaterialColor buttonColour = Colors.blue;
    if (isEvent) {
      buttonColour = Colors.green;
    }
    return ElevatedButton(
      onPressed: () {
        pressedEventsChats();
      },
      style: buttonStyle(false, buttonColour),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 50,
            child: Icon(
              Icons.event_note,
              color: Colors.grey,
              size: 30,
            ),
          ),
          Expanded(
            child: Container(
              alignment: Alignment.center,
              height: eventsButtonHeight,
              child: Text(
                'Events',
                style: simpleTextStyle(fontSize),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> buildPersonalButtons(double chatPickWidth, fontSize) {
    List<Widget> buttonsList = [];

    // We already have filtered out the "No Chats Found!" Chat region
    for (ChatData chatData in shownChatData) {
      buttonsList.add(personalButton(chatPickWidth, chatData, fontSize));
    }
    return buttonsList;
  }

  pressedPersonalButton(ChatData chatData) {
    setState(() {
      print("setting personal stuff");
      isEvent = false;
      isWorld = false;
      chatMessages.setSelectedChatData(chatData);
      chatMessages.setMessageUser(chatData.name);
      chatMessages.setActivateChatWindowTab("Personal");
      selectionScreen = false;
    });
  }

  Widget personalButton(double chatPickWidth, ChatData chatData, fontSize) {
    MaterialColor buttonColour = Colors.blue;
    if (!isEvent && !isWorld && chatMessages.getSelectedChatData() != null && chatMessages.getSelectedChatData()!.name == chatData.name) {
      buttonColour = Colors.green;
    }
    return ElevatedButton(
      onPressed: () {
        pressedPersonalButton(chatData);
      },
      style: buttonStyle(false, buttonColour),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 50,
            child: Icon(
              Icons.person,
              color: Colors.grey,
              size: 40,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Container(
              alignment: Alignment.center,
              height: 50,
              child: Text(
                chatData.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: simpleTextStyle(fontSize),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void onChangedSearchField(String typedText) {
    if (typedText.isNotEmpty) {
      shownChatData = chatMessages.regions
          .where((element) => element
          .name.toLowerCase()
          .contains(typedText.toLowerCase()))
          .toList();
    } else {
      shownChatData = chatMessages.regions;
    }
    setState(() {});
  }

  Widget personalChatSearch(double leftColumnWidth, double fontSize) {
    if (searchActive) {
      return TextFormField(
        onTap: () {
          if (!_focusSearch.hasFocus) {
            _focusSearch.requestFocus();
          }
        },
        focusNode: _focusSearch,
        controller: searchController,
        textAlign: TextAlign.center,
        style: simpleTextStyle(fontSize),
        onChanged: (text) {
          onChangedSearchField(text);
        },
        decoration: textFieldInputDecoration("Search for your friends"),
      );
    } else {
      return Container();
    }
  }

  resetSearch() {
    chatFieldController.text = "";
    searchController.text = "";
    searchActive = false;
    shownChatData = chatMessages.regions;
  }

  Widget personalChatHeader(double leftColumnWidth, double personalChatHeaderHeight, double fontSize) {
    return Container(
      height: personalChatHeaderHeight,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Personal Chats",
                style: simpleTextStyle(fontSize)
              ),
              IconButton(
                icon: const Icon(Icons.search),
                color: Colors.white,
                tooltip: 'search chats',
                onPressed: () {
                  setState(() {
                    searchActive = !searchActive;
                    if (!searchActive) {
                      resetSearch();
                    }
                    _focusSearch.requestFocus();
                  });
                },
              ),
            ]
          ),
          personalChatSearch(leftColumnWidth, fontSize),
        ]
      ),
    );
  }

  Widget personalChats(double leftColumnWidth, double remainingHeight, double fontSize) {
    double personalChatHeaderHeight = remainingHeight;
    if (hasGroupChats) {
      personalChatHeaderHeight = remainingHeight/2;
    }
    if (hasPersonalChats) {
      return Column(
        children: [
          SizedBox(height: 20),
          personalChatHeader(leftColumnWidth, 50, fontSize),
          Container(
            constraints: BoxConstraints(minHeight: 50, maxHeight: personalChatHeaderHeight - 20 - 50),
            child: SingleChildScrollView(
              child: Column(
                children: buildPersonalButtons(leftColumnWidth, fontSize),
              )
            )
          ),
        ],
      );
    } else {
      return Container();
    }
  }

  Widget groupChats(double leftColumnWidth, double remainingHeight, double fontSize) {
    // TODO: implement groupChats
    return Container();
  }

  Widget leftColumn(double leftColumnWidth, double leftColumnHeight, double fontSize) {
    double worldChatButtonHeight = 50;
    double eventsButtonHeight = 50;
    double remainingHeight = leftColumnHeight - worldChatButtonHeight - eventsButtonHeight;
    return Column(
      children: [
        Container(
          height: leftColumnHeight-50,
          child: Column(
            children: [
              worldChatButton(leftColumnWidth, worldChatButtonHeight, fontSize),
              personalChats(leftColumnWidth, remainingHeight, fontSize),
              groupChats(leftColumnWidth, remainingHeight, fontSize),
            ],
          ),
        ),
        eventsButton(leftColumnWidth, eventsButtonHeight, fontSize),
      ]
    );
  }

  Widget rightColumn(double rightColumnWidth, double rightColumnHeight, double fontSize) {
    double chatTextFieldHeight = 60;
    if (isEvent) {
      chatTextFieldHeight = 0;
    }
    return Column(
      children: [
        Container(
            width: rightColumnWidth,
            height: rightColumnHeight - chatTextFieldHeight,
            child: messageList(chatMessages, messageScrollController, userInteraction, chatMessages.getSelectedChatData(), isEvent, true)
        ),
        !isEvent
            ? chatTextField(rightColumnWidth, chatTextFieldHeight, true, chatMessages.getActivateChatWindowTab(), _chatFormKey, _focusChatWindow, chatFieldController, chatMessages.getSelectedChatData())
            : Container()
      ],
    );
  }

  Widget chatWindowNormal(double chatWindowWidth, double chatWindowHeight, double fontSize) {
    double leftColumnWidth = chatWindowWidth / 3;
    double rightColumnWidth = leftColumnWidth * 2;
    double headerHeight = 40;
    return Column(
      children: [
        chatWindowHeader(chatWindowWidth, headerHeight, fontSize),
        Row(
          children: [
            SizedBox(
              width: leftColumnWidth,
              height: chatWindowHeight-headerHeight,
              child: leftColumn(leftColumnWidth, chatWindowHeight-headerHeight, fontSize),
            ),
            SizedBox(
              width: rightColumnWidth,
              height: chatWindowHeight-headerHeight,
              child: rightColumn(rightColumnWidth, chatWindowHeight-headerHeight, fontSize),
            )
          ],
        )
      ],
    );
  }

  Widget chatWindowMobile(double chatWindowWidth, double chatWindowHeight, double fontSize) {
    double headerHeight = 40;
    if (selectionScreen) {
      return Column(
        children: [
          chatWindowHeader(chatWindowWidth, headerHeight, fontSize),
          SizedBox(
            width: chatWindowWidth,
            height: chatWindowHeight-headerHeight,
            child: leftColumn(chatWindowWidth, chatWindowHeight-headerHeight, fontSize),
          ),
        ],
      );
    } else {
      return Column(
        children: [
          chatWindowHeader(chatWindowWidth, headerHeight, fontSize),
          SizedBox(
            width: chatWindowWidth,
            height: chatWindowHeight-headerHeight,
            child: rightColumn(chatWindowWidth, chatWindowHeight-headerHeight, fontSize),
          )
        ],
      );
    }
  }

  Widget chatWindow(BuildContext context) {
    double fontSize = 16;
    double chatWindowWidth = 1500;
    // We use the total height to hide the chatbox below
    double chatWindowHeight = (MediaQuery.of(context).size.height / 10) * 9;
    normalMode = true;
    if (MediaQuery.of(context).size.width <= 800) {
      chatWindowWidth = MediaQuery.of(context).size.width;
      chatWindowHeight = MediaQuery.of(context).size.height;
      normalMode = false;
    } else if (MediaQuery.of(context).size.width <= 1500) {
      // Here we assume that it is a phone and we set the width to the total
      chatWindowWidth = MediaQuery.of(context).size.width;
    }

    return Container(
      width: chatWindowWidth,
      height: chatWindowHeight,
      color: Colors.blueGrey,
      child: normalMode
          ? chatWindowNormal(chatWindowWidth, chatWindowHeight, fontSize)
          : chatWindowMobile(chatWindowWidth, chatWindowHeight, fontSize)
    );
  }

  Widget build(BuildContext context) {
    return Align(
        alignment: FractionalOffset.center,
        child: showChatWindow ? chatWindow(context) : Container()
    );
  }

  userInteraction(bool message, String userName) {
    if (message) {
      // message the user
      // select personal region if it exists, otherwise just create it first.
      bool exists = false;
      for (int i = 0; i < chatMessages.regions.length; i++) {
        if (chatMessages.regions[i].name == userName) {
          chatMessages.setSelectedChatData(chatMessages.regions[i]);
          chatMessages.setMessageUser(chatMessages.regions[i].name);
          exists = true;
        }
      }
      if (!exists) {
        ChatData newChatData = ChatData(3, userName, false);
        chatMessages.addNewRegion(newChatData);
        chatMessages.setMessageUser(newChatData.name);
        chatMessages.setSelectedChatData(newChatData);
        // Check if the placeholder "No Chats Found!" is in the list and remove it.
        chatMessages.removePlaceholder();
      }
      chatMessages.setActivateChatWindowTab("Personal");
      hasPersonalChats = true;
      resetSearch();
      setState(() {});
    } else {
      // open the user overview panel.
      AuthServiceWorld().getUser(userName).then((value) {
        if (value != null) {
          ClearUI().clearUserInterfaces();
          UserBoxChangeNotifier().setUser(value);
          UserBoxChangeNotifier().setUserBoxVisible(true);
        } else {
          showToastMessage("Something went wrong");
        }
      });
    }
  }

}
