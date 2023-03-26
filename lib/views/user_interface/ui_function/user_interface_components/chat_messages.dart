import 'message.dart';
import 'messages/event_message.dart';
import 'messages/guild_message.dart';
import 'messages/global_message.dart';
import 'messages/local_message.dart';
import 'messages/personal_message.dart';


class ChatMessages {
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
    Message newMessage = Message(1, "Server", message, false, currentTime);
    chatMessages.add(newMessage);
  }

  addMessage(String userName, String message, int regionType) {
    DateTime currentTime = DateTime.now();
    Message? newMessage;
    // These will not all work this way and they will probably
    // functionally work different, but for now see them as placeholders
    // TODO: what to do with id's? Use them or remove them?
    if (regionType == 1) {
      newMessage = LocalMessage(1, userName, message, false, currentTime);
    } else if (regionType == 2) {
      newMessage = GuildMessage(1, userName, message, false, currentTime);
    } else if (regionType == 3) {
      newMessage = PersonalMessage(1, userName, message, false, currentTime);
    } else {
      newMessage = GlobalMessage(1, userName, message, false, currentTime);
    }
    chatMessages.add(newMessage);
  }

  addEventMessage(String message) {
    DateTime currentTime = DateTime.now();
    EventMessage newMessage = EventMessage(1, "Server", message, false, currentTime);
    eventMessages.add(newMessage);
  }
}
