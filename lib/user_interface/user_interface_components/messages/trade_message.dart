import 'package:flutter/material.dart';
import '../message.dart';


class TradeMessage extends Message {
  TradeMessage(super.id, super.senderName, super.body, super.me, super.timestamp);

  @override
  Color messageColour = Colors.blue;
}
