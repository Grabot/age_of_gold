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
                tileButton("Amethyst",
                    Image.asset('assets/images/tiles/b44ac0_noise1.png', scale: 0.8),
                    0),
                tileButton("Black",
                    Image.asset('assets/images/tiles/000000_noise1.png', scale: 0.8),
                    1),
                tileButton("Bondi Blue",
                    Image.asset('assets/images/tiles/009eaa_noise1.png', scale: 0.8),
                    2),
                tileButton("Bright Sun",
                    Image.asset('assets/images/tiles/ffd635_noise1.png', scale: 0.8),
                    3),
                tileButton("Caribbean Green",
                    Image.asset('assets/images/tiles/00cc78_noise1.png', scale: 0.8),
                    4),
                tileButton("Cerulean Blue",
                    Image.asset('assets/images/tiles/2450a4_noise1.png', scale: 0.8),
                    5),
                tileButton("Conifer",
                    Image.asset('assets/images/tiles/7eed56_noise1.png', scale: 0.8),
                    6),
                tileButton("Cornflower Blue",
                    Image.asset('assets/images/tiles/6a5cff_noise1.png', scale: 0.8),
                    7),
                tileButton("Governor Bay",
                    Image.asset('assets/images/tiles/493ac1_noise1.png', scale: 0.8),
                    8),
                tileButton("Green Haze",
                    Image.asset('assets/images/tiles/00a368_noise1.png', scale: 0.8),
                    9),
                tileButton("Iron",
                    Image.asset('assets/images/tiles/d4d7d9_noise1.png', scale: 0.8),
                    10),
                tileButton("Monza",
                    Image.asset('assets/images/tiles/be0039_noise1.png', scale: 0.8),
                    11),
                tileButton("Oslo Gray",
                    Image.asset('assets/images/tiles/898d90_noise1.png', scale: 0.8),
                    12),
                tileButton("Paarl",
                    Image.asset('assets/images/tiles/9c6926_noise1.png', scale: 0.8),
                    13),
                tileButton("Picton Blue",
                    Image.asset('assets/images/tiles/3690ea_noise1.png', scale: 0.8),
                    14),
                tileButton("Pine Green",
                    Image.asset('assets/images/tiles/00756f_noise1.png', scale: 0.8),
                    15),
                tileButton("Pink Salmon",
                    Image.asset('assets/images/tiles/ff99aa_noise1.png', scale: 0.8),
                    16),
                tileButton("Seance",
                    Image.asset('assets/images/tiles/811e9f_noise1.png', scale: 0.8),
                    17),
                tileButton("Spice",
                    Image.asset('assets/images/tiles/6d482f_noise1.png', scale: 0.8),
                    18),
                tileButton("Spray",
                    Image.asset('assets/images/tiles/51e9f4_noise1.png', scale: 0.8),
                    19),
                tileButton("Vermillion",
                    Image.asset('assets/images/tiles/ff4500_noise1.png', scale: 0.8),
                    20),
                tileButton("Web Orange",
                    Image.asset('assets/images/tiles/ffa800_noise1.png', scale: 0.8),
                    21),
                tileButton("White",
                    Image.asset('assets/images/tiles/ffffff_noise1.png', scale: 0.8),
                    22),
                tileButton("Wild Strawberry",
                    Image.asset('assets/images/tiles/ff3881_noise1.png', scale: 0.8),
                    23)
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
        return Image.asset('assets/images/tiles/b44ac0_noise1.png', scale: 0.3);
      }
      if (selectedTileInfo.selectedTile!.tileType == 1) {
        return Image.asset('assets/images/tiles/000000_noise1.png', scale: 0.3);
      }
      if (selectedTileInfo.selectedTile!.tileType == 2) {
        return Image.asset('assets/images/tiles/009eaa_noise1.png', scale: 0.3);
      }
      if (selectedTileInfo.selectedTile!.tileType == 3) {
        return Image.asset('assets/images/tiles/ffd635_noise1.png', scale: 0.3);
      }
      if (selectedTileInfo.selectedTile!.tileType == 4) {
        return Image.asset('assets/images/tiles/00cc78_noise1.png', scale: 0.3);
      }
      if (selectedTileInfo.selectedTile!.tileType == 5) {
        return Image.asset('assets/images/tiles/2450a4_noise1.png', scale: 0.3);
      }
      if (selectedTileInfo.selectedTile!.tileType == 6) {
        return Image.asset('assets/images/tiles/7eed56_noise1.png', scale: 0.3);
      }
      if (selectedTileInfo.selectedTile!.tileType == 7) {
        return Image.asset('assets/images/tiles/6a5cff_noise1.png', scale: 0.3);
      }
      if (selectedTileInfo.selectedTile!.tileType == 8) {
        return Image.asset('assets/images/tiles/493ac1_noise1.png', scale: 0.3);
      }
      if (selectedTileInfo.selectedTile!.tileType == 9) {
        return Image.asset('assets/images/tiles/00a368_noise1.png', scale: 0.3);
      }
      if (selectedTileInfo.selectedTile!.tileType == 10) {
        return Image.asset('assets/images/tiles/d4d7d9_noise1.png', scale: 0.3);
      }
      if (selectedTileInfo.selectedTile!.tileType == 11) {
        return Image.asset('assets/images/tiles/be0039_noise1.png', scale: 0.3);
      }
      if (selectedTileInfo.selectedTile!.tileType == 12) {
        return Image.asset('assets/images/tiles/898d90_noise1.png', scale: 0.3);
      }
      if (selectedTileInfo.selectedTile!.tileType == 13) {
        return Image.asset('assets/images/tiles/9c6926_noise1.png', scale: 0.3);
      }
      if (selectedTileInfo.selectedTile!.tileType == 14) {
        return Image.asset('assets/images/tiles/3690ea_noise1.png', scale: 0.3);
      }
      if (selectedTileInfo.selectedTile!.tileType == 15) {
        return Image.asset('assets/images/tiles/00756f_noise1.png', scale: 0.3);
      }
      if (selectedTileInfo.selectedTile!.tileType == 16) {
        return Image.asset('assets/images/tiles/ff99aa_noise1.png', scale: 0.3);
      }
      if (selectedTileInfo.selectedTile!.tileType == 17) {
        return Image.asset('assets/images/tiles/811e9f_noise1.png', scale: 0.3);
      }
      if (selectedTileInfo.selectedTile!.tileType == 18) {
        return Image.asset('assets/images/tiles/6d482f_noise1.png', scale: 0.3);
      }
      if (selectedTileInfo.selectedTile!.tileType == 19) {
        return Image.asset('assets/images/tiles/51e9f4_noise1.png', scale: 0.3);
      }
      if (selectedTileInfo.selectedTile!.tileType == 20) {
        return Image.asset('assets/images/tiles/ff4500_noise1.png', scale: 0.3);
      }
      if (selectedTileInfo.selectedTile!.tileType == 21) {
        return Image.asset('assets/images/tiles/ffa800_noise1.png', scale: 0.3);
      }
      if (selectedTileInfo.selectedTile!.tileType == 22) {
        return Image.asset('assets/images/tiles/ffffff_noise1.png', scale: 0.3);
      }
      if (selectedTileInfo.selectedTile!.tileType == 23) {
        return Image.asset('assets/images/tiles/ff3881_noise1.png', scale: 0.3);
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
        width: 380,
        height: 400,
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
