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

  List<Widget> hexagonButtons = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    double radius = 100;
    hexagonButtons.add(hexagonButton(radius, width/2, height/2));
    // Some slight position changes for mobile web
    if (MediaQuery.of(context).size.width < 800) {
      hexagonButtons.add(hexagonButton(radius, width / 4, height / 4));
      hexagonButtons.add(hexagonButton(radius, width / 4, (height / 4) * 3));
      hexagonButtons.add(hexagonButton(radius, (width/4) * 3, height/4));
      hexagonButtons.add(hexagonButton(radius, (width/4) * 3, (height/4) * 3));
    } else {
      hexagonButtons.add(hexagonButton(radius, width / 3, height / 4));
      hexagonButtons.add(hexagonButton(radius, width / 3, (height / 4) * 3));
      hexagonButtons.add(hexagonButton(radius, (width/3) * 2, height/4));
      hexagonButtons.add(hexagonButton(radius, (width/3) * 2, (height/4) * 3));
    }

    return Scaffold(
      appBar: appBarAgeOfGold(),
      body: Stack(
          children: <Widget>[
            hexagonButtons[0],
            hexagonButtons[1],
            hexagonButtons[2],
            hexagonButtons[3],
            hexagonButtons[4]
        ],
      ),
    );
  }
}

Widget hexagonButton(double radius, double xPos, double yPos) {
  double containerOffset = (radius/4);

  double paintOffsetX = 0;
  double paintOffsetY = -(math.sqrt(3) * radius)/2 + (containerOffset / 2);

  return Positioned(
    top: yPos-radius,
    left: xPos-radius,
    child: Column(
      children: [
        Container(
          height: (math.sqrt(3) * radius) - containerOffset,
          width: (2 * radius) - containerOffset,
          color: Colors.transparent,
          child: InkWell(
            onTap: () {},
            onHover: (val) {
              print("Val--->{}$val");
            },
            hoverColor: Colors.transparent, // We will do our own hover thing
          ),
        ),
        // CustomPaint(painter: HexagonPainter(Offset(paintOffsetX, paintOffsetY), radius)),
      ],
    ),
  );
}
