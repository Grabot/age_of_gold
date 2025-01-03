import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';

import '../views/user_interface/ui_util/chat_messages.dart';
import '../views/user_interface/ui_util/messages/global_message.dart';
import '../views/user_interface/ui_util/messages/guild_message.dart';
import '../views/user_interface/ui_util/messages/message.dart';
import '../views/user_interface/ui_util/messages/personal_message.dart';
import 'auth_api.dart';
import 'models/base_response.dart';
import 'models/user.dart';
import 'settings.dart';


class AuthServiceSocial {
  int pageSize = 60;

  static AuthServiceSocial? _instance;

  factory AuthServiceSocial() => _instance ??= AuthServiceSocial._internal();

  AuthServiceSocial._internal();

  Future<BaseResponse> addFriend(int friendId) async {
    String endPoint = "add/friend";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, dynamic>{
          "user_id": friendId,
        }
      )
    );

    BaseResponse baseResponse = BaseResponse.fromJson(response.data);
    return baseResponse;
  }

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

  sendMessageChatGuild(int guildId, String message) {
    sendMessageGuild(guildId, message).then((value) {
      if (value != "success") {
        // TODO: What to do when it is not successful
      } else {
        // The socket should handle the receiving and placing of the message
      }
    }).onError((error, stackTrace) {
      // TODO: What to do on an error?
    });
  }

  sendMessageChatPersonal(String message, int userId) {
    sendMessagePersonal(message, userId).then((value) {
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

  Future<String> sendMessageGuild(int guildId, String message) async {
    String endPoint = "send/message/guild";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, dynamic>{
          "guild_id": guildId,
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

  Future<String> sendMessagePersonal(String message, int userId) async {
    String endPoint = "send/message/personal";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, dynamic>{
          "message": message,
          "user_id": userId
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

  Future<List<Message>?> getMessagesGlobal(int page) async {
    String endPoint = "get/message/global?page=$page&size=$pageSize";
    var response = await AuthApi().dio.get(endPoint,
      options: Options(headers: {
        HttpHeaders.contentTypeHeader: "application/json",
      }),
    );

    Map<String, dynamic> json = response.data;
    // For the messages we use a fastapi pagination return function
    // This will not contain result, but we use the size parameter
    // If the size is {pageSize} it was successful, if it is 1 it failed.
    if (!json.containsKey("size")) {
      return null;
    } else {
      if (json["size"] != pageSize) {
        return null;
      } else {
        if (!json.containsKey("items")) {
          return null;
        }
        List messages = json["items"];
        List<Message> messageList = [];
        String nameMe = Settings().getUser()!.getUserName();
        for (var message in messages) {
          String senderName = message["sender_name"];
          int senderId = message["sender_id"];
          String body = message["body"];
          bool me = senderName == nameMe;
          String time = message["timestamp"];
          if (!time.endsWith("Z")) {
            // The server has utc timestamp, but it's not formatted with the 'Z'.
            time += "Z";
          }
          DateTime timestamp = DateTime.parse(time).toLocal();
          messageList.add(GlobalMessage(senderId, senderName, body, me, timestamp, true));
        }
        return messageList;
      }
    }
  }

  Future<List<GuildMessage>?> getMessagesGuild(int guildId, int page) async {
    String endPoint = "get/message/guild?page=$page&size=$pageSize";
    var response = await AuthApi().dio.post(endPoint,
      options: Options(headers: {
        HttpHeaders.contentTypeHeader: "application/json",
      }),
      data: jsonEncode(<String, dynamic>{
        "guild_id": guildId
      })
    );

    Map<String, dynamic> json = response.data;
    // For the messages we use a fastapi pagination return function
    // This will not contain result, but we use the size parameter
    // If the size is {pageSize} it was successful, if it is 1 it failed.
    if (!json.containsKey("size")) {
      return null;
    } else {
      if (json["size"] != pageSize) {
        return null;
      } else {
        if (!json.containsKey("items")) {
          return null;
        }
        List messages = json["items"];
        List<GuildMessage> messageList = [];
        String nameMe = Settings().getUser()!.getUserName();
        for (var message in messages) {
          String? senderName = message["sender_name"];
          int? senderId = message["sender_id"];
          String body = message["body"];
          String time = message["timestamp"];
          if (!time.endsWith("Z")) {
            // The server has utc timestamp, but it's not formatted with the 'Z'.
            time += "Z";
          }
          DateTime timestamp = DateTime.parse(time).toLocal();
          bool isEvent = false;
          if (senderId == null) {
            senderId = -1;
            isEvent = true;
          }
          senderName ??= "Event";
          bool me = senderName == nameMe;
          messageList.add(GuildMessage(senderId, senderName, body, me, timestamp, true, isEvent));
        }
        return messageList;
      }
    }
  }

  Future<List<PersonalMessage>?> getMessagePersonal(ChatData userGet, int page) async {
    String endPoint = "get/message/personal?page=$page&size=$pageSize";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, dynamic>{
          "user_get_id": userGet.senderId
        }
      )
    );

    Map<String, dynamic> json = response.data;
    if (!json.containsKey("size")) {
      return null;
    } else {
      if (json["size"] != pageSize) {
        return null;
      } else {
        if (!json.containsKey("items")) {
          return null;
        }
        List<PersonalMessage> messageList = [];
        for (Map<String, dynamic> message in json["items"]) {
          User? userMe = Settings().getUser();
          if (userMe != null) {
            int userId = message["user_id"];
            // int receiverId = message["receiver_id"];
            int myId = userMe.getId();
            bool me = myId == userId;

            String senderName = userGet.name;
            String to = userMe.getUserName();
            if (me) {
              senderName = userMe.getUserName();
              to = userGet.name;
            }

            String body = message["body"];
            String timeString = message["timestamp"];
            if (!timeString.endsWith("Z")) {
              // The server has utc timestamp, but it's not formatted with the 'Z'.
              timeString += "Z";
            }
            DateTime timestamp = DateTime.parse(timeString).toLocal();
            PersonalMessage personalMessage = PersonalMessage(userId, senderName, body, me, timestamp, false, to);
            messageList.add(personalMessage);
          }
        }
        return messageList;
      }
    }
  }

  Future<BaseResponse> readMessagePersonal(int userReadId) async {
    String endPoint = "read/message/personal";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, dynamic>{
          "user_read_id": userReadId
        }
      )
    );

    BaseResponse baseResponse = BaseResponse.fromJson(response.data);
    return baseResponse;
  }

  Future<User?> searchPossibleFriend(String possibleFriend) async {
    String endPoint = "search/friend";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, String>{
          "username": possibleFriend,
        }
      )
    );

    Map<String, dynamic> json = response.data;
    if (!json.containsKey("result")) {
      return null;
    } else {
      if (json["result"]) {
        if (json.containsKey("friend")) {
          return User.fromJson(json["friend"]);
        } else {
          return null;
        }
      } else {
        return null;
      }
    }
  }

  Future<BaseResponse> denyRequest(int userId) async {
    String endPoint = "deny/request";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, dynamic>{
          "user_id": userId,
        }
      )
    );

    BaseResponse baseResponse = BaseResponse.fromJson(response.data);
    return baseResponse;
  }

  Future<BaseResponse> acceptRequest(int userId) async {
    String endPoint = "accept/request";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, dynamic>{
          "user_id": userId,
        }
      )
    );

    BaseResponse baseResponse = BaseResponse.fromJson(response.data);
    return baseResponse;
  }

  Future<List?> getFriendAvatars(List<int> friendIds) async {
    String endPoint = "get/avatars";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, dynamic>{
          "avatars": friendIds
        }
      )
    );

    Map<String, dynamic> json = response.data;
    if (!json.containsKey("result")) {
      return null;
    } else {
      if (json["result"]) {
        if (json.containsKey("avatars")) {
          return json["avatars"];
        } else {
          return null;
        }
      } else {
        return null;
      }
    }
  }

}