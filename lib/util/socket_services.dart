import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../component/hexagon.dart';
import '../component/tile.dart';
import '../component/type/grass_tile.dart';
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
    // print("getting hexagon with userId: $userId");
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
    int tileQ = (hexagonList.tiles.length / 2).ceil();
    int tileR = (hexagonList.tiles[0].length / 2).ceil();
    int index = 0;
    for (var tileData in data["tiles"]) {
      GrassTile tile = GrassTile(
          tileData["id"],
          tileData["q"],
          tileData["r"],
          tileData["type"]
      );
      if (index == 30) {
        // The 31th tile from the list will be the center.
        // We set this as hexagon position
        hexagon.center = tile.getPos(0);
      }
      index += 1;
      tile.hexagon = hexagon;
      hexagon.addTile(tile);
      hexagonList.tiles[tileQ + tile.q][tileR + tile.r] = tile;
    }
    int hexQ = (hexagonList.hexagons.length / 2).ceil();
    int hexR = (hexagonList.hexagons[0].length / 2).ceil();

    hexagon.updateHexagon(0);
    hexagonList.hexagons[hexQ + hexagon.hexQArray][hexR + hexagon.hexRArray] = hexagon;
    // check if the left hexagon is initialized and if it does not have it's right hexagon initialized
    if (hexagonList.hexagons[hexQ + hexagon.hexQArray - 1][hexR + hexagon.hexRArray] != null
        && hexagonList.hexagons[hexQ + hexagon.hexQArray - 1][hexR + hexagon.hexRArray]!.right == null) {
      // If that is the case than set these two hexagons as neighbors
      hexagonList.hexagons[hexQ + hexagon.hexQArray - 1][hexR + hexagon.hexRArray]!.right = hexagon;
      hexagon.left = hexagonList.hexagons[hexQ + hexagon.hexQArray - 1][hexR + hexagon.hexRArray];
    }
    // check if the right hexagon is initialized and if it does not have it's left hexagon initialized
    if (hexagonList.hexagons[hexQ + hexagon.hexQArray + 1][hexR + hexagon.hexRArray] != null
        && hexagonList.hexagons[hexQ + hexagon.hexQArray + 1][hexR + hexagon.hexRArray]!.left == null) {
      hexagonList.hexagons[hexQ + hexagon.hexQArray + 1][hexR + hexagon.hexRArray]!.left = hexagon;
      hexagon.right = hexagonList.hexagons[hexQ + hexagon.hexQArray + 1][hexR + hexagon.hexRArray];
    }
    // check if the top right hexagon is initialized and if it does not have it's bottom left hexagon initialized
    if (hexagonList.hexagons[hexQ + hexagon.hexQArray + 1][hexR + hexagon.hexRArray - 1] != null
        && hexagonList.hexagons[hexQ + hexagon.hexQArray + 1][hexR + hexagon.hexRArray - 1]!.bottomLeft == null) {
      // If that is the case than set these two hexagons as neighbors
      hexagonList.hexagons[hexQ + hexagon.hexQArray + 1][hexR + hexagon.hexRArray - 1]!.bottomLeft = hexagon;
      hexagon.topRight = hexagonList.hexagons[hexQ + hexagon.hexQArray + 1][hexR + hexagon.hexRArray - 1];
    }
    // check if the bottom left hexagon is initialized and if it does not have it's top right hexagon initialized
    if (hexagonList.hexagons[hexQ + hexagon.hexQArray - 1][hexR + hexagon.hexRArray + 1] != null
        && hexagonList.hexagons[hexQ + hexagon.hexQArray - 1][hexR + hexagon.hexRArray + 1]!.topRight == null) {
      // If that is the case than set these two hexagons as neighbors
      hexagonList.hexagons[hexQ + hexagon.hexQArray - 1][hexR + hexagon.hexRArray + 1]!.topRight = hexagon;
      hexagon.bottomLeft = hexagonList.hexagons[hexQ + hexagon.hexQArray - 1][hexR + hexagon.hexRArray + 1];
    }
    // check if the bottom right hexagon is initialized and if it does not have it's bottom top left initialized
    if (hexagonList.hexagons[hexQ + hexagon.hexQArray][hexR + hexagon.hexRArray - 1] != null
        && hexagonList.hexagons[hexQ + hexagon.hexQArray][hexR + hexagon.hexRArray - 1]!.bottomRight == null) {
      // If that is the case than set these two hexagons as neighbors
      hexagonList.hexagons[hexQ + hexagon.hexQArray][hexR + hexagon.hexRArray - 1]!.bottomRight = hexagon;
      hexagon.topLeft = hexagonList.hexagons[hexQ + hexagon.hexQArray][hexR + hexagon.hexRArray - 1];
    }
    // check if the top left hexagon is initialized and if it does not have it's bottom right hexagon initialized
    if (hexagonList.hexagons[hexQ + hexagon.hexQArray][hexR + hexagon.hexRArray + 1] != null
        && hexagonList.hexagons[hexQ + hexagon.hexQArray][hexR + hexagon.hexRArray + 1]!.topLeft == null) {
      // If that is the case than set these two hexagons as neighbors
      hexagonList.hexagons[hexQ + hexagon.hexQArray][hexR + hexagon.hexRArray + 1]!.topLeft = hexagon;
      hexagon.bottomRight = hexagonList.hexagons[hexQ + hexagon.hexQArray][hexR + hexagon.hexRArray + 1];
    }
  }
}
