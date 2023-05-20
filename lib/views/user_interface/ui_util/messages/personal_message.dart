import 'package:flutter/material.dart';
import 'message.dart';


class PersonalMessage extends Message {
  String to;
  PersonalMessage(super.id, super.senderName, super.body, super.me, super.timestamp, super.read, this.to);

  @override
  Color messageColour = Colors.purpleAccent;

  bool equals(PersonalMessage other) {
    return this.senderName == other.senderName
        && this.body == other.body
        && this.me == other.me
        && this.timestamp == other.timestamp
        && this.to == other.to;
  }
}
