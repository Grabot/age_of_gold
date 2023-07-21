import 'dart:convert';
import 'dart:io';

import 'package:age_of_gold/services/models/base_response.dart';
import 'package:age_of_gold/services/models/guild.dart';
import 'package:age_of_gold/util/util.dart';
import 'package:dio/dio.dart';

import 'auth_api.dart';
import 'models/user.dart';


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

  Future<BaseResponse> requestToJoin(int guildId) async {
    String endPoint = "guild/request/user";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, dynamic> {
          "guild_id": guildId,
        }
      )
    );

    BaseResponse baseResponse = BaseResponse.fromJson(response.data);
    return baseResponse;
  }

  Future<List<Guild>?> getRequestedUserSend() async {
    String endPoint = "guild/requests/user/send";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, dynamic> {}
      )
    );

    Map<String, dynamic> json = response.data;
    if (!json.containsKey("result")) {
      return null;
    } else {
      if (json["result"]) {
        if (json.containsKey("guild_requests")) {
          List requests = json["guild_requests"];
          List<Guild> guilds = [];
          for (Map<String, dynamic> request in requests) {
            guilds.add(Guild.fromJson(request));
          }
          return guilds;
        } else {
          return null;
        }
      } else {
        return null;
      }
    }
  }

  Future<List<Guild>?> getRequestedUserGot() async {
    String endPoint = "guild/requests/user/got";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, dynamic> {}
        )
    );

    Map<String, dynamic> json = response.data;
    if (!json.containsKey("result")) {
      return null;
    } else {
      if (json["result"]) {
        if (json.containsKey("guild_requests")) {
          List requests = json["guild_requests"];
          List<Guild> guilds = [];
          for (Map<String, dynamic> request in requests) {
            guilds.add(Guild.fromJson(request));
          }
          return guilds;
        } else {
          return null;
        }
      } else {
        return null;
      }
    }
  }

  Future<List<User>?> getRequestedGuildSend(int guildId) async {
    String endPoint = "guild/requests/guild/send";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, dynamic> {
          "guild_id": guildId
        }
      )
    );

    Map<String, dynamic> json = response.data;
    if (!json.containsKey("result")) {
      return null;
    } else {
      if (json["result"]) {
        if (json.containsKey("guild_requests")) {
          List requests = json["guild_requests"];
          List<User> userRequests = [];
          for (Map<String, dynamic> request in requests) {
            userRequests.add(User.fromJson(request));
          }
          return userRequests;
        } else {
          return null;
        }
      } else {
        return null;
      }
    }
  }

  Future<List<User>?> getRequestedGuildGot(int guildId) async {
    String endPoint = "guild/requests/guild/got";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, dynamic> {
          "guild_id": guildId
        }
      )
    );

    Map<String, dynamic> json = response.data;
    if (!json.containsKey("result")) {
      return null;
    } else {
      if (json["result"]) {
        if (json.containsKey("guild_requests")) {
          List requests = json["guild_requests"];
          List<User> userRequests = [];
          for (Map<String, dynamic> request in requests) {
            userRequests.add(User.fromJson(request));
          }
          return userRequests;
        } else {
          return null;
        }
      } else {
        return null;
      }
    }
  }

  Future<BaseResponse> cancelRequestUser(int guildId) async {
    String endPoint = "guild/request/cancel/user";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, dynamic> {
          "guild_id": guildId,
        }
      )
    );

    BaseResponse baseResponse = BaseResponse.fromJson(response.data);
    return baseResponse;
  }

  Future<BaseResponse> cancelRequestGuild(int userId, int guildId) async {
    String endPoint = "guild/request/cancel/guild";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, dynamic> {
          "guild_id": guildId,
          "user_id": userId
        }
      )
    );

    BaseResponse baseResponse = BaseResponse.fromJson(response.data);
    return baseResponse;
  }

  Future<BaseResponse> acceptGuildRequestGuild(int guildId) async {
    String endPoint = "guild/request/accept/guild";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, dynamic> {
          "guild_id": guildId,
        }
      )
    );

    BaseResponse baseResponse = BaseResponse.fromJson(response.data);
    return baseResponse;
  }


  Future<BaseResponse> acceptGuildRequestUser(int userId, int guildId) async {
    String endPoint = "guild/request/accept/user";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, dynamic> {
          "user_id": userId,
          "guild_id": guildId,
        }
      )
    );

    BaseResponse baseResponse = BaseResponse.fromJson(response.data);
    return baseResponse;
  }

    Future<BaseResponse> askNewMember(int newMemberId, int guildId) async {
    String endPoint = "guild/request/guild";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, dynamic> {
          "user_id": newMemberId,
          "guild_id": guildId,
        }
      )
    );

    BaseResponse baseResponse = BaseResponse.fromJson(response.data);
    return baseResponse;
  }
}
