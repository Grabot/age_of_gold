import 'package:flutter/material.dart';
import '../message.dart';


class SystemMessage extends Message {
  SystemMessage(super.id, super.senderName, super.body, super.me, super.timestamp);

  @override
  Color messageColour = Colors.grey;
}