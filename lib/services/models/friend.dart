import 'package:age_of_gold/services/models/user.dart';
import 'package:flutter/material.dart';

class Friend {

  late bool accepted;
  late User? friend;
  // determines if the request was send or received, can be null
  bool? requested;

  Friend(this.accepted, this.requested, this.friend);

  Friend.fromJson(Map<String, dynamic> json) {
    if (json.containsKey("friend")) {
      friend = User.fromJson(json['friend']);
    }
    if (json.containsKey("accepted")) {
      accepted = json["accepted"];
    }
    if (json.containsKey("requested")) {
      requested = json["requested"];
    }
  }

  User? getUser() {
    return friend;
  }

  bool isAccepted() {
    return accepted;
  }

  bool isRequested() {
    return requested!;
  }

  @override
  String toString() {
    return 'Friend{accepted: $accepted, friend: $friend}';
  }

  Widget friendWidget() {
    return Container();
  }
}
