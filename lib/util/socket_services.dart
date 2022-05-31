import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../component/hexagon.dart';
import '../component/tile.dart';
import '../constants/base_url.dart';
import 'hexagon_list.dart';


class SocketServices extends ChangeNotifier {
  late IO.Socket socket;
  late HexagonList hexagonList;

  // We will use this to store the user's id, might change it later.
  int userId = -1;

  static final SocketServices _instance = SocketServices._internal();

  SocketServices._internal() {
    startSockConnection();
  }

  factory SocketServices() {
    return _instance;
  }

  void setUserId(int id) {
    userId = id;
  }

  void setHexagonList(HexagonList hexagonList) {
    this.hexagonList = hexagonList;
  }

  startSockConnection() {
    String namespace = "sock";
    String socketUrl = baseUrl + namespace;
    print("startSockConnection: $socketUrl");
    socket = IO.io(socketUrl, <String, dynamic>{
      'autoConnect': false,
      'transports': ['websocket'],
    });

    socket.onConnect((_) {
      socket.emit('message_event', 'Connected!');
    });

    socket.onDisconnect((_) {
      socket.emit('message_event', 'Disconnected!');
    });

    socket.on('message_event', (data) {
      print("message_event: $data");
    });

    socket.open();
  }

  void joinRoom() {
    socket.emit(
      "join",
      {
        'userId': userId,
      },
    );
    // After we have joined the room, we also want to listen to server events
    socket.on('send_hexagon_fail', (data) {
      print("send_hexagon_fail: $data");
      print(data);
    });
    socket.on('send_hexagon_success', (data) {
      print("send_hexagon_success");
      addHexagon(data);
      notifyListeners();
    });
  }

  void leaveRoom() {
    if (socket.connected) {
      socket.emit("leave", {
        'userId': userId,
      });
    }
  }

  getHexagon(int q, int r, int s) {
    print("getting hexagon with userId: $userId");
    socket.emit(
      "get_hexagon",
      {
        'q': q,
        'r': r,
        's': s,
        'userId': userId
      },
    );
  }

  addHexagon(data) {
    Hexagon hexagon = Hexagon.fromJson(data);
    for (var tileData in data["tiles"]) {
      // TODO: make sure the q, r, s are correct
      Tile tile = Tile(
          tileData["q"],
          tileData["r"],
          tileData["s"],
          tileData["type"]
      );
    }
  }
}
