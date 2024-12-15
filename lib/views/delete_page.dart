import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';

import '../services/auth_service_setting.dart';
import '../util/util.dart';


class DeletePage extends StatefulWidget {

  static const String route = '/delete';

  const DeletePage({super.key});

  @override
  State<DeletePage> createState() => _DeletePageState();
}

class _DeletePageState extends State<DeletePage> {

  final deleteKeyRegister = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();

  deleteAccount() {
    if (deleteKeyRegister.currentState!.validate()) {
      String email = emailController.text;
      AuthServiceSetting().deleteAccount(email).then((response) {
        if (response.getResult()) {
          showToast("email sent to $email to finalize account deletion");
        } else {
          showToast("Failed to delete account: ${response.getMessage()}");
        }
      }).onError((error, stackTrace) {
        showToast("Failed to delete account: ${error.toString()}");
      });
    }
  }

  Widget deleteBox(double width, double fontSize) {
    return Form(
      key: deleteKeyRegister,
      child: Column(
          children: [
            TextFormField(
              onTap: () {
              },
              validator: (val) {
                if (val != null && val.isNotEmpty) {
                  if (!emailValid(val)) {
                    return "Email not formatted correctly";
                  }
                }
                return val == null || val.isEmpty
                    ? "Please provide an Email"
                    : null;
              },
              scrollPadding: const EdgeInsets.only(bottom: 200),
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: "Roboto",
                  fontSize: fontSize,
                  color: Colors.white
              ),
              decoration: textFieldInputDecoration("Email"),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                deleteAccount();
              },
              style: buttonStyle(false, Colors.blue),
              child: Container(
                alignment: Alignment.center,
                width: width,
                height: 50,
                child: Text(
                  'Delete account',
                  style: simpleTextStyle(fontSize),
                ),
              ),
            )
          ]
      ),
    );
  }

  Widget deleteAccountBox(double width, double fontSize, bool normalMode) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
          children: [
            ageOfGoldLogo(width, normalMode),
            Text(
              "Delete account",
              style: TextStyle(color: Colors.white, fontSize: fontSize*2),
            ),
            Column(
              children: [
                Text(
                  "We are sorry to see you go!\nIf you are sure you want to delete account, fill in your email and click the \"delete account\" button below.\nYou will be send an email to verify your account deletion after which all details of your account is removed\nPlease note that this includes any accounts created with login via your Google, Reddit or Github account that have the same email address.",
                  style: TextStyle(color: Colors.white70, fontSize: fontSize),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            SizedBox(height: 40),
            deleteBox(width, fontSize),
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
          child: deleteAccountBox(width, fontSize, normalMode)
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

