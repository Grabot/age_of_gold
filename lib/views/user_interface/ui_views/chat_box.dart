import 'package:age_of_gold/services/auth_service_world.dart';
import 'package:age_of_gold/services/models/user.dart';
import 'package:age_of_gold/services/settings.dart';
import 'package:age_of_gold/util/util.dart';
import 'package:age_of_gold/views/user_interface/ui_function/user_interface_components/chat_messages.dart';
import 'package:age_of_gold/views/user_interface/ui_function/user_interface_components/message.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:age_of_gold/age_of_gold.dart';
import 'package:age_of_gold/services/socket_services.dart';


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
  late RegionData _selectedChatRegion;

  String activateTab = "Chat";

  int currentHexQ = 0;
  int currentHexR = 0;
  int currentTileQ = 0;
  int currentTileR = 0;

  @override
  void initState() {
    chatMessages = ChatMessages();
    socket.checkMessages(chatMessages);
    socket.addListener(socketListener);
    _focusChatBox.addListener(_onFocusChange);

    _dropdownMenuItems = buildDropdownMenuItems(_regions);
    _selectedChatRegion = _dropdownMenuItems[0].value!;
    super.initState();
  }

  List<DropdownMenuItem<RegionData>> buildDropdownMenuItems(List regions) {
    List<DropdownMenuItem<RegionData>> items = [];
    for (RegionData regionData in regions) {
      Color dropDownColour = Colors.white;
      if (regionData.type == 1) {
        dropDownColour = Colors.orange.shade300;
      } else if (regionData.type == 2) {
        dropDownColour = Colors.green.shade300;
      } else if (regionData.type == 3) {
        dropDownColour = Colors.purpleAccent.shade200;
      }
      items.add(
        DropdownMenuItem(
          value: regionData,
          child: Container(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(child:
                  Text(
                    regionData.name,
                    style: TextStyle(
                        color: dropDownColour,
                        fontSize: 15
                    ),
                  )
                )
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
    if (_focusChatBox.hasFocus) {
      // When it gets the focus we want to know where it is right now.
      List<int>? cameraProperties = widget.game.getCameraPos();
      if (cameraProperties != null) {
        currentHexQ = cameraProperties[0];
        currentHexR = cameraProperties[1];
        currentTileQ = cameraProperties[2];
        currentTileR = cameraProperties[3];
      }
    }
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
        width: 50,
        child: Text(tabName),
      ),
    );
  }

  Widget topBar(double chatBoxWidth, double topBarHeight) {
    return Container(
      width: chatBoxWidth,
      height: topBarHeight,
      color: Colors.lightGreen.withOpacity(0.75),
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
            tileBoxVisible ? chatTab("Chat") : Container(),
            tileBoxVisible ? chatTab("Events") : Container(),
            Container(
              width: topBarHeight,
              height: topBarHeight,
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

    bool isEvent = activateTab == "Events";
    if (isEvent) {
      messageBoxHeight += chatTextFieldHeight;
    }

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
                color: Colors.black.withOpacity(0.4),
                child: Column(
                  children: [
                    Expanded(
                      child: messageList(isEvent),
                    ),
                  ],
                ),
              ),
              !isEvent ? chatBoxTextField(chatBoxWidth, chatTextFieldHeight) : Container()
            ]
        ),
      ),
    );
  }

  sendMessage(String message) {
    if (_chatFormKey.currentState!.validate()) {
      String? toUser;
      if (_selectedChatRegion.type == 0) {
        AuthServiceWorld().sendMessageChatGlobal(message);
      } else if (_selectedChatRegion.type == 1) {
        AuthServiceWorld().sendMessageChatLocal(message, currentHexQ, currentHexR, currentTileQ, currentTileR);
      } else if (_selectedChatRegion.type == 2) {
        AuthServiceWorld().sendMessageChatGuild(message, "TODO");
      } else if (_selectedChatRegion.type == 3) {
        toUser = _selectedChatRegion.name;
        AuthServiceWorld().sendMessageChatPersonal(message, toUser);
      }
      chatFieldController.text = "";
    }
  }

  Widget chatBoxTextField(double chatBoxWidth, double chatTextFieldHeight) {
    double sendButtonWidth = 35;
    double regionSelectedWidth = 80;
    double regionSpacing = 10;
    if (tileBoxVisible) {
      return Container(
        color: Colors.black.withOpacity(0.7),
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
    Color dropDownColour = Colors.white;
    return Container(
      decoration: BoxDecoration(
          color: Colors.grey.withAlpha(95),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: dropDownColour.withOpacity(0.54),
            width: 2,
          ),
      ),
      child: DropdownButton(
        value: _selectedChatRegion,
        items: _dropdownMenuItems,
        onChanged: onChangeDropdownItem,
        underline: Container(),
        isExpanded: true,
        iconSize: 0.0,
      ),
    );
  }

  onChangeDropdownItem(RegionData? selectedRegion) {
    setState(() {
      if (selectedRegion != null) {
        _selectedChatRegion = selectedRegion;
      }
    });
  }

  Widget messageList(bool isEvent) {
    List<Message> messages = chatMessages.chatMessages;
    if (isEvent) {
      messages = chatMessages.eventMessages;
    }
    return messages.isNotEmpty && tileBoxVisible
        ? ListView.builder(
        itemCount: messages.length,
        reverse: true,
        controller: messageScrollController,
        itemBuilder: (context, index) {
          final reversedIndex = messages.length - 1 - index;
          return MessageTile(
            key: UniqueKey(),
            message: messages[reversedIndex],
            region: _selectedChatRegion.name,
            userInteraction: userInteraction,
          );
        })
        : Container();
  }

  @override
  Widget build(BuildContext context) {
    return chatBoxWidget();
  }

  String userSelected = "";
  userInteraction(bool message, String userName) {
    if (message) {
      // message the user
      // select personal region if it exists, otherwise just create it first.
      userSelected = userName;
      bool exists = false;
      for (int i = 0; i < _regions.length; i++) {
        if (_regions[i].name == userName) {
          _selectedChatRegion = _dropdownMenuItems[i].value!;
          exists = true;
        }
      }
      if (!exists) {
        RegionData newRegionData = RegionData(3, userName);
        // probably not needed
        _regions.add(newRegionData);
        DropdownMenuItem<RegionData> newDropDownItem = DropdownMenuItem(
          value: newRegionData,
          child: Container(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    newRegionData.name,
                    overflow: TextOverflow.fade,
                    maxLines: 1,
                    softWrap: false,
                    style: TextStyle(
                        color: Colors.purpleAccent.shade200,
                        fontSize: 15
                    ),
                  ),
                )
              ],
            ),
          ),
        );
        _dropdownMenuItems.add(newDropDownItem);
        _selectedChatRegion = _dropdownMenuItems.last.value!;
      }
      setState(() {});
    } else {
      // open the user overview panel.
    }
  }
}

class MessageTile extends StatefulWidget {
  final Message message;
  final String region;
  final Function(bool, String) userInteraction;

  const MessageTile(
      {
        required Key key,
        required this.message,
        required this.region,
        required this.userInteraction
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
    Color textColour = widget.message.messageColour;
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: "[${DateFormat('HH:mm')
                .format(widget.message.timestamp)}] ",
            style: TextStyle(
                color: textColour.withOpacity(0.54),
                fontSize: 12
            ),
          ),
          TextSpan(
            text: "${widget.message.senderName}: ",
            recognizer: TapGestureRecognizer()..onTapDown = _showPopupMenu,
            style: TextStyle(
                color: textColour,
                fontWeight: FontWeight.bold,
                fontSize: 16
            ),
          ),
          TextSpan(
            text: widget.message.body,
            style: TextStyle(
                color: textColour.withOpacity(0.70),
                fontSize: 16
            ),
          ),
        ],
      ),
    );
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
      if (widget.message.senderName != myself.userName
          && widget.message.senderName != "Server") {
        _storePosition(details);
        _showChatDetailPopupMenu();
      }
    }
  }

  void _showChatDetailPopupMenu() {
    final RenderBox overlay =
    Overlay.of(context).context.findRenderObject() as RenderBox;

    showMenu(
        context: context,
        items: [ChatDetailPopup(key: UniqueKey())],
        position: RelativeRect.fromRect(
            _tapPosition! & const Size(40, 40), Offset.zero & overlay.size))
        .then((int? delta) {
      if (delta == 1) {
        widget.userInteraction(true, widget.message.senderName);
      } else if (delta == 2) {
        widget.userInteraction(false, widget.message.senderName);
      }
      return;
    });
  }

  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
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
      RegionData(1, "Local"),
      RegionData(2, "Guild"),  // TODO: only make visible when in a guild
    ];
  }
}

class ChatDetailPopup extends PopupMenuEntry<int> {

  ChatDetailPopup({required Key key}) : super(key: key);

  @override
  bool represents(int? n) => n == 1 || n == -1;

  @override
  ChatDetailPopupState createState() => ChatDetailPopupState();

  @override
  double get height => 1;
}

class ChatDetailPopupState extends State<ChatDetailPopup> {
  @override
  Widget build(BuildContext context) {
    return getPopupItems(context);
  }
}

void buttonMessageUser(BuildContext context) {
  Navigator.pop<int>(context, 1);
}

void buttonViewUser(BuildContext context) {
  Navigator.pop<int>(context, 2);
}

Widget getPopupItems(BuildContext context) {
  return Column(children: [
    Container(
      alignment: Alignment.centerLeft,
      child: TextButton(
          onPressed: () {
            buttonMessageUser(context);
          },
          child: Text(
            'Message user',
            textAlign: TextAlign.left,
            style: TextStyle(color: Colors.white, fontSize: 14),
          )),
    ),
    Container(
      alignment: Alignment.centerLeft,
      child: TextButton(
          onPressed: () {
            buttonViewUser(context);
          },
          child: Text(
            "View user",
            textAlign: TextAlign.left,
            style: TextStyle(color: Colors.white, fontSize: 14),
          )),
    ),
  ]);
}
