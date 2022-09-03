class Message {
  late int id;
  late String senderName;
  late String body;
  late DateTime timestamp;
  late bool me;

  Message(this.id, this.senderName, this.body, this.me, this.timestamp);
}
