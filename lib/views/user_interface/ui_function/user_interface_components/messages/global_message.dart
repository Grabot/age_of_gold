import 'package:flutter/material.dart';
import '../message.dart';


class GlobalMessage extends Message {
  GlobalMessage(super.id, super.senderName, super.body, super.me, super.timestamp, super.read);

  @override
  Color messageColour = Colors.white;
}
