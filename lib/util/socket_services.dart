import 'dart:convert';
import 'package:age_of_gold/component/type/tile_amethyst.dart';
import 'package:age_of_gold/util/global.dart';
import 'package:age_of_gold/util/util.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../component/hexagon.dart';
import '../component/tile.dart';
import '../component/type/tile_black.dart';
import '../component/type/tile_bondi_blue.dart';
import '../component/type/tile_bright_sun.dart';
import '../component/type/tile_caribbean_green.dart';
import '../component/type/tile_cerulean_blue.dart';
import '../component/type/tile_cornflower_blue.dart';
import '../component/type/tile_conifer.dart';
import '../component/type/tile_governor_bay.dart';
import '../component/type/tile_green_haze.dart';
import '../component/type/tile_iron.dart';
import '../component/type/tile_monza.dart';
import '../component/type/tile_oslo_gray.dart';
import '../component/type/tile_paarl.dart';
import '../component/type/tile_picton_blue.dart';
import '../component/type/tile_pine_green.dart';
import '../component/type/tile_pink_salmon.dart';
import '../component/type/tile_seance.dart';
import '../component/type/tile_spice.dart';
import '../component/type/tile_spray.dart';
import '../component/type/tile_vermillion.dart';
import '../component/type/tile_web_orange.dart';
import '../component/type/tile_white.dart';
import '../component/type/tile_wild_strawberry.dart';
import '../constants/url_base.dart';
import '../user_interface/chat_messages.dart';
import 'hexagon_list.dart';


class SocketServices extends ChangeNotifier {
  late IO.Socket socket;

  // We will use this to store the user's id, might change it later.
  int userId = -1;
  String userName = "";

  static final SocketServices _instance = SocketServices._internal();

  SocketServices._internal() {
    startSockConnection();
  }

  factory SocketServices() {
    return _instance;
  }

  void setUser(int id, String name) {
    userId = id;
    userName = name;
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

  void joinHexRoom(int q, int r) {
    socket.emit(
      "join_hex",
      {
        'q': q,
        'r': r,
      },
    );
  }

  void leaveHexRoom(int q, int r) {
    socket.emit(
      "leave_hex",
      {
        'q': q,
        'r': r,
      },
    );
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
      receivedMessage(data["user_name"], data["message"]);
      notifyListeners();
    });
  }

  void checkTile() {
    socket.on('change_tile_type_success', (data) {
      print("tile type changed successfully");
      changeTile(data);
    });
    socket.on('change_tile_type_failed', (data) {
      print("tile type changed failed");
      print(data);
      notifyListeners();
    });
  }

  void changeTileType(int q, int r, int tileType, int wrapQ, int wrapR) {
    // The q and r will correspond to the correct tile,
    // we send the wrap variables of the hexagon too in case
    // the user is currently wrapped around the map
    socket.emit("change_tile_type", {
      "q": q,
      "r": r,
      "type": tileType,
      "wrap_q": wrapQ,
      "wrap_r": wrapR
    });
  }

  void receivedMessage(String userName, String message) {
    print("received message $userName, message: $message");
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
    joinHexRoom(q, r);

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
    hexagon.setPosition();
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
      }
      // If the type is 0
      Tile tile = setTileType(tileData["type"], tileDataQ, tileDataR, tileData);
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

  changeTile(data) {
    HexagonList hexagonList = HexagonList();
    // We just need the q and r to find the tile and change type on the old tile
    int newTileQ = data["q"];
    int newTileR = data["r"];
    int newTileType = data["type"];

    int tileQ = hexagonList.tileQ;
    int tileR = hexagonList.tileR;
    Tile? prevTile = hexagonList.tiles[tileQ + newTileQ - hexagonList.currentQ]
        [tileR + newTileR - hexagonList.currentR];
    if (prevTile != null) {
      // It has to exist before we replace it.
      Hexagon currentHex = prevTile.hexagon!;
      currentHex.hexagonTiles.removeWhere(
              (element) => element.q == data["q"] && element.r == data["r"]);

      Tile newTile = setTileType(newTileType, data["q"], data["r"], data);
      newTile.hexagon = currentHex;
      currentHex.addTile(newTile);
      newTile.hexagon!.updateHexagon(0);
      newTile.hexagon!.sortTiles();
    }
  }

  Tile setTileType(int tileType, int tileDataQ, int tileDataR, var tileData) {
    if (tileType == 1) {
      return TileBlack(
          tileDataQ,
          tileDataR,
          tileData["type"],
          tileData["q"],
          tileData["r"]
      );
    } else if (tileType == 2) {
      return TileBondiBlue(
          tileDataQ,
          tileDataR,
          tileData["type"],
          tileData["q"],
          tileData["r"]
      );
    } else if (tileType == 3) {
      return TileBrightSun(
          tileDataQ,
          tileDataR,
          tileData["type"],
          tileData["q"],
          tileData["r"]
      );
    } else if (tileType == 4) {
      return TileCaribbeanGreen(
          tileDataQ,
          tileDataR,
          tileData["type"],
          tileData["q"],
          tileData["r"]
      );
    } else if (tileType == 5) {
      return TileCeruleanBlue(
          tileDataQ,
          tileDataR,
          tileData["type"],
          tileData["q"],
          tileData["r"]
      );
    } else if (tileType == 6) {
      return TileConifer(
          tileDataQ,
          tileDataR,
          tileData["type"],
          tileData["q"],
          tileData["r"]
      );
    } else if (tileType == 7) {
      return TileCornflowerBlue(
          tileDataQ,
          tileDataR,
          tileData["type"],
          tileData["q"],
          tileData["r"]
      );
    } else if (tileType == 8) {
      return TileGovernorBay(
          tileDataQ,
          tileDataR,
          tileData["type"],
          tileData["q"],
          tileData["r"]
      );
    } else if (tileType == 9) {
      return TileGreenHaze(
          tileDataQ,
          tileDataR,
          tileData["type"],
          tileData["q"],
          tileData["r"]
      );
    } else if (tileType == 10) {
      return TileIron(
          tileDataQ,
          tileDataR,
          tileData["type"],
          tileData["q"],
          tileData["r"]
      );
    } else if (tileType == 11) {
      return TileMonza(
          tileDataQ,
          tileDataR,
          tileData["type"],
          tileData["q"],
          tileData["r"]
      );
    } else if (tileType == 12) {
      return TileOsloGray(
          tileDataQ,
          tileDataR,
          tileData["type"],
          tileData["q"],
          tileData["r"]
      );
    } else if (tileType == 13) {
      return TilePaarl(
          tileDataQ,
          tileDataR,
          tileData["type"],
          tileData["q"],
          tileData["r"]
      );
    } else if (tileType == 14) {
      return TilePictonBlue(
          tileDataQ,
          tileDataR,
          tileData["type"],
          tileData["q"],
          tileData["r"]
      );
    } else if (tileType == 15) {
      return TilePineGreen(
          tileDataQ,
          tileDataR,
          tileData["type"],
          tileData["q"],
          tileData["r"]
      );
    } else if (tileType == 16) {
      return TilePinkSalmon(
          tileDataQ,
          tileDataR,
          tileData["type"],
          tileData["q"],
          tileData["r"]
      );
    } else if (tileType == 17) {
      return TileSeance(
          tileDataQ,
          tileDataR,
          tileData["type"],
          tileData["q"],
          tileData["r"]
      );
    } else if (tileType == 18) {
      return TileSpice(
          tileDataQ,
          tileDataR,
          tileData["type"],
          tileData["q"],
          tileData["r"]
      );
    } else if (tileType == 19) {
      return TileSpray(
          tileDataQ,
          tileDataR,
          tileData["type"],
          tileData["q"],
          tileData["r"]
      );
    } else if (tileType == 20) {
      return TileVermillion(
          tileDataQ,
          tileDataR,
          tileData["type"],
          tileData["q"],
          tileData["r"]
      );
    } else if (tileType == 21) {
      return TileWebOrange(
          tileDataQ,
          tileDataR,
          tileData["type"],
          tileData["q"],
          tileData["r"]
      );
    } else if (tileType == 22) {
      return TileWhite(
          tileDataQ,
          tileDataR,
          tileData["type"],
          tileData["q"],
          tileData["r"]
      );
    } else if (tileType == 23) {
      return TileWildStrawberry(
          tileDataQ,
          tileDataR,
          tileData["type"],
          tileData["q"],
          tileData["r"]
      );
    } else {
      return TileAmethyst(
          tileDataQ,
          tileDataR,
          tileData["type"],
          tileData["q"],
          tileData["r"]
      );
    }
  }
}
