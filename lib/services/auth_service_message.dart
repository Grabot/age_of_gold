import 'dart:convert';
import 'dart:io';
import 'package:age_of_gold/services/models/login_response.dart';
import 'package:age_of_gold/services/models/register_request.dart';
import 'package:age_of_gold/services/settings.dart';
import 'package:age_of_gold/services/socket_services.dart';
import 'package:age_of_gold/views/user_interface/ui_util/messages/global_message.dart';
import 'package:age_of_gold/views/user_interface/ui_util/messages/message.dart';
import 'package:dio/dio.dart';
import 'package:tuple/tuple.dart';
import '../component/hexagon.dart';
import '../component/tile.dart';
import '../util/hexagon_list.dart';
import '../util/util.dart';
import 'auth_api.dart';
import 'models/login_request.dart';
import 'models/refresh_request.dart';
import 'models/user.dart';


class AuthServiceMessage {
  static AuthServiceMessage? _instance;

  factory AuthServiceMessage() => _instance ??= AuthServiceMessage._internal();

  AuthServiceMessage._internal();

  sendMessageChatGlobal(String message) {
    sendMessageGlobal(message).then((value) {
      if (value != "success") {
        // TODO: What to do when it is not successful
      } else {
        // The socket should handle the receiving and placing of the message
      }
    }).onError((error, stackTrace) {
      // TODO: What to do on an error?
    });
  }

  sendMessageChatLocal(String message, int hexQ, int hexR, int tileQ, int tileR) {
    sendMessageLocal(message, hexQ, hexR, tileQ, tileR).then((value) {
      if (value != "success") {
        // TODO: What to do when it is not successful
      } else {
        // The socket should handle the receiving and placing of the message
      }
    }).onError((error, stackTrace) {
      // TODO: What to do on an error?
    });
  }

  sendMessageChatGuild(String message, String guildName) {
    sendMessageGuild(message, guildName).then((value) {
      if (value != "success") {
        // TODO: What to do when it is not successful
      } else {
        // The socket should handle the receiving and placing of the message
      }
    }).onError((error, stackTrace) {
      // TODO: What to do on an error?
    });
  }

  sendMessageChatPersonal(String message, String userTo) {
    sendMessagePersonal(message, userTo).then((value) {
      if (value != "success") {
        // TODO: What to do when it is not successful
      } else {
        // The socket should handle the receiving and placing of the message
      }
    }).onError((error, stackTrace) {
      // TODO: What to do on an error?
    });
  }

  Future<String> sendMessageGlobal(String message) async {
    String endPoint = "send/message/global";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, String>{
          "message": message,
        }
      )
    );

    Map<String, dynamic> json = response.data;
    if (!json.containsKey("result")) {
      return "an error occurred";
    } else {
      if (json["result"]) {
        return "success";
      } else {
        return json["message"];
      }
    }
  }

  Future<String> sendMessageLocal(String message, int hexQ, int hexR, int tileQ, int tileR) async {
    String endPoint = "send/message/local";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, String>{
          "message": message,
          "hex_q": hexQ.toString(),
          "hex_r": hexR.toString(),
          "tile_q": tileQ.toString(),
          "tile_r": tileR.toString()
        }
      )
    );

    Map<String, dynamic> json = response.data;
    if (!json.containsKey("result")) {
      return "an error occurred";
    } else {
      if (json["result"]) {
        return "success";
      } else {
        return json["message"];
      }
    }
  }

  Future<String> sendMessageGuild(String message, String guildName) async {
    String endPoint = "send/message/guild";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, String>{
          "message": message,
          "guild_name": guildName
        }
      )
    );

    Map<String, dynamic> json = response.data;
    if (!json.containsKey("result")) {
      return "an error occurred";
    } else {
      if (json["result"]) {
        return "success";
      } else {
        return json["message"];
      }
    }
  }

  Future<String> sendMessagePersonal(String message, String toUser) async {
    String endPoint = "send/message/personal";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, String>{
          "message": message,
          "to_user": toUser
        }
      )
    );

    Map<String, dynamic> json = response.data;
    if (!json.containsKey("result")) {
      return "an error occurred";
    } else {
      if (json["result"]) {
        return "success";
      } else {
        return json["message"];
      }
    }
  }

  Future<List<Message>?> getMessagesGlobal() async {
    String endPoint = "get/message/global";
    var response = await AuthApi().dio.get(endPoint,
      options: Options(headers: {
        HttpHeaders.contentTypeHeader: "application/json",
      }),
    );

    Map<String, dynamic> json = response.data;
    if (!json.containsKey("result")) {
      return null;
    } else {
      if (json["result"]) {
        print("get messages success $json");
        List messages = json["messages"];
        List<Message> messageList = [];
        String nameMe = Settings().getUser()!.getUserName();
        for (var message in messages) {
          String senderName = message["sender_name"];
          String body = message["body"];
          bool me = senderName == nameMe;
          String time = message["timestamp"];
          if (!time.endsWith("Z")) {
            // The server has utc timestamp, but it's not formatted with the 'Z'.
            time += "Z";
          }
          DateTime timestamp = DateTime.parse(time).toLocal();
          messageList.add(GlobalMessage(0, senderName, body, me, timestamp, true));
        }
        return messageList;
      } else {
        return null;
      }
    }
  }
}