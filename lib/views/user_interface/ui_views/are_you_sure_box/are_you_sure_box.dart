import 'package:age_of_gold/age_of_gold.dart';
import 'package:flutter/material.dart';

import '../../../../locator.dart';
import '../../../../services/auth_service_guild.dart';
import '../../../../services/models/user.dart';
import '../../../../services/settings.dart';
import '../../../../util/navigation_service.dart';
import '../../../../util/util.dart';
import '../../ui_util/chat_messages.dart';
import '../guild_window/guild_information.dart';
import '../profile_box/profile_change_notifier.dart';
import 'are_you_sure_change_notifier.dart';


class AreYouSureBox extends StatefulWidget {

  final AgeOfGold game;

  const AreYouSureBox({
    required Key key,
    required this.game
  }) : super(key: key);

  @override
  AreYouSureBoxState createState() => AreYouSureBoxState();
}

class AreYouSureBoxState extends State<AreYouSureBox> {

  final FocusNode _focusAreYouSureBox = FocusNode();
  bool showAreYouSure = false;

  late AreYouSureBoxChangeNotifier areYouSureBoxChangeNotifier;

  final NavigationService _navigationService = locator<NavigationService>();

  @override
  void initState() {
    areYouSureBoxChangeNotifier = AreYouSureBoxChangeNotifier();
    areYouSureBoxChangeNotifier.addListener(areYouSureBoxChangeListener);

    _focusAreYouSureBox.addListener(_onFocusChange);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  areYouSureBoxChangeListener() {
    if (mounted) {
      if (!showAreYouSure && areYouSureBoxChangeNotifier.getAreYouSureBoxVisible()) {
        setState(() {
          showAreYouSure = true;
        });
      }
      if (showAreYouSure && !areYouSureBoxChangeNotifier.getAreYouSureBoxVisible()) {
        setState(() {
          showAreYouSure = false;
        });
      }
    }
  }

  void _onFocusChange() {
    widget.game.windowFocus(_focusAreYouSureBox.hasFocus);
  }

  cancelButtonAction() {
    areYouSureBoxChangeNotifier.setAreYouSureBoxVisible(false);
  }

  leaveGuildButtonAction() {
    int? userId = areYouSureBoxChangeNotifier.getUserId();
    int? guildId = areYouSureBoxChangeNotifier.getGuildId();
    if (userId == null || guildId == null) {
      showToastMessage("an error occurred");
      return;
    }
    User? me = Settings().getUser();
    if (me == null) {
      showToastMessage("an error occurred");
      return;
    } else {
      AuthServiceGuild().leaveGuild(userId, guildId).then((value) {
        if (value.getResult()) {
          me.setGuild(null);
          GuildInformation guildInformation = GuildInformation();
          guildInformation.setGuildCrest(null);
          guildInformation.setCrestIsDefault(true);
          ChatMessages().leaveGuild();
          ProfileChangeNotifier().notify();
          areYouSureBoxChangeNotifier.setAreYouSureBoxVisible(false);
        } else {
          showToastMessage(value.getMessage());
        }
      });
    }
  }

  Widget areYouSureLeaveGuild() {
    return TapRegion(
      onTapOutside: (tap) {
        cancelButtonAction();
      },
      child: AlertDialog(
        title: const Text("Leave guild?"),
        content: const Text("Are you sure you want to leave the guild?"),
        actions: [
          ElevatedButton(
            child: const Text("Cancel"),
            onPressed:  () {
              cancelButtonAction();
            },
          ),
          ElevatedButton(
            child: const Text("Leave"),
            onPressed:  () {
              leaveGuildButtonAction();
            },
          ),
        ],
      ),
    );
  }

  logoutAction() {
    Settings settings = Settings();
    logoutUser(settings, _navigationService);
  }

  Widget areYouSureLogout() {
    return TapRegion(
      onTapOutside: (tap) {
        cancelButtonAction();
      },
      child: AlertDialog(
        title: const Text("Logout?"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          ElevatedButton(
            child: const Text("Cancel"),
            onPressed:  () {
              cancelButtonAction();
            },
          ),
          ElevatedButton(
            child: const Text("Logout"),
            onPressed:  () {
              logoutAction();
            },
          ),
        ],
      ),
    );
  }

  Widget areYouSureBox(BuildContext context) {
    bool showLeaveGuild = areYouSureBoxChangeNotifier.getShowLeaveGuild();
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: showLeaveGuild ? areYouSureLeaveGuild() : areYouSureLogout()
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: FractionalOffset.center,
      child: showAreYouSure ? areYouSureBox(context) : Container()
    );
  }
}
