import 'package:age_of_gold/age_of_gold.dart';
import 'package:flutter/material.dart';
import 'package:age_of_gold/constants/route_paths.dart' as routes;
import 'package:flutter/scheduler.dart';

import '../locator.dart';
import '../services/auth_service_login.dart';
import '../util/navigation_service.dart';
import '../util/util.dart';


class EmailVerification extends StatefulWidget {

  final AgeOfGold game;

  const EmailVerification({
    super.key,
    required this.game
  });

  @override
  State<EmailVerification> createState() => _EmailVerificationState();
}

class _EmailVerificationState extends State<EmailVerification> {

  final NavigationService _navigationService = locator<NavigationService>();

  String? accessToken;
  String? refreshToken;

  bool emailValidated = false;
  bool alreadyVerified = false;

  @override
  void initState() {
    super.initState();
    accessToken = Uri.base.queryParameters["access_token"];
    refreshToken = Uri.base.queryParameters["refresh_token"];

    if (accessToken != null && refreshToken != null) {
      AuthServiceLogin authService = AuthServiceLogin();
      // Check if the token from the mail is still valid.
      authService.emailVerificationCheck(accessToken!, refreshToken!).then((emailVerificationResponse) {
        if (emailVerificationResponse.getResult()) {
          showToastMessage(emailVerificationResponse.getMessage());
          setState(() {
            emailValidated = true;
          });
        } else {
          showToastMessage("Verification failed, perhaps the link is expired?");
        }
      });
    } else {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _navigationService.navigateTo(routes.HomeRoute);
      });
    }
  }

  Widget emailNotValidated(double width, double fontSize) {
    return Column(
      children: [
        Text(
          "Error",
          style: TextStyle(color: Colors.white, fontSize: fontSize*2),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          "Your email address could not be verified",
          style: TextStyle(color: Colors.white70, fontSize: fontSize),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget successfullyVerified(double width, double fontSize) {
    return Column(
      children: [
        Text(
          "Validated!",
          style: TextStyle(color: Colors.white, fontSize: fontSize*2),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          "Your email address has successfully been verified",
          style: TextStyle(color: Colors.white70, fontSize: fontSize),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget verifiedAlready(double width, double fontSize) {
    return Column(
      children: [
        Text(
          "Already validated",
          style: TextStyle(color: Colors.white, fontSize: fontSize*2),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          "Your email address was already verified",
          style: TextStyle(color: Colors.white70, fontSize: fontSize),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget emailSuccessfullyValidated(double width, double fontSize) {
    return alreadyVerified ? verifiedAlready(width, fontSize) : successfullyVerified(width, fontSize);
  }

  Widget emailVerificationBox() {
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
            child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                    children: [
                      Container(
                          alignment: Alignment.center,
                          child: Image.asset(
                              "assets/images/brocast_transparent.png")
                      ),
                      !emailValidated ? emailNotValidated(width, fontSize)
                          : emailSuccessfullyValidated(width, fontSize)
                    ]
                )
            )
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          child: emailVerificationBox()
        ),
      ),
    );
  }
}

