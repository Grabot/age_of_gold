import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:tuple/tuple.dart';
import '../component/hexagon.dart';
import '../component/tile.dart';
import '../constants/url_base.dart';
import '../util/hexagon_list.dart';
import '../util/util.dart';
import '../views/user_interface/ui_util/chat_messages.dart';
import '../views/user_interface/ui_util/selected_tile_info.dart';
import '../views/user_interface/ui_views/friend_window/friend_window_change_notifier.dart';
import '../views/user_interface/ui_views/guild_window/guild_information.dart';
import '../views/user_interface/ui_views/guild_window/guild_window_change_notifier.dart';
import '../views/user_interface/ui_views/profile_box/profile_change_notifier.dart';
import 'auth_service_world.dart';
import 'models/friend.dart';
import 'models/guild.dart';
import 'models/guild_member.dart';
import 'models/user.dart';
import 'settings.dart';


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

  enteredGuildRoom(int guildId) {
    joinGuildInformation(guildId);
  }

  leaveGuildRoom(int guildId) {
    leaveGuildInformation(guildId);
  }

  startSockConnection() {
    String socketUrl = baseUrlV1_0;
    socket = io.io(socketUrl, <String, dynamic>{
      'autoConnect': false,
      'path': "/socket.io",
      'transports': ['websocket'],
    });

    socket.onConnect((_) {
      socket.emit('message_event', 'Connected!');
    });

    socket.onDisconnect((_) {
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
    });
  }

  void checkMessageEvent(data) {
    if (data == "Avatar creation done!") {
      retrieveAvatar();
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
    });
    socket.on('send_hexagon_success', (data) {
      addHexagon(hexagonList, this, data);
    });
    socket.on('change_tile_type_success', (data) {
      changeTile(data);
      notifyListeners();
    });
    socket.on('guild_requested_to_join', (data) {
      guildRequestedToJoin(data["guild"]);
      notifyListeners();
    });
    socket.on('guild_request_denied', (data) {
      guildRequestDenied(data);
      notifyListeners();
    });
    socket.on('guild_accepted_member', (data) {
      guildAcceptedMember(data["guild"]);
      notifyListeners();
    });
  }

  guildRequestedToJoin(Map<String, dynamic> guildRequest) {
    User? currentUser = Settings().getUser();
    if (currentUser != null) {
      int guildId = guildRequest["guild_id"];
      String guildName = guildRequest["guild_name"];
      bool? accepted = guildRequest["accepted"];
      bool? requested = guildRequest["requested"];
      Guild guild = Guild(guildId, guildName, 0, null);
      guild.accepted = accepted;
      guild.requested = requested;
      guild.retrieved = false;
      currentUser.addGuildInvites(guild);
    }
  }

  guildRequestDenied(Map<String, dynamic> deniedRequest) {
    User? currentUser = Settings().getUser();
    if (currentUser != null) {
      int guildId = deniedRequest["guild_id"];
      Guild deniedGuild = Guild(guildId, "", 0, null);
      currentUser.guildInvites.removeWhere((element) => element.getGuildId() == deniedGuild.guildId);
      GuildInformation().guildsSendRequests.removeWhere((element) => element.guildId == deniedGuild.guildId);
      GuildInformation().guildsGotRequests.removeWhere((element) => element.guildId == deniedGuild.guildId);
      GuildInformation().notify();
    }
  }

  guildAcceptedMember(Map<String, dynamic> acceptedRequest) {
    User? currentUser = Settings().getUser();
    if (currentUser != null) {
      int guildId = acceptedRequest["guild_id"];
      String guildName = acceptedRequest["guild_name"];
      bool? accepted = acceptedRequest["accepted"];
      bool? requested = acceptedRequest["requested"];
      Guild guild = Guild(guildId, guildName, 0, null);
      guild.accepted = accepted;
      guild.requested = requested;
      guild.retrieved = false;
      currentUser.setGuild(guild);
    }
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
      receivedMessage(from, senderId, message, timestamp);
      notifyListeners();
    });
    socket.on('send_message_personal', (data) {
      String from = data["sender_name"];
      int senderId = data["sender_id"];
      String to = data["receiver_name"];
      String message = data["message"];
      String timestamp = data["timestamp"];
      receivedMessagePersonal(from, senderId, to, message, timestamp);
      notifyListeners();
    });
  }

  void receivedMessage(String from, int senderId, String message, String timestamp) {
    chatMessages.addMessage(from, senderId, message, timestamp);
  }

  void receivedMessageGuild(int? senderId, String? senderName, String message, String timestamp) {
    chatMessages.addGuildMessage(senderId, senderName, message, timestamp);
  }

  void receivedMessagePersonal(String from, int senderId, String to, String message, String timestamp) {
    chatMessages.addPersonalMessage(from, senderId, to, message, timestamp);
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
      Friend friend = Friend(id, false, false, 0, username);
      currentUser.addFriend(friend);
      showToastMessage("received a friend request from $username");
      FriendWindowChangeNotifier().notify();
    }
  }

  deniedFriendRequest(int friendId) {
    User? currentUser = Settings().getUser();
    if (currentUser != null) {
      currentUser.removeFriend(friendId);
      FriendWindowChangeNotifier().notify();
    }
  }

  acceptFriendRequest(Map<String, dynamic> from) {
    User? currentUser = Settings().getUser();
    if (currentUser != null) {
      User newFriend = User.fromJson(from);
      Friend friend = Friend(newFriend.getId(), true, false, 0, newFriend.getUserName());
      currentUser.addFriend(friend);
      showToastMessage("${newFriend.userName} accepted your friend request");
      FriendWindowChangeNotifier().notify();
    }
  }

  void leaveRoom(int userId) {
    if (socket.connected) {
      socket.emit("leave", {
        'user_id': userId,
      });
    }
  }

  joinGuildInformation(int guildId) {
    socket.emit(
      "join_guild",
      {
        'guild_id': guildId,
      },
    );
    socket.on('send_message_guild', (data) {
      int? senderId = data["sender_id"];
      String? senderName = data["sender_name"];
      String message = data["message"];
      String timestamp = data["timestamp"];
      receivedMessageGuild(senderId, senderName, message, timestamp);
      notifyListeners();
    });
    socket.on('guild_new_member', (data) {
      addNewGuildMember(data["member"]);
      notifyListeners();
    });
    socket.on('guild_request_cancelled', (data) {
      requestGuildCancelled(data["member_cancelled"]);
      notifyListeners();
    });
    socket.on('member_request_to_join', (data) {
      requestGuildToJoin(data["member_requested"]);
      notifyListeners();
    });
    socket.on('member_asked_to_join', (data) {
      memberAskedToJoinByGuild(data["member_asked"]);
      notifyListeners();
    });
    socket.on('guild_crest_changed', (data) {
      guildCrestChanged(data);
      notifyListeners();
    });
    socket.on('member_changed_rank', (data) {
      memberChangedRank(data["member_changed"]);
      notifyListeners();
    });
    socket.on('guild_member_removed', (data) {
      guildMemberRemoved(data["member_removed"]);
      notifyListeners();
    });
  }

  leaveGuildInformation(int guildId) {
    if (socket.connected) {
      socket.emit("leave_guild", {
        'guild_id': guildId,
      });
    }
  }

  addNewGuildMember(Map<String, dynamic> member) {
    User? currentUser = Settings().getUser();
    if (currentUser != null) {
      if (currentUser.getGuild() != null) {
        int userId = member["user_id"];
        int rank = member["rank"];
        GuildMember guildMember = GuildMember(userId, rank);
        guildMember.setGuildRank();
        // First check if it is already in the guild
        // (might be possible if the user had the window open when the response came in)
        if (!currentUser.getGuild()!.getMembers().contains((element) => element.getGuildMemberId() == userId)) {
          GuildInformation guildInformation = GuildInformation();
          // set details we already know from the other lists.
          User? maybeRequested = guildInformation.requestedMembers.where((element) => element.getId() == userId).firstOrNull;
          User? maybeAsked = guildInformation.askedMembers.where((element) => element.getId() == userId).firstOrNull;
          if (maybeRequested != null) {
            guildMember.setGuildMemberName(maybeRequested.getUserName());
            guildMember.setGuildMemberAvatar(maybeRequested.getAvatar());
          } else if (maybeAsked != null) {
            guildMember.setGuildMemberName(maybeAsked.getUserName());
            guildMember.setGuildMemberAvatar(maybeAsked.getAvatar());
          }
          addNewMemberGuildMessage(guildMember);
          currentUser.getGuild()!.addMember(guildMember);
          // remove from the other lists
          guildInformation.requestedMembers.removeWhere((element) => element.id == userId);
          guildInformation.askedMembers.removeWhere((element) => element.id == userId);
          guildInformation.notify();
          notifyListeners();
        }
      }
    }
  }

  addNewMemberGuildMessage(GuildMember newGuildMember) {
    String username = newGuildMember.getGuildMemberName();
    DateTime now = DateTime.now();
    String message = "$username joined the guild!";
    receivedMessageGuild(-1, "Server", message, now.toString());
  }

  requestGuildCancelled(Map<String, dynamic> memberCancelled) {
    User? currentUser = Settings().getUser();
    if (currentUser != null) {
      if (currentUser.getGuild() != null) {
        int userId = memberCancelled["user_id"];
        GuildInformation guildInformation = GuildInformation();
        guildInformation.requestedMembers.removeWhere((element) => element.id == userId);
        guildInformation.askedMembers.removeWhere((element) => element.id == userId);
        guildInformation.notify();
        ProfileChangeNotifier().notify();
      }
    }
  }

  requestGuildToJoin(Map<String, dynamic> memberRequested) {
    User? currentUser = Settings().getUser();
    if (currentUser != null) {
      if (currentUser.getGuild() != null) {
        int userId = memberRequested["user_id"];
        GuildInformation guildInformation = GuildInformation();
        guildInformation.addRequestedMember(User(userId, "", false, [], null));
        guildInformation.notify();
        ProfileChangeNotifier().notify();
      }
    }
  }

  memberAskedToJoinByGuild(Map<String, dynamic> memberAsked) {
    User? currentUser = Settings().getUser();
    if (currentUser != null) {
      if (currentUser.getGuild() != null) {
        int userId = memberAsked["user_id"];
        GuildInformation guildInformation = GuildInformation();
        guildInformation.addAskedMember(User(userId, "", false, [], null));
        guildInformation.notify();
      }
    }
  }

  guildCrestChanged(Map<String, dynamic> crestChanged) {
    User? currentUser = Settings().getUser();
    if (currentUser != null) {
      if (currentUser.getGuild() != null) {
        if (crestChanged["guild_avatar"] == null) {
          currentUser.getGuild()!.setGuildCrest(null);
        } else {
          currentUser.getGuild()!.setGuildCrest(
              base64Decode(crestChanged["guild_avatar"].replaceAll("\n", "")));
        }
        DateTime now = DateTime.now();
        String message = "The guild crest has been changed!";
        receivedMessageGuild(-1, "Server", message, now.toString());
        GuildInformation().notify();
      }
    }
  }

  memberChangedRank(Map<String, dynamic> memberChanged) {
    User? currentUser = Settings().getUser();
    if (currentUser != null) {
      if (currentUser.getGuild() != null) {
        int guildMemberId = memberChanged["user_id"];
        int guildMemberRank = memberChanged["new_rank"];
        GuildMember changedGuildMember = GuildMember(guildMemberId, guildMemberRank);
        String? oldRank;
        GuildMember? currentRankMember = currentUser.getGuild()!.getMembers().where((element) => element.getGuildMemberId() == guildMemberId).firstOrNull;
        if (currentRankMember != null) {
          oldRank = currentRankMember.getGuildMemberRankName();
        }
        currentUser.getGuild()!.changeMemberRank(changedGuildMember);
        GuildInformation guildInformation = GuildInformation();
        memberChangedRankGuildMessage(currentUser.getGuild()!.getMembers(), guildInformation, guildMemberId, oldRank);
        // Check if the changed member is me
        if (currentUser.getId() == guildMemberId) {
          currentUser.setMyGuildRank();
        }
        guildInformation.notify();
      }
    }
  }

  memberChangedRankGuildMessage(List<GuildMember> guildMembers, GuildInformation guildInformation, int userId, String? oldRank) {
    // rank is already changed, so retrieve the member and get the new rank
    GuildMember? member = guildMembers.where((element) => element.getGuildMemberId() == userId).firstOrNull;
    String username = "";
    if (member != null) {
      username = member.getGuildMemberName();
    } else {
      return;
    }

    DateTime now = DateTime.now();
    String message = "$username changed his rank to ${member.getGuildMemberRankName()}!";
    if (oldRank != null) {
      message = "The rank of $username changed from $oldRank to ${member.getGuildMemberRankName()}!";
    }
    receivedMessageGuild(-1, "Server", message, now.toString());
  }

  guildMemberRemoved(Map<String, dynamic> memberRemoved) {
    User? currentUser = Settings().getUser();
    if (currentUser != null) {
      if (currentUser.getGuild() != null) {
        int userId = memberRemoved["user_id"];
        // only the id is needed for removal
        GuildMember changedGuildMember = GuildMember(userId, 3);
        GuildInformation guildInformation = GuildInformation();
        memberRemovedGuildMessage(currentUser.getGuild()!.getMembers(), guildInformation, userId);
        currentUser.getGuild()!.removeMember(changedGuildMember);
        // Check if the changed member is me
        if (currentUser.getId() == userId) {
          GuildWindowChangeNotifier().setGuildWindowVisible(false);
          leaveGuildRoom(currentUser.getGuild()!.getGuildId());
          currentUser.setGuild(null);
        }
        guildInformation.notify();
      }
    }
  }

  memberRemovedGuildMessage(List<GuildMember> guildMembers, GuildInformation guildInformation, int userId) {
    GuildMember? member = guildMembers.where((element) => element.getGuildMemberId() == userId).firstOrNull;
    String username = "";
    if (member != null) {
      username = member.getGuildMemberName();
    } else {
      return;
    }

    DateTime now = DateTime.now();
    String message = "$username is no longer part of the guild.";
    receivedMessageGuild(-1, "Server", message, now.toString());
  }

  getHexagon(int q, int r) {
    // Here we want to get the hexagon from the hexagonList
    // But we don't actually get the hexagons, we just fill the array with empty Hexagon objects
    // When it is needed we will retrieve the hexagons from the server with the actuallyGetHexagons function.
    // I apologize for the bad naming conventions, might change it later. (TODO?)
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
    // When we need to actually get the hexagons we first check if it maybe has done that already
    // We have 2 flags, the `setToRetrieve` flag and the `retrieved` flag.
    // We set the `setToRetrieve` flag to true because we want to retrieve the hexagon.
    hexRetrieve.setToRetrieve = true;

    Tuple2 retrieve = Tuple2(hexRetrieve.q, hexRetrieve.r);
    if (!hexRetrievals.contains(retrieve)) {
      hexRetrievals.add(retrieve);
    }

    // We will gather the hexagons and the `gatherHexagons` flag will be false at first
    // We immediately set it to true and after 500ms we will actually get the hexagons
    // This gives the code the time to gather all the hexagons that need to be retrieved
    if (!gatherHexagons) {
      Future.delayed(const Duration(milliseconds: 500), () {
        gatherHexagons = false;
        actuallyActuallyGetHexagons();
      });
      gatherHexagons = true;
    }
  }

  actuallyActuallyGetHexagons() {
    // Finally when we have checked which hexagons we want to retrieve
    // and which hexagons we should retrieve
    // and have done so for every hexagons and gathered them all.
    // we will actually get the hexagons from the server.
    AuthServiceWorld().retrieveHexagons(hexagonList, this, hexRetrievals).then((value) {
      if (value != "success") {
        // put the hexagons back to be retrieved
        hexagonList.setBackToRetrieve();
      }
    }).onError((error, stackTrace) {
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
      currentTile.hexagon!.updateHexagon(Settings().getRotation());

      addTileInfo(data, currentTile);
    }
  }

  List<Tuple2> getWrapCoordinates() {
    return wrapCoordinates;
  }

  addWrapCoordinates(Tuple2 wrapCoordinate) {
    wrapCoordinates.add(wrapCoordinate);
  }

}
