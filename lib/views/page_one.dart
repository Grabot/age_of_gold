import 'package:age_of_gold/views/hexagon_button.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'app_bar.dart';


class PageOne extends StatefulWidget {

  static const String route = '/one';

  const PageOne({Key? key}) : super(key: key);

  @override
  State<PageOne> createState() => _PageOneState();
}

class _PageOneState extends State<PageOne> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: appBarAgeOfGold(),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          // Some slight position changes for mobile web
          if (constraints.maxWidth < 800) {
            return Stack(
              children: <Widget>[
                HexagonButton(key: UniqueKey(), xPos: constraints.maxWidth / 2, yPos: constraints.maxHeight / 2, radius: 100),
                HexagonButton(key: UniqueKey(), xPos: constraints.maxWidth / 4, yPos: constraints.maxHeight / 4, radius: 100),
                HexagonButton(key: UniqueKey(), xPos: constraints.maxWidth / 4, yPos: (constraints.maxHeight / 4) * 3, radius: 100),
                HexagonButton(key: UniqueKey(), xPos: (constraints.maxWidth / 4) * 3, yPos: constraints.maxHeight / 4, radius: 100),
                HexagonButton(key: UniqueKey(), xPos: (constraints.maxWidth / 4) * 3, yPos: (constraints.maxHeight / 4) * 3, radius: 100),
              ],
            );
          } else {
            return Stack(
              children: <Widget>[
                HexagonButton(key: UniqueKey(), xPos: constraints.maxWidth / 2, yPos: constraints.maxHeight / 2, radius: 100),
                HexagonButton(key: UniqueKey(), xPos: constraints.maxWidth / 3, yPos: constraints.maxHeight / 4, radius: 100),
                HexagonButton(key: UniqueKey(), xPos: constraints.maxWidth / 3, yPos: (constraints.maxHeight / 4) * 3, radius: 100),
                HexagonButton(key: UniqueKey(), xPos: (constraints.maxWidth / 3) * 2, yPos: constraints.maxHeight / 4, radius: 100),
                HexagonButton(key: UniqueKey(), xPos: (constraints.maxWidth / 3) * 2, yPos: (constraints.maxHeight / 4) * 3, radius: 100),
              ],
            );
          }
        }
      ),
    );
  }
}
