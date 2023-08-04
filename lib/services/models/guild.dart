import 'dart:convert';
import 'dart:typed_data';

import 'package:age_of_gold/services/models/guild_member.dart';
import 'package:age_of_gold/services/models/user.dart';
import 'package:age_of_gold/util/util.dart';

class Guild {

  late int guildId;
  late String guildName;
  Uint8List? guildCrest;
  String myGuildRank = "";
  int myGuildRankId = 4;

  // The member ids of the guild, along with their ranks.
  List<GuildMember> guildMembers = [];
  bool isAdministrator = false;  // Indicates if the member has admin rights.

  bool? accepted;
  bool? requested;

  int guildScore = 0;

  bool retrieved = true;

  Guild(this.guildId, this.guildName, this.guildCrest);

  Guild.fromJson(Map<String, dynamic> json, bool minimal) {
    if (json.containsKey("guild_id")) {
      guildId = json['guild_id'];
    }
    if (json.containsKey("guild_name")) {
      guildName = json['guild_name'];
    }
    if (json.containsKey("guild_crest") && json["guild_crest"] != null) {
      guildCrest = base64Decode(json["guild_crest"].replaceAll("\n", ""));
    }
    if (json.containsKey("members")) {
      for (List member in json['members']) {
        int memberId = member[0];
        int memberRank = member[1];
        GuildMember guildMember = GuildMember(memberId, memberRank);
        guildMember.setGuildRank();
        guildMembers.add(guildMember);
      }
    }
    if (json.containsKey("accepted")) {
      accepted = json['accepted'];
    }
    if (json.containsKey("requested")) {
      requested = json['requested'];
    }
    // If it was minimal, it wasn't fully retrieved.
    retrieved = !minimal;
  }

  int getGuildId() {
    return guildId;
  }

  String getGuildName() {
    return guildName;
  }

  setGuildName(String guildName) {
    this.guildName = guildName;
  }

  Uint8List? getGuildCrest() {
    return guildCrest;
  }

  setGuildCrest(Uint8List? guildCrest) {
    this.guildCrest = guildCrest;
  }

  List<GuildMember> getMembers() {
    return guildMembers;
  }

  addMember(GuildMember member) {
    if (guildMembers.any((element) => element.getGuildMemberId() == member.getGuildMemberId())) {
      GuildMember existingMember = guildMembers
          .where((element) => element.getGuildMemberId() == member.getGuildMemberId())
          .first;
      if (member.isMemberRetrieved() && !existingMember.isMemberRetrieved()) {
        guildMembers.removeWhere((element) => element.getGuildMemberId() == existingMember.getGuildMemberId());
        guildMembers.add(member);
        return;
      } else {
        // in all other situation we do nothing because the member is already correctly in the list.
        return;
      }
    } else {
      guildMembers.add(member);
      return;
    }
  }

  removeMember(GuildMember member) {
    if (guildMembers.any((element) => element.getGuildMemberId() == member.getGuildMemberId())) {
      guildMembers.removeWhere((element) => element.getGuildMemberId() == member.getGuildMemberId());
    }
  }

  changeMemberRank(GuildMember changedGuildMember) {
    if (guildMembers.any((element) => element.getGuildMemberId() == changedGuildMember.getGuildMemberId())) {
      if (changedGuildMember.getGuildMemberRank() != null) {
        // update the rank of the changed member
        GuildMember existingMember = guildMembers
            .where((element) => element.getGuildMemberId() == changedGuildMember.getGuildMemberId())
            .first;
        existingMember.setGuildMemberRank(changedGuildMember.getGuildMemberRank()!);
        existingMember.setGuildRank();
      }
    }
  }

  setMyGuildRank(String myGuildRank) {
    this.myGuildRank = myGuildRank;
    myGuildRankId = getRankId(myGuildRank);
  }

  String getMyGuildRank() {
    return myGuildRank;
  }

  int getMyGuildRankId() {
    return myGuildRankId;
  }

  setAdministrator(bool isAdministrator) {
    this.isAdministrator = isAdministrator;
  }

  bool getAdministrator() {
    return isAdministrator;
  }

  int getGuildScore() {
    return guildScore;
  }

  @override
  String toString() {
    return 'Guild{guildId: $guildId, guildName: $guildName, guildMembers: $guildMembers}';
  }
}
