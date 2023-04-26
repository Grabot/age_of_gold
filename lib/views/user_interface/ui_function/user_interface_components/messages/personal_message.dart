import 'package:flutter/material.dart';
import '../message.dart';


class PersonalMessage extends Message {
  String to;
  PersonalMessage(super.id, super.senderName, super.body, super.me, super.timestamp, super.read, this.to);

  @override
  Color messageColour = Colors.purpleAccent;
}
