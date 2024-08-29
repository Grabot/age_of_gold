import 'package:age_of_gold/locator.dart';
import 'package:age_of_gold/services/auth_service_login.dart';
import 'package:age_of_gold/util/navigation_service.dart';
import 'package:age_of_gold/views/user_interface/ui_views/login_view/login_window_change_notifier.dart';
import 'package:flutter/material.dart';
import '../age_of_gold.dart';
import 'package:age_of_gold/constants/route_paths.dart' as routes;
import 'package:flutter/scheduler.dart';

import '../util/util.dart';


class WorldAccess extends StatefulWidget {

  final AgeOfGold game;

  const WorldAccess({
    Key? key,
    required this.game
  }) : super(key: key);

  @override
  State<WorldAccess> createState() => _WorldAccessState();
}

class _WorldAccessState extends State<WorldAccess> {

  final NavigationService _navigationService = locator<NavigationService>();

  @override
  void initState() {
    super.initState();
    String? accessToken = Uri.base.queryParameters["access_token"];
    String? refreshToken = Uri.base.queryParameters["refresh_token"];

    // Use the tokens to immediately refresh the access token
    if (accessToken != null && refreshToken != null) {
      AuthServiceLogin authService = AuthServiceLogin();
      authService.getRefresh(accessToken, refreshToken).then((loginResponse) {
        if (loginResponse.getResult()) {
          print("it was a success");
          setState(() {
            LoginWindowChangeNotifier().setLoginWindowVisible(false);
          });
        } else {
          print("it failed");
        }
        Future.delayed(const Duration(milliseconds: 500), ()
        {
          _navigationService.navigateTo(routes.HomeRoute);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
        ),
      ),
    );
  }
}
