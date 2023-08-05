import 'package:flutter/material.dart';
import 'message.dart';


class GuildMessage extends Message {
  bool guildEvent;
  GuildMessage(super.senderId, super.senderName, super.body, super.me, super.timestamp, super.read, this.guildEvent);

  @override
  Color messageColour = Colors.orangeAccent;
}
