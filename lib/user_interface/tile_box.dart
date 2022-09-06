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

  @override
  void initState() {
    super.initState();
    selectedTileInfo = SelectedTileInfo();
    selectedTileInfo.addListener(selectedTileListener);

    socket.addListener(socketListener);
    socket.checkTile();
  }

  socketListener() {
    setState(() {});
  }

  selectedTileListener() {
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
    // return Image.asset('images/flat_variation_1.png');
  }

  Widget selectionWindow() {
    if (selectedTileInfo.selectedTile != null) {
      return Column(
          children: [
            const Text(
                "change tile type:",
                style: TextStyle(color: Colors.white, fontSize: 24)
            ),
            Wrap(
              children: [
                tileButton("Grass",
                    Image.asset('images/tiles/grass_flat_1.png', scale: 0.8),
                    0),
                tileButton("Water",
                    Image.asset('images/tiles/water_flat_1.png', scale: 0.8),
                    1),
                tileButton("Dirt",
                    Image.asset('images/tiles/dirt_flat_1.png', scale: 0.8), 2)
              ],
            ),
          ]
      );
    } else {
      return Container();
    }
  }

  Widget getImage() {
    if (selectedTileInfo.selectedTile != null) {
      if (selectedTileInfo.selectedTile!.tileType == 0) {
        return Image.asset('images/tiles/grass_flat_1.png', scale: 0.3);
      }
      if (selectedTileInfo.selectedTile!.tileType == 1) {
        return Image.asset('images/tiles/water_flat_1.png', scale: 0.3);
      }
      if (selectedTileInfo.selectedTile!.tileType == 2) {
        return Image.asset('images/tiles/dirt_flat_1.png', scale: 0.3);
      }
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

  Widget tileBoxWidget() {
    return Align(
      alignment: FractionalOffset.topRight,
      child: Container(
        width: 400,
        height: 200,
        color: Colors.orange,
        child: Column(
          children: [
            currentTileWindow(),
            const SizedBox(height: 10),
            selectionWindow()
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
