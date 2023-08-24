import 'dart:typed_data';

import 'package:age_of_gold/services/models/user.dart';
import 'package:flutter/material.dart';

class Friend {

  late bool accepted;
  late int friendId;
  String? friendName;

  // determines if the request was send or received, can be null
  bool? requested;
  int? unreadMessages;

  Uint8List? friendAvatar;
  bool retrievedAvatar = false;

  Friend(this.friendId, this.accepted, this.requested, this.unreadMessages, this.friendName);

  Friend.fromJson(Map<String, dynamic> json) {
    friendId = json["friend_id"];
    if (json.containsKey("accepted")) {
      accepted = json["accepted"];
    }
    if (json.containsKey("requested")) {
      requested = json["requested"];
    }
    if (json.containsKey("unread_messages")) {
      unreadMessages = json["unread_messages"];
    }
    if (json.containsKey("friend_name")) {
      friendName = json["friend_name"];
    }
    if (json.containsKey("friend")) {
      Map<String, dynamic> friend = json["friend"];
      if (friend.containsKey("avatar")) {
        friendAvatar = friend["avatar"];
      }
    }
  }

  bool isAccepted() {
    return accepted;
  }

  setAccepted(bool accepted) {
    this.accepted = accepted;
  }

  setRequested(bool? requested) {
    this.requested = requested;
  }

  bool? isRequested() {
    return requested;
  }

  setFriendName(String? friendName) {
    this.friendName = friendName;
  }

  String? getFriendName() {
    return friendName;
  }

  int getFriendId() {
    return friendId;
  }

  setUnreadMessages(int? unreadMessages) {
    this.unreadMessages = unreadMessages;
  }

  int? getUnreadMessages() {
    return unreadMessages;
  }

  setFriendAvatar(Uint8List? friendAvatar) {
    this.friendAvatar = friendAvatar;
    if (friendAvatar != null) {
      retrievedAvatar = true;
    }
  }

  Uint8List? getFriendAvatar() {
    return friendAvatar;
  }

  @override
  String toString() {
    return 'Friend{friendId: $friendId, friendName: $friendName, accepted: $accepted, requested: $requested, unreadMessages: $unreadMessages}';
  }

}
