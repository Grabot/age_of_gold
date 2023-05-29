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
import 'package:age_of_gold/views/user_interface/ui_views/chat_box/chat_box.dart';
import 'package:age_of_gold/views/user_interface/ui_views/chat_box/chat_box_change_notifier.dart';
import 'package:age_of_gold/views/user_interface/ui_views/profile_box/profile_change_notifier.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatMessages extends ChangeNotifier {
  List<Message> chatMessages = [];
  List<EventMessage> eventMessages = [];
  Map<String, List<PersonalMessage>> personalMessages = {};
  Map<String, bool> personalMessageRetrieved = {};
  Map<String, int> personalMessagePage = {};
  String? messageUser;

  List<ChatData> regions = [];

  // We keep track of the number of personal chats and create dropdown options for those chats.
  List<DropdownMenuItem<ChatData>>? dropdownMenuItems;

  // We make a distinction between "World", "Events" and "Personal" for friends and guilds
  String activateChatTab = "World";

  bool chatWindowActive = false;
  bool unreadWorldMessages = false;
  bool unreadEventMessages = false;

  static final ChatMessages _instance = ChatMessages._internal();

  ChatData? selectedChatData;

  int currentPage = 1;

  ChatMessages._internal();

  factory ChatMessages() {
    return _instance;
  }

  setSelectedChatData(ChatData? chatData) {
    selectedChatData = chatData;
    if (chatData != null) {
      // Check if messages have already been retrieved.
      // If true any new message will have been retrieved with sockets.
      if (!personalMessageRetrieved[chatData.name]!) {
        retrievePersonalMessages(chatData);
      }
    }
    notifyListeners();
  }

  ChatData? getSelectedChatData() {
    return selectedChatData;
  }

  setChatWindowActive(bool value) {
    chatWindowActive = value;
  }

  initializeChatMessages() {
    chatMessages = [];
    DateTime firstTime = DateTime(2023);
    String message = "Welcome to the Age of Gold chat!";
    Message newMessage = Message(-1, "Server", message, false, firstTime, true);
    chatMessages.add(newMessage);
    String messageEvent = "Here you can see any event that happened in your view!";
    EventMessage newEventMessage = EventMessage(-1, "Server", messageEvent, false, firstTime, true);
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
    messages.removeWhere((element) => element.senderId == -2);

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
          PersonalMessage timeMessage = PersonalMessage(-2, "Server", timeMessageTile, false, dayMessage, true, "Server");
          messages.insert(i, timeMessage);
        } else {
          Message timeMessage = Message(-2, "Server", timeMessageTile, false, dayMessage, true);
          messages.insert(i, timeMessage);
        }
        i += 1;
      }
    }
  }

  addPersonalMessageDict(String regionName) {
    personalMessages[regionName] = [];
    DateTime firstTime = DateTime(2023);
    String message = "Start your conversation with $regionName here!";
    PersonalMessage newMessage = PersonalMessage(1, "Server", message, false, firstTime, true, regionName);
    personalMessages[regionName]!.add(newMessage);
    personalMessageRetrieved[regionName] = false;
    personalMessagePage[regionName] = 1;
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
      addPersonalMessageDict(other);
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
      ChatData newChatData = ChatData(3, other, 1, false);
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
    DateTime messageTime = DateTime.parse(timestamp).toLocal();
    bool me = false;
    if (Settings().getUser() != null) {
      if (Settings().getUser()!.getUserName() == from) {
        me = true;
      }
    }
    PersonalMessage newMessage = PersonalMessage(1, from, message, me, messageTime, false, to);
    // Add it to both the chatMessages and the personalMessages
    chatMessages.add(newMessage);
    addChatToPersonalMessages(from, to, newMessage);
    newGlobalMessageEvent(newMessage);

    if (!me) {
      checkReadPersonalMessage(from);
    }
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

  combineGlobalMessages(List<Message> messages) {
    chatMessages.addAll(messages);
    chatMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    for (int i = chatMessages.length - 1; i >= 1; i--) {
      if (chatMessages[i].equals(chatMessages[i-1])) {
        chatMessages.removeAt(i);
      }
    }
  }

  retrieveGlobalMessages() {
    AuthServiceSocial().getMessagesGlobal(currentPage).then((value) {
      if (value != null) {
        currentPage += 1;
        combineGlobalMessages(value);
        setDateTiles(chatMessages, false);
        notifyListeners();
      }
    });
  }

  retrievePersonalMessages(ChatData chatData) {
    AuthServiceSocial().getMessagePersonal(chatData.name, personalMessagePage[chatData.name]!).then((value) {
      if (value != null) {
        combinePersonalMessages(chatData, value);
        setDateTiles(personalMessages[chatData.name]!, true);
        chatData.unreadMessages = 0;
        // send a trigger that the messages are read.
        AuthServiceSocial().readMessagePersonal(chatData.name).then((value) {});
        ProfileChangeNotifier().notify();
        dropdownMenuItems = buildDropdownMenuItems();
        personalMessageRetrieved[chatData.name] = true;
        personalMessagePage[chatData.name] = personalMessagePage[chatData.name]! + 1;
      } else {
        showToastMessage(
            "Could not get messages, sorry for the inconvenience");
      }
      notifyListeners();
    }).onError((error, stackTrace) {
      showToastMessage("an error occured");
    });
  }

  retrieveMoreMessages() {
    if (activateChatTab == "World") {
      retrieveGlobalMessages();
    } else if (activateChatTab == "Personal") {
      if (selectedChatData != null) {
        retrievePersonalMessages(selectedChatData!);
      }
    }
    print("retrieving more messages");
  }

  checkReadPersonalMessage(String from) {
    if (activateChatTab == "Personal") {
      if (selectedChatData != null && selectedChatData!.name == from) {
        // new message while window open. Immediately read message
        AuthServiceSocial().readMessagePersonal(from).then((value) {});
      }
    }
  }

  addMessage(String userName, int senderId, String message, int regionType, String timestamp) {
    if (!timestamp.endsWith("Z")) {
      // The server has utc timestamp, but it's not formatted with the 'Z'.
      timestamp += "Z";
    }
    DateTime messageTime = DateTime.parse(timestamp).toLocal();
    Message? newMessage;
    bool me = false;
    if (Settings().getUser() != null) {
      me = userName == Settings().getUser()!.getUserName();
    }
    // These will not all work this way and they will probably
    // functionally work different, but for now see them as placeholders
    // TODO: what to do with id's? Use them or remove them?
    if (regionType == 1) {
      newMessage = LocalMessage(senderId, userName, message, me, messageTime, false);
    } else if (regionType == 2) {
      newMessage = GuildMessage(senderId, userName, message, me, messageTime, false);
    } else {
      newMessage = GlobalMessage(senderId, userName, message, me, messageTime, false);
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

    if (eventMessages.length > 100) {
      eventMessages.removeAt(0);
    }
    notifyListeners();
  }

  newGlobalMessageEvent(Message lastMessage) {

    if (lastMessage.senderName != Settings().getUser()!.getUserName()) {
      unreadWorldMessages = true;
    }

    if (chatMessages.length > 1000) {
      chatMessages.removeAt(0);
    }
    notifyListeners();
  }

  setActiveChatTab(String tab) {
    activateChatTab = tab;
  }

  String getActiveChatTab() {
    return activateChatTab;
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
    activateChatTab = "World";
  }

  initializeChatRegions() {
    User? currentUser = Settings().getUser();
    if (currentUser != null) {
      List<Friend> friends = currentUser.getFriends();
      for (Friend friend in friends) {
        if (friend.isAccepted() || friend.unreadMessages != 0) {
          addChatRegion(friend.getUser()!.getUserName(), friend.unreadMessages!, friend.isAccepted());
        }
      }
    }
    if (regions.isEmpty) {
      ChatData chatData = ChatData(0, "No Chats Found!", 0, false);
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
    if (activateChatTab == "Events") {
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
      addPersonalMessageDict(newRegion.name);
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

  addChatRegion(String username, int unreadMessages, bool isFriend) {
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
      ChatData newChatData = ChatData(3, username, unreadMessages, isFriend);
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
    regions = [];
    chatWindowActive = false;
    unreadWorldMessages = false;
    unreadEventMessages = false;
    eventMessages = [];
    personalMessages = {};
    personalMessageRetrieved = {};
    personalMessagePage = {};
    currentPage = 1;
    selectedChatData = null;
    messageUser = null;
    activateChatTab = "World";
    initializeChatMessages();
    retrieveGlobalMessages();
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
  bool friend;

  ChatData(this.type, this.name, this.unreadMessages, this.friend);
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
