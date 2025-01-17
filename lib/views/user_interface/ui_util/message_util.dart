import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../services/auth_service_social.dart';
import '../../../services/models/user.dart';
import '../../../services/settings.dart';
import 'chat_messages.dart';
import 'messages/message.dart';


Widget messageList(List<Message> messages, ScrollController messageScrollController, Function(bool, int, String) userInteraction, ChatData? selectedChatData, bool isEvent, bool show, double fontSize, bool minimized) {

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
          fontSize: fontSize,
          minimized: minimized,
        );
      })
      : Container();
}


class MessageTile extends StatefulWidget {
  final Message message;
  final Function(bool, int, String) userInteraction;
  final double fontSize;
  final bool minimized;

  const MessageTile(
      {
        required Key key,
        required this.message,
        required this.userInteraction,
        required this.fontSize,
        required this.minimized
      })
      : super(key: key);

  @override
  MessageTileState createState() => MessageTileState();
}

class MessageTileState extends State<MessageTile> {

  bool isMe = false;
  @override
  void initState() {
    if (Settings().getUser() != null) {
      if (widget.message.senderName == Settings().getUser()!.getUserName()) {
        isMe = true;
      }
    }
    super.initState();
  }

  TextSpan textBody() {
    Color textColour = Colors.white;
    return TextSpan(
      text: widget.message.body,
      style: TextStyle(
          color: textColour.withOpacity(0.80),
          fontSize: widget.fontSize
      ),
    );
  }

  TextSpan textSenderName() {
    Color textColour = Colors.white;
    return TextSpan(
      text: " ${widget.message.senderName}: ",
      recognizer: TapGestureRecognizer()
        ..onTapDown = _showPopupMenu,
      style: TextStyle(
          color: textColour,
          fontWeight: FontWeight.bold,
          fontSize: widget.fontSize
      ),
    );
  }

  TextSpan textDate() {
    Color textColour = Colors.white;
    return TextSpan(
      text: "[${DateFormat('HH:mm')
          .format(widget.message.timestamp)}] ",
      style: TextStyle(
          color: textColour.withOpacity(0.54),
          fontSize: widget.fontSize - 6
      ),
    );
  }

  Widget messageBubbleMe() {
    return Container(
      alignment: Alignment.bottomRight,
      child: Container(
        padding: const EdgeInsets.only(left: 10.0, right: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          color: const Color(0xFF009E00).withOpacity(0.6),
        ),
        child: RichText(
          textAlign: TextAlign.right,
          maxLines: widget.minimized ? 1 : null,
          overflow: widget.minimized ? TextOverflow.ellipsis : TextOverflow.clip,
          text: TextSpan(
            children: [
              textDate(),
              textSenderName(),
              textBody(),
            ]
          )
        ),
      )
    );
  }

  Widget messageBubble(Color textColour) {
    return Container(
        alignment: Alignment.bottomLeft,
        child: Container(
          padding: const EdgeInsets.only(left: 10.0, right: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            color: textColour.withOpacity(0.6),
          ),
          child: RichText(
              textAlign: TextAlign.left,
              maxLines: widget.minimized ? 1 : null,
              overflow: widget.minimized ? TextOverflow.ellipsis : TextOverflow.clip,
              text: TextSpan(
                  children: [
                    textDate(),
                    textSenderName(),
                    textBody(),
                  ]
              )
          ),
        )
    );
  }

  Widget timeMessageBubble() {
    return Container(
        alignment: Alignment.center,
        child: Container(
          padding: const EdgeInsets.only(left: 10.0, right: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            color: Colors.grey.withOpacity(0.8),
          ),
          child: RichText(
            maxLines: widget.minimized ? 1 : null,
            overflow: widget.minimized ? TextOverflow.ellipsis : TextOverflow.clip,
            textAlign: TextAlign.left,
            text: textBody(),
          ),
        )
    );
  }

  Widget getMessageContent() {
    if (widget.message.senderId == -2) {
      return timeMessageBubble();
    } else {
      return isMe ? messageBubbleMe() : messageBubble(
          widget.message.messageColour);
    }
  }

  Widget message() {
    return Material(
      color: Colors.transparent,
      child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              width: MediaQuery.of(context).size.width,
              alignment: Alignment.bottomLeft,
              child: Container(
                  child: getMessageContent()
              ),
            ),
          ]
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return message();
  }

  Offset? _tapPosition;

  void _showPopupMenu(TapDownDetails details) {
    User? myself = Settings().getUser();
    if (myself != null) {
      // only show popup for different users. Not myself or the server.
      bool isMe = widget.message.senderName == myself.userName;
      if (widget.message.senderName != "Server") {
        _storePosition(details);
        _showChatDetailPopupMenu(isMe);
      }
    }
  }

  void _showChatDetailPopupMenu(bool isMe) {
    final RenderBox overlay =
    Overlay.of(context).context.findRenderObject() as RenderBox;

    showMenu(
        context: context,
        items: [ChatDetailPopup(key: UniqueKey(), isMe: isMe)],
        position: RelativeRect.fromRect(
            _tapPosition! & const Size(40, 40), Offset.zero & overlay.size))
        .then((int? delta) {
      if (delta == 0) {
        widget.userInteraction(true, widget.message.senderId, widget.message.senderName);
      } else if (delta == 1) {
        widget.userInteraction(false, widget.message.senderId, widget.message.senderName);
      }
      return;
    });
  }

  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }
}

Widget chatTextField(double chatBoxWidth, double chatTextFieldHeight, bool visible, String activeTab, GlobalKey<FormState> chatFormKey, FocusNode focusChatBox, TextEditingController chatFieldController, ChatData? selectedChatData, Function(String) onChangedField) {
  double sendButtonWidth = 35;
  double regionSpacing = 10;
  if (visible) {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Row(
          children: [
            SizedBox(
              width: chatBoxWidth - sendButtonWidth - regionSpacing,
              height: chatTextFieldHeight,
              child: Form(
                key: chatFormKey,
                child: TextFormField(
                  validator: (val) {
                    if (val == null ||
                        val.isEmpty ||
                        val
                            .trimRight()
                            .isEmpty) {
                      return "Can't send an empty message";
                    }
                    return null;
                  },
                  onChanged: (value) {
                    onChangedField(value);
                  },
                  enabled: Settings().getUser() != null,
                  onFieldSubmitted: (value) {
                    sendMessage(value, activeTab, chatFormKey, selectedChatData);
                    chatFieldController.text = "";
                    focusChatBox.requestFocus();
                  },
                  keyboardType: TextInputType.multiline,
                  focusNode: focusChatBox,
                  controller: chatFieldController,
                  decoration:  const InputDecoration(
                    border: InputBorder.none,
                    labelText: 'Type your message',
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                sendMessage(chatFieldController.text, activeTab, chatFormKey, selectedChatData);
                chatFieldController.text = "";
                focusChatBox.requestFocus();
              },
              child: Container(
                  height: 35,
                  width: sendButtonWidth,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: const Icon(
                    Icons.send,
                    color: Colors.white,
                  )
              ),
            )
          ]
      ),
    );
  } else {
    return Container();
  }
}

sendMessage(String message, String activeTab, GlobalKey<FormState> chatFormKey, ChatData? selectedChatData) {
  if (chatFormKey.currentState!.validate()) {
    if (activeTab == "World") {
      AuthServiceSocial().sendMessageChatGlobal(message);
    } else if (activeTab == "Guild") {
      if (Settings().getUser() != null) {
        if (Settings().getUser()!.getGuild() != null) {
          AuthServiceSocial().sendMessageChatGuild(Settings().getUser()!.getGuild()!.getGuildId(), message);
        }
      }
    } else if (activeTab == "Personal") {
      if (selectedChatData != null) {
        int toUserid = selectedChatData.senderId;
        AuthServiceSocial().sendMessageChatPersonal(message, toUserid);
      }
    }
  }
}
