import 'package:age_of_gold/services/auth_service_social.dart';
import 'package:age_of_gold/services/models/friend.dart';
import 'package:age_of_gold/services/models/user.dart';
import 'package:age_of_gold/services/settings.dart';
import 'package:age_of_gold/util/util.dart';
import 'package:age_of_gold/views/user_interface/ui_util/messages/event_message.dart';
import 'package:age_of_gold/views/user_interface/ui_util/messages/global_message.dart';
import 'package:age_of_gold/views/user_interface/ui_util/messages/guild_message.dart';
import 'package:age_of_gold/views/user_interface/ui_util/messages/local_message.dart';
import 'package:age_of_gold/views/user_interface/ui_util/messages/message.dart';
import 'package:age_of_gold/views/user_interface/ui_util/messages/personal_message.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatMessages extends ChangeNotifier {
  List<Message> chatMessages = [];
  List<EventMessage> eventMessages = [];
  Map<String, List<PersonalMessage>> personalMessages = {};
  String? messageUser;

  List<ChatData> regions = [];

  // We keep track of the number of personal chats and create dropdown options for those chats.
  List<DropdownMenuItem<ChatData>>? dropdownMenuItems;

  // We make a distinction between "World", "Events" and "Personal" for friends and guilds
  String activateChatBoxTab = "World";
  String activateChatWindowTab = "World";

  bool chatWindowActive = false;
  bool unreadWorldMessages = false;
  bool unreadEventMessages = false;

  static final ChatMessages _instance = ChatMessages._internal();

  ChatData? selectedChatData;

  ChatMessages._internal();

  factory ChatMessages() {
    return _instance;
  }

  combinePersonalMessages(ChatData chatData, List<PersonalMessage> messages) {
    // In case of double retrieved messages remove the duplicates
    personalMessages[chatData.name]!.addAll(messages);
    personalMessages[chatData.name]!.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    for (int i = personalMessages[chatData.name]!.length - 1; i >= 1; i--) {
      if (personalMessages[chatData.name]![i].equals(personalMessages[chatData.name]![i - 1])) {
        personalMessages[chatData.name]!.removeAt(i);
      }
    }
  }

  setSelectedChatData(ChatData? chatData) {
    selectedChatData = chatData;
    if (chatData != null) {
      AuthServiceSocial().getMessagePersonal(chatData.name).then((value) {
        if (value != null) {
          combinePersonalMessages(chatData, value);
          setDateTiles(personalMessages[chatData.name]!, true);
          chatData.unreadMessages = 0;
          // send a trigger that the messages are read.
          AuthServiceSocial().readMessagePersonal(chatData.name).then((value) {});
        } else {
          showToastMessage("Could not get messages, sorry for the inconvenience");
        }
        notifyListeners();
      }).onError((error, stackTrace) {
        showToastMessage("an error occured");
      });
    }
    notifyListeners();
  }

  ChatData? getSelectedChatData() {
    return selectedChatData;
  }

  setChatWindowActive(bool value) {
    chatWindowActive = value;
    activateChatWindowTab = activateChatBoxTab;
  }

  initializeChatMessages() {
    chatMessages = [];
    DateTime firstTime = DateTime(2023);
    String message = "Welcome to the Age of Gold chat!";
    Message newMessage = Message(1, "Server", message, false, firstTime, true);
    chatMessages.add(newMessage);
    String messageEvent = "Here you can see any event that happened in your view!";
    EventMessage newEventMessage = EventMessage(1, "Server", messageEvent, false, firstTime, true);
    eventMessages.add(newEventMessage);
  }

  bool unreadPersonalMessages() {
    for (ChatData chatData in regions) {
      if (chatData.unreadMessages != 0) {
        return true;
      }
    }
    return false;
  }

  setDateTiles(List<Message> messages, bool personal) {
    // clear the date tiles if they exists already
    messages.removeWhere((element) => element.id == -1);

    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime yesterday = DateTime(now.year, now.month, now.day - 1);
    String chatTimeTile = "";
    for (int i = 1; i < messages.length; i++) {
      DateTime current = messages[i].timestamp;
      DateTime dayMessage = DateTime(current.year, current.month, current.day);
      String currentDayMessage = DateFormat.yMMMMd('en_US').format(dayMessage);

      if (chatTimeTile != currentDayMessage) {
        chatTimeTile = DateFormat.yMMMMd('en_US').format(dayMessage);

        String timeMessageTile = chatTimeTile;
        if (dayMessage == today) {
          timeMessageTile = "Today";
        }
        if (dayMessage == yesterday) {
          timeMessageTile = "Yesterday";
        }
        if (personal) {
          PersonalMessage timeMessage = PersonalMessage(-1, "Server", timeMessageTile, false, dayMessage, true, "Server");
          messages.insert(i, timeMessage);
        } else {
          Message timeMessage = Message(-1, "Server", timeMessageTile, false, dayMessage, true);
          messages.insert(i, timeMessage);
        }
        i += 1;
      }
    }
  }

  addChatToPersonalMessages(String from, String to, PersonalMessage message) {
    String me = Settings().getUser()!.getUserName();
    String other = "";
    if (from == me) {
      other = to;
    } else {
      other = from;
    }
    if (!personalMessages.containsKey(other)) {
      personalMessages[other] = [];
      DateTime firstTime = DateTime(2023);
      String message = "Start your conversation with $other here!";
      PersonalMessage newMessage = PersonalMessage(1, "Server", message, false, firstTime, true, other);
      personalMessages[other]!.add(newMessage);
    }
    personalMessages[other]!.add(message);
    bool found = false;
    for (ChatData chatData in regions) {
      if (chatData.name == other) {
        print("change region");
        // If the chatbox is open on this user we don't set the unreadMessage
        if (messageUser != other) {
          chatData.unreadMessages += 1;
        }
        found = true;
      }
    }
    if (!found) {
      print("create region");
      ChatData newChatData = ChatData(3, other, 1);
      regions.add(newChatData);
    }
    dropdownMenuItems = buildDropdownMenuItems();
    removePlaceholder();
  }

  addPersonalMessage(String from, String to, String message, String timestamp) {
    if (!timestamp.endsWith("Z")) {
      // The server has utc timestamp, but it's not formatted with the 'Z'.
      timestamp += "Z";
    }
    DateTime tileMessage = DateTime.parse(timestamp).toLocal();
    bool me = false;
    if (Settings().getUser() != null) {
      if (Settings().getUser()!.getUserName() == from) {
        me = true;
      }
    }
    PersonalMessage newMessage = PersonalMessage(1, from, message, me, tileMessage, false, to);
    // Add it to both the chatMessages and the personalMessages
    chatMessages.add(newMessage);
    addChatToPersonalMessages(from, to, newMessage);
    newGlobalMessageEvent(newMessage);
    // TODO: add check if the window is open on the chatbox and the right person. Send the read message if it is.
    // if (!me) {
    //   AuthServiceSocial().readMessagePersonal(from).then((value) {});
    // }
  }

  addMessage(String userName, String message, int regionType) {
    print("add regular message");
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
    newGlobalMessageEvent(newMessage);
  }

  List<Message> getMessagesFromUser(String senderName) {
    if (personalMessages.containsKey(senderName)) {
      return personalMessages[senderName]!;
    } else {
      return [];
    }
  }

  // We want all the messages except the personal messages send by the user.
  List<Message> getAllWorldMessages(String me) {
    List<Message> all = chatMessages.where((element) {
      if (element is PersonalMessage) {
        return element.senderName != me;
      }
      return true;
    }).toList();
    return all;
  }

  addEventMessage(String message, String userName) {
    DateTime currentTime = DateTime.now();
    EventMessage newMessage = EventMessage(1, userName, message, false, currentTime, false);
    eventMessages.add(newMessage);
    newEventMessageEvent(newMessage);
    notifyListeners();
  }

  getDropdownMenuItems() {
    return dropdownMenuItems ?? [];
  }

  newEventMessageEvent(EventMessage lastMessage) {
    if (lastMessage.senderName != Settings().getUser()!.getUserName()) {
      unreadEventMessages = true;
    }

    if (activateChatBoxTab == "Events" || (chatWindowActive && activateChatWindowTab == "Events")) {
      unreadEventMessages = false;
      lastMessage.read = true;
    }

    if (eventMessages.length > 100) {
      eventMessages.removeAt(0);
    }
    notifyListeners();
  }

  newGlobalMessageEvent(Message lastMessage) {

    if (lastMessage.senderName != Settings().getUser()!.getUserName()) {
      unreadWorldMessages = true;
    }

    if (activateChatBoxTab == "World" || (chatWindowActive && activateChatWindowTab == "World")) {
      unreadWorldMessages = false;
      lastMessage.read = true;
    }

    if (chatMessages.length > 1000) {
      chatMessages.removeAt(0);
    }
    notifyListeners();
  }

  setActiveChatBoxTab(String tab) {
    activateChatBoxTab = tab;
  }

  String getActiveChatBoxTab() {
    return activateChatBoxTab;
  }

  setActivateChatWindowTab(String tab) {
    activateChatWindowTab = tab;
    // We also set the chatbox tab.
    activateChatBoxTab = tab;
  }

  String getActivateChatWindowTab() {
    return activateChatWindowTab;
  }

  setUnreadEventMessages(bool unread) {
    unreadEventMessages = unread;
  }

  setUnreadWorldMessages(bool unread) {
    unreadWorldMessages = unread;
  }

  bool getUnreadEventMessages() {
    return unreadEventMessages;
  }

  bool getUnreadWorldMessages() {
    return unreadWorldMessages;
  }

  clearPersonalMessages() {
    personalMessages = {};
    selectedChatData = null;
    chatMessages.removeWhere((element) => element is PersonalMessage);
    eventMessages = [];
    messageUser = null;
    regions = [];
    activateChatBoxTab = "World";
    activateChatWindowTab = "World";
  }

  initializeChatRegions() {
    User? currentUser = Settings().getUser();
    if (currentUser != null) {
      List<Friend> friends = currentUser.getFriends();
      for (Friend friend in friends) {
        if (friend.isAccepted() || friend.unreadMessages != 0) {
          addChatRegion(friend.getUser()!.getUserName(), friend.unreadMessages!);
        }
      }
    }
    if (regions.isEmpty) {
      ChatData chatData = ChatData(0, "No Chats Found!", 0);
      regions.add(chatData);
    }
    dropdownMenuItems = buildDropdownMenuItems();
  }

  removePlaceholder() {
    // Check if the placeholder "No Chats Found!" is in the list and remove it.
    if (regions.length > 1) {
      if (regions[0].name == "No Chats Found!") {
        regions.removeAt(0);
      }
    }
    dropdownMenuItems = buildDropdownMenuItems();
  }

  List<Message> shownMessages = [];
  setChatMessages() {
    List<Message> messages = chatMessages;
    if (activateChatWindowTab == "Events") {
      messages = eventMessages;
    } else {
      if (selectedChatData != null) {
        messages = getMessagesFromUser(
            selectedChatData!.name
        );
      } else {
        // In the regular world chat we want to get all the messages except the personal messages that were send by the user
        if (Settings().getUser() != null) {
          messages = getAllWorldMessages(
              Settings().getUser()!.getUserName());
        }
      }
    }
    shownMessages = messages;
  }

  addNewRegion(ChatData newRegion) {
    print("adding region");
    regions.add(newRegion);

    if (!personalMessages.containsKey(newRegion.name)) {
      personalMessages[newRegion.name] = [];
      DateTime firstTime = new DateTime(2023);
      String message = "Start your conversation with ${newRegion.name} here!";
      PersonalMessage newMessage = PersonalMessage(0, "Server", message, false, firstTime, true, newRegion.name);
      personalMessages[newRegion.name]!.add(newMessage);
    }

    dropdownMenuItems = buildDropdownMenuItems();
  }

  removeOldRegion(ChatData oldRegion) {
    print("removing region");
    regions.remove(oldRegion);
    dropdownMenuItems = buildDropdownMenuItems();
  }

  setMessageUser(String? user) {
    messageUser = user;
    for (ChatData chatData in regions) {
      if (chatData.name == user) {
        dropdownMenuItems = buildDropdownMenuItems();
        break;
      }
    }
  }

  addChatRegion(String username, int unreadMessages) {
    // select personal region if it exists, otherwise just create it first.
    bool exists = false;
    for (int i = 0; i < regions.length; i++) {
      if (regions[i].name == username) {
        // _selectedChatData = chatMessages.regions[i];
        setMessageUser(regions[i].name);
        exists = true;
      }
    }
    if (!exists) {
      ChatData newChatData = ChatData(3, username, unreadMessages);
      addNewRegion(newChatData);
      setMessageUser(newChatData.name);
      // Check if the placeholder "No Chats Found!" is in the list and remove it.
      removePlaceholder();
    }
  }

  getMessageUser() {
    return messageUser;
  }

  String hintText() {
    return regions.any((element) => element.unreadMessages != 0) ? "! Chats" : "Chats";
  }

  List<DropdownMenuItem<ChatData>> buildDropdownMenuItems() {
    List<DropdownMenuItem<ChatData>> items = [];
    for (ChatData chatData in regions) {
      items.add(newDropDownItem(chatData, getChatColour(chatData.type)));
    }
    return items;
  }

  login() {
    personalMessages = {};
    selectedChatData = null;
    messageUser = null;
    activateChatBoxTab = "World";
    activateChatWindowTab = "World";
    initializeChatMessages();
    AuthServiceSocial().getMessagesGlobal().then((value) {
      if (value != null) {
        chatMessages.addAll(value.reversed);
        setDateTiles(chatMessages, false);
        notifyListeners();
      }
    });
    // populate chatData with guilds or friends?
    initializeChatRegions();
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

  newDropDownItem(ChatData newChatData, Color textColour) {
    return DropdownMenuItem(
      value: newChatData,
      child: Container(
        padding: const EdgeInsets.only(left: 6.0),
        child: Row(
          children: [
            newChatData.unreadMessages != 0 ? Text("! ") : Text("  "),
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
}

class ChatData {
  int type;
  String name;
  int unreadMessages;

  ChatData(this.type, this.name, this.unreadMessages);
}

class ChatDetailPopup extends PopupMenuEntry<int> {

  final bool isMe;

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
