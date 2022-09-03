
import 'package:flutter/material.dart';

import '../age_of_gold.dart';
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

  List<Message> messages = [];

  TextEditingController chatFieldController = TextEditingController();

  @override
  void initState() {
    DateTime example = DateTime.now();
    messages.add(Message(1, "Max", "message test 1message test 1 message test 1 message test 1 message test 1 message test 1 message test 1message test 1 message test 1", false, example));
    messages.add(Message(2, "Max", "message test 2 message test 2 message test 2 message test 2 message test 2 message test 2 message test 2 message test 2 message test 2 message test 2", false, example));
    messages.add(Message(3, "Harry", "message test 3", false, example));
    messages.add(Message(4, "Steve", "message test 4", false, example));
    messages.add(Message(5, "Tessa", "message test 5", false, example));
    messages.add(Message(6, "Marlou", "message test 6", false, example));
    messages.add(Message(7, "Marlou", "message test 7", false, example));
    messages.add(Message(8, "Kristi", "message test 8", false, example));
    messages.add(Message(9, "Test", "message test 9", false, example));
    messages.add(Message(10, "Test2", "message test 10", false, example));
    messages.add(Message(11, "Test2", "message test 11", false, example));
    _focusChatBox.addListener(_onFocusChange);
    super.initState();
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
        height: 300,
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

  Widget chatBoxTextField() {
    return TextFormField(
      focusNode: _focusChatBox,
      controller: chatFieldController,
      decoration: const InputDecoration(
        border: UnderlineInputBorder(),
        labelText: 'Type your message',
      ),
    );
  }

  Widget messageList() {
    return messages.isNotEmpty
        ? ListView.builder(
        itemCount: messages.length,
        reverse: true,
        controller: messageScrollController,
        itemBuilder: (context, index) {
          final reversedIndex = messages.length - 1 - index;
          return MessageTile(
              key: UniqueKey(),
              message: messages[reversedIndex]);
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
            TextStyle(color: Colors.white54, fontSize: 12),
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
