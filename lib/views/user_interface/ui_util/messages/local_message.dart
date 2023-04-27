import 'package:flutter/material.dart';
import 'message.dart';


class LocalMessage extends Message {
  LocalMessage(super.id, super.senderName, super.body, super.me, super.timestamp, super.read);

  @override
  Color messageColour = Colors.orange.shade300;
}
