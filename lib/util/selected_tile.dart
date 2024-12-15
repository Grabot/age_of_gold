import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flame/components.dart';
import '../component/tile.dart';
import '../constants/global.dart';


Vector2 pointyHexCorner(double i, Vector2 center, int rotation) {
  double angleDeg = 60 * i;
  if (rotation % 2 == 1) {
    angleDeg += 30;
  }

  double angleRad = pi/180 * angleDeg;
  double pointX = center.x + (xSize * cos(angleRad)) + xSize;
  double pointY = center.y + (ySize * sin(angleRad)) + ySize;
  double xOffset = 0;
  double yOffset = 0;

  if (rotation == 0) {
    yOffset -= 4;
    xOffset += 1;
  } else if (rotation == 1) {
    xOffset -= 3;
  } else if (rotation == 2) {
    yOffset -= 4;
  } else if (rotation == 3) {
    xOffset -= 4;
  } else if (rotation == 4) {
    yOffset -= 4;
  } else if (rotation == 5) {
    xOffset -= 4;
  } else if (rotation == 6) {
    yOffset -= 4;
  } else if (rotation == 7) {
    xOffset -= 4;
    yOffset -= 1;
  } else if (rotation == 8) {
    yOffset -= 4;
  } else if (rotation == 9) {
    xOffset -= 3;
    yOffset -= 1;
  } else if (rotation == 10) {
    yOffset -= 4;
    xOffset += 1;
  } else if (rotation == 11) {
    xOffset -= 3;
    yOffset -= 1;
  }
  return Vector2(pointX + xOffset, pointY + yOffset);
}

drawTileSelection(Tile selectedTile, Canvas canvas, int rotation) {
  Vector2 point1 = pointyHexCorner(0, selectedTile.getPos(), rotation);
  Vector2 point2 = pointyHexCorner(1, selectedTile.getPos(), rotation);
  Vector2 point3 = pointyHexCorner(2, selectedTile.getPos(), rotation);
  Vector2 point4 = pointyHexCorner(3, selectedTile.getPos(), rotation);
  Vector2 point5 = pointyHexCorner(4, selectedTile.getPos(), rotation);
  Vector2 point6 = pointyHexCorner(5, selectedTile.getPos(), rotation);

  var points = Float32List.fromList(
      [
        point1.x, point1.y,
        point2.x, point2.y,
        point3.x, point3.y,
        point4.x, point4.y,
        point5.x, point5.y,
        point6.x, point6.y,
        point1.x, point1.y
      ]);

  Paint selectedPaint = Paint()
    ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 5)
    ..style = PaintingStyle.stroke
    ..color = const Color.fromRGBO(255, 255, 0, 1.0)
    ..strokeWidth = 1;

  canvas.drawRawPoints(
      PointMode.polygon,
      points,
      selectedPaint
  );
}

tileSelected(Tile selectedTile, Canvas canvas, int rotation) {
  drawTileSelection(selectedTile, canvas, rotation);
}