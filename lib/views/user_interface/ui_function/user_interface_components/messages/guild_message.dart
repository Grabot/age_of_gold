import 'package:flutter/material.dart';
import '../message.dart';


class GuildMessage extends Message {
  GuildMessage(super.id, super.senderName, super.body, super.me, super.timestamp, super.read);

  @override
  Color messageColour = Colors.green.shade300;
}
