import 'package:flutter/material.dart';
import 'dart:math' as math;


class HexagonButton extends StatefulWidget {
  HexagonButton({
    required Key key,
    required this.xPos,
    required this.yPos
  }) : super(key: key);

  final double xPos;
  final double yPos;

  @override
  _HexagonButtonState createState() => _HexagonButtonState();
}

class _HexagonButtonState extends State<HexagonButton> {

  double radius = 100;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    double containerOffset = (radius/4);

    double paintOffsetX = 0;
    double paintOffsetY = -(math.sqrt(3) * radius)/2 + (containerOffset / 2);

    return Positioned(
      top: widget.yPos-radius,
      left: widget.xPos-radius,
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
          CustomPaint(painter: HexagonPainter(Offset(paintOffsetX, paintOffsetY), radius)),
        ],
      ),
    );
  }
}

class HexagonPainter extends CustomPainter {
  static const int SIDES_OF_HEXAGON = 6;
  final double radius;
  final Offset center;

  HexagonPainter(this.center, this.radius);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = Colors.red;
    Path path = createHexagonPath();
    canvas.drawPath(path, paint);
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
