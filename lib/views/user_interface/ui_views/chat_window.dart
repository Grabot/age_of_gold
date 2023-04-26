import 'package:age_of_gold/age_of_gold.dart';
import 'package:age_of_gold/services/auth_service_world.dart';
import 'package:age_of_gold/services/socket_services.dart';
import 'package:age_of_gold/util/util.dart';
import 'package:age_of_gold/views/user_interface/ui_function/user_interface_components/chat_messages.dart';
import 'package:age_of_gold/views/user_interface/ui_function/user_interface_util/chat_window_change_notifier.dart';
import 'package:age_of_gold/views/user_interface/ui_function/user_interface_util/message_util.dart';
import 'package:age_of_gold/views/user_interface/ui_function/user_interface_util/user_box_change_notifier.dart';
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
  ChatData? _selectedChatData;

  bool hasGroupChats = false;

  final FocusNode _focusSearch = FocusNode();
  final TextEditingController searchController = TextEditingController();
  bool searchActive = false;
  List<ChatData> shownChatData = [];


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
          chatMessages.setChatWindowActive(true);
          if (chatMessages.regions[0].name != "No Chats Found!") {
            hasPersonalChats = true;
            shownChatData = chatMessages.regions;
          }
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

  void _onFocusChange() {
    widget.game.chatWindowFocus(_focusChatWindow.hasFocus);
  }

  void _onFocusChangeSearch() {
    widget.game.chatWindowFocus(_focusSearch.hasFocus);
  }

  goBack() {
    setState(() {
      chatWindowChangeNotifier.setChatWindowVisible(false);
    });
  }

  Widget chatWindowHeader(double headerWidth, double headerHeight, double fontSize) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
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
      _selectedChatData = null;
      chatMessages.setMessageUser(null);
      isEvent = false;
      isWorld = true;
    });
  }

  pressedEventsChats() {
    setState(() {
      chatMessages.setActivateChatWindowTab("Events");
      _selectedChatData = null;
      chatMessages.setMessageUser(null);
      isEvent = true;
      isWorld = false;
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
              "assets/images/ui/globe_icon_no_colour.png",
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
      _selectedChatData = chatData;
      chatMessages.setMessageUser(chatData.name);
      chatMessages.setActivateChatWindowTab("Personal");
    });
  }

  Widget personalButton(double chatPickWidth, ChatData chatData, fontSize) {
    MaterialColor buttonColour = Colors.blue;
    if (!isEvent && !isWorld && _selectedChatData != null && _selectedChatData!.name == chatData.name) {
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

  Widget rightColumn(double rightColumnWidth, double leftColumnHeight, double fontSize) {
    double chatTextFieldHeight = 60;
    if (isEvent) {
      chatTextFieldHeight = 0;
    }
    return Column(
      children: [
        Container(
            width: rightColumnWidth,
            height: leftColumnHeight - chatTextFieldHeight,
            child: messageList(chatMessages, messageScrollController, userInteraction, _selectedChatData, isEvent, true)
        ),
        !isEvent
            ? chatTextField(rightColumnWidth, chatTextFieldHeight, true, chatMessages.getActivateChatWindowTab(), _chatFormKey, _focusChatWindow, chatFieldController, _selectedChatData)
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
    return Column(
      children: [
        chatWindowHeader(chatWindowWidth, 40, fontSize),
      ],
    );
  }

  Widget chatWindow(BuildContext context) {
    double fontSize = 16;
    double chatWindowWidth = 1500;
    double chatWindowHeight = (MediaQuery.of(context).size.height / 10) * 9;
    bool normalMode = true;
    if (MediaQuery.of(context).size.width <= 1500) {
      // Here we assume that it is a phone and we set the width to the total
      chatWindowWidth = MediaQuery.of(context).size.width;
    } else if (MediaQuery.of(context).size.width <= 800) {
      normalMode = false;
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
          _selectedChatData = chatMessages.regions[i];
          chatMessages.setMessageUser(chatMessages.regions[i].name);
          exists = true;
        }
      }
      if (!exists) {
        ChatData newChatData = ChatData(3, userName, false);
        chatMessages.addNewRegion(newChatData);
        chatMessages.setMessageUser(newChatData.name);
        _selectedChatData = newChatData;
        // Check if the placeholder "No Chats Found!" is in the list and remove it.
        chatMessages.removePlaceholder();
      }
      setState(() {});
    } else {
      // open the user overview panel.
      AuthServiceWorld().getUser(userName).then((value) {
        if (value != null) {
          UserBoxChangeNotifier().setUser(value);
          UserBoxChangeNotifier().setUserBoxVisible(true);
        } else {
          showToastMessage("Something went wrong");
        }
      });
    }
  }

}
