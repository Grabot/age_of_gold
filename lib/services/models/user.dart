import 'dart:convert';
import 'dart:typed_data';

import 'package:age_of_gold/services/models/friend.dart';

class User {

  late int id;
  late String userName;
  late DateTime tileLock;
  late bool verified;
  late List<Friend> friends;
  Uint8List? avatar;

  User(this.id, this.userName, this.verified, this.friends, String timeLock) {
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

  Uint8List? getAvatar() {
    return avatar;
  }

  void setAvatar(Uint8List avatar) {
    this.avatar = avatar;
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

    if (json.containsKey("verified")) {
      verified = json["verified"];
    }
    if (json.containsKey("friends")) {
      print("contained friends!");
      print(json["friends"]);
      // friends = json["friends"]; // TODO: won't work? Create a list of Users from just usernames or ids?
      friends = [];
      for (var friend in json["friends"]) {
        friends.add(Friend.fromJson(friend));
      }
    } else {
      print("just create empty stuff");
      friends = [];
    }

    if (json.containsKey("tile_lock")) {
      String timeLock = json["tile_lock"];
      if (!timeLock.endsWith("Z")) {
        // The server has utc timestamp, but it's not formatted with the 'Z'.
        timeLock += "Z";
      }
      tileLock = DateTime.parse(timeLock).toLocal();
    } else {
      // If the timeLlock is not present it will not be used.
      tileLock = DateTime.now();
    }

    if (json.containsKey("avatar")) {
      avatar = base64Decode(json["avatar"].replaceAll("\n", ""));
    }
  }

  @override
  String toString() {
    return 'User{userName: $userName}';
  }
}
