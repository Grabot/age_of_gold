import 'package:age_of_gold/age_of_gold.dart';
import 'package:age_of_gold/services/auth_service_message.dart';
import 'package:age_of_gold/services/auth_service_world.dart';
import 'package:age_of_gold/services/models/user.dart';
import 'package:age_of_gold/services/settings.dart';
import 'package:age_of_gold/services/socket_services.dart';
import 'package:age_of_gold/util/util.dart';
import 'package:age_of_gold/views/user_interface/ui_function/user_interface_components/chat_messages.dart';
import 'package:age_of_gold/views/user_interface/ui_function/user_interface_components/message.dart';
import 'package:age_of_gold/views/user_interface/ui_function/user_interface_util/chat_box_change_notifier.dart';
import 'package:age_of_gold/views/user_interface/ui_function/user_interface_util/chat_window_change_notifier.dart';
import 'package:age_of_gold/views/user_interface/ui_function/user_interface_util/message_util.dart';
import 'package:age_of_gold/views/user_interface/ui_function/user_interface_util/user_box_change_notifier.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


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

  ChatData? _selectedChatData;

  // TODO: Will the "local" chat option remain? This can be removed if not.
  int currentHexQ = 0;
  int currentHexR = 0;
  int currentTileQ = 0;
  int currentTileR = 0;

  @override
  void initState() {
    chatBoxChangeNotifier = ChatBoxChangeNotifier();
    chatBoxChangeNotifier.addListener(chatBoxChangeListener);

    chatMessages = ChatMessages();
    chatMessages.addListener(newMessageListener);
    socket.checkMessages(chatMessages);
    socket.addListener(socketListener);
    _focusChatBox.addListener(_onFocusChange);
    chatMessages.setActiveChatBoxTab("");

    super.initState();
  }

  newMessageListener() {
    if (mounted) {
      setState(() {});
    }
  }

  chatBoxChangeListener() {
    if (mounted) {
      if (!tileBoxVisible && chatBoxChangeNotifier.getChatBoxVisible()) {
        setState(() {
          if (chatBoxChangeNotifier.getChatUser() != null) {
            userInteraction(true, chatBoxChangeNotifier.getChatUser()!);
            chatMessages.setActiveChatBoxTab("Personal");
          }
          tileBoxVisible = true;
        });
      }
      if (tileBoxVisible && !chatBoxChangeNotifier.getChatBoxVisible()) {
        setState(() {
          tileBoxVisible = false;
          chatMessages.setActiveChatBoxTab("");
        });
      }
      if (tileBoxVisible && chatBoxChangeNotifier.getChatUser() != null) {
        // The user has selected a user to message. Change to that chat.
        userInteraction(true, chatBoxChangeNotifier.getChatUser()!);
        chatMessages.setActiveChatBoxTab("Personal");
        _focusChatBox.requestFocus();
      }
    }
  }

  socketListener() {
    if (mounted) {
      setState(() {});
    }
  }

  void _onFocusChange() {
    widget.game.chatBoxFocus(_focusChatBox.hasFocus);
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
    if (!tileBoxVisible) {
      tileBoxVisible = true;
    }
    setState(() {
      chatMessages.setActiveChatBoxTab(tabName);
      _selectedChatData = null;
      chatMessages.setMessageUser(null);
      readMessages();
    });
  }

  Widget chatTab(String tabName, bool hasUnreadMessages) {
    bool buttonActive = chatMessages.getActiveChatBoxTab() == tabName;
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
    if (chatMessages.getActiveChatBoxTab() == "") {
      // If there is no tab active we will activate the world tab
      chatMessages.setActiveChatBoxTab("World");
    }
    if (chatMessages.getActiveChatBoxTab() == "World") {
      chatMessages.unreadWorldMessages = false;
      // We only set the last one to true,
      // since that's the one we use to determine if there are unread messages
      chatMessages.chatMessages.last.read = true;
    } else if (chatMessages.getActiveChatBoxTab() == "Events") {
      chatMessages.setUnreadEventMessages(false);
      chatMessages.eventMessages.last.read = true;
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
              _selectedChatData = null;
              chatMessages.setMessageUser(null);
              chatMessages.setActiveChatBoxTab("");
              tileBoxVisible = false;
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
            tileBoxVisible = true;
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
            chatTabChats(),
            showOrHideChatBox(topBarHeight)
          ],
        ),
      ),
    );
  }

  Widget chatBoxNormal(double chatBoxWidth) {

    double topBarHeight = 34; // always visible
    double messageBoxHeight = 300;
    double chatTextFieldHeight = 60;
    double alwaysVisibleHeight = topBarHeight;
    double totalHeight = messageBoxHeight + chatTextFieldHeight + topBarHeight;

    bool isEvent = chatMessages.getActiveChatBoxTab() == "Events";
    bool userLoggedIn = Settings().getUser() != null;
    if (isEvent || !userLoggedIn) {
      messageBoxHeight += chatTextFieldHeight;
    }

    bool showMessageField = (tileBoxVisible || !normalMode);

    return Container(
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
                    child: messageList(chatMessages, messageScrollController, userInteraction, _selectedChatData, isEvent, showMessageField),
                  ),
                ],
              ),
            ),
            !isEvent && userLoggedIn
                ? chatTextField(chatBoxWidth, chatTextFieldHeight, tileBoxVisible, chatMessages.getActiveChatBoxTab(), _chatFormKey, _focusChatBox, chatFieldController, _selectedChatData)
                : Container()
          ]
      ),
    );
  }

  Widget mobileMinimized(double chatBoxWidth, double topBarHeight) {
    bool showMessageField = (tileBoxVisible || !normalMode);
    return Row(
      children: [
        showMesssageWindow(topBarHeight),
        GestureDetector(
          onTap: () {
            setState(() {
              tileBoxVisible = true;
              readMessages();
            });
          },
          child: SizedBox(
            width: chatBoxWidth - (topBarHeight * 2),
            child: Column(
              children: [
                Expanded(
                  child: messageList(chatMessages, messageScrollController, userInteraction, _selectedChatData, false, showMessageField),
                ),
              ],
            ),
          ),
        ),
        showOrHideChatBox(topBarHeight)
      ],
    );
  }

  Widget mobileMaximized(double chatBoxWidth, double totalHeight, double topBarHeight) {
    double chatTextFieldHeight = 60;
    double messageBoxHeight = totalHeight - chatTextFieldHeight - topBarHeight;

    bool isEvent = chatMessages.getActiveChatBoxTab() == "Events";
    bool userLoggedIn = Settings().getUser() != null;
    if (isEvent || !userLoggedIn) {
      messageBoxHeight += chatTextFieldHeight;
    }
    bool showMessageField = (tileBoxVisible || !normalMode);

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
                  child: messageList(chatMessages, messageScrollController, userInteraction, _selectedChatData, isEvent, showMessageField),
                ),
              ],
            ),
          ),
          !isEvent && userLoggedIn
              ? chatTextField(chatBoxWidth, chatTextFieldHeight, tileBoxVisible, chatMessages.getActiveChatBoxTab(), _chatFormKey, _focusChatBox, chatFieldController, _selectedChatData)
              : Container()
        ],
      ),
    );
  }

  Widget chatBoxMobile(double chatBoxWidth) {
    double topBarHeight = tileBoxVisible ? 34 : 60;
    double totalHeight = MediaQuery.of(context).size.height - 200;
    double alwaysVisibleHeight = topBarHeight;

    return Container(
      width: chatBoxWidth,
      height: tileBoxVisible ? totalHeight : alwaysVisibleHeight,
      color: Colors.black.withOpacity(0.4),
      child: tileBoxVisible ? mobileMaximized(chatBoxWidth, totalHeight, topBarHeight) : mobileMinimized(chatBoxWidth, topBarHeight),
    );
  }

  bool normalMode = true;
  Widget chatBoxWidget() {
    normalMode = true;
    double chatBoxWidth = 500;
    if (MediaQuery.of(context).size.width <= 800) {
      // Here we assume that it is a phone and we set the width to the total
      chatBoxWidth = MediaQuery.of(context).size.width;
      normalMode = false;
    }

    return Align(
      alignment: FractionalOffset.bottomLeft,
      child: normalMode ? chatBoxNormal(chatBoxWidth) : chatBoxMobile(chatBoxWidth)
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
          value: _selectedChatData,
          disabledHint: null,
          items: chatMessages.getDropdownMenuItems(),
          dropdownWidth: 300,
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
          iconSize: 0.0,
        ),
      ),
    );
  }

  onChangeDropdownItem(ChatData? selectedChat) {
    setState(() {
      if (selectedChat != null) {
        if (!tileBoxVisible) {
          tileBoxVisible = true;
        }
        // There is a placeholder text when there are no chats active
        // If the user decides to click this anyway it will do nothing
        if (selectedChat.name != "No Chats Found!") {
          _selectedChatData = selectedChat;
          chatMessages.setMessageUser(selectedChat.name);
          // removeUnreadPersonalMessage(selectedChat);
          chatMessages.setActiveChatBoxTab("Personal");
        } else {
          chatMessages.setActiveChatBoxTab("World");
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return chatBoxWidget();
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
      chatMessages.setActiveChatBoxTab("Personal");
      if (!tileBoxVisible) {
        tileBoxVisible = true;
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
