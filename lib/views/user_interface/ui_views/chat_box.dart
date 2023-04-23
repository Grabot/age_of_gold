import 'package:age_of_gold/services/auth_service_message.dart';
import 'package:age_of_gold/services/auth_service_world.dart';
import 'package:age_of_gold/services/models/user.dart';
import 'package:age_of_gold/services/settings.dart';
import 'package:age_of_gold/util/util.dart';
import 'package:age_of_gold/views/user_interface/ui_function/user_interface_components/chat_messages.dart';
import 'package:age_of_gold/views/user_interface/ui_function/user_interface_components/message.dart';
import 'package:age_of_gold/views/user_interface/ui_function/user_interface_components/messages/event_message.dart';
import 'package:age_of_gold/views/user_interface/ui_function/user_interface_components/messages/personal_message.dart';
import 'package:age_of_gold/views/user_interface/ui_function/user_interface_util/chat_box_change_notifier.dart';
import 'package:age_of_gold/views/user_interface/ui_function/user_interface_util/chat_window_change_notifier.dart';
import 'package:age_of_gold/views/user_interface/ui_function/user_interface_util/message_util.dart';
import 'package:age_of_gold/views/user_interface/ui_function/user_interface_util/user_box_change_notifier.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
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
  late ChatBoxChangeNotifier chatBoxChangeNotifier;

  bool tileBoxVisible = false;

  // final List<RegionData> _regions = RegionData.getRegions();
  List<ChatData> _regions = [];
  late List<DropdownMenuItem<ChatData>> _dropdownMenuItems;
  ChatData? _selectedChatData;

  String activateTab = "World";

  // TODO: Will the "local" chat option remain? This can be removed if not.
  int currentHexQ = 0;
  int currentHexR = 0;
  int currentTileQ = 0;
  int currentTileR = 0;

  bool unreadWorldMessages = false;
  bool unreadEventMessages = false;

  @override
  void initState() {
    chatBoxChangeNotifier = ChatBoxChangeNotifier();
    chatBoxChangeNotifier.addListener(chatBoxChangeListener);

    chatMessages = ChatMessages();
    chatMessages.addListener(newMessageListener);
    socket.checkMessages(chatMessages);
    socket.addListener(socketListener);
    _focusChatBox.addListener(_onFocusChange);

    // populate chatData with guilds or friends?
    ChatData chatData = ChatData(0, "No Chats Found!", false);
    _regions.add(chatData);
    _dropdownMenuItems = buildDropdownMenuItems(_regions);
    super.initState();
  }

  newDropDownItem(ChatData newChatData, Color textColour) {
    return DropdownMenuItem(
      value: newChatData,
      child: Container(
        padding: const EdgeInsets.only(left: 6.0),
        child: Row(
          children: [
            newChatData.unreadMessages ? Text("! ") : Text("  "),
            Expanded(
              child: Text(
                newChatData.name,
                overflow: TextOverflow.fade,
                maxLines: 1,
                softWrap: false,
                style: TextStyle(
                    color: textColour,
                    fontSize: 16
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  removeUnreadPersonalMessage(ChatData removeUnreadMessage) {

    DropdownMenuItem<ChatData>? messageDropDown;
    for (DropdownMenuItem<ChatData> dropdownMenuItem in _dropdownMenuItems) {
      if (dropdownMenuItem.value!.name == removeUnreadMessage.name) {
        messageDropDown = dropdownMenuItem;
      }
    }
    if (messageDropDown != null) {
      ChatData newChatData = ChatData(removeUnreadMessage.type, removeUnreadMessage.name, false);
      DropdownMenuItem<ChatData> newMessageDropDown = newDropDownItem(newChatData, getChatColour(newChatData.type));
      // add the new objects to their lists
      _regions.add(newChatData);
      _dropdownMenuItems.add(newMessageDropDown);

      if (_selectedChatData == removeUnreadMessage) {
        _selectedChatData = newChatData;
      }
      // remove the old objects from their lists
      _regions.remove(removeUnreadMessage);
      _dropdownMenuItems.remove(messageDropDown);
    }
  }

  checkForUnreadPersonalMessages(PersonalMessage lastMessage) {
    // If the Chatbox is open but they get a personal message,
    // show the indicator within the dropdown menu from who it was.
    // Not sure why, but the only way I got it too work was to find
    // both the objects in the regions and dropdownmenuitems and clone them.
    // After that remove the old objects and add the cloned objects
    // to the list with the correct boolean set.
    ChatData? messageChat;
    for (ChatData chatData in _regions) {
      if (chatData.name == lastMessage.senderName) {
        messageChat = chatData;
      }
    }
    DropdownMenuItem<ChatData>? messageDropDown;
    for (DropdownMenuItem<ChatData> dropdownMenuItem in _dropdownMenuItems) {
      if (dropdownMenuItem.value!.name == lastMessage.senderName) {
        messageDropDown = dropdownMenuItem;
      }
    }
    if (messageChat != null && messageDropDown != null) {
      if (_selectedChatData != messageChat) {
        ChatData newChatData = ChatData(
            messageChat.type, messageChat.name, true);
        DropdownMenuItem<ChatData> newMessageDropDown = newDropDownItem(newChatData, getChatColour(newChatData.type));
        // add the new objects to their lists
        _regions.add(newChatData);
        _dropdownMenuItems.add(newMessageDropDown);

        if (_selectedChatData == messageChat) {
          _selectedChatData = newChatData;
        }
        // remove the old objects from their lists
        _regions.remove(messageChat);
        _dropdownMenuItems.remove(messageDropDown);
      }
    } else {
      // if the dropdown item is not present yet create it with unread messages
      // As long as it is not the current user. or if the chatbox is open on this chatbox
      if (Settings().getUser()!.getUserName() != lastMessage.senderName) {
        ChatData newChatData = ChatData(3, lastMessage.senderName, true);
        DropdownMenuItem<ChatData> newMessageDropDown = newDropDownItem(
            newChatData, getChatColour(newChatData.type));
        _regions.add(newChatData);
        _dropdownMenuItems.add(newMessageDropDown);
        removePlaceholder();
      }
    }
  }

  newMessageListener() {
    if (mounted) {
      Message lastMessage = chatMessages.chatMessages.last;
      EventMessage eventMessage = chatMessages.eventMessages.last;

      if (lastMessage is PersonalMessage && !lastMessage.read) {
        checkForUnreadPersonalMessages(lastMessage);
      }
      if (!lastMessage.read && lastMessage.senderName != Settings().getUser()!.getUserName()) {
        unreadWorldMessages = true;
      }
      if (!eventMessage.read && eventMessage.senderName != Settings().getUser()!.getUserName()) {
        unreadEventMessages = true;
      }
      if (tileBoxVisible) {
        if (activateTab == "World") {
          unreadWorldMessages = false;
          lastMessage.read = true;
        }
        if (activateTab == "Events") {
          unreadEventMessages = false;
          eventMessage.read = true;
        }
      }
      setState(() {});
      chatMessages.removeOldMessages();
    }
  }

  chatBoxChangeListener() {
    if (mounted) {
      if (!tileBoxVisible && chatBoxChangeNotifier.getChatBoxVisible()) {
        setState(() {
          if (chatBoxChangeNotifier.getChatUser() != null) {
            userInteraction(true, chatBoxChangeNotifier.getChatUser()!);
            activateTab = "Personal";
          }
          tileBoxVisible = true;
        });
      }
      if (tileBoxVisible && !chatBoxChangeNotifier.getChatBoxVisible()) {
        setState(() {
          tileBoxVisible = false;
        });
      }
      if (tileBoxVisible && chatBoxChangeNotifier.getChatUser() != null) {
        // The user has selected a user to message. Change to that chat.
        userInteraction(true, chatBoxChangeNotifier.getChatUser()!);
        activateTab = "Personal";
        _focusChatBox.requestFocus();
      }
    }
  }

  List<DropdownMenuItem<ChatData>> buildDropdownMenuItems(List regions) {
    List<DropdownMenuItem<ChatData>> items = [];
    for (ChatData chatData in regions) {
      items.add(newDropDownItem(chatData, getChatColour(chatData.type)));
    }
    return items;
  }

  Color getChatColour(int chatType) {
    Color dropDownColour = Colors.white;
    if (chatType == 1) {
      dropDownColour = Colors.orange.shade300;
    } else if (chatType == 2) {
      dropDownColour = Colors.green.shade300;
    } else if (chatType == 3) {
      dropDownColour = Colors.purpleAccent.shade200;
    }
    return dropDownColour;
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

  pressedChatTab(String tabName) {
    print("pressed chat tab");
    if (!tileBoxVisible) {
      tileBoxVisible = true;
    }
    if (tabName != activateTab) {
      setState(() {
        activateTab = tabName;
        _selectedChatData = null;
        readMessages();
      });
    }
  }

  Widget chatTab(String tabName, bool hasUnreadMessages) {
    bool buttonActive = activateTab == tabName;
    if (!tileBoxVisible) {
      buttonActive = false;
      activateTab = "";
    }
    return ElevatedButton(
      onPressed: () {
        pressedChatTab(tabName);
      },
      style: buttonStyle(buttonActive, Colors.green),
      child: Row(
        children: [
          hasUnreadMessages ? Text("!  ") : Text("   "),
          Container(
            width: 50,
            child: Text(tabName),
          ),
        ]
      ),
    );
  }

  readMessages() {
    if (activateTab == "") {
      // If there is no tab active we will activate the world tab
      activateTab = "World";
    }
    if (activateTab == "World") {
      unreadWorldMessages = false;
      // We only set the last one to true,
      // since that's the one we use to determine if there are unread messages
      chatMessages.chatMessages.last.read = true;
    } else if (activateTab == "Events") {
      unreadEventMessages = false;
      chatMessages.eventMessages.last.read = true;
    }
  }

  showChatWindow() {
    print("showing chat window");
    ChatBoxChangeNotifier().setChatBoxVisible(false);
    ChatWindowChangeNotifier().setChatWindowVisible(true);
  }

  Widget showOrHideChatBox(double iconSize) {
    if (tileBoxVisible) {
      return Container(
          width: iconSize,
          height: iconSize,
          child: IconButton(
          icon: const Icon(Icons.keyboard_double_arrow_down),
          color: Colors.white,
          tooltip: 'Hide chat',
          onPressed: () {
            setState(() {
              _selectedChatData = null;
              activateTab = "World";
              tileBoxVisible = !tileBoxVisible;
            });
          },
        ),
      );
    } else {
      return Container(
        width: iconSize,
        height: iconSize,
        child: IconButton(
        icon: const Icon(Icons.keyboard_double_arrow_up),
        color: Colors.white,
        tooltip: 'Show chat',
        onPressed: () {
          setState(() {
            readMessages();
            tileBoxVisible = !tileBoxVisible;
          });
        },
    ),
      );
    }
  }

  Widget chatDropDownRegionTopBar() {
    return Container(
      padding: EdgeInsets.only(left: 5, right: 5),
      child: GestureDetector(
        child: Container(
          height: 34,
          width: 120,
          child: chatDropDownRegion(),
        ),
      ),
    );
  }

  Widget chatTabWorld() {
    return chatTab("World", unreadWorldMessages);
  }

  Widget chatTabEvents() {
    return chatTab("Events", unreadEventMessages);
  }

  Widget chatTabChats() {
    return chatDropDownRegionTopBar();
  }

  Widget showMesssageWindow(double iconSize) {
    return Container(
      width: iconSize,
      height: iconSize,
      child: IconButton(
        icon: const Icon(Icons.mail),
        color: Colors.white,
        tooltip: 'Show chat window',
        onPressed: () {
          showChatWindow();
        },
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
            showMesssageWindow(topBarHeight),
            chatTabWorld(),
            chatTabEvents(),
            chatTabChats(),
            showOrHideChatBox(topBarHeight)
          ],
        ),
      ),
    );
  }

  Widget chatBoxNormal(double chatBoxWidth) {

    double topBarHeight = 34; // always visible
    double messageBoxHeight = 300;
    double chatTextFieldHeight = 60;
    double alwaysVisibleHeight = topBarHeight;
    double totalHeight = messageBoxHeight + chatTextFieldHeight + topBarHeight;

    bool isEvent = activateTab == "Events";
    bool userLoggedIn = Settings().getUser() != null;
    if (isEvent || !userLoggedIn) {
      messageBoxHeight += chatTextFieldHeight;
    }

    bool showMessageField = (tileBoxVisible || !normalMode);

    return Container(
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
                    child: messageList(chatMessages, messageScrollController, userInteraction, _selectedChatData, isEvent, showMessageField),
                  ),
                ],
              ),
            ),
            !isEvent && userLoggedIn ? chatBoxTextField(chatBoxWidth, chatTextFieldHeight) : Container()
          ]
      ),
    );
  }

  Widget mobileMinimized(double chatBoxWidth, double topBarHeight) {
    bool showMessageField = (tileBoxVisible || !normalMode);
    return Row(
      children: [
        showMesssageWindow(topBarHeight),
        GestureDetector(
          onTap: () {
            setState(() {
              tileBoxVisible = true;
              readMessages();
            });
          },
          child: SizedBox(
            width: chatBoxWidth - (topBarHeight * 2),
            child: Column(
              children: [
                Expanded(
                  child: messageList(chatMessages, messageScrollController, userInteraction, _selectedChatData, false, showMessageField),
                ),
              ],
            ),
          ),
        ),
        showOrHideChatBox(topBarHeight)
      ],
    );
  }

  Widget mobileMaximized(double chatBoxWidth, double totalHeight, double topBarHeight) {
    double chatTextFieldHeight = 60;
    double messageBoxHeight = totalHeight - chatTextFieldHeight - topBarHeight;

    bool isEvent = activateTab == "Events";
    bool userLoggedIn = Settings().getUser() != null;
    if (isEvent || !userLoggedIn) {
      messageBoxHeight += chatTextFieldHeight;
    }
    bool showMessageField = (tileBoxVisible || !normalMode);

    return Container(
      width: chatBoxWidth,
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
                  child: messageList(chatMessages, messageScrollController, userInteraction, _selectedChatData, isEvent, showMessageField),
                ),
              ],
            ),
          ),
          !isEvent && userLoggedIn ? chatBoxTextField(chatBoxWidth, chatTextFieldHeight) : Container()
        ],
      ),
    );
  }

  Widget chatBoxMobile(double chatBoxWidth) {
    double topBarHeight = tileBoxVisible ? 34 : 50;
    double totalHeight = MediaQuery.of(context).size.height - 200;
    double alwaysVisibleHeight = topBarHeight;

    return Container(
      width: chatBoxWidth,
      height: tileBoxVisible ? totalHeight : alwaysVisibleHeight,
      color: Colors.black.withOpacity(0.4),
      child: tileBoxVisible ? mobileMaximized(chatBoxWidth, totalHeight, topBarHeight) : mobileMinimized(chatBoxWidth, topBarHeight),
    );
  }

  bool normalMode = true;
  Widget chatBoxWidget() {
    normalMode = true;
    double chatBoxWidth = 500;
    if (MediaQuery.of(context).size.width <= 800) {
      // Here we assume that it is a phone and we set the width to the total
      chatBoxWidth = MediaQuery.of(context).size.width;
      normalMode = false;
    }

    return Align(
      alignment: FractionalOffset.bottomLeft,
      child: normalMode ? chatBoxNormal(chatBoxWidth) : chatBoxMobile(chatBoxWidth)
    );
  }

  sendMessage(String message) {
    if (_chatFormKey.currentState!.validate()) {
      String? toUser;
      if (activateTab == "World") {
        AuthServiceMessage().sendMessageChatGlobal(message);
      } else if (activateTab == "Personal") {
        if (_selectedChatData != null) {
          toUser = _selectedChatData!.name;
          AuthServiceMessage().sendMessageChatPersonal(message, toUser);
        }
      }
      chatFieldController.text = "";
      // Keep the focus on the textfield in case of second message
      _focusChatBox.requestFocus();
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
              SizedBox(
                width: chatBoxWidth - sendButtonWidth - regionSpacing,
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
                    enabled: Settings().getUser() != null,
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
    String hintText = _regions.any((element) => element.unreadMessages) ? "! Chats" : "Chats";
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
      child: DropdownButtonHideUnderline(
        child: DropdownButton2(
          value: _selectedChatData,
          disabledHint: null,
          items: _dropdownMenuItems,
          dropdownWidth: 300,
          onChanged: onChangeDropdownItem,
          hint: Container(
            padding: EdgeInsets.only(left: 15),
            child: RichText(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                text: hintText,
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          isExpanded: true,
          iconSize: 0.0,
        ),
      ),
    );
  }

  onChangeDropdownItem(ChatData? selectedChat) {
    setState(() {
      if (selectedChat != null) {
        if (!tileBoxVisible) {
          tileBoxVisible = true;
        }
        // There is a placeholder text when there are no chats active
        // If the user decides to click this anyway it will do nothing
        if (selectedChat.name != "No Chats Found!") {
          _selectedChatData = selectedChat;
          removeUnreadPersonalMessage(selectedChat);
          activateTab = "Personal";
        } else {
          activateTab = "World";
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return chatBoxWidget();
  }

  removePlaceholder() {
    // Check if the placeholder "No Chats Found!" is in the list and remove it.
    if (_dropdownMenuItems.length > 1) {
      if (_dropdownMenuItems[0].value!.name == "No Chats Found!") {
        _dropdownMenuItems.removeAt(0);
      }
    }
    if (_regions.length > 1) {
      if (_regions[0].name == "No Chats Found!") {
        _regions.removeAt(0);
      }
    }
  }

  userInteraction(bool message, String userName) {
    if (message) {
      // message the user
      // select personal region if it exists, otherwise just create it first.
      bool exists = false;
      for (int i = 0; i < _regions.length; i++) {
        if (_regions[i].name == userName) {
          _selectedChatData = _dropdownMenuItems[i].value!;
          removeUnreadPersonalMessage(_dropdownMenuItems[i].value!);
          exists = true;
        }
      }
      if (!exists) {
        ChatData newChatData = ChatData(3, userName, false);
        _regions.add(newChatData);
        DropdownMenuItem<ChatData> dropDownItem = newDropDownItem(newChatData, getChatColour(newChatData.type));
        _dropdownMenuItems.add(dropDownItem);
        _selectedChatData = _dropdownMenuItems.last.value!;
        removeUnreadPersonalMessage(_dropdownMenuItems.last.value!);
        // Check if the placeholder "No Chats Found!" is in the list and remove it.
        removePlaceholder();
      }
      activateTab = "Personal";
      if (!tileBoxVisible) {
        tileBoxVisible = true;
      }
      setState(() {});
    } else {
      // open the user overview panel.
      AuthServiceWorld().getUser(userName).then((value) {
        if (value != null) {
          UserBoxChangeNotifier().setUser(value);
          UserBoxChangeNotifier().setUserBoxVisible(true);
        } else {
          showToastMessage("Something went wrong");
        }
      });
    }
  }
}

class MessageTile extends StatefulWidget {
  final Message message;
  final Function(bool, String) userInteraction;

  const MessageTile(
      {
        required Key key,
        required this.message,
        required this.userInteraction
      })
      : super(key: key);

  @override
  MessageTileState createState() => MessageTileState();
}

class MessageTileState extends State<MessageTile> {

  bool isMe = false;
  @override
  void initState() {
    if (widget.message.senderName == Settings().getUser()!.getUserName()) {
      isMe = true;
    }
    super.initState();
  }

  Widget getMessageContent() {
    Color textColour = widget.message.messageColour;
    if (isMe) {
      textColour = Colors.blue;
    }
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
        widget.userInteraction(true, widget.message.senderName);
      } else if (delta == 1) {
        widget.userInteraction(false, widget.message.senderName);
      }
      return;
    });
  }

  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }
}

class ChatData {
  int type;
  String name;
  bool unreadMessages;

  ChatData(this.type, this.name, this.unreadMessages);
}

class ChatDetailPopup extends PopupMenuEntry<int> {

  bool isMe;
  ChatDetailPopup({
    required Key key,
    required this.isMe
  }) : super(key: key);

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
    return getPopupItems(context, widget.isMe);
  }
}

void buttonMessageUser(BuildContext context) {
  Navigator.pop<int>(context, 0);
}

void buttonViewUser(BuildContext context) {
  Navigator.pop<int>(context, 1);
}

Widget getPopupItems(BuildContext context, bool isMe) {
  return Column(children: [
    !isMe ? Container(
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
    ) : Container(),
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
