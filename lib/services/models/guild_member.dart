import 'dart:typed_data';

import 'package:age_of_gold/services/models/user.dart';
import 'package:flutter/material.dart';

class GuildMember {

  late int guildMemberId;  // same as user id
  int? guildMemberRank;
  String guildMemberRankName = "";
  String guildMemberName = "";

  Uint8List? guildMemberAvatar;
  bool memberRetrieved = false;

  bool isMe = false;

  GuildMember(this.guildMemberId, this.guildMemberRank);

  GuildMember.fromJson(Map<String, dynamic> json) {
    guildMemberId = json["id"];

    if (json.containsKey("username")) {
      guildMemberName = json["username"];
    }
    if (json.containsKey("avatar")) {
      guildMemberAvatar = json["avatar"];
    }
    setGuildRank();
  }

  setGuildMemberId(int guildMemberId) {
    this.guildMemberId = guildMemberId;
  }

  int getGuildMemberId() {
    return guildMemberId;
  }

  setGuildMemberRank(int guildMemberRank) {
    this.guildMemberRank = guildMemberRank;
  }

  int? getGuildMemberRank() {
    return guildMemberRank;
  }

  setGuildMemberName(String guildMemberName) {
    this.guildMemberName = guildMemberName;
    if (guildMemberAvatar != null) {
      memberRetrieved = true;
    }
  }

  String getGuildMemberName() {
    return guildMemberName;
  }

  setGuildMemberAvatar(Uint8List? guildMemberAvatar) {
    this.guildMemberAvatar = guildMemberAvatar;
    if (guildMemberAvatar != null) {
      memberRetrieved = true;
    }
  }

  setGuildRank() {
    if (getGuildMemberRank() != null) {
      if (getGuildMemberRank() == 0) {
        setGuildMemberRankName("Guildmaster");
      } else if (getGuildMemberRank() == 1) {
        setGuildMemberRankName("Officer");
      } else if (getGuildMemberRank() == 2) {
        setGuildMemberRankName("Merchant");
      } else {
        setGuildMemberRankName("Trader");
      }
    }
  }

  setGuildMemberRankName(String guildMemberRankName) {
    this.guildMemberRankName = guildMemberRankName;
  }

  String getGuildMemberRankName() {
    return guildMemberRankName;
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
