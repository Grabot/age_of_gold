import 'package:flutter/material.dart';


class Message {
  late int id;
  late String senderName;
  late String body;
  late DateTime timestamp;
  late bool me;
  Color messageColour = Colors.white;

  Message(this.id, this.senderName, this.body, this.me, this.timestamp);
}