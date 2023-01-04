import 'dart:convert';
import 'dart:io';
import 'package:age_of_gold/services/models/login_response.dart';
import 'package:age_of_gold/services/models/register_request.dart';
import 'package:dio/dio.dart';
import '../util/util.dart';
import 'auth_api.dart';
import 'models/login_request.dart';
import 'models/refresh_request.dart';


class AuthService {
  static AuthService? _instance;

  factory AuthService() => _instance ??= AuthService._internal();

  AuthService._internal();

  Future<LoginResponse> getLogin(LoginRequest loginRequest) async {

    AuthApi().dio.options.extra['withCredentials'] = true;

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

    AuthApi().dio.options.extra['withCredentials'] = true;

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

    AuthApi().dio.options.extra['withCredentials'] = true;

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

    AuthApi().dio.options.extra['withCredentials'] = true;

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

  Future<LoginResponse> getTest() async {

    AuthApi().dio.options.extra['withCredentials'] = true;

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