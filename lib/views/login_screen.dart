import 'package:age_of_gold/locator.dart';
import 'package:age_of_gold/services/models/login_request.dart';
import 'package:age_of_gold/util/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../age_of_gold.dart';
import '../constants/url_base.dart';
import '../services/auth_service_login.dart';
import '../services/models/register_request.dart';
import '../services/settings.dart';
import '../util/util.dart';
import 'package:age_of_gold/constants/route_paths.dart' as routes;

import 'user_interface/ui_function/user_interface_util/loading_box_change_notifier.dart';


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

  FocusNode _focusEmail = FocusNode();
  FocusNode _focusPassword = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.game.isMounted) {
      print("game is mounted!");
      widget.game.endGame();
    }
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _focusPassword.requestFocus();
      Future.delayed(const Duration(milliseconds: 150), () {
        FocusScope.of(context).unfocus();
      });
    });
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
    if (formKeyLogin.currentState!.validate() && !isLoading) {
      isLoading = true;
      // send login request
      String emailOrUserName = emailOrUsernameController.text;
      String password = password1Controller.text;
      AuthServiceLogin authService = AuthServiceLogin();
      authService.getLogin(LoginRequest(emailOrUserName, password)).then((loginResponse) {
        if (loginResponse.getResult()) {
          print("signing in");
          goToGame(_navigationService, widget.game);
        } else if (!loginResponse.getResult()) {
          showToastMessage(loginResponse.getMessage());
          isLoading = false;
        }
      }).onError((error, stackTrace) {
        showToastMessage(error.toString());
        isLoading = false;
      });
    }
  }

  signUpAgeOfGold() {
    if (formKeyRegister.currentState!.validate() && !isLoading) {
      isLoading = true;
      String email = emailController.text;
      String userName = usernameController.text;
      String password = password2Controller.text;
      AuthServiceLogin authService = AuthServiceLogin();
      authService.getRegister(RegisterRequest(email, userName, password)).then((loginResponse) {
        if (loginResponse.getResult()) {
          print("signing up");
          goToGame(_navigationService, widget.game);
        } else if (!loginResponse.getResult()) {
          showToastMessage(loginResponse.getMessage());
          isLoading = false;
        }
      }).onError((error, stackTrace) {
        showToastMessage(error.toString());
        isLoading = false;
      });
    }
  }

  forgotPassword() {
    if (formKeyReset.currentState!.validate() && !isLoading) {
      isLoading = true;
      print("this guy forgot his gosh darned password");
      resetEmail = forgotPasswordEmailController.text;
      AuthServiceLogin authService = AuthServiceLogin();
      authService.getPasswordReset(resetEmail).then((passwordResetResponse) {
        if (passwordResetResponse.getResult()) {
          setState(() {
            passwordResetSend = true;
          });
          isLoading = true;
        } else if (!passwordResetResponse.getResult()) {
          showToastMessage(passwordResetResponse.getMessage());
          resetEmail = "";
          isLoading = true;
        }
      }).onError((error, stackTrace) {
        showToastMessage(error.toString());
        resetEmail = "";
        isLoading = true;
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
        Column(
          children: [
            Text(
              "Please check the email address $resetEmail for instructions to reset your password. \nThis might take a few minutes",
              style: TextStyle(color: Colors.white70, fontSize: fontSize),
            ),
          ]
        ),
        const SizedBox(height: 50),
        ElevatedButton(
          onPressed: () {
            setState(() {
              passwordResetSend = false;
            });
          },
          style: buttonStyle(false, Colors.blue),
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
            Column(
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
                autofillHints: [AutofillHints.email],
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
              style: buttonStyle(false, Colors.blue),
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
          AutofillGroup(
            child: Column(
              children: [
                TextFormField(
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
                  focusNode: _focusEmail,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: [
                    AutofillHints.email,
                    AutofillHints.username
                  ],
                  textInputAction: TextInputAction.next,
                  controller: emailOrUsernameController,
                  textAlign: TextAlign.center,
                  style: simpleTextStyle(fontSize),
                  decoration:
                  textFieldInputDecoration("Email or Username"),
                ),
                TextFormField(
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
                  focusNode: _focusPassword,
                  autofillHints: [AutofillHints.password],
                  onEditingComplete: () => TextInput.finishAutofillContext(),
                  controller: password1Controller,
                  textAlign: TextAlign.center,
                  style: simpleTextStyle(fontSize),
                  decoration:
                  textFieldInputDecoration("Password"),
                ),
              ],
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
            style: buttonStyle(false, Colors.blue),
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
          TextFormField(
            onTap: () {
              if (!isLoading) {
                print("tapped field 1.5");
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
            keyboardType: TextInputType.emailAddress,
            autofillHints: [AutofillHints.email],
            textAlign: TextAlign.center,
            style: simpleTextStyle(fontSize),
            decoration:
            textFieldInputDecoration("Email"),
          ),
          TextFormField(
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
            keyboardType: TextInputType.name,
            autofillHints: [AutofillHints.username],
            controller: usernameController,
            textAlign: TextAlign.center,
            style: simpleTextStyle(fontSize),
            decoration:
            textFieldInputDecoration("Username"),
          ),
          TextFormField(
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
            autofillHints: [AutofillHints.newPassword],
            textAlign: TextAlign.center,
            style: simpleTextStyle(fontSize),
            decoration:
            textFieldInputDecoration("Password"),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              if (!isLoading) {
                signUpAgeOfGold();
              }
            },
            style: buttonStyle(false, Colors.blue),
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
            goToGame(_navigationService, widget.game);
          },
          style: buttonStyle(false, Colors.blue),
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
    double height = (MediaQuery.of(context).size.height / 10) * 9;
    // When the width is smaller than this we assume it's mobile.
    if (MediaQuery.of(context).size.width <= 800) {
      width = MediaQuery.of(context).size.width - 50;
      height = MediaQuery.of(context).size.height - 150;
      loginBoxSize = 50;
      fontSize = MediaQuery.of(context).size.width / 40;
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
