import 'dart:convert';
import 'dart:io';
import 'package:age_of_gold/services/settings.dart';
import 'package:dio/dio.dart';
import 'auth_api.dart';
import 'models/base_response.dart';


class AuthServiceSetting {
  static AuthServiceSetting? _instance;

  factory AuthServiceSetting() => _instance ??= AuthServiceSetting._internal();

  AuthServiceSetting._internal();

  Future<BaseResponse> changeUserName(String newUsername) async {
    String endPoint = "change/username";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, String>{
          "username": newUsername,
        }
      )
    );

    BaseResponse baseResponse = BaseResponse.fromJson(response.data);
    return baseResponse;
  }
}