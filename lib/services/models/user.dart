
class User {

  late int id;
  late String userName;
  late DateTime tileLock;

  User(this.id, this.userName, String timeLock) {
    if (!timeLock.endsWith("Z")) {
      // The server has utc timestamp, but it's not formatted with the 'Z'.
      timeLock += "Z";
    }
    tileLock = DateTime.parse(timeLock).toLocal();
  }

  String getUserName() {
    return userName;
  }

  DateTime getTileLock() {
    return tileLock;
  }

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userName = json["username"];
    String timeLock = json["tile_lock"];
    if (!timeLock.endsWith("Z")) {
      // The server has utc timestamp, but it's not formatted with the 'Z'.
      timeLock += "Z";
    }
    tileLock = DateTime.parse(timeLock).toLocal();
  }

  @override
  String toString() {
    return 'User{id: $id, userName: $userName, tileLock: $tileLock}';
  }
}
