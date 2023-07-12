import 'dart:convert';
import 'dart:io';

import 'package:age_of_gold/services/models/base_response.dart';
import 'package:age_of_gold/services/models/guild.dart';
import 'package:dio/dio.dart';

import 'auth_api.dart';


class AuthServiceGuild {

  static AuthServiceGuild? _instance;

  factory AuthServiceGuild() => _instance ??= AuthServiceGuild._internal();

  AuthServiceGuild._internal();

  Future<BaseResponse> createGuild(int userId, String guildName, String? guildCrest) async {
    String endPoint = "guild/create";
    String dataCreate;
    if (guildCrest != null) {
      dataCreate = jsonEncode(<String, dynamic> {
        "user_id": userId,
        "guild_name": guildName,
        "guild_crest": guildCrest,
      });
    } else {
      dataCreate = jsonEncode(<String, dynamic> {
        "user_id": userId,
        "guild_name": guildName,
      });
    }
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: dataCreate
    );

    BaseResponse baseResponse = BaseResponse.fromJson(response.data);
    return baseResponse;
  }

}
