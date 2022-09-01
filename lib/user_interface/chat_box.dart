
import 'package:flutter/material.dart';

import 'user_interface_components/message.dart';

List<Message> messages = [
  Message(1, 1, "message test 1"),
  Message(2, 2, "message test 2"),
  Message(3, 3, "message test 3"),
  Message(4, 4, "message test 4"),
  Message(5, 5, "message test 5"),
  Message(6, 6, "message test 6"),
  Message(7, 7, "message test 7")
];
var messageScrollController = ScrollController();

Widget chatBoxWidget() {
  return Align(
    alignment: FractionalOffset.bottomLeft,
    child: Container(
      width: 400,
      height: 80,
      color: Colors.orange,
      child: Column(
        children: [
          Expanded(
            child: messageList()
          ),
        ]
      ),
    ),
  );
}

Widget messageList() {
  return messages.isNotEmpty
      ? ListView.builder(
      itemCount: messages.length,
      shrinkWrap: true,
      reverse: true,
      controller: messageScrollController,
      itemBuilder: (context, index) {
        return MessageTile(
            key: UniqueKey(),
            message: messages[index]);
      })
      : Container();
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
