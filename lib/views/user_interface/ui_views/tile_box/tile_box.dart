import 'package:age_of_gold/age_of_gold.dart';
import 'package:age_of_gold/locator.dart';
import 'package:age_of_gold/services/auth_service_world.dart';
import 'package:age_of_gold/services/settings.dart';
import 'package:age_of_gold/services/socket_services.dart';
import 'package:age_of_gold/util/navigation_service.dart';
import 'package:age_of_gold/util/render_objects.dart';
import 'package:age_of_gold/util/util.dart';
import 'package:age_of_gold/views/user_interface/ui_util/selected_tile_info.dart';
import 'package:age_of_gold/views/user_interface/ui_views/profile_box/profile_change_notifier.dart';
import 'package:age_of_gold/views/user_interface/ui_views/user_box/user_box_change_notifier.dart';
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

  double offsetLeft = 0;
  double offsetTop = 0;

  double tileBoxWidth = 290;
  double tileBoxHeight = 280;

  double totalWidth = 0;  // Will be set later and it can change
  double totalHeight = 0;  // Will be set later and it can change

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
      setState(() {});
    }
  }

  selectedTileListener() {
    if (mounted) {
      if (selectedTileInfo.selectedTile != null) {
        _selectedTile =
        _dropdownMenuItems[selectedTileInfo.selectedTile!.tileType].value!;
      }
      setTileBoxPosition();
      setState(() {});
    }
  }

  setTileBoxPosition() {
    if (selectedTileInfo.getTapPos() != null) {
      offsetLeft = selectedTileInfo.getTapPos()!.x;
      offsetTop = selectedTileInfo.getTapPos()!.y;

      offsetLeft -= tileBoxWidth/2;

      double rightSide = offsetLeft + tileBoxWidth;
      double leftSide = offsetLeft - tileBoxWidth/2;
      double bottomSide = offsetTop + tileBoxHeight;

      if (rightSide > totalWidth) {
        offsetLeft = totalWidth - tileBoxWidth;
      } else if (leftSide < 0) {
        offsetLeft = 0;
      }
      if (bottomSide > totalHeight) {
        offsetTop = offsetTop - tileBoxHeight;
      }
    }
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
          print("change tile type value: $value");
          if (value == "success") {
            selectedTileInfo.selectedTile!.tileType = tileType;
            selectedTileInfo.setLastChangedByAvatar(settings.getAvatar()!);
            selectedTileInfo.setLastChangedTime(DateTime.now());
            setState(() {
              selectedTileInfo.setLastChangedBy(settings.getUser()!.getUserName());
              // Set the tile back to zero so the tilebox will disappear.
              selectedTileInfo.setCurrentTile(null);
            });
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

  Widget dropdownThing(double dropDownWidth, double dropDownHeight) {
    if (selectedTileInfo.selectedTile != null) {
      return SizedBox(
        width: dropDownWidth,
        height: dropDownHeight,
        child: DropdownButton(
          value: _selectedTile,
          items: _dropdownMenuItems,
          onChanged: onChangeDropdownItem,
        ),
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

  Widget tileDetail(double tileDetailWidth, double tileDetailHeight) {
    return SizedBox(
      width: tileDetailWidth,
      height: tileDetailHeight,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Tile:  "),
              Column(
                children: [
                  Text("Q: ${selectedTileInfo.selectedTile!.tileQ}"),
                  Text("R: ${selectedTileInfo.selectedTile!.tileR}"),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  int detailUserColour = 0;

  Color getUserDetailColour() {
    if (detailUserColour == 0) {
      return Colors.orange;
    } else if (detailUserColour == 1) {
      return Colors.orange.shade700;
    } else {
      return Colors.orange.shade300;
    }
  }

  viewUser() {
    String userName = selectedTileInfo.getTileChangedBy()!;
    AuthServiceWorld().getUser(userName).then((value) {
      if (value != null) {
        setState(() {
          selectedTileInfo.selectedTile = null;
        });
        UserBoxChangeNotifier().setUser(value);
        UserBoxChangeNotifier().setUserBoxVisible(true);
      }
    });
    }

  Widget changedDetail(double changedDetailWidth, double changedDetailHeight) {
    double avatarBoxHeight = 69;
    double changedAtHeight = 15;
    double changedHeight = changedDetailHeight - avatarBoxHeight - changedAtHeight - 20;
    return SizedBox(
      width: changedDetailWidth,
      height: changedDetailHeight,
      child: Column(
        children: [
          SizedBox(
            width: changedDetailWidth,
            height: changedHeight,
            child: const Text("Last changed by:")
          ),
          InkWell(
            onTap: () {
              setState(() {
                detailUserColour = 2;
              });
              viewUser();
            },
            onHover: (hovering) {
              setState(() {
                if (hovering) {
                  detailUserColour = 1;
                } else {
                  detailUserColour = 0;
                }
              });
            },
            child: Container(
              color: getUserDetailColour(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  avatarBox(avatarBoxHeight, avatarBoxHeight, selectedTileInfo.getLastChangedByAvatar()!),
                  Expanded(
                    child: SizedBox(
                        width: changedDetailWidth - avatarBoxHeight,
                        child: RichText(
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                              text: selectedTileInfo.getTileChangedBy()!,
                              style: simpleTextStyle(16)
                            )
                        )
                    ),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
              width: changedDetailWidth,
              height: changedAtHeight,
              child: Text(selectedTileInfo.getChangedAt()!)
          ),
          const SizedBox(height: 10)
        ],
      ),
    );
  }

  Widget tileBoxWidget() {
    double currentTileHeight = 40;
    double changedDetailHeight = 124;
    if (selectedTileInfo.getLastChangedBy() == null) {
      tileBoxHeight = 156;
    } else {
      tileBoxHeight = 280;
    }
    double dropDownHeight = 70;
    bool showTileDetail = false;
    if (selectedTileInfo.selectedTile != null) {
      showTileDetail = true;
    }
    return showTileDetail ? Positioned(
      left: offsetLeft,
      top: offsetTop,
      child: Container(
        width: tileBoxWidth,
        color: Colors.orange,
        child: Column(
          children: [
            tileDetail(tileBoxWidth, currentTileHeight),
            if (selectedTileInfo.getLastChangedBy() != null && selectedTileInfo.getLastChangedByAvatar() != null)
              changedDetail(tileBoxWidth, changedDetailHeight),
            if (selectedTileInfo.getLastChangedBy() == null)
                const Text("Tile untouched"),
            dropdownThing(tileBoxWidth, dropDownHeight),
          ]
        ),
      ),
    ) : Container();
  }

  @override
  Widget build(BuildContext context) {
    totalWidth = MediaQuery.of(context).size.width;
    totalHeight = MediaQuery.of(context).size.height;
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
