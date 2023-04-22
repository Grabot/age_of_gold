import 'package:flutter/material.dart';

import 'message.dart';
import 'messages/event_message.dart';
import 'messages/guild_message.dart';
import 'messages/global_message.dart';
import 'messages/local_message.dart';
import 'messages/personal_message.dart';


class ChatMessages extends ChangeNotifier {
  List<Message> chatMessages = [];
  List<EventMessage> eventMessages = [];

  static final ChatMessages _instance = ChatMessages._internal();

  ChatMessages._internal() {
    initializeChatMessages();
  }

  factory ChatMessages() {
    return _instance;
  }

  initializeChatMessages() {
    DateTime currentTime = DateTime.now();
    String message = "Welcome to the Age of Gold chat!";
    Message newMessage = Message(1, "Server", message, false, currentTime, true);
    chatMessages.add(newMessage);
    String messageEvent = "Here you can see any event that happened in your view!";
    EventMessage newEventMessage = EventMessage(1, "Server", messageEvent, false, currentTime, true);
    eventMessages.add(newEventMessage);
  }

  addPersonalMessage(String from, String to, String message) {
    DateTime currentTime = DateTime.now();
    Message newMessage = PersonalMessage(1, from, message, false, currentTime, false, to);
    chatMessages.add(newMessage);
    notifyListeners();
  }

  addMessage(String userName, String message, int regionType) {
    DateTime currentTime = DateTime.now();
    Message? newMessage;
    // These will not all work this way and they will probably
    // functionally work different, but for now see them as placeholders
    // TODO: what to do with id's? Use them or remove them?
    if (regionType == 1) {
      newMessage = LocalMessage(1, userName, message, false, currentTime, false);
    } else if (regionType == 2) {
      newMessage = GuildMessage(1, userName, message, false, currentTime, false);
    } else {
      newMessage = GlobalMessage(1, userName, message, false, currentTime, false);
    }
    chatMessages.add(newMessage);
    notifyListeners();
  }

  List<Message> getMessagesFromUser(String senderName, String me) {
    List<PersonalMessage> personalMessages = chatMessages.whereType<PersonalMessage>().toList();
    return personalMessages.where((message) =>
          (message.senderName == senderName && message.to == me)
        || (message.senderName == me && message.to == senderName)
    ).toList();
  }

  addEventMessage(String message, String userName) {
    DateTime currentTime = DateTime.now();
    EventMessage newMessage = EventMessage(1, userName, message, false, currentTime, false);
    eventMessages.add(newMessage);
    notifyListeners();
  }

  removeOldMessages() {
    if (chatMessages.length > 1000) {
      chatMessages.removeAt(0);
    }
    if (eventMessages.length > 100) {
      eventMessages.removeAt(0);
    }
  }

  clearMessages() {
    chatMessages = [];
    eventMessages = [];
    initializeChatMessages();
  }
}
