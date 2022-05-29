import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../constants/base_url.dart';


class SocketServices extends ChangeNotifier {
  late IO.Socket socket;

  static final SocketServices _instance = SocketServices._internal();

  SocketServices._internal() {
    startSockConnection();
  }

  factory SocketServices() {
    return _instance;
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
      // print(data);
    });

    socket.open();
  }

  void joinRoomSolo(int broId) {
    print("join room solo!");
    this.socket.emit(
      "join",
      {
      },
    );
  }


}
