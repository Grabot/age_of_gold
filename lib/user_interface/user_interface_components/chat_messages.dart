import 'package:age_of_gold/user_interface/user_interface_components/message.dart';

class ChatMessages {
  List<Message> chatMessages = [];

  static final ChatMessages _instance = ChatMessages._internal();

  ChatMessages._internal() {
    initializeChatMessages();
  }

  factory ChatMessages() {
    return _instance;
  }

  initializeChatMessages() {
    DateTime currentTime = DateTime.now();
    String message = "Welcome to the global chat!";
    Message newMessage = Message(1, "Server", message, false, currentTime);
    chatMessages.add(newMessage);
  }

  addMessage(String userName, String message) {
    DateTime currentTime = DateTime.now();
    Message newMessage = Message(1, userName, message, false, currentTime);
    chatMessages.add(newMessage);
  }
}