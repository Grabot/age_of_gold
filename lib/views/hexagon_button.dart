import 'package:flutter/material.dart';
import 'dart:math' as math;

class HexagonButton extends StatefulWidget {

  final double xPos;
  final double yPos;
  final double radius;

  const HexagonButton({
    required Key key,
    required this.xPos,
    required this.yPos,
    required this.radius
  }) : super(key: key);

  @override
  _HexagonButtonState createState() => _HexagonButtonState();
}

class _HexagonButtonState extends State<HexagonButton> {

  double radius = 100;

  HexagonPainter? test;

  double containerOffset = 0;

  double paintOffsetX = 0;
  double paintOffsetY = 0;

  @override
  void initState() {
    super.initState();
    radius = widget.radius;

    containerOffset = (radius/4);

    paintOffsetX = radius - (containerOffset/2);
    paintOffsetY = (math.sqrt(3) * radius)/2 - (containerOffset / 2);

    test = HexagonPainter(
        Offset(paintOffsetX, paintOffsetY),
        radius);
  }

  hoverHexagonButton(bool hover) {
    print("hovering hexagon button: $hover");
    test!.changeColour(hover);
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.yPos-radius,
      left: widget.xPos-radius,
      child: Stack(
        children: [
          CustomPaint(
              painter: test!
          ),
          Container(
            height: (math.sqrt(3) * radius) - containerOffset,
            width: (2 * radius) - containerOffset,
            child: Image(
                image: AssetImage("assets/images/Github_logo_PNG1.png"),
            ),
          ),
          Container(
            height: (math.sqrt(3) * radius) - containerOffset,
            width: (2 * radius) - containerOffset,
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                print("tapped");
              },
              onHover: (val) {
                hoverHexagonButton(val);
              },
              hoverColor: Colors.transparent, // We will do our own hover thing
            ),
          ),
        ],
      ),
    );
  }
}

class HexagonPainter extends CustomPainter {
  static const int SIDES_OF_HEXAGON = 6;
  final double radius;
  final Offset center;

  Paint normalColour = Paint()..color = Colors.lightBlue;
  Paint hoverColour = Paint()..color = Colors.blue;
  Paint currentColour = Paint()..color = Colors.lightBlue;

  HexagonPainter(this.center, this.radius);

  @override
  void paint(Canvas canvas, Size size) {
    Path path = createHexagonPath();
    canvas.drawPath(path, currentColour);
  }

  changeColour(bool hover) {
    print("change colour?");
    if (hover) {
      currentColour = hoverColour;
    } else {
      currentColour = normalColour;
    }
  }

  Path createHexagonPath() {
    final path = Path();
    var angle = (math.pi * 2) / SIDES_OF_HEXAGON;
    Offset firstPoint = Offset(radius * math.cos(0.0), radius * math.sin(0.0));
    path.moveTo(firstPoint.dx + center.dx, firstPoint.dy + center.dy);
    for (int i = 1; i <= SIDES_OF_HEXAGON; i++) {
      double x = radius * math.cos(angle * i) + center.dx;
      double y = radius * math.sin(angle * i) + center.dy;
      path.lineTo(x, y);
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
