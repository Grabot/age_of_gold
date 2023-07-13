import 'dart:convert';
import 'dart:io';

import 'package:age_of_gold/services/models/base_response.dart';
import 'package:age_of_gold/services/models/guild.dart';
import 'package:age_of_gold/util/util.dart';
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

  Future<BaseResponse> leaveGuild() async {
    String endPoint = "guild/leave";
    var response = await AuthApi().dio.get(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        },
      )
    );

    BaseResponse baseResponse = BaseResponse.fromJson(response.data);
    return baseResponse;
  }

  Future<Guild?> searchGuild(String guildName) async {
    String endPoint = "guild/search";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, dynamic> {
          "guild_name": guildName,
        }
      )
    );

    Map<String, dynamic> json = response.data;
    if (!json.containsKey("result")) {
      return null;
    } else {
      if (json["result"]) {
        if (json.containsKey("guild")) {
          return Guild.fromJson(json["guild"]);
        } else {
          return null;
        }
      } else {
        return null;
      }
    }
  }

}
