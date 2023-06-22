import 'dart:convert';
import 'dart:io';
import 'package:age_of_gold/services/models/login_response.dart';
import 'package:age_of_gold/services/models/register_request.dart';
import 'package:dio/dio.dart';
import '../util/util.dart';
import 'auth_api.dart';
import 'models/base_response.dart';
import 'models/login_request.dart';
import 'settings.dart';


class AuthServiceLogin {
  static AuthServiceLogin? _instance;

  factory AuthServiceLogin() => _instance ??= AuthServiceLogin._internal();

  AuthServiceLogin._internal();

  Future<LoginResponse> getLogin(LoginRequest loginRequest) async {
    print("getting logging");
    Settings().setLoggingIn(true);
    String endPoint = "login";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: loginRequest.toJson()
    );

    LoginResponse loginResponse = LoginResponse.fromJson(response.data);
    if (loginResponse.getResult()) {
      print("successful login getLogin");
      successfulLogin(loginResponse);
    }
    return loginResponse;
  }

  Future<LoginResponse> getRegister(RegisterRequest registerRequest) async {
    Settings().setLoggingIn(true);
    String endPoint = "register";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: registerRequest.toJson()
    );

    LoginResponse loginResponse = LoginResponse.fromJson(response.data);
    if (loginResponse.getResult()) {
      print("successful login getRegister");
      successfulLogin(loginResponse);
    }
    return loginResponse;
  }

  Future<LoginResponse> getRefresh(String accessToken, String refreshToken) async {
    Settings().setLoggingIn(true);
    String endPoint = "refresh";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, dynamic> {
          "access_token": accessToken,
          "refresh_token": refreshToken
        }
      )
    );

    LoginResponse loginResponse = LoginResponse.fromJson(response.data);
    if (loginResponse.getResult()) {
      print("successful login getRefresh");
      successfulLogin(loginResponse);
    }
    return loginResponse;
  }

  Future<LoginResponse> getTokenLogin(String accessToken) async {
    Settings().setLoggingIn(true);
    String endPoint = "login/token";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, String> {
          "access_token": accessToken
        }
      )
    );

    LoginResponse loginResponse = LoginResponse.fromJson(response.data);
    if (loginResponse.getResult()) {
      print("successful login getTokenLogin");
      successfulLogin(loginResponse);
    }
    return loginResponse;
  }

  Future<BaseResponse> getPasswordReset(String email) async {
    String endPoint = "password/reset";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, String> {
          "email": email
        }
      )
    );

    BaseResponse baseResponse = BaseResponse.fromJson(response.data);

    return baseResponse;
  }

  Future<BaseResponse> passwordResetCheck(String accessToken) async {
    String endPoint = "password/check";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, String> {
          "access_token": accessToken
        }
      )
    );

    BaseResponse baseResponse = BaseResponse.fromJson(response.data);

    return baseResponse;
  }

  Future<BaseResponse> updatePassword(String accessToken, String newPassword) async {
    String endPoint = "password/update";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, String> {
          "access_token": accessToken,
          "new_password": newPassword
        }
      )
    );

    BaseResponse baseResponse = BaseResponse.fromJson(response.data);

    return baseResponse;
  }

  Future<BaseResponse> emailVerificationSend() async {
    String endPoint = "email/verification";
    var response = await AuthApi().dio.get(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }
      ),
    );

    BaseResponse baseResponse = BaseResponse.fromJson(response.data);

    return baseResponse;
  }

  Future<BaseResponse> emailVerificationCheck(String accessToken) async {
    String endPoint = "email/verification";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, String> {
          "access_token": accessToken
        }
      )
    );

    BaseResponse baseResponse = BaseResponse.fromJson(response.data);

    return baseResponse;
  }

  Future<LoginResponse> getTest() async {
    String endPoint = "test";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, String>{
        }
      )
    );

    LoginResponse loginResponse = LoginResponse.fromJson(response.data);
    if (loginResponse.getResult()) {
      print("test endpoint was positive");
    }
    return loginResponse;
  }
}