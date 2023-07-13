import 'dart:convert';
import 'dart:typed_data';

import 'package:age_of_gold/services/models/friend.dart';
import 'package:age_of_gold/services/models/guild.dart';
import 'package:age_of_gold/services/models/guild_member.dart';

class User {

  late int id;
  late String userName;
  late DateTime tileLock;
  late bool verified;
  late List<Friend> friends;
  Uint8List? avatar;
  Guild? guild;

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
      if (f.getFriendName()!.toLowerCase() == friend.getFriendName()!.toLowerCase()) {
        f.setAccepted(friend.isAccepted());
        f.setRequested(friend.isRequested());
        f.setFriendName(friend.getFriendName());
        f.setUnreadMessages(friend.getUnreadMessages());
        f.setFriendAvatar(friend.getFriendAvatar());
        f.setFriendId(friend.getFriendId());
        f.retrievedAvatar = friend.retrievedAvatar;
        return;
      }
    }
    // If the friend was not updated we add it to the list.
    friends.add(friend);
  }

  removeFriend(int friendId) {
    friends.removeWhere((friend) => friend.getFriendId() == friendId);
  }

  Guild? getGuild() {
    return guild;
  }

  setGuild(Guild? guild) {
    this.guild = guild;
  }

  setGuildRank() {
    if (guild != null) {
      for (GuildMember member in guild!.getMembers()) {
        if (member.getGuildMemberId() == id) {
          if (member.getGuildMemberRank() == 0) {
            guild!.setGuildRank("Guildmaster");
          } else if (member.getGuildMemberRank() == 1) {
            guild!.setGuildRank("Officer");
          } else if (member.getGuildMemberRank() == 2) {
            guild!.setGuildRank("Merchant");
          } else {
            guild!.setGuildRank("Trader");
          }
          return;
        }
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

    if (json.containsKey("avatar") && json["avatar"] != null) {
      avatar = base64Decode(json["avatar"].replaceAll("\n", ""));
    }

    if (json.containsKey("guild") && json["guild"] != null) {
      guild = Guild.fromJson(json["guild"]);
      setGuildRank();
    }
  }

  @override
  String toString() {
    return 'User{userName: $userName}';
  }
}
