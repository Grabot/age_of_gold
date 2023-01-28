import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flame/components.dart';
import '../component/tile.dart';
import '../constants/global.dart';


Vector2 pointyHexCorner(double i, Vector2 center) {
  double angleDeg = 60 * i;

  double angleRad = pi/180 * angleDeg;
  double pointX = center.x + (xSize * cos(angleRad)) + xSize;
  double pointY = center.y + (ySize * sin(angleRad)) + ySize;
  return Vector2(pointX, pointY - 4);
}

drawTileSelection(Tile selectedTile, Canvas canvas) {
  Vector2 point1 = pointyHexCorner(0, selectedTile.getPos());
  Vector2 point2 = pointyHexCorner(1, selectedTile.getPos());
  Vector2 point3 = pointyHexCorner(2, selectedTile.getPos());
  Vector2 point4 = pointyHexCorner(3, selectedTile.getPos());
  Vector2 point5 = pointyHexCorner(4, selectedTile.getPos());
  Vector2 point6 = pointyHexCorner(5, selectedTile.getPos());

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

tileSelected(Tile selectedTile, Canvas canvas) {
  drawTileSelection(selectedTile, canvas);
}