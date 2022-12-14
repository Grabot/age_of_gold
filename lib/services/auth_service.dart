import 'dart:io';
import 'package:age_of_gold/services/models/login_response.dart';
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

    var response = await AuthApi().dio.post('login',
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: loginRequest.toJson()
    );

    print(response);
    print(response.headers);

    LoginResponse loginResponse = LoginResponse.fromJson(response.data);
    successfulLogin(loginResponse.getUser(), loginResponse.getAccessToken(), loginResponse.getRefreshToken());
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