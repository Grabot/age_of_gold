import 'dart:async';
import 'dart:convert';
import 'package:age_of_gold/services/settings.dart';
import 'package:age_of_gold/util/util.dart';
import 'package:http/http.dart' as http;

import '../constants/url_base.dart';


Future signUp(String userName, String email, String password) async {
  String urlRegister = '${baseUrlV1_1}register';
  Uri uriRegister = Uri.parse(urlRegister);

  http.Response responsePost = await http
      .post(
    uriRegister,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'user_name': userName,
      'email': email,
      'password': password
    }),
  )
      .timeout(
    Duration(seconds: 8),
    onTimeout: () {
      return new http.Response("", 404);
    },
  );

  print("resposne!!! ${responsePost.body}");

  if (responsePost.statusCode == 404 || responsePost.body.isEmpty) {
    return "Could not connect to the server";
  } else {
    Map<String, dynamic> registerResponse = jsonDecode(responsePost.body);
    if (registerResponse.containsKey("result") &&
        registerResponse.containsKey("message")) {
      bool result = registerResponse["result"];
      String message = registerResponse["message"];
      print("message: $message");
      if (result) {
        print("it was good");
        String accessToken = registerResponse["access_token"];
        String refreshToken = registerResponse["refresh_token"];
        Map<String, dynamic> user = registerResponse["user"];

        Settings settings = Settings();
        settings.setAccessToken(accessToken);
        settings.setRefreshToken(refreshToken);
        settings.setUserName(user["username"]);

        return "success";
      } else {
        return message;
      }
    }
  }
  return "an unknown error has occurred";
}

Future<String> signIn(
    String emailOrUserName, String password) async {
  String urlLogin = '${baseUrlV1_1}login';
  print("going to login with url $urlLogin");
  Uri uriLogin = Uri.parse(urlLogin);

  String postBody = "";
  if (emailValid(emailOrUserName)) {
    // email
    postBody = jsonEncode(<String, String>{
      'email': emailOrUserName,
      'password': password
    });
    print("postbody with email $postBody");
  } else {
    // user name
    postBody = jsonEncode(<String, String>{
      'user_name': emailOrUserName,
      'password': password
    });
    print("postbody with user_name $postBody");
  }

  http.Response responsePost = await http
      .post(
    uriLogin,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8'
    },
    body: postBody,
  )
      .timeout(
    const Duration(seconds: 8),
    onTimeout: () {
      return new http.Response("", 404);
    },
  );

  print("resonse: ${responsePost.body}");

  if (responsePost.statusCode == 404 || responsePost.body.isEmpty) {
    return "Could not connect to the server";
  } else {
    Map<String, dynamic> signInResponse;
    try {
      signInResponse = jsonDecode(responsePost.body);
    } on Exception catch (_) {
      return "an unknown error has occurred";
    }
    if (signInResponse.containsKey("result") &&
        signInResponse.containsKey("message")) {
      bool result = signInResponse["result"];
      String message = signInResponse["message"];
      if (result) {
        String accessToken = signInResponse["access_token"];
        String refreshToken = signInResponse["refresh_token"];
        Map<String, dynamic> user = signInResponse["user"];

        Settings settings = Settings();
        settings.setAccessToken(accessToken);
        settings.setRefreshToken(refreshToken);
        settings.setUserName(user["username"]);

        print("got result: $accessToken  $refreshToken");
        print('user: $user');
        return "success";
      } else {
        return message;
      }
    }
  }
  return "an unknown error has occurred";
}

Future<String> refreshAccessToken(
    String accessToken, String refreshToken, bool details) async {
  String urlRefresh = '${baseUrlV1_1}refresh';
  print("going to refresh access token with url $urlRefresh");
  Uri uriRefresh = Uri.parse(urlRefresh);

  http.Response responsePost = await http
      .post(
    uriRefresh,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8'
    },
    body: jsonEncode(<String, String>{
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'details': details ? "1" : "0"
    }),
  )
      .timeout(
    const Duration(seconds: 8),
    onTimeout: () {
      return new http.Response("", 404);
    },
  );

  print("refresh response ${responsePost.body}");
  if (responsePost.statusCode == 404 || responsePost.body.isEmpty) {
    return "Could not connect to the server";
  } else {
    Map<String, dynamic> refreshResponse;
    try {
      refreshResponse = jsonDecode(responsePost.body);
    } on Exception catch (_) {
      return "an unknown error has occurred";
    }
    if (refreshResponse.containsKey("result") &&
        refreshResponse.containsKey("message")) {
      bool result = refreshResponse["result"];
      String message = refreshResponse["message"];
      if (result) {
        String accessToken = refreshResponse["access_token"];
        String refreshToken = refreshResponse["refresh_token"];
        Map<String, dynamic> user = refreshResponse["user"];

        Settings settings = Settings();
        settings.setAccessToken(accessToken);
        settings.setRefreshToken(refreshToken);
        if (details) {
          settings.setUserName(user["username"]);
        }

        print("got result: $accessToken  $refreshToken");
        return "success";
      } else {
        return message;
      }
    }
  }
  return "an unknown error has occurred";
}