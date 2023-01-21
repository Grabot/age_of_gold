import 'dart:convert';
import 'package:age_of_gold/services/models/user.dart';
import 'package:age_of_gold/services/settings.dart';
import 'package:age_of_gold/constants/global.dart';
import 'package:age_of_gold/util/util.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../component/hexagon.dart';
import '../component/tile.dart';
import '../constants/url_base.dart';
import '../user_interface/user_interface_components/chat_messages.dart';
import '../util/hexagon_list.dart';
import 'package:tuple/tuple.dart';


class SocketServices extends ChangeNotifier {
  late io.Socket socket;

  // We will use this to store the user's id, might change it later.
  int userId = -1;
  String userName = "Not logged in";

  static final SocketServices _instance = SocketServices._internal();

  HexagonList hexagonList = HexagonList();
  late ChatMessages chatMessages;

  List<Tuple2> wrapCoordinates = [];
  SocketServices._internal() {
    startSockConnection();
  }

  factory SocketServices() {
    return _instance;
  }

  void setUser(User user) {
    userId = user.id;
    userName = user.getUserName();
    notifyListeners();
  }

  startSockConnection() {
    String namespace = "sock";
    String socketUrl = baseUrlV1_1 + namespace;
    socket = io.io(socketUrl, <String, dynamic>{
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
      // print("message_event: $data");
    });

    socket.open();
  }

  void joinHexRoom(Hexagon hex) {
    socket.emit(
      "join_hex",
      {
        'q': hex.q,
        'r': hex.r,
      },
    );
  }

  void leaveHexRoom(Hexagon hex) {
    socket.emit(
      "leave_hex",
      {
        'q': hex.q,
        'r': hex.r,
      },
    );
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
      showToastMessage("hexagon getting failed!");
      // print(data);
    });
    socket.on('send_hexagon_success', (data) {
      addHexagon(data);
    });
  }

  void checkMessages(ChatMessages chatMessages) {
    this.chatMessages = chatMessages;
    socket.on('send_message_success', (data) {
      receivedMessage(data["user_name"], data["message"]);
      notifyListeners();
    });
  }

  void checkTile() {
    socket.on('change_tile_type_success', (data) {
      changeTile(data);
      notifyListeners();
    });
    socket.on('change_tile_type_failed', (data) {
      showToastMessage("changing tile type failed!");
      notifyListeners();
    });
    socket.on('get_tile_info_success', (data) {
      updateTileInfo(data);
      notifyListeners();
    });
    socket.on('get_tile_info_failed', (data) {
      showToastMessage("get more tile information failed?!");
      notifyListeners();
    });
  }

  getTileInfo(int q, int r) {
    socket.emit(
      "get_tile_info",
      {
        'q': q,
        'r': r,
      },
    );
  }

  void changeTileType(int q, int r, int tileType) {
    // The q and r will correspond to the correct tile,
    // we send the wrap variables of the hexagon too in case
    // the user is currently wrapped around the map
    print("user id: $userId");
    socket.emit("change_tile_type", {
      "id": userId,
      "q": q,
      "r": r,
      "type": tileType
    });
  }

  void receivedMessage(String userName, String message) {
    chatMessages.addMessage(userName, message);
  }

  void sendMessage(String message) {
    if (socket.connected) {
      socket.emit("send_message", {
        'user_name': userName,
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
    int qHex = hexagonList.hexQ + q - hexagonList.currentHexQ;
    int rHex = hexagonList.hexR + r - hexagonList.currentHexR;

    if (qHex < 0 || qHex >= hexagonList.hexagons.length
        || rHex < 0 || rHex >= hexagonList.hexagons[0].length) {
      return;
    }

    if (hexagonList.hexagons[qHex][rHex] == null) {
      hexagonList.hexagons[qHex][rHex] = Hexagon(q, r);
    }
  }

  actuallyGetHexagons(Hexagon hexRetrieve) {
    // setToRetrieve and retrieve are both false if it gets here.
    hexRetrieve.setToRetrieve = true;

    socket.emit(
      "get_hexagon",
      {
        'q': hexRetrieve.hexQArray,
        'r': hexRetrieve.hexRArray
      },
    );
  }

  addHexagon(data) {
    Hexagon hexagon = Hexagon.fromJson(data);
    int tileQ = hexagonList.tileQ;
    int tileR = hexagonList.tileR;
    for (var tileData in jsonDecode(data["tiles"])) {
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

        Tuple2 coordinates = Tuple2<int, int>(hexagon.getWrapQ(), hexagon.getWrapR());
        if (!wrapCoordinates.contains(coordinates)) {
          wrapCoordinates.add(coordinates);
        }
      }
      // If the type is 0
      Tile tile = createTile(tileData["type"], tileDataQ, tileDataR, tileData);
      tile.hexagon = hexagon;
      hexagon.addTile(tile);
      int qTile = tileQ + tile.q - hexagonList.currentQ;
      int rTile = tileR + tile.r - hexagonList.currentR;
      if (qTile >= 0 && qTile < hexagonList.tiles.length &&
            rTile >= 0 && rTile < hexagonList.tiles[0].length) {
        hexagonList.tiles[qTile][rTile] = tile;
      }
    }

    hexagon.updateHexagon();
    int qHex = hexagonList.hexQ + hexagon.hexQArray - hexagonList.currentHexQ;
    int rHex = hexagonList.hexR + hexagon.hexRArray - hexagonList.currentHexR;
    if (qHex < 0 || qHex >= hexagonList.hexagons.length
        || rHex < 0 || rHex >= hexagonList.hexagons[0].length) {
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

  Tile? getTile(data) {
    // We just need the q and r to find the tile and change type on the old tile
    int newTileQ = data["q"];
    int newTileR = data["r"];

    int tileQ = hexagonList.tileQ;
    int tileR = hexagonList.tileR;
    int qArray = tileQ + newTileQ - hexagonList.currentQ;
    int rArray = tileR + newTileR - hexagonList.currentR;

    // return hexagonList.tiles[qArray][rArray];
    if (qArray >= 0 &&
        qArray <= hexagonList.tiles.length &&
        rArray >= 0 &&
        rArray <= hexagonList.tiles[0].length) {
      Tile? test = hexagonList.tiles[qArray][rArray];
      return test;
    } else {
      return getTileWrap(hexagonList, qArray, rArray, newTileQ, newTileR, wrapCoordinates);
    }
  }

  updateTileInfo(data) {
    Tile? currentTile = getTile(data);
    if (currentTile != null) {
      addTileInfo(data, currentTile);
    }
  }

  addTileInfo(data, Tile prevTile) {
    if (data["last_changed_by"] != null && data["last_changed_time"] != null) {
      print("data: " + data.toString());
      User user = User.fromJson(data["last_changed_by"]);
      String nameLastChanged = user.getUserName();
      String lastChanged = data["last_changed_time"];
      if (!lastChanged.endsWith("Z")) {
        // The server has utc timestamp, but it's not formatted with the 'Z'.
        lastChanged += "Z";
      }
      prevTile.setLastChangedBy(nameLastChanged);
      prevTile.setLastChangedTime(DateTime.parse(lastChanged).toLocal());
      Settings().setUser(user);
    }
  }

  changeTile(data) {
    int newTileType = data["type"];

    Tile? currentTile = getTile(data);
    if (currentTile != null) {
      currentTile.setTileType(newTileType);
      currentTile.hexagon!.updateHexagon();

      addTileInfo(data, currentTile);
    }
  }

  Tile createTile(int tileType, int tileDataQ, int tileDataR, var tileData) {
    return Tile(
        tileDataQ,
        tileDataR,
        tileData["type"],
        tileData["q"],
        tileData["r"]
    );
  }

  String getUserName() {
    return userName;
  }
}
