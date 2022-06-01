import 'dart:math';
import '../util/global.dart';

// TODO: Change it to getHexagons?
List<int> getTileFromPos(double mouseX, double mouseY, int rotate) {
  double qDetailed = -1;
  double rDetailed = -1;
  double sDetailed = -1;
  if (rotate == 0) {
    double xTranslate = (2/3 * mouseX);
    qDetailed = xTranslate / xSize;
    double yTranslate1 = (-1/3 * mouseX);
    double yTranslate2 = (sqrt(3) / 3 * mouseY);
    yTranslate2 *= -1;  // The y axis gets positive going down, so we flip it.
    rDetailed = (yTranslate1 / xSize) + (yTranslate2 / ySize);
    sDetailed = (qDetailed + rDetailed) * -1;
  } else if (rotate == 1) {
    double xTranslate = (2/3 * mouseY);
    qDetailed = xTranslate / ySize;
    double yTranslate1 = (-1/3 * mouseY);
    double yTranslate2 = (sqrt(3) / 3 * -mouseX) + xSize;
    yTranslate2 *= -1;  // The y axis gets positive going down, so we flip it.
    rDetailed = (yTranslate1 / ySize) + (yTranslate2 / xSize);
    sDetailed = (qDetailed + rDetailed) * -1;
  } else if (rotate == 2) {
    double xTranslate = (2 / 3 * mouseX) - xSize;
    xTranslate *= -1; // Flip the mouse x because the map is fully rotated
    qDetailed = xTranslate / xSize;
    double yTranslate1 = (-1 / 3 * mouseX) + ySize;
    yTranslate1 *= -1; // Flip the mouse x because the map is fully rotated
    double yTranslate2 = (sqrt(3) / 3 * mouseY) - ySize;
    // Now we should flip the mouse y, but that is already done so we won't
    rDetailed = (yTranslate1 / xSize) + (yTranslate2 / ySize);
    sDetailed = (qDetailed + rDetailed) * -1;
  } else if (rotate == 3) {
    double xTranslate = (2/3 * -mouseY) + ySize;
    qDetailed = xTranslate / ySize;
    double yTranslate1 = (-1/3 * -mouseY) - ySize;
    double yTranslate2 = (sqrt(3) / 3 * mouseX) - ySize;
    yTranslate2 *= -1;  // The y axis gets positive going down, so we flip it.
    rDetailed = (yTranslate1 / ySize) + (yTranslate2 / xSize);
    sDetailed = (qDetailed + rDetailed) * -1;
  }

  int q = qDetailed.round();
  int r = rDetailed.round();
  int s = sDetailed.round();

  double qDiff = (q - qDetailed).abs();
  double rDiff = (r - rDetailed).abs();
  double sDiff = (s - sDetailed).abs();

  if (qDiff > rDiff && qDiff > sDiff) {
    q = -r - s;
  } else if (rDiff > sDiff) {
    r = -q - s;
  } else {
    s = -q - r;
  }
  return [q, r, s];
}