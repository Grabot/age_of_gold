import 'package:flutter/material.dart';
import '../../age_of_gold.dart';
import '../../services/auth_service_world.dart';
import '../../services/socket_services.dart';
import '../../user_interface/user_interface_components/chat_messages.dart';
import '../../user_interface/user_interface_components/message.dart';
import 'package:intl/intl.dart';

import '../../util/util.dart';


class ChatBox extends StatefulWidget {

  final AgeOfGold game;

  const ChatBox({
    required Key key,
    required this.game
  }) : super(key: key);

  @override
  ChatBoxState createState() => ChatBoxState();
}

class ChatBoxState extends State<ChatBox> {

  final FocusNode _focusChatBox = FocusNode();
  var messageScrollController = ScrollController();

  final GlobalKey<FormState> _chatFormKey = GlobalKey<FormState>();

  TextEditingController chatFieldController = TextEditingController();

  SocketServices socket = SocketServices();
  late ChatMessages chatMessages;

  bool tileBoxVisible = false;

  final List<RegionData> _regions = RegionData.getRegions();
  late List<DropdownMenuItem<RegionData>> _dropdownMenuItems;
  late RegionData _selectedRegion;

  String activateTab = "All";

  @override
  void initState() {
    chatMessages = ChatMessages();
    socket.checkMessages(chatMessages);
    socket.addListener(socketListener);
    _focusChatBox.addListener(_onFocusChange);

    _dropdownMenuItems = buildDropdownMenuItems(_regions);
    _selectedRegion = _dropdownMenuItems[0].value!;
    super.initState();
  }

  List<DropdownMenuItem<RegionData>> buildDropdownMenuItems(List regions) {
    List<DropdownMenuItem<RegionData>> items = [];
    for (RegionData regionData in regions) {
      items.add(
        DropdownMenuItem(
          value: regionData,
          child: Container(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text(regionData.name)
              ],
            ),
          ),
        ),
      );
    }
    return items;
  }

  socketListener() {
    if (mounted) {
      setState(() {});
    }
  }

  void _onFocusChange() {
    widget.game.chatBoxFocus(_focusChatBox.hasFocus);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget chatTab(String tabName) {
    bool buttonActive = activateTab == tabName;

    return ElevatedButton(
      onPressed: () {
        if (tabName != activateTab) {
          setState(() {
            activateTab = tabName;
          });
        }
      },
      style: buttonStyle(buttonActive, Colors.green),
      child: Container(
        width: 40,
        child: Text(tabName),
      ),
    );
  }

  Widget topBar(double chatBoxWidth, double topBarHeight) {
    return Container(
      width: chatBoxWidth,
      height: topBarHeight,
      color: Colors.lightGreen,
      child: Align(
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: topBarHeight,
              height: topBarHeight,
              child: IconButton(
                icon: const Icon(Icons.email_outlined),
                tooltip: 'Open chat details',
                onPressed: () {
                  print("pressed");
                },
              ),
            ),
            tileBoxVisible ? chatTab("All") : Container(),
            tileBoxVisible ? chatTab("Global") : Container(),
            tileBoxVisible ? chatTab("Trade") : Container(),
            tileBoxVisible ? chatTab("Clan") : Container(),
            Container(
              width: topBarHeight,
              height: topBarHeight,
              color: Colors.lightGreen,
              child: tileBoxVisible ? IconButton(
                icon: const Icon(Icons.keyboard_double_arrow_down),
                color: Colors.white,
                tooltip: 'Hide chat',
                onPressed: () {
                  setState(() {
                    tileBoxVisible = !tileBoxVisible;
                  });
                },
              ) : IconButton(
                icon: const Icon(Icons.keyboard_double_arrow_up),
                color: Colors.white,
                tooltip: 'Show chat',
                onPressed: () {
                  setState(() {
                    tileBoxVisible = !tileBoxVisible;
                  });
                },
              )
            )
          ],
        ),
      ),
    );
  }

  Widget chatBoxWidget() {
    double chatBoxWidth = 450;
    if (MediaQuery.of(context).size.width <= 800) {
      // Here we assume that it is a phone and we set the width to the total
      chatBoxWidth = MediaQuery.of(context).size.width;
    }

    double topBarHeight = 40; // always visible
    double messageBoxHeight = 300;
    double chatTextFieldHeight = 60;
    double alwaysVisibleHeight = topBarHeight;
    double totalHeight = messageBoxHeight + chatTextFieldHeight + topBarHeight;

    return Align(
      alignment: FractionalOffset.bottomLeft,
      child: Container(
        width: chatBoxWidth,
        height: tileBoxVisible ? totalHeight : alwaysVisibleHeight,
        child: Column(
            children: [
              topBar(chatBoxWidth, topBarHeight),
              Container(
                width: chatBoxWidth,
                height: tileBoxVisible ? messageBoxHeight : 0,
                color: Colors.blueAccent,
                child: Column(
                  children: [
                    Expanded(
                      child: messageList(),
                    ),
                  ],
                ),
              ),
              chatBoxTextField(chatBoxWidth, chatTextFieldHeight)
            ]
        ),
      ),
    );
  }

  sendMessage(String message) {
    if (_chatFormKey.currentState!.validate()) {
      AuthServiceWorld().sendMessage(message).then((value) {
        if (value != "success") {
          // TODO: What to do when it is not successful
        } else {
          print("success!");
        }
      }).onError((error, stackTrace) {
        // TODO: What to do on an error?
      });
      chatFieldController.text = "";
    }
  }

  Widget chatBoxTextField(double chatBoxWidth, double chatTextFieldHeight) {
    double sendButtonWidth = 35;
    double regionSelectedWidth = 80;
    double regionSpacing = 10;
    if (tileBoxVisible) {
      return Container(
        color: Colors.blueAccent,
        child: Row(
            children: [
              Container(
                padding: EdgeInsets.only(right: regionSpacing),
                child: GestureDetector(
                  child: Container(
                    height: 40,
                    width: regionSelectedWidth,
                    child: chatDropDownRegion(),
                  ),
                ),
              ),
              SizedBox(
                width: chatBoxWidth - regionSelectedWidth - sendButtonWidth - regionSpacing,
                height: chatTextFieldHeight,
                child: Form(
                  key: _chatFormKey,
                  child: TextFormField(
                    validator: (val) {
                      if (val == null ||
                          val.isEmpty ||
                          val.trimRight().isEmpty) {
                        return "Can't send an empty message";
                      }
                      return null;
                    },
                    onFieldSubmitted: (value) {
                      sendMessage(value);
                    },
                    keyboardType: TextInputType.multiline,
                    focusNode: _focusChatBox,
                    controller: chatFieldController,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Type your message',
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  sendMessage(chatFieldController.text);
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

  Widget chatDropDownRegion() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.grey.withAlpha(95),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: Colors.white54,
            width: 2,
          ),
      ),
      child: DropdownButton(
        value: _selectedRegion,
        items: _dropdownMenuItems,
        onChanged: onChangeDropdownItem,
        style: TextStyle(
            color: Colors.white,
            fontSize: 15
        ),
        underline: Container(),
        isExpanded: true,
        iconSize: 0.0,
      ),
    );
  }

  onChangeDropdownItem(RegionData? selectedRegion) {
    setState(() {
      if (selectedRegion != null) {
        _selectedRegion = selectedRegion;
      }
    });
  }

  Widget messageList() {
    return chatMessages.chatMessages.isNotEmpty && tileBoxVisible
        ? ListView.builder(
        itemCount: chatMessages.chatMessages.length,
        reverse: true,
        controller: messageScrollController,
        itemBuilder: (context, index) {
          final reversedIndex = chatMessages.chatMessages.length - 1 - index;
          return MessageTile(
              key: UniqueKey(),
              message: chatMessages.chatMessages[reversedIndex]);
        })
        : Container();
  }

  @override
  Widget build(BuildContext context) {
    return chatBoxWidget();
  }

}

class MessageTile extends StatefulWidget {
  final Message message;

  const MessageTile(
      {
        required Key key,
        required this.message
      })
      : super(key: key);

  @override
  MessageTileState createState() => MessageTileState();
}

class MessageTileState extends State<MessageTile> {

  @override
  void initState() {
    super.initState();
  }

  Widget getMessageContent() {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: "[${DateFormat('HH:mm')
                .format(widget.message.timestamp)}] ",
            style:
            const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          TextSpan(
            text: "${widget.message.senderName}: ",
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          TextSpan(
            text: widget.message.body,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
}

class RegionData {
  int type;
  String name;

  RegionData(this.type, this.name);

  // The idea is that besides global
  // you will have recently whispered users and clans added in the dropdown
  static List<RegionData> getRegions() {
    return <RegionData>[
      RegionData(0, "Global"),
      RegionData(0, "Trade"),
      RegionData(0, "Clan"),
    ];
  }
}