import 'package:flutter/material.dart';
import '../age_of_gold.dart';
import '../services/socket_services.dart';
import 'chat_messages.dart';
import 'user_interface_components/message.dart';
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

  TextEditingController chatFieldController = TextEditingController();

  SocketServices socket = SocketServices();
  late ChatMessages chatMessages;

  bool tileBoxVisible = false;

  double chatBoxWidth = 350;

  @override
  void initState() {
    chatMessages = ChatMessages();
    socket.checkMessages(chatMessages);
    socket.addListener(socketListener);
    _focusChatBox.addListener(_onFocusChange);
    super.initState();
  }

  socketListener() {
    if (mounted) {
      setState(() {});
    }
  }

  void _onFocusChange() {
    widget.game.chatBoxFocus(_focusChatBox.hasFocus);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget topBar() {
    return Container(
      width: chatBoxWidth,
      height: 25,
      color: Colors.lightGreen,
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          width: 30,
          height: 25,
          color: Colors.lightGreen,
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    tileBoxVisible = !tileBoxVisible;
                  });
                },
                child: tileBoxVisible ? const Icon(
                  Icons.keyboard_double_arrow_down,
                  color: Colors.white,
                ) : const Icon(
                  Icons.keyboard_double_arrow_up,
                  color: Colors.white,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget chatBoxWidget() {
    if (MediaQuery.of(context).size.width <= 800) {
      // Here we assume that it is a phone and we set the width to the total
      chatBoxWidth = MediaQuery.of(context).size.width;
    } else {
      chatBoxWidth = 350;
    }
    return Align(
      alignment: FractionalOffset.bottomLeft,
      child: Container(
        width: chatBoxWidth,
        height: tileBoxVisible ? 300 : 25,
        color: Colors.green,
        child: Column(
            children: [
              topBar(),
              Expanded(
                child: messageList()
              ),
              chatBoxTextField()
            ]
        ),
      ),
    );
  }

  sendMessage(String message) {
    socket.sendMessage(message);
    chatFieldController.text = "";
  }

  Widget chatBoxTextField() {
    if (tileBoxVisible) {
      return Row(
          children: [
            SizedBox(
              width: chatBoxWidth - 35,
              height: 50,
              child: TextFormField(
                validator: (val) {
                  if (val == null ||
                      val.isEmpty ||
                      val
                          .trimRight()
                          .isEmpty) {
                    return "Can't send an empty message";
                  }
                  return null;
                },
                onFieldSubmitted: (value) {
                  sendMessage(value);
                },
                keyboardType: TextInputType.multiline,
                focusNode: _focusChatBox,
                controller: chatFieldController,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Type your message',
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                sendMessage(chatFieldController.text);
              },
              child: Container(
                  height: 35,
                  width: 35,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: const Icon(
                    Icons.send,
                    color: Colors.white,
                  )
              ),
            )
          ]
      );
    } else {
      return Container();
    }
  }

  Widget messageList() {
    return chatMessages.chatMessages.isNotEmpty && tileBoxVisible
        ? ListView.builder(
        itemCount: chatMessages.chatMessages.length,
        reverse: true,
        controller: messageScrollController,
        itemBuilder: (context, index) {
          final reversedIndex = chatMessages.chatMessages.length - 1 - index;
          return MessageTile(
              key: UniqueKey(),
              message: chatMessages.chatMessages[reversedIndex]);
        })
        : Container();
  }

  @override
  Widget build(BuildContext context) {
    return chatBoxWidget();
  }

}

class MessageTile extends StatefulWidget {
  final Message message;

  const MessageTile(
      {
        required Key key,
        required this.message
      })
      : super(key: key);

  @override
  MessageTileState createState() => MessageTileState();
}

class MessageTileState extends State<MessageTile> {

  @override
  void initState() {
    super.initState();
  }

  Widget getMessageContent() {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: "[${DateFormat('HH:mm')
                .format(widget.message.timestamp)}] ",
            style:
            const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          TextSpan(
            text: "${widget.message.senderName}: ",
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          TextSpan(
            text: widget.message.body,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            width: MediaQuery.of(context).size.width,
            alignment: Alignment.bottomLeft,
            child: Container(
              child: getMessageContent()
            ),
          ),
        ]
      ),
    );
  }
}
