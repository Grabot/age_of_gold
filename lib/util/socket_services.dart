import 'dart:convert';

import 'package:age_of_gold/util/global.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../component/hexagon.dart';
import '../component/tile.dart';
import '../component/type/grass_tile.dart';
import '../constants/url_base.dart';
import '../user_interface/chat_messages.dart';
import 'hexagon_list.dart';


class SocketServices extends ChangeNotifier {
  late IO.Socket socket;

  // We will use this to store the user's id, might change it later.
  int userId = -1;

  // int hexagonsToRetrieve = 0;

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
    print("joining room");
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
    });
  }

  late ChatMessages chatMessages;
  void checkMessages(ChatMessages chatMessages) {
    this.chatMessages = chatMessages;
    socket.on('send_message_success', (data) {
      print("received a message");
      receivedMessage(data);
      notifyListeners();
    });
  }

  void receivedMessage(String message) {
    chatMessages.addMessage(message);
  }

  void sendMessage(String message) {
    if (socket.connected) {
      socket.emit("send_message", {
        'user_id': userId,
        'message': message
      });
    }
  }

  void leaveRoom() {
    if (socket.connected) {
      socket.emit("leave", {
        'userId': userId,
      });
    }
  }

  getHexagon(int q, int r) {
    print("getting hexagon q: $q r: $r");

    socket.emit(
      "get_hexagon",
      {
        'q': q,
        'r': r
      },
    );
  }

  addHexagon(data) {
    HexagonList hexagonList = HexagonList();
    Hexagon hexagon = Hexagon.fromJson(data);
    if (data.containsKey("wraparound")) {
      hexagon.setWrapQ(data["wraparound"]["q"]);
      hexagon.setWrapR(data["wraparound"]["r"]);
      if (hexagon.getWrapQ() != 0) {
        hexagon.hexQArray += (mapSize * 2 + 1) * hexagon.getWrapQ();
      }
      if (hexagon.getWrapR() != 0) {
        hexagon.hexRArray += (mapSize * 2 + 1) * hexagon.getWrapR();
      }
    }
    int tileQ = hexagonList.tileQ;
    int tileR = hexagonList.tileR;
    int index = 0;
    for (var tileData in data["tiles"]) {
      int tileDataQ = tileData["q"];
      int tileDataR = tileData["r"];
      if (data.containsKey("wraparound")) {
        if (hexagon.getWrapQ() != 0) {
          tileDataQ += (mapSize * 2 + 1) * 9 * hexagon.getWrapQ();
          tileDataR += (mapSize * 2 + 1) * -4 * hexagon.getWrapQ();
        }
        if (hexagon.getWrapR() != 0) {
          tileDataQ += (mapSize * 2 + 1) * 5 * hexagon.getWrapR();
          tileDataR += (mapSize * 2 + 1) * -9 * hexagon.getWrapR();
        }
      }
      GrassTile tile = GrassTile(
          tileDataQ,
          tileDataR,
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
      hexagonList.tiles[tileQ + tile.q - hexagonList.currentQ][tileR + tile.r - hexagonList.currentR] = tile;
    }

    hexagon.updateHexagon(0);
    int qHex = hexagonList.hexQ + hexagon.hexQArray - hexagonList.currentHexQ;
    int rHex = hexagonList.hexR + hexagon.hexRArray - hexagonList.currentHexR;
    if (qHex < 0 || qHex >= hexagonList.hexagons.length
        || rHex < 0 || rHex >= hexagonList.hexagons[0].length) {
      print("no longer in the screen");
      return;
    }
    hexagonList.hexagons[qHex][rHex] = hexagon;

    // check if the left hexagon is initialized and if it does not have it's right hexagon initialized
    int qHexLeft = qHex - 1;
    int rHexLeft = rHex;
    if (qHexLeft >= 0) {
      if (hexagonList.hexagons[qHexLeft][rHexLeft] != null
          && hexagonList.hexagons[qHexLeft][rHexLeft]!.right == null) {
        // If that is the case than set these two hexagons as neighbors
        hexagonList.hexagons[qHexLeft][rHexLeft]!.right = hexagon;
        hexagon.left = hexagonList.hexagons[qHexLeft][rHexLeft];
      }
    }
    // check if the right hexagon is initialized and if it does not have it's left hexagon initialized
    int qHexRight = qHex + 1;
    int rHexRight = rHex;
    if (qHexRight < hexagonList.hexagons.length) {
      if (hexagonList.hexagons[qHexRight][rHexRight] != null
          && hexagonList.hexagons[qHexRight][rHexRight]!.left == null) {
        hexagonList.hexagons[qHexRight][rHexRight]!.left = hexagon;
        hexagon.right = hexagonList.hexagons[qHexRight][rHexRight];
      }
    }
    // check if the top right hexagon is initialized and if it does not have it's bottom left hexagon initialized
    int qHexTopRight = qHex + 1;
    int rHexTopRight = rHex - 1;
    if (rHexTopRight >= 0 && qHexTopRight < hexagonList.hexagons.length) {
      if (hexagonList.hexagons[qHexTopRight][rHexTopRight] != null
          && hexagonList.hexagons[qHexTopRight][rHexTopRight]!.bottomLeft ==
              null) {
        // If that is the case than set these two hexagons as neighbors
        hexagonList.hexagons[qHexTopRight][rHexTopRight]!.bottomLeft = hexagon;
        hexagon.topRight = hexagonList.hexagons[qHexTopRight][rHexTopRight];
      }
    }
    // check if the bottom left hexagon is initialized and if it does not have it's top right hexagon initialized
    int qHexBottomLeft = qHex - 1;
    int rHexBottomLeft = rHex + 1;
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
    int qHexBottomRight = qHex;
    int rHexBottomRight = rHex - 1;
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
    int qHexTopLeft = qHex;
    int rHexTopLeft = rHex + 1;
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
