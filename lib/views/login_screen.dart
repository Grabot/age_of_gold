import 'package:age_of_gold/services/auth.dart';
import 'package:age_of_gold/services/models/login_request.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../age_of_gold.dart';
import '../constants/url_base.dart';
import '../services/auth_service.dart';
import '../services/settings.dart';
import '../util/util.dart';


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

  final formKeyLogin = GlobalKey<FormState>();
  final formKeyRegister = GlobalKey<FormState>();

  TextEditingController emailOrUsernameController = new TextEditingController();
  TextEditingController emailController = new TextEditingController();
  TextEditingController usernameController = new TextEditingController();
  TextEditingController password1Controller = new TextEditingController();
  TextEditingController password2Controller = new TextEditingController();

  // TODO: Keep using this for android and ios?
  // final SecureStorage _secureStorage = SecureStorage();

  @override
  void initState() {
    print("login screen");
    super.initState();
    // TODO: Change accesstoken to the cookie thing?
    // _secureStorage.getAccessToken().then((accessToken) {
    //   if (accessToken != null && accessToken != "") {
    //     // Something is stored, check if the user can just log in automatically
    //     tokenLogin(accessToken).then((value) {
    //       if (value == "success") {
    //         print("it was a success");
    //         // If the access token was still good we go straight to the world.
    //         Navigator.pushNamed(context, "/world");
    //       }
    //     });
    //   }
    // });
  }

  @override
  void dispose() {
    emailController.dispose();
    password1Controller.dispose();
    password2Controller.dispose();
    super.dispose();
  }

  bool signUpMode = false;
  bool isLoading = false;

  TextStyle simpleTextStyle(double fontSize) {
    return TextStyle(color: Colors.white, fontSize: fontSize);
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
    if (formKeyLogin.currentState!.validate()) {
      // send login request
      String emailOrUserName = emailOrUsernameController.text;
      String password = password1Controller.text;
      AuthService authService = AuthService();
      authService.getLogin(LoginRequest(emailOrUserName, password)).then((loginResponse) {
        if (loginResponse.getResult()) {
          Navigator.pushNamed(context, "/world");
        }
      });
    }
  }

  signUpAgeOfGold() {
    if (formKeyRegister.currentState!.validate()) {
      String email = emailController.text;
      String userName = usernameController.text;
      String password = password2Controller.text;
      signUp(userName, email, password).then((value) {
        if (value == "success") {
          Navigator.pushNamed(context, "/world");
        }
      });
    }
  }

  Widget login(double width, double fontSize) {
    return Form(
      key: formKeyLogin,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Login",
                style: TextStyle(color: Colors.white, fontSize: fontSize*2),
              ),
              Row(
                children: [
                  InkWell(
                      onTap: () {
                        if (!isLoading) {
                          setState(() {
                            signUpMode = !signUpMode;
                          });
                        }
                      },
                      child: Text(
                        "Create new Account",
                        style: TextStyle(color: Colors.blue, fontSize: fontSize),
                      )
                  ),
                  Text(
                      " instead?",
                      style: TextStyle(fontSize: fontSize)
                  )
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: TextFormField(
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
              style: simpleTextStyle(fontSize),
              decoration:
              textFieldInputDecoration("Email or Username"),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: TextFormField(
              onTap: () {
                if (!isLoading) {
                  print("tapped field 3 2");
                }
              },
              obscureText: true,
              validator: (val) {
                return val == null || val.isEmpty
                    ? "Please provide a password"
                    : null;
              },
              controller: password1Controller,
              textAlign: TextAlign.center,
              style: simpleTextStyle(fontSize),
              decoration:
              textFieldInputDecoration("Password"),
            ),
          ),
          const SizedBox(height: 30),
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
              child: Text("Login", style: simpleTextStyle(fontSize)),
            ),
          ),
        ]
      ),
    );
  }

  Widget register(double width, double fontSize) {
    return Form(
      key: formKeyRegister,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Create Account",
                style: TextStyle(color: Colors.white, fontSize: fontSize*2),
              ),
              Row(
                children: [
                  InkWell(
                      onTap: () {
                        if (!isLoading) {
                          setState(() {
                            signUpMode = !signUpMode;
                          });
                        }
                      },
                      child: Text(
                        "Log In",
                        style: TextStyle(color: Colors.blue, fontSize: fontSize),
                      )
                  ),
                  Text(
                      " instead?",
                      style: TextStyle(fontSize: fontSize)
                  )
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: TextFormField(
              onTap: () {
                if (!isLoading) {
                  print("tapped field 1.5");
                  Settings settings = Settings();
                  print("access token: ${settings.getAccessToken()}");
                  print("refresh token: ${settings.getAccessToken()}");
                }
              },
              validator: (val) {
                if (val != null) {
                  if (!emailValid(val)) {
                    return "Email not formatted correctly";
                  }
                }
                return val == null || val.isEmpty
                    ? "Please provide an Email"
                    : null;
              },
              controller: emailController,
              textAlign: TextAlign.center,
              style: simpleTextStyle(fontSize),
              decoration:
              textFieldInputDecoration("Email"),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: TextFormField(
              onTap: () {
                if (!isLoading) {
                  print("tapped field 1.2");
                }
              },
              validator: (val) {
                if (val != null) {
                  if (emailValid(val)) {
                    return "username cannot be formatted as an email";
                  }
                }
                return val == null || val.isEmpty
                    ? "Please provide a username"
                    : null;
              },
              controller: usernameController,
              textAlign: TextAlign.center,
              style: simpleTextStyle(fontSize),
              decoration:
              textFieldInputDecoration("Username"),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: TextFormField(
              onTap: () {
                if (!isLoading) {
                  print("tapped field 3 1");
                }
              },
              obscureText: true,
              validator: (val) {
                return val == null || val.isEmpty
                    ? "Please provide a password"
                    : null;
              },
              controller: password2Controller,
              textAlign: TextAlign.center,
              style: simpleTextStyle(fontSize),
              decoration:
              textFieldInputDecoration("Password"),
            ),
          ),
          const SizedBox(height: 30),
          GestureDetector(
            onTap: () {
              if (!isLoading) {
                signUpAgeOfGold();
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
              child: Text("Create free account", style: simpleTextStyle(fontSize)),
            ),
          ),
        ]
      ),
    );
  }

  Widget loginScreen(double width, double loginBoxSize, double fontSize) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
            children: [
              Container(
                  alignment: Alignment.center,
                  child: Image.asset(
                      "assets/images/brocast_transparent.png")
              ),
              signUpMode ? register(width, fontSize) : login(width, fontSize),
              Row(
                children: [
                  Expanded(
                    child: new Container(
                        margin: const EdgeInsets.only(left: 10.0, right: 20.0),
                        child: Divider(
                          color: Colors.white,
                          height: 36,
                        )),
                  ),
                  signUpMode ? Text("or register with") : Text("or login with"),
                  Expanded(
                    child: new Container(
                        margin: const EdgeInsets.only(left: 20.0, right: 10.0),
                        child: Divider(
                          color: Colors.white,
                          height: 36,
                        )),
                  ),
                ]
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                      children: [
                        InkWell(
                          onTap: () {
                            final Uri _url = Uri.parse(googleLogin);
                            _launchUrl(_url);
                            print("tapped Google");
                          },
                          child: SizedBox(
                            height: loginBoxSize,
                            width: loginBoxSize,
                            child: Image.asset(
                                "assets/images/gogle_button.png"
                            ),
                          ),
                        ),
                        Text(
                          "Google",
                          style: TextStyle(fontSize: fontSize),
                        )
                      ]
                  ),
                  SizedBox(width: 10),
                  Column(
                    children: [
                      InkWell(
                        onTap: () {
                          final Uri _url = Uri.parse(githubLogin);
                          _launchUrl(_url);
                        },
                        child: SizedBox(
                          height: loginBoxSize,
                          width: loginBoxSize,
                          child: Image.asset(
                              "assets/images/github_button.png"
                          ),
                        ),
                      ),
                      Text(
                        "Github",
                        style: TextStyle(fontSize: fontSize),
                      )
                    ],
                  ),
                  SizedBox(width: 10),
                  Column(
                    children: [
                      InkWell(
                        onTap: () {
                          print("tapped reddit");
                          final Uri _url = Uri.parse(redditLogin);
                          _launchUrl(_url);
                        },
                        child: SizedBox(
                          height: loginBoxSize,
                          width: loginBoxSize,
                          child: Image.asset(
                              "assets/images/reddit_button.png"
                          ),
                        ),
                      ),
                      Text(
                        "Reddit",
                        style: TextStyle(fontSize: fontSize),
                      )
                    ]
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
      ),
    );
  }

  Widget tileBoxWidget(BuildContext context) {
    double fontSize = 16;
    double loginBoxSize = 100;
    double width = 800;
    double height = (MediaQuery.of(context).size.height / 10) * 8;
    // When the width is smaller than this we assume it's mobile.
    if (MediaQuery.of(context).size.width <= 800) {
      width = MediaQuery.of(context).size.width - 50;
      height = MediaQuery.of(context).size.height - 250;
      loginBoxSize = 50;
      fontSize = 10;
    }
    return Align(
      alignment: FractionalOffset.center,
      child: visible ? Container(
        width: width,
        height: height,
        color: Colors.orange,
        child: loginScreen(width, loginBoxSize, fontSize)
      ) : Container(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return tileBoxWidget(context);
  }

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(
      url,
      webOnlyWindowName: '_self'
    )) {
      throw 'Could not launch $url';
    }
  }
}
