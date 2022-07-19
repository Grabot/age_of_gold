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
    int qHexLeft = hexQ + hexagon.hexQArray - 1;
    int rHexLeft = hexR + hexagon.hexRArray;
    if (qHexLeft >= 0) {
      if (hexagonList.hexagons[qHexLeft][rHexLeft] != null
          && hexagonList.hexagons[qHexLeft][rHexLeft]!.right == null) {
        // If that is the case than set these two hexagons as neighbors
        hexagonList.hexagons[qHexLeft][rHexLeft]!.right = hexagon;
        hexagon.left = hexagonList.hexagons[qHexLeft][rHexLeft];
      }
    }
    // check if the right hexagon is initialized and if it does not have it's left hexagon initialized
    int qHexRight = hexQ + hexagon.hexQArray + 1;
    int rHexRight = hexR + hexagon.hexRArray;
    if (qHexRight < hexagonList.hexagons.length) {
      if (hexagonList.hexagons[qHexRight][rHexRight] != null
          && hexagonList.hexagons[qHexRight][rHexRight]!.left == null) {
        hexagonList.hexagons[qHexRight][rHexRight]!.left = hexagon;
        hexagon.right = hexagonList.hexagons[qHexRight][rHexRight];
      }
    }
    // check if the top right hexagon is initialized and if it does not have it's bottom left hexagon initialized
    int qHexTopRight = hexQ + hexagon.hexQArray + 1;
    int rHexTopRight = hexR + hexagon.hexRArray - 1;
    if (rHexTopRight >= 0 && rHexTopRight < hexagonList.hexagons.length) {
      if (hexagonList.hexagons[qHexTopRight][rHexTopRight] != null
          && hexagonList.hexagons[qHexTopRight][rHexTopRight]!.bottomLeft ==
              null) {
        // If that is the case than set these two hexagons as neighbors
        hexagonList.hexagons[qHexTopRight][rHexTopRight]!.bottomLeft = hexagon;
        hexagon.topRight = hexagonList.hexagons[qHexTopRight][rHexTopRight];
      }
    }
    // check if the bottom left hexagon is initialized and if it does not have it's top right hexagon initialized
    int qHexBottomLeft = hexQ + hexagon.hexQArray - 1;
    int rHexBottomLeft = hexR + hexagon.hexRArray + 1;
    if (qHexBottomLeft >= 0 && rHexBottomLeft < hexagonList.hexagons.length) {
      if (hexagonList.hexagons[qHexBottomLeft][rHexBottomLeft] != null &&
          hexagonList.hexagons[qHexBottomLeft][rHexBottomLeft]!.topRight ==
              null) {
        // If that is the case than set these two hexagons as neighbors
        hexagonList.hexagons[qHexBottomLeft][rHexBottomLeft]!.topRight =
            hexagon;
        hexagon.bottomLeft =
        hexagonList.hexagons[qHexBottomLeft][rHexBottomLeft];
      }
    }
    // check if the bottom right hexagon is initialized and if it does not have it's bottom top left initialized
    int qHexBottomRight = hexQ + hexagon.hexQArray;
    int rHexBottomRight = hexR + hexagon.hexRArray - 1;
    if (rHexBottomRight >= 0) {
      if (hexagonList.hexagons[qHexBottomRight][rHexBottomRight] != null &&
          hexagonList.hexagons[qHexBottomRight][rHexBottomRight]!.bottomRight ==
              null) {
        // If that is the case than set these two hexagons as neighbors
        hexagonList.hexagons[qHexBottomRight][rHexBottomRight]!.bottomRight =
            hexagon;
        hexagon.topLeft =
        hexagonList.hexagons[qHexBottomRight][rHexBottomRight];
      }
    }
    // check if the top left hexagon is initialized and if it does not have it's bottom right hexagon initialized
    int qHexTopLeft = hexQ + hexagon.hexQArray;
    int rHexTopLeft = hexR + hexagon.hexRArray + 1;
    if (rHexTopLeft < hexagonList.hexagons.length) {
      if (hexagonList.hexagons[qHexTopLeft][rHexTopLeft] != null
          && hexagonList.hexagons[qHexTopLeft][rHexTopLeft]!.topLeft == null) {
        // If that is the case than set these two hexagons as neighbors
        hexagonList.hexagons[qHexTopLeft][rHexTopLeft]!.topLeft = hexagon;
        hexagon.bottomRight = hexagonList.hexagons[qHexTopLeft][rHexTopLeft];
      }
    }
  }
}
