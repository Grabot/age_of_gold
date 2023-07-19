
import 'dart:convert';

import 'package:age_of_gold/services/auth_service_social.dart';
import 'package:age_of_gold/services/models/guild_member.dart';
import 'package:age_of_gold/services/models/user.dart';
import 'package:age_of_gold/views/user_interface/ui_views/change_guild_crest_box/change_guild_crest_change_notifier.dart';

Future<void> retrieveGuildMembers(User me) async {
  if (me.getGuild() != null) {
    // Some members have been added or removed, we need to update the list
    // or we have not yet retrieved the users from the ids
    List<int> membersToRetrieve = [];
    for (GuildMember member in me.getGuild()!.getMembers()) {
      if (member.getGuildMemberId() != null && !member.isMemberRetrieved()) {
        membersToRetrieve.add(member.getGuildMemberId()!);
      }
    }
    if (membersToRetrieve.isNotEmpty) {
      var value = await AuthServiceSocial().getFriendAvatars(membersToRetrieve);
      if (value != null) {
        for (Map<String, dynamic> guildMember in value) {
          int guildMemberId = guildMember["id"];
          String guildMemberName = guildMember["username"];
          String guildMemberAvatar = guildMember["avatar"];
          for (GuildMember member in me.getGuild()!.getMembers()) {
            if (member.getGuildMemberId() == guildMemberId) {
              member.setGuildMemberName(guildMemberName);
              member.setGuildMemberAvatar(base64Decode(guildMemberAvatar.replaceAll("\n", "")));
            }
          }
        }
      }
    }
  }
  return;
}

setGuildCrest(User me, ChangeGuildCrestChangeNotifier changeGuildCrestChangeNotifier) {
  if (me.getGuild() != null ) {
    if (me.getGuild()!.getGuildCrest() != null) {
      changeGuildCrestChangeNotifier.setGuildCrest(me.getGuild()!.getGuildCrest()!);
      changeGuildCrestChangeNotifier.setDefault(false);
    }
  }
}
