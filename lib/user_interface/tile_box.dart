import 'package:age_of_gold/user_interface/selected_tile_info.dart';
import 'package:flutter/material.dart';
import '../age_of_gold.dart';
import '../util/socket_services.dart';


class TileBox extends StatefulWidget {

  final AgeOfGold game;

  const TileBox({
    required Key key,
    required this.game
  }) : super(key: key);

  @override
  TileBoxState createState() => TileBoxState();
}

class TileBoxState extends State<TileBox> {

  late SelectedTileInfo selectedTileInfo;

  SocketServices socket = SocketServices();

  // Initial Selected Value
  final List<TileData> _tiles = TileData.getTiles();
  late List<DropdownMenuItem<TileData>> _dropdownMenuItems;
  late TileData _selectedTile;

  @override
  void initState() {
    super.initState();
    selectedTileInfo = SelectedTileInfo();
    selectedTileInfo.addListener(selectedTileListener);

    socket.addListener(socketListener);
    socket.checkTile();

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
    setState(() {});
  }

  selectedTileListener() {
    if (selectedTileInfo.selectedTile != null) {
      _selectedTile = _dropdownMenuItems[selectedTileInfo.selectedTile!.tileType].value!;
    }
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  changeTileType(String tileName, int tileType) {
    if (tileName != selectedTileInfo.getTileType()) {
      socket.changeTileType(
          selectedTileInfo.selectedTile!.tileQ,
          selectedTileInfo.selectedTile!.tileR,
          tileType,
          selectedTileInfo.selectedTile!.hexagon!.wrapQ,
          selectedTileInfo.selectedTile!.hexagon!.wrapR
      );

      selectedTileInfo.selectedTile!.tileType = tileType;
      setState(() {});
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
      return Image.asset(tileData.imagePath, scale: 0.3);
    }
    return Container();
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
    return Align(
      alignment: FractionalOffset.topRight,
      child: Container(
        width: 380,
        height: 400,
        child: Column(
          children: [
            currentTileWindow(),
            const SizedBox(height: 10),
            dropdownThing()
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
      TileData(0, "Amethyst", "assets/images/tiles/b44ac0_noise1.png"),
      TileData(1, "Black", "assets/images/tiles/000000_noise1.png"),
      TileData(2, "Bondi Blue", "assets/images/tiles/009eaa_noise1.png"),
      TileData(3, "Bright Sun", "assets/images/tiles/ffd635_noise1.png"),
      TileData(4, "Caribbean Green", "assets/images/tiles/00cc78_noise1.png"),
      TileData(5, "Cerulean Blue", "assets/images/tiles/2450a4_noise1.png"),
      TileData(6, "Conifer", "assets/images/tiles/7eed56_noise1.png"),
      TileData(7, "Cornflower Blue", "assets/images/tiles/6a5cff_noise1.png"),
      TileData(8, "Governor Bay", "assets/images/tiles/493ac1_noise1.png"),
      TileData(9, "Green Haze", "assets/images/tiles/00a368_noise1.png"),
      TileData(10, "Iron", "assets/images/tiles/d4d7d9_noise1.png"),
      TileData(11, "Monza", "assets/images/tiles/be0039_noise1.png"),
      TileData(12, "Oslo Gray", "assets/images/tiles/898d90_noise1.png"),
      TileData(13, "Paarl", "assets/images/tiles/9c6926_noise1.png"),
      TileData(14, "Picton Blue", "assets/images/tiles/3690ea_noise1.png"),
      TileData(15, "Pine Green", "assets/images/tiles/00756f_noise1.png"),
      TileData(16, "Pink Salmon", "assets/images/tiles/ff99aa_noise1.png"),
      TileData(17, "Seance", "assets/images/tiles/811e9f_noise1.png"),
      TileData(18, "Spice", "assets/images/tiles/6d482f_noise1.png"),
      TileData(19, "Spray", "assets/images/tiles/51e9f4_noise1.png"),
      TileData(20, "Vermillion", "assets/images/tiles/ff4500_noise1.png"),
      TileData(21, "Web Orange", "assets/images/tiles/ffa800_noise1.png"),
      TileData(22, "White", "assets/images/tiles/ffffff_noise1.png"),
      TileData(23, "Wild Strawberry", "assets/images/tiles/ff3881_noise1.png")
    ];
  }
}