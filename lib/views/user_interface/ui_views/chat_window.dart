import 'package:age_of_gold/age_of_gold.dart';
import 'package:age_of_gold/util/util.dart';
import 'package:age_of_gold/views/user_interface/ui_function/user_interface_util/chat_window_change_notifier.dart';
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

  late ChatWindowChangeNotifier chatWindowChangeNotifier;

  @override
  void initState() {
    chatWindowChangeNotifier = ChatWindowChangeNotifier();
    chatWindowChangeNotifier.addListener(chatWindowChangeListener);

    _focusChatWindow.addListener(_onFocusChange);
    super.initState();
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
}
