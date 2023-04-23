

import 'package:age_of_gold/services/settings.dart';
import 'package:age_of_gold/views/user_interface/ui_function/user_interface_components/chat_messages.dart';
import 'package:age_of_gold/views/user_interface/ui_function/user_interface_components/message.dart';
import 'package:age_of_gold/views/user_interface/ui_views/chat_box.dart';
import 'package:flutter/material.dart';

Widget messageList(ChatMessages chatMessages, ScrollController messageScrollController, Function(bool, String) userInteraction, ChatData? selectedChatData, bool isEvent, bool show) {
  List<Message> messages = chatMessages.chatMessages;
  if (isEvent) {
    messages = chatMessages.eventMessages;
  } else {
    if (selectedChatData != null) {
      messages = chatMessages.getMessagesFromUser(
          selectedChatData.name,
          Settings().getUser()!.getUserName()
      );
    } else {
      // In the regular world chat we want to filter out the personal messages that were send by the user
      messages = chatMessages.getAllWorldMessages(Settings().getUser()!.getUserName());
    }
  }
  // In the mobile mode there is always a small section of the chat visible.
  return messages.isNotEmpty && show
      ? ListView.builder(
      itemCount: messages.length,
      reverse: true,
      controller: messageScrollController,
      itemBuilder: (context, index) {
        final reversedIndex = messages.length - 1 - index;
        return MessageTile(
          key: UniqueKey(),
          message: messages[reversedIndex],
          userInteraction: userInteraction,
        );
      })
      : Container();
}

