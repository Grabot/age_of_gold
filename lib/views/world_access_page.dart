import 'package:age_of_gold/age_of_gold.dart';
import 'package:age_of_gold/views/user_interface/ui_views/login_view/login_window_change_notifier.dart';
import 'package:flutter/material.dart';
import 'package:age_of_gold/constants/route_paths.dart' as routes;

import '../locator.dart';
import '../services/auth_service_login.dart';
import '../util/navigation_service.dart';


class WorldAccess extends StatefulWidget {

  final AgeOfGold game;

  const WorldAccess({
    super.key,
    required this.game
  });

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
          setState(() {
            LoginWindowChangeNotifier().setLoginWindowVisible(false);
          });
        }
        Future.delayed(const Duration(milliseconds: 500), () {
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
