import 'package:flutter/material.dart';


class Message {
  late int senderId;
  late String senderName;
  late String body;
  late DateTime timestamp;
  late bool me;
  late bool read;
  Color messageColour = Colors.black12;

  Message(this.senderId, this.senderName, this.body, this.me, this.timestamp, this.read);

  bool equals(Message other) {
    return senderName == other.senderName
        && body == other.body
        && me == other.me
        && timestamp == other.timestamp;
  }
}
