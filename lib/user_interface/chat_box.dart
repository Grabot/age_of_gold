
import 'package:flutter/material.dart';

import '../age_of_gold.dart';
import '../util/socket_services.dart';
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

  Widget chatBoxWidget() {
    return Align(
      alignment: FractionalOffset.bottomLeft,
      child: Container(
        width: 400,
        height: 100,
        color: Colors.green,
        child: Column(
            children: [
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
    return Row(
      children: [
        SizedBox(
          width: 365,
          height: 50,
          child: TextFormField(
            validator: (val) {
              if (val == null ||
                  val.isEmpty ||
                  val.trimRight().isEmpty) {
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
  }

  Widget messageList() {
    return chatMessages.chatMessages.isNotEmpty
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

  MessageTile(
      {required Key key, required this.message})
      : super(key: key);

  @override
  _MessageTileState createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {

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
