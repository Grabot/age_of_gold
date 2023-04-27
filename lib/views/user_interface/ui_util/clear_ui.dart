import 'package:age_of_gold/views/user_interface/ui_util/selected_tile_info.dart';
import 'package:age_of_gold/views/user_interface/ui_views/change_avatar_box/change_avatar_change_notifier.dart';
import 'package:age_of_gold/views/user_interface/ui_views/chat_window/chat_window_change_notifier.dart';
import 'package:age_of_gold/views/user_interface/ui_views/friend_window/friend_window_change_notifier.dart';
import 'package:age_of_gold/views/user_interface/ui_views/profile_box/profile_change_notifier.dart';
import 'package:age_of_gold/views/user_interface/ui_views/user_box/user_box_change_notifier.dart';
import 'package:flutter/material.dart';


class ClearUI extends ChangeNotifier {

  static final ClearUI _instance = ClearUI._internal();

  ClearUI._internal();

  factory ClearUI() {
    return _instance;
  }

  clearUserInterfaces() {
    if (ChangeAvatarChangeNotifier().getChangeAvatarVisible()) {
      ChangeAvatarChangeNotifier().setChangeAvatarVisible(false);
    }
    if (ChatWindowChangeNotifier().getChatWindowVisible()) {
      ChatWindowChangeNotifier().setChatWindowVisible(false);
    }
    if (FriendWindowChangeNotifier().getFriendWindowVisible()) {
      FriendWindowChangeNotifier().setFriendWindowVisible(false);
    }
    if (UserBoxChangeNotifier().getUserBoxVisible()) {
      UserBoxChangeNotifier().setUserBoxVisible(false);
    }
    if (ProfileChangeNotifier().getProfileVisible()) {
      ProfileChangeNotifier().setProfileVisible(false);
    }
  }
}
