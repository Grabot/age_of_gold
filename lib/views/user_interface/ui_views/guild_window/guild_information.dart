import 'dart:convert';
import 'dart:typed_data';

import 'package:age_of_gold/services/auth_service_guild.dart';
import 'package:age_of_gold/services/auth_service_social.dart';
import 'package:age_of_gold/services/models/guild.dart';
import 'package:age_of_gold/services/models/user.dart';
import 'package:flutter/material.dart';


class GuildInformation extends ChangeNotifier {

  Uint8List? guildCrest;
  bool crestIsDefault = false;

  List<User> requestedMembers = [];
  bool requestedMembersRetrieved = false;

  List<User> askedMembers = [];
  bool askedMembersRetrieved = false;

  List<Guild> guildsSendRequests = [];
  bool guildSendRequestsRetrieved = false;

  List<Guild> guildsGotRequests = [];
  bool guildsGotRequestsRetrieved = false;

  static final GuildInformation _instance = GuildInformation._internal();

  GuildInformation._internal();

  factory GuildInformation() {
    return _instance;
  }

  setGuildCrest(Uint8List? guildCrest) {
    this.guildCrest = guildCrest;
  }

  Uint8List? getGuildCrest() {
    return guildCrest;
  }

  setCrestIsDefault(bool crestIsDefault) {
    this.crestIsDefault = crestIsDefault;
  }

  getCrestIsDefault() {
    return crestIsDefault;
  }

  Future<bool> checkRetrievedUsers(List<User> checkUsers) async {
    List<int> membersToRetrieve = [];
    for (User member in checkUsers) {
      if (member.getAvatar() == null) {
        membersToRetrieve.add(member.getId());
      }
    }
    if (membersToRetrieve.isNotEmpty) {
      List? response = await AuthServiceSocial().getFriendAvatars(membersToRetrieve);
      if (response != null) {
        for (Map<String, dynamic> possibleGuildMember in response) {
          int userId = possibleGuildMember["id"];
          String userName = possibleGuildMember["username"];
          String userAvatar = possibleGuildMember["avatar"];
          for (User requestedMember in checkUsers) {
            if (requestedMember.getId() == userId) {
              requestedMember.setUsername(userName);
              requestedMember.setAvatar(base64Decode(userAvatar.replaceAll("\n", "")));
            }
          }
        }
        return true;
      }
    }
    return false;
  }

  Future<bool> getRequestedGuildSend(int guildId, bool minimal) async {
    if (requestedMembersRetrieved) {
      // Check if any of the users in the requestedMembers list have not been retrieved.
      return checkRetrievedUsers(requestedMembers);
    } else {
      List<User>? response = await AuthServiceGuild().getRequestedGuildSend(guildId, minimal);
      if (response != null) {
        requestedMembers = response;
        requestedMembersRetrieved = true;
        return true;
      } else {
        return false;
      }
    }
  }

  Future<bool> getRequestedGuildGot(int guildId) async {
    if (askedMembersRetrieved) {
      return checkRetrievedUsers(askedMembers);
    } else {
      List<User>? response = await AuthServiceGuild().getRequestedGuildGot(guildId);
      if (response != null) {
        askedMembers = response;
        askedMembersRetrieved = true;
        return true;
      } else {
        return false;
      }
    }
  }

  Future<bool> getRequestedUserSend() async {
    if (guildSendRequestsRetrieved) {
      print("not doing got");
      return false;
    } else {
      print("going to retreive got");
      List<Guild>? response = await AuthServiceGuild().getRequestedUserSend();
      if (response != null) {
        guildsSendRequests = response;
        guildSendRequestsRetrieved = true;
        return true;
      } else {
        return false;
      }
    }
  }

  Future<bool> getRequestedUserGot(bool minimal) async {
    if (guildsGotRequestsRetrieved) {
      print("not doing got");
      return false;
    } else {
      print("going to retreive got");
      List<Guild>? response = await AuthServiceGuild().getRequestedUserGot(minimal);
      if (response != null) {
        guildsGotRequests = response;
        guildsGotRequestsRetrieved = true;
        return true;
      } else {
        return false;
      }
    }
  }

  addRequestedMember(User user) {
    if (requestedMembers.any((element) => element.getId() == user.getId())) {
      User existingMember = requestedMembers.where((element) => element.getId() == user.getId()).first;
      if (user.getAvatar() != null && existingMember.getAvatar() == null) {
        requestedMembers.removeWhere((element) => element.getId() == existingMember.getId());
        requestedMembers.add(user);
      } else {
        // in all other situation we do nothing because the member is already correctly in the list.
      }
    } else {
      requestedMembers.add(user);
    }
    checkRetrievedUsers(requestedMembers);
    notifyListeners();
  }

  addAskedMember(User user) {
    if (askedMembers.any((element) => element.getId() == user.getId())) {
      User existingMember = askedMembers.where((element) => element.getId() == user.getId()).first;
      if ((user.getAvatar() != null) && existingMember.getAvatar() == null) {
        askedMembers.removeWhere((element) => element.getId() == existingMember.getId());
        askedMembers.add(user);
      } else {
        // in all other situation we do nothing because the member is already correctly in the list.
      }
    } else {
      askedMembers.add(user);
    }
    checkRetrievedUsers(askedMembers);
    notifyListeners();
  }

  clearInformation() {
    guildCrest = null;
    crestIsDefault = false;
    requestedMembers = [];
    requestedMembersRetrieved = false;
    askedMembers = [];
    askedMembersRetrieved = false;
    guildsSendRequests = [];
    guildSendRequestsRetrieved = false;
    guildsGotRequests = [];
    guildsGotRequestsRetrieved = false;
  }

  notify() {
    notifyListeners();
  }
}
