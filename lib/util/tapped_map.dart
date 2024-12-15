import 'dart:math';

import '../constants/global.dart';


List<int> getTileFromPos(double mouseX, double mouseY, int rotation) {
  double qDetailed = 0;
  double rDetailed = 0;
  double sDetailed = 0;

  if (rotation % 2 == 0 ) {
    double xTranslate = (2 / 3 * mouseX);
    qDetailed = xTranslate / xSize;
    double yTranslate1 = (-1 / 3 * mouseX);
    double yTranslate2 = (sqrt(3) / 3 * mouseY);
    rDetailed = (yTranslate1 / xSize) + (yTranslate2 / ySize);
  } else {
    double yTrans1 = (2 / 3 * mouseY);
    rDetailed = yTrans1 / ySize;
    double xTrans1 = (-1 / 3 * mouseY);
    double xTrans2 = (sqrt(3) / 3 * mouseX);
    qDetailed = (xTrans1 / ySize) + (xTrans2 / xSize);
  }
  sDetailed = -qDetailed - rDetailed;

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

  // We now return the correct tile coordinates based on the rotation
  if (rotation == 1) {
    return [s, q];
  } else if (rotation == 2) {
    return [s, q];
  } else if (rotation == 3) {
    return [-r, -s];
  } else if (rotation == 4) {
    return [-r, -s];
  } else if (rotation == 5) {
    return [q, r];
  } else if (rotation == 6) {
    return [q, r];
  } else if (rotation == 7) {
    return [-s, -q];
  } else if (rotation == 8) {
    return [-s, -q];
  } else if (rotation == 9) {
    return [r, s];
  } else if (rotation == 10) {
    return [r, s];
  } else if (rotation == 11) {
    return [-q, -r];
  } else {
    // rotation 0
    return [-q, -r];
  }
}
