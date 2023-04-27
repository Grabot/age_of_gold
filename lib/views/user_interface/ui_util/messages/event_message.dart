import 'package:flutter/material.dart';
import 'message.dart';


class EventMessage extends Message {

  EventMessage(super.id, super.senderName, super.body, super.me, super.timestamp, super.read);

  @override
  Color messageColour = Colors.grey;
}
