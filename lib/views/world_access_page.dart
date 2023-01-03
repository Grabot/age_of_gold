import 'package:age_of_gold/locator.dart';
import 'package:age_of_gold/services/auth_service.dart';
import 'package:age_of_gold/services/models/refresh_request.dart';
import 'package:age_of_gold/util/navigation_service.dart';
import 'package:flutter/material.dart';
import '../age_of_gold.dart';
import 'package:age_of_gold/constants/route_paths.dart' as routes;
import 'package:flutter/scheduler.dart';


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
    String baseUrl = Uri.base.toString();
    String? accessToken = Uri.base.queryParameters["access_token"];
    String? refreshToken = Uri.base.queryParameters["refresh_token"];

    print("base: $baseUrl");
    print("access token: $accessToken");
    print("refresh token: $refreshToken");
    // Use the tokens to immediately refresh the access token
    if (accessToken != null && refreshToken != null) {
      AuthService authService = AuthService();
      authService.getRefresh(RefreshRequest(accessToken, refreshToken)).then((loginResponse) {
        if (loginResponse.getResult()) {
          print("it was a success");
          _navigationService.navigateTo(routes.GameRoute);
        } else {
          print("it failed");
          _navigationService.navigateTo(routes.HomeRoute);
        }
      });
    } else {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _navigationService.navigateTo(routes.HomeRoute);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: appBarAgeOfGold(),
      body: Center(
        child: Container(
        ),
      ),
    );
  }
}
