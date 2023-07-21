import 'dart:typed_data';

import 'package:age_of_gold/services/auth_service_guild.dart';
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

  Future<bool> getRequestedGuildSend(int guildId, bool minimal) async {
    if (requestedMembersRetrieved) {
      return false;
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
      return false;
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
}
