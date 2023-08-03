import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:age_of_gold/services/auth_service_social.dart';
import 'package:age_of_gold/services/models/guild_member.dart';
import 'package:age_of_gold/services/models/user.dart';
import 'package:age_of_gold/services/settings.dart';
import 'package:age_of_gold/util/util.dart';
import 'package:age_of_gold/views/user_interface/ui_util/chat_messages.dart';
import 'package:age_of_gold/views/user_interface/ui_util/selected_tile_info.dart';
import 'package:age_of_gold/views/user_interface/ui_views/guild_window/guild_information.dart';
import 'package:age_of_gold/views/user_interface/ui_views/profile_box/profile_change_notifier.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../component/hexagon.dart';
import '../component/tile.dart';
import '../constants/url_base.dart';
import '../util/hexagon_list.dart';
import 'package:tuple/tuple.dart';
import 'auth_service_world.dart';
import 'models/friend.dart';


class SocketServices extends ChangeNotifier {
  late io.Socket socket;

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

  login(int userId) {
    joinRoom(userId);
  }

  logout(int userId) {
    leaveRoom(userId);
  }

  enteredGuild(int guildId) {
    joinGuildInformation(guildId);
  }

  startSockConnection() {
    String socketUrl = baseUrlV1_0;
    socket = io.io(socketUrl, <String, dynamic>{
      'autoConnect': false,
      'path': "/socket.io",
      'transports': ['websocket'],
    });

    socket.onConnect((_) {
      print("on connect");
      socket.emit('message_event', 'Connected!');
    });

    socket.onDisconnect((_) {
      print("on disconnect");
      socket.emit('message_event', 'Disconnected!');
    });

    socket.on('message_event', (data) {
      checkMessageEvent(data);
    });

    socket.open();
  }

  retrieveAvatar() {
    AuthServiceWorld().getAvatarUser().then((value) {
      if (value != null) {
        Uint8List avatar = base64Decode(value.replaceAll("\n", ""));
        Settings().setAvatar(avatar);
        if (Settings().getUser() != null) {
          Settings().getUser()!.setAvatar(avatar);
        }
        ProfileChangeNotifier().notify();
      }
    }).onError((error, stackTrace) {
      // TODO: What to do on an error? Reset?
      print("error: $error");
    });
  }

  void checkMessageEvent(data) {
    if (data == "Avatar creation done!") {
      retrieveAvatar();
    } else {
      // print("message_event: $data");
    }
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

  void joinRoom(int userId) {
    if (userId != -1) {
      socket.emit(
        "join",
        {
          'user_id': userId,
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

  bool joinedChatRooms = false;
  void checkMessages(ChatMessages chatMessages) {
    if (joinedChatRooms) {
      return;
    }
    joinedChatRooms = true;
    this.chatMessages = chatMessages;
    socket.on('send_message_global', (data) {
      String from = data["sender_name"];
      int senderId = data["sender_id"];
      String message = data["body"];
      String timestamp = data["timestamp"];
      receivedMessage(from, senderId, message, timestamp, 0);
      notifyListeners();
    });
    socket.on('send_message_local', (data) {
      String from = data["user_name"];
      String message = data["message"];
      String tileQ = data["tile_q"];
      String tileR = data["tile_r"];
      String timestamp = data["timestamp"];
      receivedMessageLocal(from, message, timestamp, 1, tileQ, tileR);
      notifyListeners();
    });
    socket.on('send_message_guild', (data) {
      String from = data["user_name"];
      int senderId = data["sender_id"];
      String message = data["message"];
      String timestamp = data["timestamp"];
      receivedMessage(from, senderId, message, timestamp, 2);
      notifyListeners();
    });
    socket.on('send_message_personal', (data) {
      print("received a personal message! :D");
      String from = data["sender_name"];
      int senderId = data["sender_id"];
      String to = data["receiver_name"];
      String message = data["message"];
      String timestamp = data["timestamp"];
      receivedMessagePersonal(from, senderId, to, message, timestamp);
      notifyListeners();
    });
  }

  void receivedMessage(String from, int senderId, String message, String timestamp, int regionType) {
    print("received message $senderId");
    chatMessages.addMessage(from, senderId, message, regionType, timestamp);
  }

  void receivedMessagePersonal(String from, int senderId, String to, String message, String timestamp) {
    chatMessages.addPersonalMessage(from, senderId, to, message, timestamp);
  }

  void receivedMessageLocal(String from, String message, String timestamp, int regionType, String tileQ, String tileR) {
    String localMessage = "from tile($tileQ, $tileR): $message";
    chatMessages.addMessage(from, -1, localMessage, regionType, timestamp);
  }

  bool joinedFriendRooms = false;
  checkFriends() {
    if (joinedFriendRooms) {
      return;
    }
    joinedFriendRooms = true;
    socket.on('received_friend_request', (data) {
      Map<String, dynamic> from = data["from"];
      receivedFriendRequest(from);
      notifyListeners();
    });
    socket.on('denied_friend', (data) {
      int friendId = data["friend_id"];
      deniedFriendRequest(friendId);
      notifyListeners();
    });
    socket.on('accept_friend_request', (data) {
      print("accept friend request $data");
      Map<String, dynamic> from = data["from"];
      acceptFriendRequest(from);
      notifyListeners();
    });
  }

  receivedFriendRequest(Map<String, dynamic> from) {
    User? currentUser = Settings().getUser();
    if (currentUser != null) {
      int id = from["id"];
      String username = from["username"];
      Friend friend = Friend(false, false, 0, username);
      friend.setFriendId(id);
      String avatarFriend = from["avatar"];
      friend.retrievedAvatar = true;
      friend.setFriendAvatar(base64Decode(avatarFriend.replaceAll("\n", "")));
      currentUser.addFriend(friend);
      showToastMessage("received a friend request from $username");
    }
  }

  deniedFriendRequest(int friendId) {
    User? currentUser = Settings().getUser();
    if (currentUser != null) {
      currentUser.removeFriend(friendId);
    }
  }

  acceptFriendRequest(Map<String, dynamic> from) {
    User? currentUser = Settings().getUser();
    if (currentUser != null) {
      User newFriend = User.fromJson(from);
      Friend friend = Friend(false, false, newFriend.id, newFriend.getUserName());
      String avatarFriend = from["avatar"];
      friend.retrievedAvatar = true;
      friend.setFriendAvatar(base64Decode(avatarFriend.replaceAll("\n", "")));
      currentUser.addFriend(friend);
      showToastMessage("${newFriend.userName} accepted your friend request");
    }
  }

  void leaveRoom(int userId) {
    if (socket.connected) {
      socket.emit("leave", {
        'user_id': userId,
      });
    }
  }

  void joinGuildInformation(int guildId) {
    socket.emit(
      "join_guild",
      {
        'guild_id': guildId,
      },
    );
    socket.on('guild_new_member', (data) {
      print("newGuildMember $data");
      addNewGuildMember(data["member"]);
      notifyListeners();
    });
  }

  addNewGuildMember(Map<String, dynamic> member) {
    int userId = member["user_id"];
    int rank = member["rank"];
    GuildMember guildMember = GuildMember(userId, rank);
    guildMember.setGuildRank();
    User? currentUser = Settings().getUser();
    if (currentUser != null) {
      if (currentUser.getGuild() != null) {
        // First check if it is already in the guild
        // (might be possible if the user had the window open when the response came in)
        if (!currentUser.getGuild()!.getMembers().contains((element) => element.getGuildMemberId() == userId)) {
          currentUser.getGuild()!.addMember(guildMember);
          // currentUser.getGuild()!.removeGuildInvite(User(userId, "", false, [], null));
          GuildInformation guildInformation = GuildInformation();
          guildInformation.requestedMembers.removeWhere((element) => element.id == userId);
          guildInformation.askedMembers.removeWhere((element) => element.id == userId);
          guildInformation.notify();
          notifyListeners();
        }
      }
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
      User user = User.fromJson(data["last_changed_by"]);
      String nameLastChanged = user.getUserName();
      String lastChanged = data["last_changed_time"];
      if (!lastChanged.endsWith("Z")) {
        // The server has utc timestamp, but it's not formatted with the 'Z'.
        lastChanged += "Z";
      }

      SelectedTileInfo selectedTileInfo = SelectedTileInfo();
      selectedTileInfo.setLastChangedBy(nameLastChanged);
      selectedTileInfo.setLastChangedTime(DateTime.parse(lastChanged).toLocal());

      String newColour = getTileColour(prevTile.getTileType());
      String tileEvent = "tile(${prevTile.q}, ${prevTile.r}) changed to the colour: $newColour";
      chatMessages.addEventMessage(tileEvent, nameLastChanged);
    }
  }

  changeTile(data) {
    int newTileType = data["type"];

    Tile? currentTile = getTile(hexagonList, wrapCoordinates, data);
    if (currentTile != null) {
      currentTile.setTileType(newTileType);
      currentTile.hexagon!.updateHexagon();

      addTileInfo(data, currentTile);
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

}
