import 'package:age_of_gold/age_of_gold.dart';
import 'package:age_of_gold/services/auth_service_world.dart';
import 'package:age_of_gold/services/settings.dart';
import 'package:age_of_gold/services/socket_services.dart';
import 'package:age_of_gold/util/util.dart';
import 'package:age_of_gold/views/user_interface/ui_function/user_interface_components/chat_messages.dart';
import 'package:age_of_gold/views/user_interface/ui_function/user_interface_components/message.dart';
import 'package:age_of_gold/views/user_interface/ui_function/user_interface_components/messages/event_message.dart';
import 'package:age_of_gold/views/user_interface/ui_function/user_interface_components/messages/personal_message.dart';
import 'package:age_of_gold/views/user_interface/ui_function/user_interface_util/chat_window_change_notifier.dart';
import 'package:age_of_gold/views/user_interface/ui_function/user_interface_util/message_util.dart';
import 'package:age_of_gold/views/user_interface/ui_function/user_interface_util/user_box_change_notifier.dart';
import 'package:age_of_gold/views/user_interface/ui_views/chat_box.dart';
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

  late ChatWindowChangeNotifier chatWindowChangeNotifier;
  var messageScrollController = ScrollController();

  ChatData? _selectedChatData;

  @override
  void initState() {
    chatWindowChangeNotifier = ChatWindowChangeNotifier();
    chatWindowChangeNotifier.addListener(chatWindowChangeListener);

    chatMessages = ChatMessages();
    chatMessages.addListener(newMessageListener);

    _focusChatWindow.addListener(_onFocusChange);
    super.initState();
  }

  newMessageListener() {
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
          showChatWindow = true;
        });
      }
      if (showChatWindow && !chatWindowChangeNotifier.getChatWindowVisible()) {
        setState(() {
          showChatWindow = false;
        });
      }
    }
  }

  void _onFocusChange() {
    widget.game.chatWindowFocus(_focusChatWindow.hasFocus);
  }

  goBack() {
    setState(() {
      chatWindowChangeNotifier.setChatWindowVisible(false);
    });
  }

  Widget chatWindowHeader(double width, double fontSize) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            child: Text(
              "Chat window",
              style: simpleTextStyle(fontSize),
            )
          ),
          IconButton(
              icon: const Icon(Icons.close),
              color: Colors.orangeAccent.shade200,
              tooltip: 'cancel',
              onPressed: () {
                goBack();
              }
          ),
        ]
    );
  }

  Widget worldChatButton(double chatPickWidth, fontSize) {
    return ElevatedButton(
      onPressed: () {
        print("world chat button");
      },
      style: buttonStyle(false, Colors.blue),
      child: Container(
        alignment: Alignment.center,
        width: chatPickWidth,
        height: 50,
        child: Text(
          'World Chat',
          style: simpleTextStyle(fontSize),
        ),
      ),
    );
  }

  Widget chatWindowNormal(double chatWindowWidth, double fontSize) {
    return Container(
      child: Column(
        children: [
          chatWindowHeader(chatWindowWidth, fontSize),
          Row(
            children: [
              Column(
                children: [
                  worldChatButton((chatWindowWidth/3), fontSize)
                ],
              ),
              Column(
                children: [
                  Container(
                    width: chatWindowWidth - ((chatWindowWidth/3)*2),
                    height: 400,
                    child: messageList(chatMessages, messageScrollController, userInteraction, _selectedChatData, false, true)
                  )
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  Widget chatWindowMobile(double chatWindowWidth, double fontSize) {
    return Container(
      child: Column(
        children: [
          chatWindowHeader(chatWindowWidth, fontSize),
        ],
      ),
    );
  }

  Widget chatWindow(BuildContext context) {
    double fontSize = 16;
    double chatWindowWidth = 800;
    double chatWindowHeight = (MediaQuery.of(context).size.height / 10) * 9;
    bool normalMode = true;
    if (MediaQuery.of(context).size.width <= 800) {
      // Here we assume that it is a phone and we set the width to the total
      chatWindowWidth = MediaQuery.of(context).size.width;
      normalMode = false;
    }

    return Container(
      width: chatWindowWidth,
      height: chatWindowHeight,
      color: Colors.brown,
      child: normalMode
          ? chatWindowNormal(chatWindowWidth, fontSize)
          : chatWindowMobile(chatWindowWidth, fontSize)
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
      chatMessages.setActiveTab("Personal");
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
