import 'package:age_of_gold/age_of_gold.dart';
import 'package:age_of_gold/services/auth_service_guild.dart';
import 'package:age_of_gold/services/models/user.dart';
import 'package:age_of_gold/services/settings.dart';
import 'package:age_of_gold/util/navigation_service.dart';
import 'package:age_of_gold/util/util.dart';
import 'package:age_of_gold/views/user_interface/ui_views/are_you_sure_box/are_you_sure_change_notifier.dart';
import 'package:age_of_gold/views/user_interface/ui_views/guild_window/guild_information.dart';
import 'package:age_of_gold/views/user_interface/ui_views/guild_window/guild_window_change_notifier.dart';
import 'package:flutter/material.dart';
import 'package:age_of_gold/locator.dart';


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
    widget.game.loadingBoxFocus(_focusAreYouSureBox.hasFocus);
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
          print("leave guild success");
          if (me.guild != null) {
            me.setGuild(null);
            GuildInformation guildInformation = GuildInformation();
            guildInformation.setGuildCrest(null);
            guildInformation.setCrestIsDefault(true);
            GuildWindowChangeNotifier().setGuildWindowVisible(true);
            areYouSureBoxChangeNotifier.setAreYouSureBoxVisible(false);
          } else {
            showToastMessage("an error occured");
          }
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
        title: Text("Leave guild?"),
        content: Text("Are you sure you want to leave the guild?"),
        actions: [
          ElevatedButton(
            child: Text("Cancel"),
            onPressed:  () {
              cancelButtonAction();
            },
          ),
          ElevatedButton(
            child: Text("Leave"),
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
        title: Text("Logout?"),
        content: Text("Are you sure you want to logout?"),
        actions: [
          ElevatedButton(
            child: Text("Cancel"),
            onPressed:  () {
              cancelButtonAction();
            },
          ),
          ElevatedButton(
            child: Text("Logout"),
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
