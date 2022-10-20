import 'package:age_of_gold/user_interface/selected_tile_info.dart';
import 'package:flutter/material.dart';
import '../age_of_gold.dart';
import '../util/socket_services.dart';


class LoginScreen extends StatefulWidget {

  final AgeOfGold game;

  const LoginScreen({
    required Key key,
    required this.game
  }) : super(key: key);

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {

  bool visible = true;

  // TODO: Add focusnodes on other textfields?
  final FocusNode _focusLoginEmail = FocusNode();
  final FocusNode _focusLoginPass = FocusNode();

  final formKey = GlobalKey<FormState>();
  TextEditingController emailOrUsernameController = new TextEditingController();
  TextEditingController emailController = new TextEditingController();
  TextEditingController usernameController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();

  @override
  void initState() {
    _focusLoginEmail.addListener(_onFocusChangeEmail);
    _focusLoginPass.addListener(_onFocusChangePass);
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _onFocusChangeEmail() {
    widget.game.loginFocus(_focusLoginEmail.hasFocus);
  }
  void _onFocusChangePass() {
    widget.game.loginFocus(_focusLoginPass.hasFocus);
  }

  bool signUpMode = false;
  bool isLoading = false;

  TextStyle simpleTextStyle() {
    return const TextStyle(color: Colors.white, fontSize: 16);
  }

  InputDecoration textFieldInputDecoration(String hintText) {
    return InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Colors.white54,
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white54),
        ));
  }


  signInAgeOfGold() {
    if (formKey.currentState!.validate()) {

    }
  }

  // TODO: Segment it a bit more to make it more readable
  Widget loginScreen() {
    return SingleChildScrollView(
      reverse: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Form(
            key: formKey,
            child: Column(
              children: [
                Container(
                    alignment: Alignment.center,
                    child: Image.asset(
                        "assets/images/brocast_transparent.png")
                ),
                !signUpMode ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: TextFormField(
                    focusNode: _focusLoginEmail,
                    onTap: () {
                      if (!isLoading) {
                        print("tapped field 1");
                      }
                    },
                    validator: (val) {
                      return val == null || val.isEmpty
                          ? "Please provide an Email or Username"
                          : null;
                    },
                    controller: emailOrUsernameController,
                    textAlign: TextAlign.center,
                    style: simpleTextStyle(),
                    decoration:
                    textFieldInputDecoration("Email or Username"),
                  ),
                ) : Container(),
                signUpMode ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: TextFormField(
                    focusNode: _focusLoginEmail,
                    onTap: () {
                      if (!isLoading) {
                        print("tapped field 1.5");
                      }
                    },
                    validator: (val) {
                      return val == null || val.isEmpty
                          ? "Please provide an Email"
                          : null;
                    },
                    controller: emailController,
                    textAlign: TextAlign.center,
                    style: simpleTextStyle(),
                    decoration:
                    textFieldInputDecoration("Email"),
                  ),
                ) : Container(),
                signUpMode ? const SizedBox(height: 30) : const SizedBox(height: 0),
                signUpMode ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: TextFormField(
                    focusNode: _focusLoginEmail,
                    onTap: () {
                      if (!isLoading) {
                        print("tapped field 1.8");
                      }
                    },
                    validator: (val) {
                      return val == null || val.isEmpty
                          ? "Please provide an username"
                          : null;
                    },
                    controller: usernameController,
                    textAlign: TextAlign.center,
                    style: simpleTextStyle(),
                    decoration:
                    textFieldInputDecoration("Username"),
                  ),
                ) : Container(),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: TextFormField(
                    onTap: () {
                      if (!isLoading) {
                        print("tapped field 3");
                      }
                    },
                    focusNode: _focusLoginPass,
                    obscureText: true,
                    validator: (val) {
                      return val == null || val.isEmpty
                          ? "Please provide a password"
                          : null;
                    },
                    controller: passwordController,
                    textAlign: TextAlign.center,
                    style: simpleTextStyle(),
                    decoration:
                    textFieldInputDecoration("Password"),
                  ),
                ),
                const SizedBox(height: 60),
                GestureDetector(
                  onTap: () {
                    if (!isLoading) {
                      signInAgeOfGold();
                    }
                  },
                  child: Container(
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [
                          Color(0xBf007EF4),
                          Color(0xff2A75BC)
                        ]),
                        borderRadius: BorderRadius.circular(30)),
                    child: signUpMode
                        ? Text("Sign up",
                        style: simpleTextStyle())
                        : Text("Sign in",
                        style: simpleTextStyle()),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      child: signUpMode
                          ? const Text(
                        "Already have an account?  ",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16),
                      )
                          : const Text(
                        "Don't have an account?  ",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (!isLoading) {
                            setState(() {
                              signUpMode = !signUpMode;
                            });
                          }
                        },
                        child: signUpMode
                            ? const Text(
                          "Login now!",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              decoration:
                              TextDecoration.underline),
                        )
                            : const Text(
                          "Register now!",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              decoration:
                              TextDecoration.underline),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 100),
              ],
            )),
      ),
    );
  }

  Widget tileBoxWidget(BuildContext context) {
    double width = MediaQuery.of(context).size.width / 2;
    double height = (MediaQuery.of(context).size.height / 10) * 8;
    // When the width is smaller than this we assume it's mobile.
    if (MediaQuery.of(context).size.width <= 800) {
      width = MediaQuery.of(context).size.width - 50;
      height = MediaQuery.of(context).size.height - 250;
    }
    return Align(
      alignment: FractionalOffset.center,
      child: visible ? Container(
        width: width,
        height: height,
        color: Colors.orange,
        child: loginScreen()
      ) : Container(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return tileBoxWidget(context);
  }
}
