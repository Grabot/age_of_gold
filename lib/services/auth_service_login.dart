import 'dart:convert';
import 'dart:io';
import 'package:age_of_gold/services/models/login_response.dart';
import 'package:age_of_gold/services/models/register_request.dart';
import 'package:dio/dio.dart';
import '../util/util.dart';
import 'auth_api.dart';
import 'models/base_response.dart';
import 'models/login_request.dart';
import 'models/refresh_request.dart';


class AuthServiceLogin {
  static AuthServiceLogin? _instance;

  factory AuthServiceLogin() => _instance ??= AuthServiceLogin._internal();

  AuthServiceLogin._internal();

  Future<LoginResponse> getLogin(LoginRequest loginRequest) async {
    String endPoint = "login";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: loginRequest.toJson()
    );

    LoginResponse loginResponse = LoginResponse.fromJson(response.data);
    if (loginResponse.getResult()) {
      successfulLogin(loginResponse);
    }
    return loginResponse;
  }

  Future<LoginResponse> getRegister(RegisterRequest registerRequest) async {
    String endPoint = "register";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: registerRequest.toJson()
    );

    LoginResponse loginResponse = LoginResponse.fromJson(response.data);
    if (loginResponse.getResult()) {
      successfulLogin(loginResponse);
    }
    return loginResponse;
  }

  Future<LoginResponse> getRefresh(RefreshRequest refreshRequest) async {
    String endPoint = "refresh";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: refreshRequest.toJson()
    );

    LoginResponse loginResponse = LoginResponse.fromJson(response.data);
    if (loginResponse.getResult()) {
      successfulLogin(loginResponse);
    }
    return loginResponse;
  }

  Future<LoginResponse> getTokenLogin(String accessToken) async {
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