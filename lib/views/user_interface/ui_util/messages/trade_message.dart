import 'package:flutter/material.dart';
import 'message.dart';


class TradeMessage extends Message {
  TradeMessage(super.senderId, super.senderName, super.body, super.me, super.timestamp, super.read);

  @override
  Color messageColour = Colors.blue;
}
