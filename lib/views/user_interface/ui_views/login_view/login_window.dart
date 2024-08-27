import 'dart:async';
import 'dart:io';

import 'package:age_of_gold/age_of_gold.dart';
import 'package:age_of_gold/constants/url_base.dart';
import 'package:age_of_gold/services/auth_service_login.dart';
import 'package:age_of_gold/services/models/login_request.dart';
import 'package:age_of_gold/services/models/register_request.dart';
import 'package:age_of_gold/util/util.dart';
import 'package:age_of_gold/views/user_interface/ui_views/login_view/login_window_change_notifier.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginWindow extends StatefulWidget {

  final AgeOfGold game;

  const LoginWindow({
    required Key key,
    required this.game
  }) : super(key: key);

  @override
  LoginWindowState createState() => LoginWindowState();
}

class LoginWindowState extends State<LoginWindow> {

  bool showLoginWindow = false;

  late LoginWindowChangeNotifier loginWindowChangeNotifier;

  bool normalMode = true;
  bool isLoading = false;

  int signUpMode = 0;
  bool passwordResetSend = false;

  final formKeyLogin = GlobalKey<FormState>();
  final formKeyReset = GlobalKey<FormState>();
  final formKeyRegister = GlobalKey<FormState>();

  TextEditingController emailOrUsernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController password1Controller = TextEditingController();
  TextEditingController password2Controller = TextEditingController();
  TextEditingController forgotPasswordEmailController = TextEditingController();

  final FocusNode _focusEmail = FocusNode();
  final FocusNode _focusPassword = FocusNode();

  final ScrollController _controller = ScrollController();
  bool showTopScoreScreen = true;
  bool showBottomScoreScreen = true;

  late StreamSubscription<bool> keyboardSubscription;

  double loginBoxSize = 100;
  double loginWidth = 0;
  double loginHeight = 0;
  double fontSize = 16;

  @override
  void initState() {
    loginWindowChangeNotifier = LoginWindowChangeNotifier();
    loginWindowChangeNotifier.addListener(loginWindowChangeListener);
    var keyboardVisibilityController = KeyboardVisibilityController();
    keyboardSubscription = keyboardVisibilityController.onChange.listen((bool visible) {
      if (visible) {
        setState(() {
          loginHeight = (loginHeight / 3) * 2;
        });
      } else {
        setState(() {
          setWindowSize();
        });
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    keyboardSubscription.cancel();
    _controller.dispose();
    super.dispose();
  }

  goBack() {
    setState(() {
      LoginWindowChangeNotifier().setLoginWindowVisible(false);
      widget.game.windowFocus(false);
    });
  }

  signInAgeOfGold() {
    if (formKeyLogin.currentState!.validate() && !isLoading) {
      _controller.jumpTo(0);
      isLoading = true;
      // send login request
      String emailOrUserName = emailOrUsernameController.text;
      String password = password1Controller.text;
      AuthServiceLogin authServiceLogin = AuthServiceLogin();
      LoginRequest loginRequest = LoginRequest(emailOrUserName, password);
      authServiceLogin.getLogin(loginRequest).then((loginResponse) {
        if (loginResponse.getResult()) {
          isLoading = false;
          goBack();
          setState(() {});
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
      _controller.jumpTo(0);
      isLoading = true;
      String email = emailController.text;
      String userName = usernameController.text;
      String password = password2Controller.text;
      AuthServiceLogin authService = AuthServiceLogin();
      RegisterRequest registerRequest = RegisterRequest(email, userName, password);
      authService.getRegister(registerRequest).then((loginResponse) {
        if (loginResponse.getResult()) {
          isLoading = false;
          goBack();
          setState(() {});
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

  String resetEmail = "";
  forgotPassword() {
    if (formKeyReset.currentState!.validate() && !isLoading) {
      _controller.jumpTo(0);
      isLoading = true;
      resetEmail = forgotPasswordEmailController.text;
      AuthServiceLogin authService = AuthServiceLogin();
      authService.getPasswordReset(resetEmail).then((passwordResetResponse) {
        if (passwordResetResponse.getResult()) {
          setState(() {
            passwordResetSend = true;
          });
          isLoading = false;
        } else if (!passwordResetResponse.getResult()) {
          showToastMessage(passwordResetResponse.getMessage());
          resetEmail = "";
          isLoading = false;
        }
      }).onError((error, stackTrace) {
        showToastMessage(error.toString());
        resetEmail = "";
        isLoading = false;
      });
    }
  }

  setWindowSize() {

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    normalMode = true;
    loginBoxSize = 100;
    loginWidth = 800;
    loginHeight = (screenHeight / 10) * 6;
    // When the width is smaller than this we assume it's mobile.
    if (screenWidth <= 800 || screenHeight - 200 > screenWidth) {
      loginWidth = screenWidth - 50;
      normalMode = false;
      loginBoxSize = 50;
      loginHeight = (screenHeight / 10) * 7;
    }
  }

  loginWindowChangeListener() {
    if (mounted) {
      if (!showLoginWindow && loginWindowChangeNotifier.getLoginWindowVisible()) {
        setWindowSize();
        setState(() {
          showLoginWindow = true;
        });
      }
      if (showLoginWindow && !loginWindowChangeNotifier.getLoginWindowVisible()) {
        setState(() {
          showLoginWindow = false;
          signUpMode = 0;
          passwordResetSend = false;
        });
      }
    }
  }

  Widget loginAlternatives(double loginBoxSize) {
    return Column(
      children: [
        Row(
            children: [
              Expanded(
                child: Container(
                    margin: const EdgeInsets.only(left: 10.0, right: 20.0),
                    child: const Divider(
                      color: Colors.white,
                      height: 36,
                    )),
              ),
              signUpMode == 0 ? Text(
                "or login with",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: fontSize
                ),
              ) : Container(),
              signUpMode == 1 ? Text(
                "or register with",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: fontSize
                ),
              ) : Container(),
              Expanded(
                child: Container(
                    margin: const EdgeInsets.only(left: 20.0, right: 10.0),
                    child: const Divider(
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
                      _handleSignInGoogle();
                    },
                    child: SizedBox(
                      height: loginBoxSize,
                      width: loginBoxSize,
                      child: Image.asset(
                          "assets/images/google_button.png"
                      ),
                    ),
                  ),
                  Text(
                    "Google",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: fontSize
                    ),
                  )
                ]
            ),
            const SizedBox(width: 10),
            Column(
              children: [
                InkWell(
                  onTap: () {
                    final Uri url = Uri.parse(githubLogin);
                    _launchUrl(url);
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
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: fontSize
                  ),
                )
              ],
            ),
            const SizedBox(width: 10),
            Column(
                children: [
                  InkWell(
                    onTap: () {
                      final Uri url = Uri.parse(redditLogin);
                      _launchUrl(url);
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
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: fontSize
                    ),
                  )
                ]
            ),
          ],
        ),
      ],
    );
  }

  Widget resetPasswordEmailSend(double width) {
    return Column(
      children: [
        Text(
          "Check your email",
          style: TextStyle(color: Colors.white, fontSize: fontSize*2),
        ),
        const SizedBox(height: 10),
        Column(
            children: [
              Text(
                "Please check the email address $resetEmail for instructions to reset your password. \nThis might take a few minutes",
                style: TextStyle(color: Colors.white70, fontSize: fontSize),
              ),
            ]
        ),
      ],
    );
  }

  Widget resetPassword(double width) {
    return Form(
      key: formKeyReset,
      child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Reset your password",
                  style: TextStyle(color: Colors.white, fontSize: fontSize*1.5),
                ),
              ],
            ),
            const SizedBox(height: 10),
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

                },
                validator: (val) {
                  return val == null || val.isEmpty
                      ? "Please provide an Email address"
                      : null;
                },
                onFieldSubmitted: (value) {
                  if (!isLoading) {
                    forgotPassword();
                  }
                },
                scrollPadding: const EdgeInsets.only(bottom: 130),
                controller: forgotPasswordEmailController,
                autofillHints: const [AutofillHints.email],
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: "Roboto",
                    fontSize: fontSize,
                    color: Colors.white
                ),
                decoration:
                textFieldInputDecoration("Email adddress"),
              ),
            ),
            const SizedBox(height: 20),
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

  Widget register(double width) {
    return Form(
      key: formKeyRegister,
      child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Create Account",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: fontSize*1.5),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: fontSize*1.5
                  ),
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
                          style: TextStyle(
                              color: Colors.blue,
                              fontSize: fontSize*0.8
                          ),
                        )
                    ),
                    Text(
                        " instead?",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: fontSize*0.8
                        )
                    )
                  ],
                ),
              ],
            ),
            TextFormField(
              onTap: () {

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
            TextFormField(
              onTap: () {

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
              scrollPadding: const EdgeInsets.only(bottom: 150),
              keyboardType: TextInputType.name,
              autofillHints: const [AutofillHints.username],
              controller: usernameController,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: "Roboto",
                  fontSize: fontSize,
                  color: Colors.white
              ),
              decoration: textFieldInputDecoration("Username"),
            ),
            TextFormField(
              onTap: () {

              },
              obscureText: true,
              validator: (val) {
                return val == null || val.isEmpty
                    ? "Please provide a password"
                    : null;
              },
              onFieldSubmitted: (value) {
                if (!isLoading) {
                  signUpAgeOfGold();
                }
              },
              scrollPadding: const EdgeInsets.only(bottom: 100),
              controller: password2Controller,
              autofillHints: const [AutofillHints.newPassword],
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: "Roboto",
                  fontSize: fontSize,
                  color: Colors.white
              ),
              decoration: textFieldInputDecoration("Password"),
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

  Widget login(double width) {
    return Form(
      key: formKeyLogin,
      child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Login",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: fontSize*1.5),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: fontSize*1.5),
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
                          style: TextStyle(
                              color: Colors.blue,
                              fontSize: fontSize*0.8
                          ),
                        )
                    ),
                    Text(
                        " instead?",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: fontSize*0.8
                        )
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

                    },
                    validator: (val) {
                      return val == null || val.isEmpty
                          ? "Please provide an Email or Username"
                          : null;
                    },
                    focusNode: _focusEmail,
                    scrollPadding: const EdgeInsets.only(bottom: 160),
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [
                      AutofillHints.email,
                      AutofillHints.username
                    ],
                    textInputAction: TextInputAction.next,
                    controller: emailOrUsernameController,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: "Roboto",
                        fontSize: fontSize,
                        color: Colors.white
                    ),
                    decoration:
                    textFieldInputDecoration("Email or Username"),
                  ),
                  TextFormField(
                    onTap: () {

                    },
                    onFieldSubmitted: (value) {
                      if (!isLoading) {
                        signInAgeOfGold();
                      }
                    },
                    obscureText: true,
                    validator: (val) {
                      return val == null || val.isEmpty
                          ? "Please provide a password"
                          : null;
                    },
                    scrollPadding: const EdgeInsets.only(bottom: 110),
                    focusNode: _focusPassword,
                    autofillHints: const [AutofillHints.password],
                    onEditingComplete: () => TextInput.finishAutofillContext(),
                    controller: password1Controller,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: "Roboto",
                        fontSize: fontSize,
                        color: Colors.white
                    ),
                    decoration:
                    textFieldInputDecoration("Password"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
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
                          style: TextStyle(color: Colors.blue, fontSize: fontSize*0.8),
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
            ),
          ]
      ),
    );
  }

  Widget loginHeader(double headerHeight) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(),
          IconButton(
              icon: const Icon(Icons.close),
              color: Colors.orangeAccent.shade200,
              onPressed: () {
                setState(() {
                  goBack();
                });
              }
          ),
        ]
    );
  }

  Widget ageOfGoldName() {
    return Text(
      "Age of Gold",
      style: TextStyle(
          color: Colors.white,
          fontSize: fontSize*2
      ),
    );
  }

  Widget loginScreen(double loginBoxSize) {
    return SingleChildScrollView(
        controller: _controller,
        child: Container(
          color: Colors.amber,
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              loginHeader(40),
              const SizedBox(height: 10),
              ageOfGoldName(),
              const SizedBox(height: 10),
              ageOfGoldLogo(loginWidth, normalMode),
              signUpMode == 0 ? login(loginWidth - (30 * 2)) : Container(),
              signUpMode == 1 ? register(loginWidth - (30 * 2)) : Container(),
              signUpMode == 2 && !passwordResetSend ? resetPassword(loginWidth - (30 * 2)) : Container(),
              signUpMode == 2 && passwordResetSend ? resetPasswordEmailSend(loginWidth - (30 * 2)) : Container(),
              signUpMode != 2 ? loginAlternatives(loginBoxSize) : Container(),
              const SizedBox(height: 40),
            ],
          ),
        ),
    );
  }

  Widget loginOrRegisterBox() {

    return Align(
      alignment: FractionalOffset.center,
      child: showLoginWindow ? SizedBox(
          width: loginWidth,
          height: loginHeight,
          child: loginScreen(loginBoxSize)
      ) : Container(),
    );
  }

  Widget loginOrRegisterScreen(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.black.withOpacity(0.7),
        child: Center(
            child: TapRegion(
                onTapOutside: (tap) {
                  goBack();
                },
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(),
                      loginOrRegisterBox(),
                    ]
                )
            )
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: FractionalOffset.center,
        child: showLoginWindow ? loginOrRegisterScreen(context) : Container()
    );
  }

  Future<void> _launchUrl(Uri url) async {
    if (kIsWeb) {
      if (!await launchUrl(
          url,
          webOnlyWindowName: '_self'
      )) {
        throw 'Could not launch $url';
      }
    } else {
      if (!await launchUrl(
          url,
          mode: LaunchMode.externalApplication
      )) {
        throw 'Could not launch $url';
      }
    }
  }

  Future<void> _handleSignInGoogle() async {

    isLoading = true;
    const List<String> scopes = <String>[
      'email',
    ];

    GoogleSignIn googleSignIn;
    if (kIsWeb) {
      // Web
      googleSignIn = GoogleSignIn(
        clientId: clientIdLoginWeb,
        scopes: scopes,
      );
    } else if (Platform.isIOS || Platform.isMacOS) {
      // IOS
      googleSignIn = GoogleSignIn(
        clientId: clientIdLoginIOS,
        scopes: scopes,
      );
    } else {
      // Android
      googleSignIn = GoogleSignIn(
        scopes: scopes,
      );
    }

    String? googleAccessToken;
    try {
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount!.authentication;
      googleAccessToken = googleSignInAuthentication.accessToken;

      if (googleAccessToken == null) {
        isLoading = false;
        showToastMessage("Google login failed");
        return;
      }
    } catch (error) {
      isLoading = false;
      return;
    }

    AuthServiceLogin().getLoginGoogle(googleAccessToken).then((
        loginResponse) {
      if (loginResponse.getResult()) {
        goBack();
        isLoading = false;
        setState(() {});
      } else if (!loginResponse.getResult()) {
        showToastMessage(loginResponse.getMessage());
      }
    }).onError((error, stackTrace) {
      showToastMessage(error.toString());
    });
    isLoading = false;
  }
}
