import 'dart:math';
import '../util/global.dart';


List<int> getTileFromPos(double mouseX, double mouseY, int rotate) {
  double qDetailed = -1;
  double rDetailed = -1;
  double sDetailed = -1;

  // We need to adjust by 1 so minus the xSize
  double xTranslate = (2/3 * mouseX) - xSize;
  qDetailed = xTranslate / xSize;
  double yTranslate1 = (-1/3 * mouseX);
  // We need to adjust by 1 so minus the ySize
  double yTranslate2 = (sqrt(3) / 3 * mouseY) - ySize;
  yTranslate2 *= -1;  // The y axis gets positive going down, so we flip it.
  rDetailed = (yTranslate1 / xSize) + (yTranslate2 / ySize);
  sDetailed = (qDetailed + rDetailed) * -1;

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