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

  User(this.id, this.userName, this.verified, this.friends, String? timeLock) {
    if (timeLock != null) {
      if (!timeLock.endsWith("Z")) {
        // The server has utc timestamp, but it's not formatted with the 'Z'.
        timeLock += "Z";
      }
      tileLock = DateTime.parse(timeLock).toLocal();
    } else {
      tileLock = DateTime.now();
    }
  }

  int getId() {
    return id;
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

  List<Friend> getFriends() {
    return friends;
  }

  addFriend(Friend friend) {
    // update friend if the username is already in the list
    for (Friend f in friends) {
      if (f.getUser()!.getUserName().toLowerCase() == friend.getUser()!.getUserName().toLowerCase()) {
        f.setAccepted(friend.isAccepted());
        f.setRequested(friend.isRequested());
        f.setUser(friend.getUser());
        return;
      }
    }
    // If the friend was not updated we add it to the list.
    friends.add(friend);
  }

  removeFriend(String username) {
    friends.removeWhere((friend) => friend.getUser()!.getUserName().toLowerCase() == username.toLowerCase());
  }

  acceptFriend(String username) {
    // We find the user in the friends list and set the accepted flag to true.
    for (Friend friend in friends) {
      if (friend.getUser()!.getUserName().toLowerCase() == username.toLowerCase()) {
        friend.setAccepted(true);
        break;
      }
    }
  }

  User.fromJson(Map<String, dynamic> json) {

    id = json['id'];
    userName = json["username"];

    if (json.containsKey("verified")) {
      verified = json["verified"];
    }
    if (json.containsKey("friends")) {
      friends = [];
      for (var friend in json["friends"]) {
        friends.add(Friend.fromJson(friend));
      }
    } else {
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
