import 'dart:convert';

import 'package:age_of_gold/age_of_gold.dart';
import 'package:age_of_gold/component/tile.dart';
import 'package:age_of_gold/locator.dart';
import 'package:age_of_gold/services/auth_service_world.dart';
import 'package:age_of_gold/services/settings.dart';
import 'package:age_of_gold/services/socket_services.dart';
import 'package:age_of_gold/util/countdown.dart';
import 'package:age_of_gold/util/navigation_service.dart';
import 'package:age_of_gold/util/util.dart';
import 'package:age_of_gold/views/user_interface/ui_function/user_interface_util/profile_change_notifier.dart';
import 'package:age_of_gold/views/user_interface/ui_function/user_interface_util/selected_tile_info.dart';
import 'package:age_of_gold/views/user_interface/ui_function/user_interface_util/user_box_change_notifier.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';


class TileBox extends StatefulWidget {

  final AgeOfGold game;

  const TileBox({
    required Key key,
    required this.game
  }) : super(key: key);

  @override
  TileBoxState createState() => TileBoxState();
}

class TileBoxState extends State<TileBox> with TickerProviderStateMixin {

  late SelectedTileInfo selectedTileInfo;
  late ProfileChangeNotifier profileChangeNotifier;
  final NavigationService _navigationService = locator<NavigationService>();
  SocketServices socket = SocketServices();
  Settings settings = Settings();

  // Initial Selected Value
  final List<TileData> _tiles = TileData.getTiles();
  late List<DropdownMenuItem<TileData>> _dropdownMenuItems;
  late TileData _selectedTile;

  @override
  void initState() {
    super.initState();
    selectedTileInfo = SelectedTileInfo();
    selectedTileInfo.addListener(selectedTileListener);

    profileChangeNotifier = ProfileChangeNotifier();
    profileChangeNotifier.addListener(profileChangeListener);
    settings.addListener(profileChangeListener);

    socket.addListener(socketListener);

    _dropdownMenuItems = buildDropdownMenuItems(_tiles);
    _selectedTile = _dropdownMenuItems[0].value!;
  }

  List<DropdownMenuItem<TileData>> buildDropdownMenuItems(List tiles) {
    List<DropdownMenuItem<TileData>> items = [];
    for (TileData tileData in tiles) {
      items.add(
        DropdownMenuItem(
          value: tileData,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Image.asset(
                  tileData.imagePath,
                  width: 120,
                  height: 60,
                  scale: 0.5
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(tileData.name)
              ],
            ),
          ),
        ),
      );
    }
    return items;
  }

  socketListener() {
    if (mounted) {
      setState(() {});
    }
  }

  profileChangeListener() {
    if (mounted) {
      print("profile change in tilebox");
      setState(() {});
    }
  }

  selectedTileListener() {
    if (mounted) {
      if (selectedTileInfo.selectedTile != null) {
        _selectedTile =
        _dropdownMenuItems[selectedTileInfo.selectedTile!.tileType].value!;
      }
      setState(() {});
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  changeTileType(String tileName, int tileType) {
    if (settings.getUser() == null) {
      showToastMessage("You must be logged in to change tiles");
    } else if (settings.getUser()!.getTileLock().isBefore(DateTime.now())) {
      // The lock needs to be over.
      if (tileName != selectedTileInfo.getTileType()) {
        AuthServiceWorld().changeTileType(
            selectedTileInfo.selectedTile!.tileQ,
            selectedTileInfo.selectedTile!.tileR,
            tileType
        ).then((value) {
          if (value == "success") {
            selectedTileInfo.selectedTile!.tileType = tileType;
            // TODO: update the tilelock in profile overview?
          } else if(value == "not allowed") {
            showToastMessage("Failed to change tile to $tileName");
          } else if(value == "back to login") {
            logoutUser(settings, _navigationService);
          } else if(value == "error occurred") {
            showToastMessage("An error occurred while changing tile to $tileName");
          } else {
            logoutUser(settings, _navigationService);
          }
        }).onError((error, stackTrace) {
          showToastMessage("An error occurred while changing tile to $tileName");
        });
      }
    } else {
      showToastMessage("Not allowed to change a tile for another ${settings.getUser()!.getTileLock().difference(DateTime.now()).inSeconds} seconds.");
      _selectedTile =
      _dropdownMenuItems[selectedTileInfo.selectedTile!.tileType].value!;
    }
  }

  Widget tileButton(String tileName, Image tile, int tileType) {
    return ElevatedButton(
      onPressed: () {
        changeTileType(tileName, tileType);
      },
      child: Column(
        children: [
          tile,
          const SizedBox(
            width: 5,
          ),
          Text(tileName),
        ],
      ),
    );
  }

  Widget getImage() {
    if (selectedTileInfo.selectedTile != null) {
      int tileTypeSelected = selectedTileInfo.selectedTile!.tileType;
      TileData tileData = _tiles[tileTypeSelected];
      return Image.asset(tileData.imagePath, scale: 1);
    }
    return Container();
  }

  Widget currentTileInformation() {
    String? lastChangedBy = selectedTileInfo.getTileChangedBy();
    if (settings.getUser() != null) {
      if (lastChangedBy == settings.getUser()!.getUserName()) {
        lastChangedBy = "You!";
      }
    }
    if (lastChangedBy != null) {
      return Expanded(
        child: Column(
          children: [
            RichText(
              overflow: TextOverflow.fade,
              maxLines: 2,
              softWrap: false,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "Last changed by: ",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16
                    ),
                  ),
                  TextSpan(
                    text: lastChangedBy,
                    recognizer: TapGestureRecognizer()..onTapDown = clickedUser,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16
                    ),
                  ),
                ],
              ),
            ),
            RichText(
              text: TextSpan(
                text: selectedTileInfo.getChangedAt(),
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16
                ),
              ),
            )
          ],
        ),
      );
    } else {
      return Text("Tile untouched");
    }
  }

  clickedUser(TapDownDetails details) {
    String? lastChangedBy = selectedTileInfo.getTileChangedBy();
    if (lastChangedBy == null || settings.getUser() == null || lastChangedBy != settings.getUser()!.getUserName()) {
      AuthServiceWorld().getUser(selectedTileInfo.getTileChangedBy()!).then((value) {
        if (value != null) {
          UserBoxChangeNotifier().setUser(value);
          UserBoxChangeNotifier().setUserBoxVisible(true);
          print("you have just clicked a user ${selectedTileInfo
              .getTileChangedBy()})");
        } else {
          showToastMessage("Failed to get user");
        }
      }).onError((error, stackTrace) {
        showToastMessage("Failed to get user");
      });
    }
  }

  Widget currentTileWindow() {
    return Column(
      children:[
        const Text(
            "current tile:",
            style: TextStyle(color: Colors.white, fontSize: 24)
        ),
        Text(
            "type: ${selectedTileInfo.getTileType()}",
            style: const TextStyle(color: Colors.white, fontSize: 24)
        ),
        getImage(),
        Text(
            selectedTileInfo.tileInfo(),
            style: const TextStyle(color: Colors.white, fontSize: 20)
        ),
      ]
    );
  }

  Widget dropdownThing() {
    if (selectedTileInfo.selectedTile != null) {
      return DropdownButton(
        value: _selectedTile,
        items: _dropdownMenuItems,
        onChanged: onChangeDropdownItem,
      );
    } else {
      return Container();
    }
  }

  onChangeDropdownItem(TileData? selectedTile) {
    setState(() {
      if (selectedTile != null) {
        _selectedTile = selectedTile;
        changeTileType(_selectedTile.name, _selectedTile.type);
      }
    });
  }

  Widget tileBoxWidget() {
    double tileBoxWidth = 350;
    double tileBoxHeight = 300;
    if (MediaQuery.of(context).size.width <= 800) {
      // Here we assume that it is a phone and we set the width to the total
      tileBoxWidth = MediaQuery.of(context).size.width;
    } else {
      tileBoxWidth = 350;
    }

    bool showTileDetail = false;
    if (selectedTileInfo.selectedTile != null) {
      showTileDetail = true;
    }
    return Align(
      alignment: FractionalOffset.topRight,
      child: Container(
        width: tileBoxWidth,
        height: showTileDetail ? tileBoxHeight : 0,
        color: Colors.orange,
        child: Column(
          children: [
            const SizedBox(height: 20),
            currentTileWindow(),
            const SizedBox(height: 10),
            dropdownThing(),
            const SizedBox(height: 10),
            currentTileInformation(),
          ]
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return tileBoxWidget();
  }
}

class TileData {
  int type;
  String name;
  String imagePath;

  TileData(this.type, this.name, this.imagePath);

  static List<TileData> getTiles() {
    return <TileData>[
      TileData(0, "Amethyst", "assets/images/tiles/Sprite_b44ac0.png"),
      TileData(1, "Black", "assets/images/tiles/Sprite_000000.png"),
      TileData(2, "Bondi Blue", "assets/images/tiles/Sprite_009eaa.png"),
      TileData(3, "Bright Sun", "assets/images/tiles/Sprite_ffd635.png"),
      TileData(4, "Caribbean Green", "assets/images/tiles/Sprite_00cc78.png"),
      TileData(5, "Cerulean Blue", "assets/images/tiles/Sprite_2450a4.png"),
      TileData(6, "Conifer", "assets/images/tiles/Sprite_7eed56.png"),
      TileData(7, "Cornflower Blue", "assets/images/tiles/Sprite_6a5cff.png"),
      TileData(8, "Governor Bay", "assets/images/tiles/Sprite_493ac1.png"),
      TileData(9, "Green Haze", "assets/images/tiles/Sprite_00a368.png"),
      TileData(10, "Iron", "assets/images/tiles/Sprite_d4d7d9.png"),
      TileData(11, "Monza", "assets/images/tiles/Sprite_be0039.png"),
      TileData(12, "Oslo Gray", "assets/images/tiles/Sprite_898d90.png"),
      TileData(13, "Paarl", "assets/images/tiles/Sprite_9c6926.png"),
      TileData(14, "Picton Blue", "assets/images/tiles/Sprite_3690ea.png"),
      TileData(15, "Pine Green", "assets/images/tiles/Sprite_00756f.png"),
      TileData(16, "Pink Salmon", "assets/images/tiles/Sprite_ff99aa.png"),
      TileData(17, "Seance", "assets/images/tiles/Sprite_811e9f.png"),
      TileData(18, "Spice", "assets/images/tiles/Sprite_6d482f.png"),
      TileData(19, "Spray", "assets/images/tiles/Sprite_51e9f4.png"),
      TileData(20, "Vermillion", "assets/images/tiles/Sprite_ff4500.png"),
      TileData(21, "Web Orange", "assets/images/tiles/Sprite_ffa800.png"),
      TileData(22, "White", "assets/images/tiles/Sprite_ffffff.png"),
      TileData(23, "Wild Strawberry", "assets/images/tiles/Sprite_ff3881.png")
    ];
  }
}

