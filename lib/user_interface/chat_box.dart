
import 'package:flutter/material.dart';

import '../age_of_gold.dart';
import 'user_interface_components/message.dart';

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

  final FocusNode _focus = FocusNode();
  var messageScrollController = ScrollController();

  List<Message> messages = [];

  TextEditingController chatFieldController = TextEditingController();

  @override
  void initState() {
    messages.add(Message(1, 1, "message test 1"));
    messages.add(Message(2, 2, "message test 2"));
    messages.add(Message(3, 3, "message test 3"));
    messages.add(Message(4, 4, "message test 4"));
    messages.add(Message(5, 5, "message test 5"));
    messages.add(Message(6, 6, "message test 6"));
    messages.add(Message(7, 7, "message test 7"));
    messages.add(Message(8, 8, "message test 8"));
    messages.add(Message(9, 9, "message test 9"));
    messages.add(Message(10, 10, "message test 10"));
    messages.add(Message(11, 11, "message test 11"));
    _focus.addListener(_onFocusChange);
    super.initState();
  }

  void _onFocusChange() {
    debugPrint("Focus: ${_focus.hasFocus.toString()}");
    widget.game.chatBoxFocus(_focus.hasFocus);
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
        height: 200,
        color: Colors.orange,
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
      focusNode: _focus,
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

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      width: 100,
      color: Colors.green,
      child: Text(widget.message.body),
    );
  }
}
