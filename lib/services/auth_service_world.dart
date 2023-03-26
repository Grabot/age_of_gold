import 'dart:convert';
import 'dart:io';
import 'package:age_of_gold/services/models/login_response.dart';
import 'package:age_of_gold/services/models/register_request.dart';
import 'package:age_of_gold/services/settings.dart';
import 'package:age_of_gold/services/socket_services.dart';
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


class AuthServiceWorld {
  static AuthServiceWorld? _instance;

  factory AuthServiceWorld() => _instance ??= AuthServiceWorld._internal();

  AuthServiceWorld._internal();

  Future<String> changeTileType(int q, int r, int tileType) async {
    String endPoint = "tile/change";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, String>{
          "q": q.toString(),
          "r": r.toString(),
          "type": tileType.toString()
        }
      )
    );

    Map<String, dynamic> json = response.data;
    print("response is $json");
    if (json.containsKey("result")) {
      if (json["result"]) {
        // update the lock time of the user.
        Settings settings = Settings();
        if (json.containsKey("tile_lock") && settings.getUser() != null) {
          settings.getUser()!.updateTileLock(json["tile_lock"]);
          return "success";
        } else {
          return "error occurred";
        }
      } else {
        return json["message"];
      }
    }
    return "back to login";
  }

  Future<String> retrieveHexagons(HexagonList hexagonList, SocketServices socketServices, List<Tuple2> hexRetrievals) async {
    String endPoint = "hexagon/get";

    List hexToRetrieve = hexRetrievals.map((e) => {
      'q': e.item1,
      'r': e.item2,
    }).toList();

    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, String> {
          "hexagons": jsonEncode(hexToRetrieve)
        }
      )
    );

    Map<String, dynamic> json = response.data;

    if (!json.containsKey("result")) {
      return "an error occurred";
    } else {
      if (json["result"]) {
        var hexagons = json["hexagons"];
        for (var hex in hexagons) {
          addHexagon(hexagonList, socketServices, hex);
        }
        return "success";
      } else {
        return json["message"];
      }
    }
  }

  Future<String> getTileInfo(Tile tile) async {
    String endPoint = "tile/get/info";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, String>{
          "q": tile.tileQ.toString(),
          "r": tile.tileR.toString()
        }
      )
    );

    Map<String, dynamic> json = response.data;
    print("response is $json");
    if (!json.containsKey("result")) {
      return "an error occurred";
    } else {
      if (json["result"]) {
        Map<String, dynamic> jsonTile = json["tile"];
        if (jsonTile["last_changed_by"] != null && jsonTile["last_changed_time"] != null) {
          print("data: " + jsonTile.toString());
          User user = User.fromJson(jsonTile["last_changed_by"]);
          String nameLastChanged = user.getUserName();
          String lastChanged = jsonTile["last_changed_time"];
          if (!lastChanged.endsWith("Z")) {
            // The server has utc timestamp, but it's not formatted with the 'Z'.
            lastChanged += "Z";
          }
          tile.setLastChangedBy(nameLastChanged);
          tile.setLastChangedTime(DateTime.parse(lastChanged).toLocal());
          // TODO: Find a way to update the tilebox
        }
        return "success";
      } else {
        return json["message"];
      }
    }
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
    print("response is $json");
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
    print("response is $json");
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
    print("response is $json");
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
    print("response is $json");
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
}