import 'package:flutter/material.dart';


class Message {
  late int id;
  late String senderName;
  late String body;
  late DateTime timestamp;
  late bool me;
  late bool read;
  Color messageColour = Colors.black12;

  Message(this.id, this.senderName, this.body, this.me, this.timestamp, this.read);

  bool equals(Message other) {
    return this.senderName == other.senderName
        && this.body == other.body
        && this.me == other.me
        && this.timestamp == other.timestamp;
  }
}
