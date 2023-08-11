import 'dart:convert';

import 'package:age_of_gold/services/auth_service_social.dart';
import 'package:age_of_gold/services/models/friend.dart';
import 'package:age_of_gold/services/models/user.dart';
import 'package:flutter/material.dart';


class FriendWindowChangeNotifier extends ChangeNotifier {

  bool showFriendWindow = false;
  String headerText = "Social";
  bool unansweredFriendRequests = false;

  static final FriendWindowChangeNotifier _instance = FriendWindowChangeNotifier._internal();

  FriendWindowChangeNotifier._internal();

  factory FriendWindowChangeNotifier() {
    return _instance;
  }

  setFriendWindowVisible(bool visible) {
    showFriendWindow = visible;
    notifyListeners();
  }

  getFriendWindowVisible() {
    return showFriendWindow;
  }

  String getHeaderText() {
    return headerText;
  }

  setHeaderText(String text) {
    headerText = text;
    notifyListeners();
  }

  checkUnansweredFriendRequests(User? me) {
    if (me != null) {
      unansweredFriendRequests = false;
      for (Friend friend in me.friends) {
        if (!friend.isAccepted() && friend.requested != null && friend.requested == false) {
          unansweredFriendRequests = true;
          break;
        }
      }
    }
  }

  retrieveIds(User me, List<int> friendsToRetrieve) async {
    AuthServiceSocial().getFriendAvatars(friendsToRetrieve).then((value) {
      if (value != null) {
        for (Map<String, dynamic> possibleGuildMember in value) {
          int userId = possibleGuildMember["id"];
          String userName = possibleGuildMember["username"];
          String userAvatar = possibleGuildMember["avatar"];
          for (Friend friend in me.getFriends()) {
            if (friend.getFriendId() == userId) {
              friend.setFriendName(userName);
              friend.setFriendAvatar(base64Decode(userAvatar.replaceAll("\n", "")));
              break;
            }
          }
        }
        notifyListeners();
      }
    });
  }

  checkAcceptedRetrieved(User me) async {
    List<int> friendsToRetrieve = [];
    for (Friend friend in me.getFriends()) {
      if (friend.isAccepted()) {
        if (!friend.retrievedAvatar) {
          friendsToRetrieve.add(friend.getFriendId());
        }
      }
    }
    if (friendsToRetrieve.isNotEmpty) {
      retrieveIds(me, friendsToRetrieve);
    }
  }

  checkRequestedRetrieved(User me) async {
    List<int> friendsToRetrieve = [];
    for (Friend friend in me.getFriends()) {
      if (!friend.isAccepted()) {
        if (!friend.retrievedAvatar) {
          friendsToRetrieve.add(friend.getFriendId());
        }
      }
    }
    if (friendsToRetrieve.isNotEmpty) {
      retrieveIds(me, friendsToRetrieve);
    }
  }

  notify() {
    notifyListeners();
  }
}
