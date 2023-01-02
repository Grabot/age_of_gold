// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'package:age_of_gold/services/settings.dart';
// import 'package:age_of_gold/util/util.dart';
// import 'package:age_of_gold/util/web_storage.dart';
// import 'package:dio/dio.dart';
// import 'package:http/http.dart' as http;
// // import 'package:http/browser_client.dart';
//
// import '../constants/url_base.dart';
//
//
// Future signUp(String userName, String email, String password) async {
//   String urlRegister = '${baseUrlV1_1}register';
//   Uri uriRegister = Uri.parse(urlRegister);
//
//   http.Client client = http.Client();
//
//   http.Response responsePost = await client.post(
//     uriRegister,
//     headers: <String, String>{
//       'Content-Type': 'application/json; charset=UTF-8',
//     },
//     body: jsonEncode(<String, String>{
//       'user_name': userName,
//       'email': email,
//       'password': password
//     }),
//   )
//       .timeout(
//     Duration(seconds: 8),
//     onTimeout: () {
//       return new http.Response("", 404);
//     },
//   );
//
//   print("resposne!!! ${responsePost.body}");
//
//   if (responsePost.statusCode == 404 || responsePost.body.isEmpty) {
//     return "Could not connect to the server";
//   } else {
//     Map<String, dynamic> registerResponse = jsonDecode(responsePost.body);
//     if (registerResponse.containsKey("result") &&
//         registerResponse.containsKey("message")) {
//       bool result = registerResponse["result"];
//       String message = registerResponse["message"];
//       print("message: $message");
//       if (result) {
//         successfulLogin(registerResponse, true);
//         return "success";
//       } else {
//         return message;
//       }
//     }
//   }
//   return "an unknown error has occurred";
// }
//
// Future<String> signIn(
//     String emailOrUserName, String password) async {
//   String urlLogin = '${baseUrlV1_1}login';
//   print("going to login with url $urlLogin");
//   Uri uriLogin = Uri.parse(urlLogin);
//
//   var dio = Dio();
//
//   String postBody = "";
//   if (emailValid(emailOrUserName)) {
//     // email
//     postBody = jsonEncode(<String, String>{
//       'email': emailOrUserName,
//       'password': password
//     });
//   } else {
//     // user name
//     postBody = jsonEncode(<String, String>{
//       'user_name': emailOrUserName,
//       'password': password
//     });
//   }
//
//   try {
//     dio.options.extra['withCredentials'] = true;
//     String urlTest = '${baseUrlV1_1}login';
//     var response = await dio.post(urlTest,
//         options: Options(headers: {
//           HttpHeaders.contentTypeHeader: "application/json",
//         }),
//         data: postBody);
//     print(response);
//     print(response.headers);
//   } catch (e) {
//     print(e);
//   }
//
//   // print("resonse: ${responsePost.body}");
//   // print("response: ${responsePost.headers}");
//   //
//   // if (responsePost.statusCode == 404 || responsePost.body.isEmpty) {
//   //   return "Could not connect to the server";
//   // } else {
//   //   Map<String, dynamic> signInResponse;
//   //   try {
//   //     signInResponse = jsonDecode(responsePost.body);
//   //   } on Exception catch (_) {
//   //     return "an unknown error has occurred";
//   //   }
//   //   if (signInResponse.containsKey("result") &&
//   //       signInResponse.containsKey("message")) {
//   //     bool result = signInResponse["result"];
//   //     String message = signInResponse["message"];
//   //     if (result) {
//   //       successfulLogin(signInResponse, true);
//   //       return "success";
//   //     } else {
//   //       return message;
//   //     }
//   //   }
//   // }
//   return "an unknown error has occurred";
// }
//
// Future<String> refreshAccessToken(
//     String accessToken, String refreshToken, bool details) async {
//   String urlRefresh = '${baseUrlV1_1}refresh';
//   print("going to refresh access token with url $urlRefresh");
//   Uri uriRefresh = Uri.parse(urlRefresh);
//
//   http.Client client = http.Client();
//
//   http.Response responsePost = await client.post(
//     uriRefresh,
//     headers: <String, String>{
//       'Content-Type': 'application/json; charset=UTF-8'
//     },
//     body: jsonEncode(<String, String>{
//       'access_token': accessToken,
//       'refresh_token': refreshToken,
//       'details': details ? "1" : "0"
//     }),
//   )
//       .timeout(
//     const Duration(seconds: 8),
//     onTimeout: () {
//       return new http.Response("", 404);
//     },
//   );
//
//   print("refresh response ${responsePost.body}");
//   if (responsePost.statusCode == 404 || responsePost.body.isEmpty) {
//     return "Could not connect to the server";
//   } else {
//     Map<String, dynamic> refreshResponse;
//     try {
//       refreshResponse = jsonDecode(responsePost.body);
//     } on Exception catch (_) {
//       return "an unknown error has occurred";
//     }
//     if (refreshResponse.containsKey("result") &&
//         refreshResponse.containsKey("message")) {
//       bool result = refreshResponse["result"];
//       String message = refreshResponse["message"];
//       if (result) {
//         successfulLogin(refreshResponse, details);
//         return "success";
//       } else {
//         return message;
//       }
//     }
//   }
//   return "an unknown error has occurred";
// }
//
//
// Future tokenLogin(String accessToken) async {
//   String urlAccessToken = '${baseUrlV1_1}accessToken';
//   Uri uriAccessToken = Uri.parse(urlAccessToken);
//
//   http.Client client = http.Client();
//
//   http.Response responsePost = await client.post(
//     uriAccessToken,
//     headers: <String, String>{
//       'Content-Type': 'application/json; charset=UTF-8',
//     },
//     body: jsonEncode(<String, String>{
//       'access_token': accessToken,
//     }),
//   )
//       .timeout(
//     Duration(seconds: 8),
//     onTimeout: () {
//       return new http.Response("", 404);
//     },
//   );
//
//   if (responsePost.statusCode == 404 || responsePost.body.isEmpty) {
//     return "Could not connect to the server";
//   } else {
//     Map<String, dynamic> accessTokenResponse = jsonDecode(responsePost.body);
//     if (accessTokenResponse.containsKey("result") &&
//         accessTokenResponse.containsKey("message")) {
//       bool result = accessTokenResponse["result"];
//       String message = accessTokenResponse["message"];
//       print("message: $message");
//       if (result) {
//         successfulLogin(accessTokenResponse, true);
//         return "success";
//       } else {
//         return message;
//       }
//     }
//   }
//   return "an unknown error has occurred";
// }
//
// successfulLogin(Map<String, dynamic> response, bool details) {
//   String accessToken = response["access_token"];
//   String refreshToken = response["refresh_token"];
//   Map<String, dynamic> user = response["user"];
//
//   Settings settings = Settings();
//   settings.setAccessToken(accessToken);
//   settings.setRefreshToken(refreshToken);
//
//   // We also store the access token in the cookies.
//   // If the user comes back he can use it to continue to be logged in
//
//   SecureStorage secureStorage = SecureStorage();
//   secureStorage.setAccessToken(accessToken);
//
//   // print("got result: $accessToken  $refreshToken");
// }