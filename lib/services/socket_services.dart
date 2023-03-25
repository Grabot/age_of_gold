import 'dart:async';
import 'package:age_of_gold/services/models/user.dart';
import 'package:age_of_gold/util/util.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../component/hexagon.dart';
import '../component/tile.dart';
import '../constants/url_base.dart';
import '../user_interface/user_interface_components/chat_messages.dart';
import '../util/hexagon_list.dart';
import 'package:tuple/tuple.dart';

import 'auth_service_world.dart';


class SocketServices extends ChangeNotifier {
  late io.Socket socket;

  // We will use this to store the user's id, might change it later.
  int userId = -1;
  String userName = "Not logged in";

  static final SocketServices _instance = SocketServices._internal();

  HexagonList hexagonList = HexagonList();
  late ChatMessages chatMessages;

  List<Tuple2> wrapCoordinates = [];

  bool gatherHexagons = false;
  List<Tuple2> hexRetrievals = [];
  List<Tuple2> currentHexRooms = [];

  SocketServices._internal() {
    startSockConnection();
  }

  factory SocketServices() {
    return _instance;
  }

  logout() {
    userId = -1;
    userName ="Not logged in";
  }

  void setUser(User user) {
    userId = user.id;
    userName = user.getUserName();
    notifyListeners();
  }

  startSockConnection() {
    String namespace = "sock";
    String socketUrl = baseUrlV1_0 + namespace;
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
    int q = hex.q;
    int r = hex.r;
    Tuple2 hexJoin = Tuple2(q, r);
    if (!currentHexRooms.contains(hexJoin)) {
      currentHexRooms.add(hexJoin);

      emitHexJoin(q, r);
    }
  }

  emitHexJoin(int q, int r) {
    // print("joining hex q: $q r:$r");
    socket.emit(
      "join_hex",
      {
        'q': q,
        'r': r,
      },
    );
  }

  void leaveHexRoom(Hexagon hex) {
    int q = hex.q;
    int r = hex.r;
    Tuple2 hexLeave = Tuple2(q, r);
    if (currentHexRooms.contains(hexLeave)) {
      currentHexRooms.remove(hexLeave);

      emitHexLeave(q, r);
    }
  }

  emitHexLeave(int q, int r) {
    // print("leaving hex q: ${q} r:${r}");
    socket.emit(
      "leave_hex",
      {
        'q': q,
        'r': r,
      },
    );
  }

  void joinRoom() {
    if (userId != -1) {
      socket.emit(
        "join",
        {
          'userId': userId,
        },
      );
    }
    // After we have joined the room, we also want to listen to server events
    socket.on('send_hexagon_fail', (data) {
      showToastMessage("hexagon getting failed!");
      // print(data);
    });
    socket.on('send_hexagon_success', (data) {
      addHexagon(hexagonList, this, data);
    });
    socket.on('change_tile_type_success', (data) {
      changeTile(data);
      notifyListeners();
    });
  }

  void checkMessages(ChatMessages chatMessages) {
    this.chatMessages = chatMessages;
    socket.on('send_message_success', (data) {
      String from = data["user_name"];
      String message = data["message"];
      int regionType = int.parse(data["region_type"]);
      receivedMessage(from, message, regionType);
      notifyListeners();
    });
  }

  void receivedMessage(String from, String message, int regionType) {
    chatMessages.addMessage(from, message, regionType);
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

    Tuple2 retrieve = Tuple2(hexRetrieve.q, hexRetrieve.r);
    if (!hexRetrievals.contains(retrieve)) {
      hexRetrievals.add(retrieve);
    }

    if (!gatherHexagons) {
      Future.delayed(const Duration(milliseconds: 500), () {
        gatherHexagons = false;
        actuallyActuallyGetHexagons();
      });
      gatherHexagons = true;
    }
  }

  actuallyActuallyGetHexagons() {
    AuthServiceWorld().retrieveHexagons(hexagonList, this, hexRetrievals).then((value) {
      if (value != "success") {
        // put the hexagons back to be retrieved
        hexagonList.setBackToRetrieve();
      } else {
        print("success getting hexes!");
      }
    }).onError((error, stackTrace) {
      // TODO: What to do on an error? Reset?
      print("error: $error");
      // put the hexagons back to be retrieved
      hexagonList.setBackToRetrieve();
    });

    hexRetrievals = [];
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
    }
  }

  changeTile(data) {
    int newTileType = data["type"];

    Tile? currentTile = getTile(hexagonList, wrapCoordinates, data);
    if (currentTile != null) {
      String oldColour = getTileColour(currentTile.getTileType());
      currentTile.setTileType(newTileType);
      currentTile.hexagon!.updateHexagon();

      addTileInfo(data, currentTile);
      String newColour = getTileColour(currentTile.getTileType());
      String tileEvent = "tile q: ${currentTile.q} r: ${currentTile.r} changed from the colour: $oldColour to $newColour";
      chatMessages.addEventMessage(tileEvent);
    }
  }

  List<Tuple2> getWrapCoordinates() {
    return wrapCoordinates;
  }

  addWrapCoordinates(Tuple2 wrapCoordinate) {
    wrapCoordinates.add(wrapCoordinate);
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
