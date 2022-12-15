import 'package:flutter/material.dart';
import '../age_of_gold.dart';
import '../services/auth.dart';
import '../services/settings.dart';
import 'package:flutter/scheduler.dart';
import 'app_bar.dart';


class WorldAccess extends StatefulWidget {

  static const String route = '/worldaccess';
  final AgeOfGold game;

  const WorldAccess({
    Key? key,
    required this.game
  }) : super(key: key);

  @override
  State<WorldAccess> createState() => _WorldAccessState();
}

class _WorldAccessState extends State<WorldAccess> {

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
    //   refreshAccessToken(accessToken, refreshToken, true).then((value) {
    //     if (value == "success") {
    //       print("it was a success");
    //       Navigator.pushNamed(context, "/world");
    //     } else {
    //       print("it failed");
    //       Navigator.of(context).pushNamed("/");
    //     }
    //   });
    // } else {
    //   SchedulerBinding.instance.addPostFrameCallback((_) {
    //     Navigator.of(context).pushNamed("/");
    //   });
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
