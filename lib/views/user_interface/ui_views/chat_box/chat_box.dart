import 'dart:async';

import 'package:age_of_gold/age_of_gold.dart';
import 'package:age_of_gold/services/auth_service_world.dart';
import 'package:age_of_gold/services/models/user.dart';
import 'package:age_of_gold/services/settings.dart';
import 'package:age_of_gold/services/socket_services.dart';
import 'package:age_of_gold/util/util.dart';
import 'package:age_of_gold/views/user_interface/ui_util/chat_messages.dart';
import 'package:age_of_gold/views/user_interface/ui_util/clear_ui.dart';
import 'package:age_of_gold/views/user_interface/ui_util/message_util.dart';
import 'package:age_of_gold/views/user_interface/ui_views/chat_box/chat_box_change_notifier.dart';
import 'package:age_of_gold/views/user_interface/ui_views/chat_window/chat_window_change_notifier.dart';
import 'package:age_of_gold/views/user_interface/ui_views/user_box/user_box_change_notifier.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';


class ChatBox extends StatefulWidget {

  final AgeOfGold game;

  const ChatBox({
    required Key key,
    required this.game
  }) : super(key: key);

  @override
  ChatBoxState createState() => ChatBoxState();
}

class ChatBoxState extends State<ChatBox> {

  final FocusNode _focusChatBox = FocusNode();
  var messageScrollController = ScrollController();

  final GlobalKey<FormState> _chatFormKey = GlobalKey<FormState>();

  TextEditingController chatFieldController = TextEditingController();

  SocketServices socket = SocketServices();
  late ChatMessages chatMessages;
  late ChatBoxChangeNotifier chatBoxChangeNotifier;

  bool tileBoxVisible = false;

  // TODO: Will the "local" chat option remain? This can be removed if not.
  int currentHexQ = 0;
  int currentHexR = 0;
  int currentTileQ = 0;
  int currentTileR = 0;

  late Timer chatBoxTimer;

  @override
  void initState() {
    chatBoxChangeNotifier = ChatBoxChangeNotifier();
    chatBoxChangeNotifier.addListener(chatBoxChangeListener);

    chatMessages = ChatMessages();
    chatMessages.addListener(newMessageListener);
    socket.checkMessages(chatMessages);
    socket.addListener(socketListener);
    _focusChatBox.addListener(_onFocusChange);
    chatMessages.setActiveChatTab("");

    chatBoxTimer = Timer(Duration(seconds: 0), () {});
    super.initState();
  }

  newMessageListener() {
    if (mounted) {
      if (tileBoxVisible || ChatWindowChangeNotifier().getChatWindowVisible()) {
        if (chatMessages.getActiveChatTab() == "World") {
          chatMessages.setUnreadWorldMessages(false);
        }
        if (chatMessages.getActiveChatTab() == "Events") {
          chatMessages.setUnreadEventMessages(false);
        }
      }
      setState(() {});
    }
  }

  int chatBoxOpenTime = 30;
  tileBoxOpen() {
    tileBoxVisible = true;
    chatBoxChangeNotifier.setChatBoxVisible(true);
    chatBoxTimer = Timer(Duration(seconds: chatBoxOpenTime), () {
      setState(() {
        tileBoxVisible = false;
        chatBoxChangeNotifier.setChatBoxVisible(false);
      });
    });
  }

  resetTimer() {
    chatBoxTimer.cancel();
    chatBoxTimer = Timer(Duration(seconds: chatBoxOpenTime), () {
      setState(() {
        tileBoxVisible = false;
        chatBoxChangeNotifier.setChatBoxVisible(false);
      });
    });
  }

  chatBoxChangeListener() {
    if (mounted) {
      if (!normalMode) {
        if (chatMessages.getActiveChatTab() == "World" || chatMessages.getActiveChatTab() == "Events") {
          chatMessages.setSelectedChatData(null);
        }
      }
      if (!tileBoxVisible && chatBoxChangeNotifier.getChatBoxVisible()) {
        if (chatMessages.selectedChatData != null) {
          userInteraction(true, chatMessages.selectedChatData!.senderId, chatMessages.selectedChatData!.name);
          chatMessages.setActiveChatTab("Personal");
        }
      }
      if (tileBoxVisible && !chatBoxChangeNotifier.getChatBoxVisible()) {
        tileBoxVisible = false;
      }
      if (tileBoxVisible && chatMessages.selectedChatData != null) {
        // The user has selected a user to message. Change to that chat.
        userInteraction(true, chatMessages.selectedChatData!.senderId, chatMessages.selectedChatData!.name);
        chatMessages.setActiveChatTab("Personal");
        _focusChatBox.requestFocus();
      }
      setState(() {});
    }
  }

  socketListener() {
    if (mounted) {
      setState(() {});
    }
  }

  void _onFocusChange() {
    widget.game.windowFocus(_focusChatBox.hasFocus);
    if (_focusChatBox.hasFocus) {
      // When it gets the focus we want to know where it is right now.
      List<int>? cameraProperties = widget.game.getCameraPos();
      if (cameraProperties != null) {
        currentHexQ = cameraProperties[0];
        currentHexR = cameraProperties[1];
        currentTileQ = cameraProperties[2];
        currentTileR = cameraProperties[3];
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  pressedChatTab(String tabName) {
    print("pressed chat tab");
    resetTimer();
    if (!tileBoxVisible) {
      tileBoxOpen();
    }
    setState(() {
      chatMessages.setActiveChatTab(tabName);
      chatMessages.setSelectedChatData(null);
      chatMessages.setMessageUser(null);
      chatMessages.checkPersonalMessageRead();
      chatMessages.checkReadGuildMessage();
      readMessages();
    });
  }

  Widget chatTab(String tabName, bool hasUnreadMessages) {
    bool buttonActive = chatMessages.getActiveChatTab() == tabName;
    if (!tileBoxVisible) {
      buttonActive = false;
    }
    return ElevatedButton(
      onPressed: () {
        pressedChatTab(tabName);
      },
      style: buttonStyle(buttonActive, Colors.green),
      child: Row(
        children: [
          hasUnreadMessages ? Text("!  ") : Text("   "),
          Container(
            width: 50,
            child: Text(tabName),
          ),
        ]
      ),
    );
  }

  readMessages() {
    if (chatMessages.getActiveChatTab() == "") {
      // If there is no tab active we will activate the world tab
      chatMessages.setActiveChatTab("World");
    }
    if (chatMessages.getActiveChatTab() == "World") {
      chatMessages.unreadWorldMessages = false;
      // We only set the last one to true,
      // since that's the one we use to determine if there are unread messages
      if (chatMessages.chatMessages.isNotEmpty) {
        chatMessages.chatMessages.last.read = true;
      }
    } else if (chatMessages.getActiveChatTab() == "Guild") {
      chatMessages.setUnreadGuildMessages(false);
      if (chatMessages.guildMessages.isNotEmpty) {
        chatMessages.guildMessages.last.read = true;
      }
    } else if (chatMessages.getActiveChatTab() == "Events") {
      chatMessages.setUnreadEventMessages(false);
      if (chatMessages.eventMessages.isNotEmpty) {
        chatMessages.eventMessages.last.read = true;
      }
    }
  }

  showChatWindow() {
    ChatBoxChangeNotifier().setChatBoxVisible(false);
    ChatWindowChangeNotifier().setChatWindowVisible(true);
  }

  Widget showOrHideChatBox(double iconSize) {
    if (tileBoxVisible) {
      return Container(
          width: iconSize,
          height: iconSize,
          child: IconButton(
          icon: const Icon(Icons.keyboard_double_arrow_down),
          color: Colors.white,
          tooltip: 'Hide chat',
          onPressed: () {
            setState(() {
              tileBoxVisible = false;
              chatBoxChangeNotifier.setChatBoxVisible(false);
            });
          },
        ),
      );
    } else {
      return Container(
        width: iconSize,
        height: iconSize,
        child: IconButton(
        icon: const Icon(Icons.keyboard_double_arrow_up),
        color: Colors.white,
        tooltip: 'Show chat',
        onPressed: () {
          setState(() {
            readMessages();
            tileBoxOpen();
          });
        },
    ),
      );
    }
  }

  Widget chatDropDownRegionTopBar() {
    return Container(
      padding: EdgeInsets.only(left: 5, right: 5),
      child: GestureDetector(
        child: Container(
          height: 34,
          width: 120,
          child: chatDropDownRegion(),
        ),
      ),
    );
  }

  Widget chatTabWorld() {
    return chatTab("World", chatMessages.getUnreadWorldMessages());
  }

  Widget chatTabEvents() {
    return chatTab("Events", chatMessages.getUnreadEventMessages());
  }

  Widget chatTabGuild() {
    User? currentUser = Settings().getUser();
    if (currentUser != null && currentUser.getGuild() != null) {
      return chatTab("Guild", chatMessages.getUnreadGuildMessages());
    } else {
      return Container();
    }
  }

  Widget chatTabChats() {
    return chatDropDownRegionTopBar();
  }

  Widget showMesssageWindow(double iconSize) {
    return Container(
      width: iconSize,
      height: iconSize,
      child: IconButton(
        icon: const Icon(Icons.mail),
        color: Colors.white,
        tooltip: 'Show chat window',
        onPressed: () {
          showChatWindow();
        },
      ),
    );
  }

  Widget topBar(double chatBoxWidth, double topBarHeight) {
    return Container(
      width: chatBoxWidth,
      height: topBarHeight,
      color: Colors.lightGreen.withOpacity(0.75),
      child: Align(
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            showMesssageWindow(topBarHeight),
            chatTabWorld(),
            chatTabEvents(),
            chatTabGuild(),
            chatTabChats(),
            showOrHideChatBox(topBarHeight)
          ],
        ),
      ),
    );
  }

  setChatMessages() {
    chatMessages.setChatMessages();
  }

  Widget chatBoxNormal(double chatBoxWidth, double fontSize) {

    double topBarHeight = 34; // always visible
    double messageBoxHeight = 300;
    double chatTextFieldHeight = 60;
    double alwaysVisibleHeight = topBarHeight;
    double totalHeight = messageBoxHeight + chatTextFieldHeight + topBarHeight;

    bool isEvent = chatMessages.getActiveChatTab() == "Events";
    bool userLoggedIn = Settings().getUser() != null;
    if (isEvent || !userLoggedIn) {
      messageBoxHeight += chatTextFieldHeight;
    }

    bool showMessageField = (tileBoxVisible || !normalMode);

    setChatMessages();
    return SingleChildScrollView(
      child: SizedBox(
        width: chatBoxWidth,
        height: tileBoxVisible ? totalHeight : alwaysVisibleHeight,
        child: Column(
            children: [
              topBar(chatBoxWidth, topBarHeight),
              Container(
                width: chatBoxWidth,
                height: tileBoxVisible ? messageBoxHeight : 0,
                color: Colors.black.withOpacity(0.4),
                child: Column(
                  children: [
                    Expanded(
                      child: messageList(chatMessages.shownMessages, messageScrollController, userInteraction, chatMessages.getSelectedChatData(), isEvent, showMessageField, fontSize, false),
                    ),
                  ],
                ),
              ),
              !isEvent && userLoggedIn
                  ? chatTextField(chatBoxWidth, chatTextFieldHeight, tileBoxVisible, chatMessages.getActiveChatTab(), _chatFormKey, _focusChatBox, chatFieldController, chatMessages.getSelectedChatData(), onChangedField)
                  : Container()
            ]
        ),
      ),
    );
  }

  onChangedField(String text) {
    resetTimer();
  }

  Widget mobileMinimized(double chatBoxWidth, double topBarHeight, double fontSize) {
    bool showMessageField = (tileBoxVisible || !normalMode);
    setChatMessages();
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              showChatWindow();
              readMessages();
            });
          },
          child: SizedBox(
            width: chatBoxWidth - topBarHeight,
            child: Column(
              children: [
                Expanded(
                  child: messageList(chatMessages.shownMessages, messageScrollController, userInteraction, chatMessages.getSelectedChatData(), false, showMessageField, fontSize, true),
                ),
              ],
            ),
          ),
        ),
        showMesssageWindow(topBarHeight),
      ],
    );
  }

  Widget mobileMaximized(double chatBoxWidth, double totalHeight, double topBarHeight, double fontSize) {
    double chatTextFieldHeight = 60;
    double messageBoxHeight = totalHeight - chatTextFieldHeight - topBarHeight;

    bool isEvent = chatMessages.getActiveChatTab() == "Events";
    bool userLoggedIn = Settings().getUser() != null;
    if (isEvent || !userLoggedIn) {
      messageBoxHeight += chatTextFieldHeight;
    }
    bool showMessageField = (tileBoxVisible || !normalMode);

    setChatMessages();
    return Container(
      width: chatBoxWidth,
      child: Column(
        children: [
          topBar(chatBoxWidth, topBarHeight),
          Container(
            width: chatBoxWidth,
            height: tileBoxVisible ? messageBoxHeight : 0,
            color: Colors.black.withOpacity(0.4),
            child: Column(
              children: [
                Expanded(
                  child: messageList(chatMessages.shownMessages, messageScrollController, userInteraction, chatMessages.getSelectedChatData(), isEvent, showMessageField, fontSize, false),
                ),
              ],
            ),
          ),
          !isEvent && userLoggedIn
              ? chatTextField(chatBoxWidth, chatTextFieldHeight, tileBoxVisible, chatMessages.getActiveChatTab(), _chatFormKey, _focusChatBox, chatFieldController, chatMessages.getSelectedChatData(), onChangedField)
              : Container()
        ],
      ),
    );
  }

  Widget chatBoxMobile(double chatBoxWidth, double fontSize) {
    double topBarHeight = tileBoxVisible ? 34 : 45;
    double totalHeight = MediaQuery.of(context).size.height - 200;
    double alwaysVisibleHeight = topBarHeight;

    return Container(
      width: chatBoxWidth,
      height: tileBoxVisible ? totalHeight : alwaysVisibleHeight,
      color: Colors.black.withOpacity(0.4),
      child: tileBoxVisible
          ? mobileMaximized(chatBoxWidth, totalHeight, topBarHeight, fontSize)
          : mobileMinimized(chatBoxWidth, topBarHeight, fontSize),
    );
  }

  bool normalMode = true;
  Widget chatBoxWidget() {
    normalMode = true;
    double chatBoxWidth = 500;
    double fontSize = 18;
    if (MediaQuery.of(context).size.width <= 800) {
      // Here we assume that it is a phone and we set the width to the total
      chatBoxWidth = MediaQuery.of(context).size.width;
      normalMode = false;
      fontSize = 12;
    }

    return Align(
      alignment: FractionalOffset.bottomLeft,
      child: normalMode
          ? chatBoxNormal(chatBoxWidth, fontSize)
          : chatBoxMobile(chatBoxWidth, fontSize)
    );
  }

  Widget chatDropDownRegion() {
    String hintText = chatMessages.hintText();
    Color dropDownColour = Colors.white;
    return Container(
      decoration: BoxDecoration(
          color: Colors.grey.withAlpha(95),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: dropDownColour.withOpacity(0.54),
            width: 2,
          ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2(
          value: chatMessages.getSelectedChatData(),
          disabledHint: null,
          items: chatMessages.getDropdownMenuItems(),
          // dropdownWidth: 300,
          onChanged: onChangeDropdownItem,
          hint: Container(
            padding: EdgeInsets.only(left: 15),
            child: RichText(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                text: hintText,
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          isExpanded: true,
          // iconSize: 0.0,
        ),
      ),
    );
  }

  onChangeDropdownItem(ChatData? selectedChat) {
    setState(() {
      if (selectedChat != null) {
        if (!tileBoxVisible) {
          tileBoxOpen();
        }
        // There is a placeholder text when there are no chats active
        // If the user decides to click this anyway it will do nothing
        if (selectedChat.name != "No Chats Found!") {
          chatMessages.setSelectedChatData(selectedChat);
          chatMessages.setMessageUser(selectedChat.name);
          chatMessages.setActiveChatTab("Personal");
          if (chatMessages.checkIfPersonalMessageIsRead(selectedChat.name, null)) {
            chatMessages.readChatData(selectedChat);
          }
        } else {
          chatMessages.setActiveChatTab("World");
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return chatBoxWidget();
  }

  userInteraction(bool message, int senderId, String userName) {
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
        ChatData newChatData = ChatData(3, senderId, userName, 0, false);
        chatMessages.addNewRegion(newChatData);
        chatMessages.setMessageUser(newChatData.name);
        chatMessages.setSelectedChatData(newChatData);
        // Check if the placeholder "No Chats Found!" is in the list and remove it.
        chatMessages.removePlaceholder();
      }
      chatMessages.setActiveChatTab("Personal");
      if (normalMode && !tileBoxVisible) {
        tileBoxOpen();
      } else if (!normalMode) {
        showChatWindow();
      }
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
