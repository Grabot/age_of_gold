import 'package:age_of_gold/locator.dart';
import 'package:age_of_gold/services/auth_service_login.dart';
import 'package:age_of_gold/util/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../age_of_gold.dart';
import 'package:age_of_gold/constants/route_paths.dart' as routes;
import 'package:flutter/scheduler.dart';

import '../util/util.dart';


class PasswordReset extends StatefulWidget {

  final AgeOfGold game;

  const PasswordReset({
    Key? key,
    required this.game
  }) : super(key: key);

  @override
  State<PasswordReset> createState() => _PasswordResetState();
}

class _PasswordResetState extends State<PasswordReset> {

  final NavigationService _navigationService = locator<NavigationService>();

  TextEditingController passwordReset1Controller = TextEditingController();

  final formKeyPasswordReset = GlobalKey<FormState>();

  String? accessToken;
  String? refreshToken;

  bool invalid = false;
  bool passwordUpdated = false;

  @override
  void initState() {
    super.initState();
    String baseUrl = Uri.base.toString();
    String path = Uri.base.path;
    accessToken = Uri.base.queryParameters["access_token"];
    refreshToken = Uri.base.queryParameters["refresh_token"];

    print("base: $baseUrl");
    print("path: $path");
    print("access token: $accessToken");
    print("refresh token: $refreshToken");

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
          print("password updated $updatePasswordResponse");
          print("password updated ${updatePasswordResponse.getResult()}");
          print("password updated ${updatePasswordResponse.getMessage()}");
          setState(() {
            passwordUpdated = updatePasswordResponse.getResult();
          });
        });
      } else {
        showToastMessage("an error occured");
      }
    }
  }

  Widget invalidPasswordBox(double width, double fontSize) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          Container(
              alignment: Alignment.center,
              child: Image.asset(
                  "assets/images/brocast_transparent.png")
          ),
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

  Widget enterNewPassword(double width, double fontSize) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: Form(
        key: formKeyPasswordReset,
        child: Column(
          children: [
            Container(
                alignment: Alignment.center,
                child: Image.asset(
                    "assets/images/brocast_transparent.png")
            ),
            Text(
              "Reset your password",
              style: TextStyle(color: Colors.white, fontSize: fontSize*2),
            ),
            SizedBox(height: 10),
            Text(
              "Enter a new password below to change your password.",
              style: TextStyle(color: Colors.white70, fontSize: fontSize),
            ),
            SizedBox(height: 20),
            Column(
              children: [
                TextFormField(
                  onTap: () {
                    print("tapped");
                  },
                  obscureText: true,
                  validator: (val) {
                    return val == null || val.isEmpty
                        ? "fill in new password"
                        : null;
                  },
                  textInputAction: TextInputAction.next,
                  controller: passwordReset1Controller,
                  autofillHints: [AutofillHints.newPassword],
                  textAlign: TextAlign.center,
                  style: simpleTextStyle(fontSize),
                  decoration: textFieldInputDecoration("password"),
                ),
              ],
            ),
            SizedBox(height: 40),
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

  Widget passwordHasBeenUpdated(double width, double fontSize) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: Form(
            key: formKeyPasswordReset,
            child: Column(
                children: [
                Container(
                alignment: Alignment.center,
                child: Image.asset(
                    "assets/images/brocast_transparent.png")
            ),
            Text(
              "Password Changed!",
              style: TextStyle(color: Colors.white, fontSize: fontSize*2),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              "Your password has been changed successfully!\nGo back to the login screen to log in with your new password",
              style: TextStyle(color: Colors.white70, fontSize: fontSize),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
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
                  'Back to login',
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

  Widget newPasswordBox(double width, double fontSize) {
    return passwordUpdated ? passwordHasBeenUpdated(width, fontSize) : enterNewPassword(width, fontSize);
  }

  Widget passwordBox() {
    double fontSize = 16;
    double width = 800;
    double height = (MediaQuery.of(context).size.height / 10) * 9;
    // When the width is smaller than this we assume it's mobile.
    if (MediaQuery.of(context).size.width <= 800) {
      width = MediaQuery.of(context).size.width - 50;
      height = MediaQuery.of(context).size.height - 250;
      fontSize = 10;
    }

    return Container(
      width: width,
      height: height,
      color: Colors.orange,
      child: SingleChildScrollView(
        child: !invalid ? newPasswordBox(width, fontSize)
            : invalidPasswordBox(width, fontSize)
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

