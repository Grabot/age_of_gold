import 'dart:convert';
import 'dart:io';
import 'package:age_of_gold/services/models/login_response.dart';
import 'package:age_of_gold/services/models/register_request.dart';
import 'package:age_of_gold/services/settings.dart';
import 'package:dio/dio.dart';
import '../util/web_storage.dart';
import 'auth_api.dart';
import 'models/login_request.dart';
import 'models/user.dart';


class AuthService {
  static AuthService? _instance;

  factory AuthService() => _instance ??= AuthService._();

  AuthService._();

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
      successfulLogin(loginResponse.getUser(), loginResponse.getAccessToken(),
          loginResponse.getRefreshToken());
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
      successfulLogin(loginResponse.getUser(), loginResponse.getAccessToken(),
          loginResponse.getRefreshToken());
    }
    return loginResponse;
  }

  Future<LoginResponse> refreshAccessToken(String refreshToken) async {

    AuthApi().dio.options.extra['withCredentials'] = true;

    String endPoint = "refresh";
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
      successfulLogin(loginResponse.getUser(), loginResponse.getAccessToken(),
          loginResponse.getRefreshToken());
    }
    return loginResponse;
  }

  successfulLogin(User? user, String? accessToken, String? refreshToken) {
    // TODO: Only do this with Android or IOS?
    SecureStorage secureStorage = SecureStorage();

    Settings settings = Settings();

    if (accessToken != null) {
      settings.setAccessToken(accessToken);
      secureStorage.setAccessToken(accessToken);
    }
    if (refreshToken != null) {
      settings.setRefreshToken(refreshToken);
    }
    if (user != null) {
      settings.setUser(user);
    }

  }
}