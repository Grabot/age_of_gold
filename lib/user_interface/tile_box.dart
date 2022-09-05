import 'package:age_of_gold/user_interface/selected_tile_info.dart';
import 'package:flutter/material.dart';
import '../age_of_gold.dart';


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

  @override
  void initState() {
    super.initState();
    selectedTileInfo = SelectedTileInfo();
    selectedTileInfo.addListener(selectedTileListener);
  }

  selectedTileListener() {
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: FractionalOffset.topRight,
      child: Container(
        width: 400,
        height: 100,
        color: Colors.orange,
        child: Center(
          child: Text('Tile: ${selectedTileInfo.tileInfo()}'),
        ),
      ),
    );
  }
}