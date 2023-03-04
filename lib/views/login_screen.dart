import 'package:age_of_gold/locator.dart';
import 'package:age_of_gold/services/models/login_request.dart';
import 'package:age_of_gold/util/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../age_of_gold.dart';
import '../constants/url_base.dart';
import '../services/auth_service_login.dart';
import '../services/models/register_request.dart';
import '../services/settings.dart';
import '../util/util.dart';
import 'package:age_of_gold/constants/route_paths.dart' as routes;


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

  final NavigationService _navigationService = locator<NavigationService>();

  bool visible = true;

  final formKeyLogin = GlobalKey<FormState>();
  final formKeyReset = GlobalKey<FormState>();
  final formKeyRegister = GlobalKey<FormState>();

  TextEditingController emailOrUsernameController = new TextEditingController();
  TextEditingController emailController = new TextEditingController();
  TextEditingController usernameController = new TextEditingController();
  TextEditingController password1Controller = new TextEditingController();
  TextEditingController password2Controller = new TextEditingController();
  TextEditingController forgotPasswordEmailController = new TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    password1Controller.dispose();
    password2Controller.dispose();
    super.dispose();
  }

  int signUpMode = 0;
  bool passwordResetSend = false;
  bool isLoading = false;

  String resetEmail = "";

  signInAgeOfGold() {
    if (formKeyLogin.currentState!.validate()) {
      // send login request
      String emailOrUserName = emailOrUsernameController.text;
      String password = password1Controller.text;
      AuthServiceLogin authService = AuthServiceLogin();
      authService.getLogin(LoginRequest(emailOrUserName, password)).then((loginResponse) {
        if (loginResponse.getResult()) {
          print("signing in");
          _navigationService.navigateTo(routes.GameRoute);
        } else if (!loginResponse.getResult()) {
          showToastMessage(loginResponse.getMessage());
        }
      }).onError((error, stackTrace) {
        showToastMessage(error.toString());
      });
    }
  }

  signUpAgeOfGold() {
    if (formKeyRegister.currentState!.validate()) {
      String email = emailController.text;
      String userName = usernameController.text;
      String password = password2Controller.text;
      AuthServiceLogin authService = AuthServiceLogin();
      authService.getRegister(RegisterRequest(email, userName, password)).then((loginResponse) {
        if (loginResponse.getResult()) {
          print("signing up");
          _navigationService.navigateTo(routes.GameRoute);
        } else if (!loginResponse.getResult()) {
          showToastMessage(loginResponse.getMessage());
        }
      }).onError((error, stackTrace) {
        showToastMessage(error.toString());
      });
    }
  }

  forgotPassword() {
    if (formKeyReset.currentState!.validate()) {
      print("this guy forgot his gosh darned password");
      resetEmail = forgotPasswordEmailController.text;
      AuthServiceLogin authService = AuthServiceLogin();
      authService.getPasswordReset(resetEmail).then((passwordResetResponse) {
        if (passwordResetResponse.getResult()) {
          setState(() {
            passwordResetSend = true;
          });
        } else if (!passwordResetResponse.getResult()) {
          showToastMessage(passwordResetResponse.getMessage());
          resetEmail = "";
        }
      }).onError((error, stackTrace) {
        showToastMessage(error.toString());
        resetEmail = "";
      });
    }
  }

  Widget loginAlternatives(double loginBoxSize, double fontSize) {
    return Column(
      children: [
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
              signUpMode == 0 ? Text("or login with") : Container(),
              signUpMode == 1 ? Text("or register with") : Container(),
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
      ],
    );
  }

  Widget resetPasswordEmailSend(double width, double fontSize) {
    return Column(
      children: [
        Text(
          "Check your email",
          style: TextStyle(color: Colors.white, fontSize: fontSize*2),
        ),
        SizedBox(height: 10),
        Text(
          "Please check the email address $resetEmail for instructions to reset your password. \nThis might take a few minutes",
          style: TextStyle(color: Colors.white70, fontSize: fontSize),
        ),
        const SizedBox(height: 50),
        ElevatedButton(
          onPressed: () {
            setState(() {
              passwordResetSend = false;
            });
          },
          style: buttonStyle(),
          child: Container(
            alignment: Alignment.center,
            width: width,
            height: 50,
            child: Text(
              'Resend email',
              style: simpleTextStyle(fontSize),
            ),
          ),
        )
      ],
    );
  }

  Widget resetPassword(double width, double fontSize) {
    return Form(
      key: formKeyReset,
      child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Reset your password",
                  style: TextStyle(color: Colors.white, fontSize: fontSize*2),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    "Enter your email address and we will send you instructions to reset your password.",
                    style: TextStyle(color: Colors.white70, fontSize: fontSize),
                ),
              ]
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextFormField(
                onTap: () {
                  if (!isLoading) {
                    print("tapped field forgot password");
                  }
                },
                validator: (val) {
                  return val == null || val.isEmpty
                      ? "Please provide an Email address"
                      : null;
                },
                controller: forgotPasswordEmailController,
                textAlign: TextAlign.center,
                style: simpleTextStyle(fontSize),
                decoration:
                textFieldInputDecoration("Email adddress"),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(),
                Row(
                  children: [
                    InkWell(
                        onTap: () {
                          if (!isLoading) {
                            setState(() {
                              signUpMode = 0;
                            });
                          }
                        },
                        child: Text(
                          "Back to login",
                          style: TextStyle(color: Colors.blue, fontSize: fontSize),
                        )
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (!isLoading) {
                  forgotPassword();
                }
              },
              style: buttonStyle(),
              child: Container(
                alignment: Alignment.center,
                width: width,
                height: 50,
                child: Text(
                  'Continue',
                  style: simpleTextStyle(fontSize),
                ),
              ),
            )
          ]
      ),
    );
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
                            signUpMode = 1;
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
            padding: const EdgeInsets.symmetric(horizontal: 20),
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
            padding: const EdgeInsets.symmetric(horizontal: 20),
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
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(),
              Row(
                children: [
                  InkWell(
                      onTap: () {
                        if (!isLoading) {
                          setState(() {
                            signUpMode = 2;
                          });
                        }
                      },
                      child: Text(
                        "Forgot password?",
                        style: TextStyle(color: Colors.blue, fontSize: fontSize),
                      )
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (!isLoading) {
                signInAgeOfGold();
              }
            },
            style: buttonStyle(),
            child: Container(
              alignment: Alignment.center,
              width: width,
              height: 50,
              child: Text(
                'Login',
                style: simpleTextStyle(fontSize),
              ),
            ),
          )
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
                            signUpMode = 0;
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
            padding: const EdgeInsets.symmetric(horizontal: 20),
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
            padding: const EdgeInsets.symmetric(horizontal: 20),
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
            padding: const EdgeInsets.symmetric(horizontal: 20),
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
          ElevatedButton(
            onPressed: () {
              if (!isLoading) {
                signUpAgeOfGold();
              }
            },
            style: buttonStyle(),
            child: Container(
              alignment: Alignment.center,
              width: width,
              height: 50,
              child: Text(
                'Create free account',
                style: simpleTextStyle(fontSize),
              ),
            ),
          )
        ]
      ),
    );
  }

  Widget previewBox(double width, double fontSize) {
    return Column(
      children: [
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
              Text("or"),
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
        ElevatedButton(
          onPressed: () {
            _navigationService.navigateTo(routes.GameRoute);
          },
          style: buttonStyle(),
          child: Container(
            alignment: Alignment.center,
            width: width,
            height: 50,
            child: Text(
              'Check out the world',
              style: simpleTextStyle(fontSize),
            ),
          ),
        )
      ],
    );
  }

  Widget loginScreen(double width, double loginBoxSize, double fontSize) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: Column(
            children: [
              Container(
                  alignment: Alignment.center,
                  child: Image.asset("assets/images/brocast_transparent.png")
              ),
              signUpMode == 0 ? login(width - (30 * 2), fontSize) : Container(),
              signUpMode == 1 ? register(width - (30 * 2), fontSize) : Container(),
              signUpMode == 2 && !passwordResetSend ? resetPassword(width - (30 * 2), fontSize) : Container(),
              signUpMode == 2 && passwordResetSend ? resetPasswordEmailSend(width - (30 * 2), fontSize) : Container(),
              signUpMode != 2 ? loginAlternatives(loginBoxSize, fontSize) : Container(),
              signUpMode != 2 ? previewBox(width, fontSize) : Container(),
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
    if (mounted) {
      final arguments = (ModalRoute
          .of(context)
          ?.settings
          .arguments ?? <String, dynamic>{}) as Map;
      if (arguments.containsKey('message')) {
        showToastMessage(arguments['message']);
      }
    }

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
