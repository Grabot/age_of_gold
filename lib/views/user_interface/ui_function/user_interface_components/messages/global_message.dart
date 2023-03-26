import 'package:flutter/material.dart';
import '../message.dart';


class GlobalMessage extends Message {
  GlobalMessage(super.id, super.senderName, super.body, super.me, super.timestamp);

  @override
  Color messageColour = Colors.white;
}
