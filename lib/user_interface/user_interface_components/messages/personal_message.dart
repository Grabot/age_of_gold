import 'package:flutter/material.dart';
import '../message.dart';


class PersonalMessage extends Message {
  PersonalMessage(super.id, super.senderName, super.body, super.me, super.timestamp);

  @override
  Color messageColour = Colors.purpleAccent.shade100;
}
