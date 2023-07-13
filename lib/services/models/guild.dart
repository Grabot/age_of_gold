import 'dart:convert';
import 'dart:typed_data';

import 'package:age_of_gold/services/models/guild_member.dart';

class Guild {

  late int guildId;
  late String guildName;
  Uint8List? guildCrest;
  String guildRank = "";

  // The member ids of the guild, along with their ranks.
  // List<List<int>> members = [[]];
  List<GuildMember> guildMembers = [];

  Guild(this.guildId, this.guildName, this.guildCrest);

  Guild.fromJson(Map<String, dynamic> json) {
    if (json.containsKey("id")) {
      guildId = json['id'];
    }
    if (json.containsKey("guild_name")) {
      guildName = json['guild_name'];
    }
    if (json.containsKey("guild_crest") && json["guild_crest"] != null) {
      guildCrest = base64Decode(json["guild_crest"].replaceAll("\n", ""));
    }
    if (json.containsKey("members")) {
      // members = json['members'];
      for (List member in json['members']) {
        int memberId = member[0];
        int memberRank = member[1];
        GuildMember guildMember = GuildMember(memberId, memberRank);
        guildMembers.add(guildMember);
      }
    }
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
    guildMembers.add(member);
  }

  setGuildRank(String guildRank) {
    this.guildRank = guildRank;
  }

  String getGuildRank() {
    return guildRank;
  }

  @override
  String toString() {
    return 'Guild{guildId: $guildId, guildName: $guildName, guildMembers: $guildMembers}';
  }
}
