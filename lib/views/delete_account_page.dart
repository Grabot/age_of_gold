import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:age_of_gold/constants/route_paths.dart' as routes;
import 'package:oktoast/oktoast.dart';

import '../locator.dart';
import '../services/auth_service_login.dart';
import '../util/navigation_service.dart';
import '../util/util.dart';


class DeleteAccountPage extends StatefulWidget {

  static const String route = '/deletion';

  const DeleteAccountPage({super.key});

  @override
  State<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  final NavigationService _navigationService = locator<NavigationService>();

  final deleteKeyRegister = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();

  String? accessToken;
  String? refreshToken;
  String? origin;

  bool busy = true;
  bool invalid = true;

  @override
  void initState() {
    super.initState();
    accessToken = Uri.base.queryParameters["access_token"];
    refreshToken = Uri.base.queryParameters["refresh_token"];
    origin = Uri.base.queryParameters["origin"];

    invalid = true;
    if (accessToken != null && refreshToken != null && origin != null) {
      // Check if the token from the mail is still valid.
      AuthServiceLogin().removeAccount(accessToken!, refreshToken!, origin!).then((deleteAccountResponse) {
        busy = false;
        setState(() {
          invalid = !deleteAccountResponse.getResult();
        });
      }).onError((error, stackTrace) {
        busy = false;
        showToast("Failed to delete account: ${error.toString()}");
      });
    } else {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _navigationService.navigateTo(routes.HomeRoute);
      });
    }
  }

  Widget deleteAccountBox(double width, double fontSize, bool normalMode) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
          children: [
            ageOfGoldLogo(width, normalMode),
            Text(
              "Account Deleted",
              style: TextStyle(color: Colors.white, fontSize: fontSize*2),
            ),
            Column(
              children: [
                Text(
                  "Your Hex Place account has been deleted.",
                  style: TextStyle(color: Colors.white70, fontSize: fontSize),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            SizedBox(height: 40),
          ]
      ),
    );
  }

  Widget invalidLink(double width, double fontSize, bool normalMode) {
    return busy ? Container() : Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
          children: [
            ageOfGoldLogo(width, normalMode),
            Text(
              "Invalid Link",
              style: TextStyle(color: Colors.white, fontSize: fontSize*2),
            ),
            Column(
              children: [
                Text(
                  "This link has expired or has already been used. \nTo delete your account, first verify if it's not already removed, then return to the account removal page and fill in your email to receive a new email.",
                  style: TextStyle(color: Colors.white70, fontSize: fontSize),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            SizedBox(height: 40),
          ]
      ),
    );
  }

  Widget passwordBox() {
    double totalWidth = MediaQuery.of(context).size.width;
    double totalHeight = MediaQuery.of(context).size.height;
    double heightScale = totalHeight / 800;
    double fontSize = 16 * heightScale;
    double width = 800;
    double height = (totalHeight / 10) * 9;
    bool normalMode = true;
    // When the width is smaller than this we assume it's mobile.
    if (totalWidth <= 800) {
      width = totalWidth - 50;
      height = totalHeight - 250;
      normalMode = false;
    }

    return Container(
      width: width,
      height: height,
      color: Colors.orange,
      child: SingleChildScrollView(
          child: invalid
              ? invalidLink(width, fontSize, normalMode)
              : deleteAccountBox(width, fontSize, normalMode)
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
            child: passwordBox()
        ),
      ),
    );
  }
}

