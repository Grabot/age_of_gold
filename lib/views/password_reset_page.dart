import 'package:age_of_gold/age_of_gold.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:age_of_gold/constants/route_paths.dart' as routes;

import '../locator.dart';
import '../services/auth_service_login.dart';
import '../util/navigation_service.dart';
import '../util/util.dart';


class PasswordReset extends StatefulWidget {

  final AgeOfGold game;

  const PasswordReset({
    super.key,
    required this.game
  });

  @override
  State<PasswordReset> createState() => _PasswordResetState();
}

class _PasswordResetState extends State<PasswordReset> {

  final NavigationService _navigationService = locator<NavigationService>();

  TextEditingController passwordReset1Controller = TextEditingController();

  final formKeyPasswordReset = GlobalKey<FormState>();

  String? accessToken;
  String? refreshToken;

  // By default we assume it's invalid
  bool invalid = true;
  bool passwordUpdated = false;

  @override
  void initState() {
    super.initState();
    accessToken = Uri.base.queryParameters["access_token"];
    refreshToken = Uri.base.queryParameters["refresh_token"];

    invalid = true;
    if (accessToken != null && refreshToken != null) {
      // Check if the token from the mail is still valid.
      AuthServiceLogin().passwordResetCheck(accessToken!, refreshToken!).then((passwordResetResponse) {
        setState(() {
          invalid = !passwordResetResponse.getResult();
        });
      });
    } else {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _navigationService.navigateTo(routes.HomeRoute);
      });
    }
  }

  resetPassword() {
    if (formKeyPasswordReset.currentState!.validate()) {
      // The other controller has the same password.
      if (accessToken != null && refreshToken != null) {
        String newPassword = passwordReset1Controller.text;
        // Check if the token from the mail is still valid.
        AuthServiceLogin().updatePassword(accessToken!, refreshToken!, newPassword).then((updatePasswordResponse) {
          setState(() {
            passwordUpdated = updatePasswordResponse.getResult();
          });
        });
      } else {
        showToastMessage("an error occured");
      }
    }
  }

  Widget invalidPasswordBox(double width, double fontSize, bool normalMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          ageOfGoldLogo(width, normalMode),
          Text(
            "Invalid link",
            style: TextStyle(color: Colors.white, fontSize: fontSize*2),
          ),
          Column(
            children: [
              Text(
                "This link has expired or has already been used. \nTo reset your password, return to the login page and select \"Forgot Password\" to send a new email.",
                style: TextStyle(color: Colors.white70, fontSize: fontSize),
                textAlign: TextAlign.center,
              ),
            ],
          )
        ]
      ),
    );
  }

  Widget enterNewPassword(double width, double fontSize, bool normalMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Form(
        key: formKeyPasswordReset,
        child: Column(
          children: [
            ageOfGoldLogo(width, normalMode),
            Text(
              "Reset your password",
              style: TextStyle(color: Colors.white, fontSize: fontSize*2),
            ),
            const SizedBox(height: 10),
            Text(
              "Enter a new password below to change your password.",
              style: TextStyle(color: Colors.white70, fontSize: fontSize),
            ),
            const SizedBox(height: 20),
            Column(
              children: [
                TextFormField(
                  onTap: () {
                  },
                  obscureText: true,
                  validator: (val) {
                    return val == null || val.isEmpty
                        ? "fill in new password"
                        : null;
                  },
                  textInputAction: TextInputAction.next,
                  controller: passwordReset1Controller,
                  autofillHints: const [AutofillHints.newPassword],
                  textAlign: TextAlign.center,
                  style: simpleTextStyle(fontSize),
                  decoration: textFieldInputDecoration("password"),
                ),
              ],
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                resetPassword();
              },
              style: buttonStyle(false, Colors.blue),
              child: Container(
                alignment: Alignment.center,
                width: width,
                height: 50,
                child: Text(
                  'Reset password',
                  style: simpleTextStyle(fontSize),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget passwordHasBeenUpdated(double width, double fontSize, bool normalMode) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Form(
            key: formKeyPasswordReset,
            child: Column(
                children: [
                  ageOfGoldLogo(width, normalMode),
            Text(
              "Password Changed!",
              style: TextStyle(color: Colors.white, fontSize: fontSize*2),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              "Your password has been changed successfully!\nGo back to the game and log in with your new password",
              style: TextStyle(color: Colors.white70, fontSize: fontSize),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                backToLogin();
              },
              style: buttonStyle(false, Colors.blue),
              child: Container(
                alignment: Alignment.center,
                width: width,
                height: 50,
                child: Text(
                  'Back to game',
                  style: simpleTextStyle(fontSize),
                ),
              ),
            ),
          ]
        ),
      ),
    );
  }

  backToLogin() {
    _navigationService.navigateTo(routes.HomeRoute);
  }

  Widget newPasswordBox(double width, double fontSize, bool normalMode) {
    return passwordUpdated ? passwordHasBeenUpdated(width, fontSize, normalMode) : enterNewPassword(width, fontSize, normalMode);
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
        child: !invalid ? newPasswordBox(width, fontSize, normalMode)
            : invalidPasswordBox(width, fontSize, normalMode)
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

