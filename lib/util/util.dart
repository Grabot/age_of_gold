
import 'dart:math';

import 'package:age_of_gold/util/socket_services.dart';
import 'package:flame/components.dart';

import '../component/hexagon.dart';
import '../component/tile.dart';
import 'global.dart';
import 'hexagon_list.dart';

List removeDuplicates(List hexToRetrieve) {
  List hexToRetrieveUnique = [];
  // If coordinates were found to retrieve
  if (hexToRetrieve.isNotEmpty) {
    for (int x = 0; x < hexToRetrieve.length; x++) {
      bool noRepeat = true;
      List value1 = hexToRetrieve[x];
      for (int y = x + 1; y < hexToRetrieve.length; y++) {
        List value2 = hexToRetrieve[y];
        if (value1[0] == value2[0] && value1[1] == value2[1]) {
          noRepeat = false;
          break;
        }
      }
      if (noRepeat) {
        hexToRetrieveUnique.add(value1);
      }
    }
  }
  return hexToRetrieveUnique;
}


getTilePosition(int q, int r) {
  double xPos = xSize * 3 / 2 * q - xSize;
  double yTr1 = ySize * (sqrt(3) / 2 * q);
  yTr1 *= -1; // The y axis gets positive going down, so we flip it.
  double yTr2 = ySize * (sqrt(3) * r);
  yTr2 *= -1; // The y axis gets positive going down, so we flip it.
  double yPos = yTr1 + yTr2 - ySize;

  // slight offset to put the center in the center and not a corner.
  xPos += xSize;
  yPos += ySize;

  return Vector2(xPos, yPos);
}
