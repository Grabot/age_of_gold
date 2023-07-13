import 'dart:typed_data';

import 'package:age_of_gold/services/models/user.dart';
import 'package:flutter/material.dart';

class GuildMember {

  int? guildMemberId;
  int? guildMemberRank;
  String? guildMemberName;

  Uint8List? guildMemberAvatar;
  bool memberRetrieved = false;

  bool isMe = false;

  GuildMember(this.guildMemberId, this.guildMemberRank);

  GuildMember.fromJson(Map<String, dynamic> json) {
    if (json.containsKey("id")) {
      guildMemberId = json["id"];
    }
    if (json.containsKey("username")) {
      guildMemberName = json["username"];
    }
    if (json.containsKey("avatar")) {
      guildMemberAvatar = json["avatar"];
    }
  }

  setGuildMemberId(int? guildMemberId) {
    this.guildMemberId = guildMemberId;
  }

  int? getGuildMemberId() {
    return guildMemberId;
  }

  int? getGuildMemberRank() {
    return guildMemberRank;
  }

  setGuildMemberName(String? guildMemberName) {
    this.guildMemberName = guildMemberName;
    if (guildMemberAvatar != null && guildMemberName != null) {
      memberRetrieved = true;
    }
  }

  String? getGuildMemberName() {
    return guildMemberName;
  }

  setGuildMemberAvatar(Uint8List? guildMemberAvatar) {
    this.guildMemberAvatar = guildMemberAvatar;
    if (guildMemberAvatar != null && guildMemberName != null) {
      memberRetrieved = true;
    }
  }

  Uint8List? getGuildMemberAvatar() {
    return guildMemberAvatar;
  }

  setRetrieved(bool retrieved) {
    memberRetrieved = retrieved;
  }

  bool isMemberRetrieved() {
    return memberRetrieved;
  }

  setIsMe(bool isMe) {
    this.isMe = isMe;
  }

  @override
  String toString() {
    return 'GuildMember{guildMemberId: $guildMemberId, guildMemberRank: $guildMemberRank, guildMemberName: $guildMemberName}';
  }

}
