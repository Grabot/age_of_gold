
class User {

  late int id;
  late String userName;
  late DateTime tileLock;
  late bool verified;

  User(this.id, this.userName, this.verified, String timeLock) {
    if (!timeLock.endsWith("Z")) {
      // The server has utc timestamp, but it's not formatted with the 'Z'.
      timeLock += "Z";
    }
    tileLock = DateTime.parse(timeLock).toLocal();
  }

  String getUserName() {
    return userName;
  }

  setUsername(String username) {
    userName = username;
  }

  DateTime getTileLock() {
    return tileLock;
  }

  bool isVerified() {
    return verified;
  }

  updateTileLock(String tileLock) {
    if (!tileLock.endsWith("Z")) {
      // The server has utc timestamp, but it's not formatted with the 'Z'.
      tileLock += "Z";
    }
    this.tileLock = DateTime.parse(tileLock).toLocal();
  }

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userName = json["username"];
    verified = json["verified"];
    String timeLock = json["tile_lock"];
    if (!timeLock.endsWith("Z")) {
      // The server has utc timestamp, but it's not formatted with the 'Z'.
      timeLock += "Z";
    }
    tileLock = DateTime.parse(timeLock).toLocal();
  }

  @override
  String toString() {
    return 'User{id: $id, userName: $userName, verified: $verified, tileLock: $tileLock}';
  }
}
