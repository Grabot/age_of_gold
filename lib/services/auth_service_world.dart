import 'dart:convert';
import 'dart:io';
import 'package:age_of_gold/services/models/login_response.dart';
import 'package:age_of_gold/services/models/register_request.dart';
import 'package:age_of_gold/services/socket_services.dart';
import 'package:dio/dio.dart';
import 'package:tuple/tuple.dart';
import '../component/hexagon.dart';
import '../util/hexagon_list.dart';
import '../util/util.dart';
import 'auth_api.dart';
import 'models/login_request.dart';
import 'models/refresh_request.dart';


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
        return "success";
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
    print("response is $json");
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
}