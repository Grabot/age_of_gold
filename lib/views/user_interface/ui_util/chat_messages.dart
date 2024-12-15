import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../services/auth_service_guild.dart';
import '../../../services/auth_service_social.dart';
import '../../../services/models/friend.dart';
import '../../../services/models/user.dart';
import '../../../services/settings.dart';
import '../../../util/util.dart';
import '../ui_views/chat_box/chat_box_change_notifier.dart';
import '../ui_views/chat_window/chat_window_change_notifier.dart';
import '../ui_views/profile_box/profile_change_notifier.dart';
import 'messages/event_message.dart';
import 'messages/global_message.dart';
import 'messages/guild_message.dart';
import 'messages/message.dart';
import 'messages/personal_message.dart';

class ChatMessages extends ChangeNotifier {
  List<Message> chatMessages = [];
  List<EventMessage> eventMessages = [];
  Map<String, List<PersonalMessage>> personalMessages = {};
  List<GuildMessage> guildMessages = [];
  Map<String, bool> personalMessageRetrieved = {};
  Map<String, int> personalMessagePage = {};
  String? messageUser;

  List<ChatData> regions = [];

  // We keep track of the number of personal chats and create dropdown options for those chats.
  List<DropdownMenuItem<ChatData>>? dropdownMenuItems;

  // We make a distinction between "World", "Events", "Guild" and "Personal" for friends
  String activateChatTab = "World";

  bool chatWindowActive = false;
  bool unreadWorldMessages = false;
  bool unreadEventMessages = false;
  bool unreadGuildMessages = false;

  static final ChatMessages _instance = ChatMessages._internal();

  ChatData? selectedChatData;

  int currentPage = 1;
  int currentPageGuild = 1;

  int worldMessagesUnread = 0;
  int guildMessagesUnread = 0;

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
    } else {
      // check if the guild was pressed and retrieve the messages
      if (getActiveChatTab() == "Guild") {
        retrieveGuildMessages();
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
    DateTime firstTime = DateTime(2023);
    String message = "Welcome to the Hex Place chat!";
    Message newMessage = Message(-1, "Server", message, false, firstTime, true);
    chatMessages.add(newMessage);
    String messageEvent = "Here you can see any event that happened in your view!";
    EventMessage newEventMessage = EventMessage(-1, "Server", messageEvent, false, firstTime, true);
    eventMessages.add(newEventMessage);
    String messageGuild = "Welcome to your Guild chat!";
    GuildMessage newMessageGuild = GuildMessage(-1, "Server", messageGuild, false, firstTime, true, true);
    guildMessages.add(newMessageGuild);
  }

  bool unreadPersonalMessages() {
    for (ChatData chatData in regions) {
      if (chatData.unreadMessages != 0) {
        return true;
      }
    }
    if (unreadGuildMessages) {
      return true;
    }
    return false;
  }

  setDateTiles(List<Message> messages, int chat) {
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
        if (chat == 1) {
          // guild chat
          GuildMessage timeMessage = GuildMessage(-2, "Server", timeMessageTile, false, dayMessage, true, true);
          messages.insert(i, timeMessage);
        } else if (chat == 2) {
          // personal chat
          PersonalMessage timeMessage = PersonalMessage(-2, "Server", timeMessageTile, false, dayMessage, true, "Server");
          messages.insert(i, timeMessage);
        } else {
          // gobal chat (0)
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

  addChatToPersonalMessages(String from, int senderId, String to, PersonalMessage message) {
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
        // If the chatbox is open on this user we don't set the unreadMessage
        if (!checkIfPersonalMessageIsRead(other, null)) {
          chatData.unreadMessages += 1;
          setDateTiles(personalMessages[chatData.name]!, 2);
        }
        found = true;
      }
    }
    if (!found) {
      ChatData newChatData = ChatData(3, senderId, other, 1, false);
      regions.add(newChatData);
    }
    dropdownMenuItems = buildDropdownMenuItems();
    removePlaceholder();
  }

  setGuildUnreadMessages() {
    User? currentUser = Settings().getUser();
    if (currentUser != null) {
      if (currentUser.getGuild() != null) {
        if (currentUser.getGuild()!.unreadMessages > 0) {
          guildMessagesUnread = currentUser.getGuild()!.unreadMessages;
          unreadGuildMessages = true;
        }
            }
    }
  }

  checkPersonalMessageRead() {
    for (ChatData chatData in regions) {
      if (checkIfPersonalMessageIsRead(chatData.name, null)) {
        // either the chat window or the chat box was open and the chat was open on this user.
        readChatData(chatData);
      }
    }
  }

  readChatData(ChatData chatData) {
    chatData.unreadMessages = 0;
    ProfileChangeNotifier().notify();
    dropdownMenuItems = buildDropdownMenuItems();
    AuthServiceSocial().readMessagePersonal(chatData.senderId).then((value) {});
  }

  checkIfPersonalMessageIsRead(String? fromName, int? fromId) {
    if (ChatWindowChangeNotifier().getChatWindowVisible() ||
        ChatBoxChangeNotifier().getChatBoxVisible()) {
      if (fromName != null) {
        if (selectedChatData != null && selectedChatData!.name == fromName) {
          return true;
        }
      }
      if (fromId != null) {
        if (selectedChatData != null && selectedChatData!.senderId == fromId) {
          return true;
        }
      }
    }
    return false;
  }

  addPersonalMessage(String from, int senderId, String to, String message, String timestamp) {
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
    PersonalMessage newMessage = PersonalMessage(senderId, from, message, me, messageTime, false, to);
    // Add it to both the chatMessages and the personalMessages
    chatMessages.add(newMessage);
    setDateTiles(chatMessages, 0);
    addChatToPersonalMessages(from, senderId, to, newMessage);
    newGlobalMessageEvent(newMessage);

    if (!me) {
      checkReadPersonalMessage(senderId);
    }
    notifyListeners();
  }

  addGuildMessage(int? senderId, String? senderName, String message, String timestamp) {
    bool isGuildEvent = false;
    if (senderName == null) {
      senderName = "Server";
      isGuildEvent = true;
    }
    senderId ??= -1;
    if (!timestamp.endsWith("Z")) {
      // The server has utc timestamp, but it's not formatted with the 'Z'.
      timestamp += "Z";
    }
    DateTime messageTime = DateTime.parse(timestamp).toLocal();
    bool me = false;
    if (Settings().getUser() != null) {
      if (Settings().getUser()!.getUserName() == senderName) {
        me = true;
      }
    }

    GuildMessage newMessage = GuildMessage(senderId, senderName, message, me, messageTime, false, isGuildEvent);
    guildMessages.add(newMessage);
    setDateTiles(chatMessages, 1);

    if (!me) {
      checkReadGuildMessage();
    }
    newGuildMessageEvent(newMessage);
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

  combineGuildMessages(List<GuildMessage> messages) {
    guildMessages.addAll(messages);
    guildMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    for (int i = guildMessages.length - 1; i >= 1; i--) {
      if (guildMessages[i].equals(guildMessages[i-1])) {
        guildMessages.removeAt(i);
      }
    }
  }

  retrieveGlobalMessages() {
    AuthServiceSocial().getMessagesGlobal(currentPage).then((value) {
      if (value != null) {
        currentPage += 1;
        combineGlobalMessages(value);
        setDateTiles(chatMessages, 0);
        notifyListeners();
      }
    });
  }

  retrieveGuildMessages() {
    User? currentUser = Settings().getUser();
    if (currentUser != null) {
      if (currentUser.getGuild() != null) {
        AuthServiceSocial().getMessagesGuild(currentUser.getGuild()!.getGuildId(), currentPageGuild).then((
            value) {
          if (value != null) {
            currentPageGuild += 1;
            combineGuildMessages(value);
            setDateTiles(guildMessages, 1);
            AuthServiceGuild().readMessageGuild(currentUser.getGuild()!.guildId).then((value) {});
            notifyListeners();
          }
        });
      }
    }
  }

  retrievePersonalMessages(ChatData chatData) {
    AuthServiceSocial().getMessagePersonal(chatData, personalMessagePage[chatData.name]!).then((value) {
      if (value != null) {
        combinePersonalMessages(chatData, value);
        setDateTiles(personalMessages[chatData.name]!, 2);
        chatData.unreadMessages = 0;
        // send a trigger that the messages are read.
        AuthServiceSocial().readMessagePersonal(chatData.senderId).then((value) {});
        ProfileChangeNotifier().notify();
        dropdownMenuItems = buildDropdownMenuItems();
        personalMessageRetrieved[chatData.name] = true;
        personalMessagePage[chatData.name] = personalMessagePage[chatData.name]! + 1;
      } else {
        showToastMessage("Could not get messages, sorry for the inconvenience");
      }
      notifyListeners();
    }).onError((error, stackTrace) {
      showToastMessage("an error occured");
    });
  }

  retrieveMoreMessages() {
    if (activateChatTab == "World") {
      retrieveGlobalMessages();
    } else if (activateChatTab == "Guild") {
      retrieveGuildMessages();
    } else if (activateChatTab == "Personal") {
      if (selectedChatData != null) {
        retrievePersonalMessages(selectedChatData!);
      }
    }
  }

  checkReadPersonalMessage(int fromId) {
    if (activateChatTab == "Personal") {
      if (checkIfPersonalMessageIsRead(null, fromId)) {
        AuthServiceSocial().readMessagePersonal(fromId).then((value) {});
      }
    }
  }

  checkReadGuildMessage() {
    if (activateChatTab == "Guild") {
      User? currentUser = Settings().getUser();
      if (currentUser != null) {
        if (currentUser.getGuild() != null) {
          if (ChatWindowChangeNotifier().getChatWindowVisible() ||
              ChatBoxChangeNotifier().getChatBoxVisible()) {
            AuthServiceGuild().readMessageGuild(currentUser.getGuild()!.guildId).then((value) {});
            unreadGuildMessages = false;
            guildMessagesUnread = 0;
            ProfileChangeNotifier().notify();
            notifyListeners();
          }
        }
      }
    }
  }

  addMessage(String userName, int senderId, String message, String timestamp) {
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
    newMessage = GlobalMessage(senderId, userName, message, me, messageTime, false);
    chatMessages.add(newMessage);
    newGlobalMessageEvent(newMessage);
    notifyListeners();
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

  newGuildMessageEvent(GuildMessage lastMessage) {
    if (lastMessage.senderName != Settings().getUser()!.getUserName()) {
      if (activateChatTab == "Guild") {
        if (ChatWindowChangeNotifier().getChatWindowVisible() ||
            ChatBoxChangeNotifier().getChatBoxVisible()) {
          return;
        }
      }
      unreadGuildMessages = true;
      guildMessagesUnread += 1;
    }

    if (guildMessages.length > 100) {
      guildMessages.removeAt(0);
    }
    notifyListeners();
  }

  newGlobalMessageEvent(Message lastMessage) {
    if (lastMessage.senderName != Settings().getUser()!.getUserName()) {
      // There is a special case for when the user has a different chat open, a personal chat.
      // These show up in the global messages, but if a new message is send in that chat
      // we don't want to show it as unread in the global chat
      if (activateChatTab == "Personal") {
        if (ChatWindowChangeNotifier().getChatWindowVisible() ||
            ChatBoxChangeNotifier().getChatBoxVisible()) {
          if (!lastMessage.me && selectedChatData != null && selectedChatData!.senderId == lastMessage.senderId) {
            return;
          }
        }
      }
      if (activateChatTab == "World") {
        if (ChatWindowChangeNotifier().getChatWindowVisible() ||
            ChatBoxChangeNotifier().getChatBoxVisible()) {
          return;
        }
      }
      // In other cases we set the unread messages to true and add a unread message
      unreadWorldMessages = true;
      worldMessagesUnread += 1;
    }

    if (chatMessages.length > 1000) {
      chatMessages.removeAt(0);
    }
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

  setUnreadGuildMessages(bool unread) {
    if (unread == false) {
      guildMessagesUnread = 0;
    }
    unreadGuildMessages = unread;
  }

  setUnreadWorldMessages(bool unread) {
    if (unread == false) {
      worldMessagesUnread = 0;
    }
    unreadWorldMessages = unread;
  }

  bool getUnreadEventMessages() {
    return unreadEventMessages;
  }

  bool getUnreadGuildMessages() {
    return unreadGuildMessages;
  }

  bool getUnreadWorldMessages() {
    return unreadWorldMessages;
  }

  clearPersonalMessages() {
    personalMessages = {};
    selectedChatData = null;
    chatMessages.removeWhere((element) => element is PersonalMessage);
    eventMessages = [];
    guildMessages = [];
    messageUser = null;
    regions = [];
    activateChatTab = "World";
  }

  leaveGuild() {
    guildMessages = [];
    unreadGuildMessages = false;
    chatMessages.removeWhere((element) => element is GuildMessage);
    unreadGuildMessages = false;
  }

  initializeChatRegions() {
    User? currentUser = Settings().getUser();
    if (currentUser != null) {
      List<Friend> friends = currentUser.getFriends();
      for (Friend friend in friends) {
        addChatRegion(
            friend.getFriendId(),
            friend.getFriendName()!,
            friend.unreadMessages!,
            friend.isAccepted(),
            false
        );
      }
      if (currentUser.getGuild() != null) {
        if (currentUser.getGuild()!.unreadMessages > 0) {
          unreadGuildMessages = true;
          guildMessagesUnread = currentUser.getGuild()!.unreadMessages;
        }
      }
    }
    if (regions.isEmpty) {
      ChatData chatData = ChatData(0, -1, "No Chats Found!", 0, false);
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
    } else if (activateChatTab == "Guild") {
      messages = guildMessages;
    } else {
      if (selectedChatData != null) {
        messages = getMessagesFromUser(
            selectedChatData!.name
        );
      } else {
        // In the regular world chat we want to get all the messages except the personal messages that were send by me to someone
        if (Settings().getUser() != null) {
          messages = getAllWorldMessages(
              Settings().getUser()!.getUserName());
        }
      }
    }
    shownMessages = messages;
  }

  addNewRegion(ChatData newRegion) {
    regions.add(newRegion);

    if (!personalMessages.containsKey(newRegion.name)) {
      addPersonalMessageDict(newRegion.name);
    }

    dropdownMenuItems = buildDropdownMenuItems();
  }

  removeOldRegion(ChatData oldRegion) {
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

  addChatRegion(int senderId, String username, int unreadMessages, bool isFriend, bool selectUser) {
    // select personal region if it exists, otherwise just create it first.
    bool exists = false;
    for (int i = 0; i < regions.length; i++) {
      if (regions[i].name == username) {
        if (selectUser) {
          selectedChatData = regions[i];
          setMessageUser(regions[i].name);
        }
        exists = true;
      }
    }
    if (!exists) {
      ChatData newChatData = ChatData(3, senderId, username, unreadMessages, isFriend);
      addNewRegion(newChatData);
      if (selectUser) {
        selectedChatData = newChatData;
        setMessageUser(newChatData.name);
      }
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
    chatMessages = [];
    chatWindowActive = false;
    unreadWorldMessages = false;
    unreadEventMessages = false;
    unreadGuildMessages = false;
    guildMessagesUnread = 0;
    worldMessagesUnread = 0;
    eventMessages = [];
    guildMessages = [];
    personalMessages = {};
    personalMessageRetrieved = {};
    personalMessagePage = {};
    currentPage = 1;
    currentPageGuild = 1;
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
            newChatData.unreadMessages != 0 ? const Text("! ") : const Text("  "),
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
  int senderId;
  String name;
  int unreadMessages;
  bool friend;

  ChatData(this.type, this.senderId, this.name, this.unreadMessages, this.friend);
}

class ChatDetailPopup extends PopupMenuEntry<int> {

  final bool isMe;

  const ChatDetailPopup({
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
          child: const Text(
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
          child: const Text(
            "View user",
            textAlign: TextAlign.left,
            style: TextStyle(color: Colors.white, fontSize: 14),
          )),
    ),
  ]);
}
