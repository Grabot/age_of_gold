import 'package:age_of_gold/util/hexagon_list.dart';
import 'package:age_of_gold/util/socket_services.dart';
import 'package:age_of_gold/util/tapped_map.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../component/hexagon.dart';
import '../component/tile.dart';
import 'check_offset.dart';


renderHexagons(Canvas canvas, Vector2 camera, HexagonList hexagonList, Rect screen, int variation, SocketServices socketServices) {

  List<int> tileProperties = getTileFromPos(camera.x, camera.y);
  int q = tileProperties[0];
  int r = tileProperties[1];

  checkVisible(hexagonList, screen, socketServices);

  offsetMap(q, r, hexagonList, socketServices);

  drawHexagons(canvas, variation, screen, hexagonList, socketServices);
}

checkVisible(HexagonList hexagonList, Rect screen, SocketServices socketServices) {
  for (int top = 0; top <= hexagonList.hexagons.length - 1; top++) {
    Hexagon? currentHexagon;
    for (int right = hexagonList.hexagons.length - 1; right >= 0; right--) {
      currentHexagon = hexagonList.hexagons[right][top];
      if (currentHexagon != null) {
        if (currentHexagon.center.x > screen.left
            && currentHexagon.center.x < screen.right
            && currentHexagon.center.y > screen.top
            && currentHexagon.center.y < screen.bottom) {
          if (!currentHexagon.setToRetrieve && !currentHexagon.retrieved) {
            // The hexagon has not been retrieved yet and
            // not flagged to be retrieved.
            // We will send out the socket call and flag it as retrieved
            socketServices.actuallyGetHexagons(currentHexagon);
          }
          if (!currentHexagon.visible) {
            // The hex was flagged as not visible, so it has entered the view
            // Set the flag accordingly and join the hex room.
            currentHexagon.visible = true;
            socketServices.joinHexRoom(currentHexagon);
          }
        } else {
          // The hex is not visible.
          if (currentHexagon.visible) {
            // The hex is still flagged as visible so it has just left the view
            // Set the flag accordingly and leave the hex socket room.
            currentHexagon.visible = false;
            socketServices.leaveHexRoom(currentHexagon);
          }
        }
      }
    }
  }
}

drawHexagons(Canvas canvas, int variation, Rect screen, HexagonList hexagonList, SocketServices socketServices) {
  // draw from top to bottom
  for (int top = 0; top <= hexagonList.hexagons.length - 1; top++) {
    Hexagon? currentHexagon;
    for (int right = hexagonList.hexagons.length - 1; right >= 0; right--) {
      currentHexagon = hexagonList.hexagons[right][top];
      if (currentHexagon != null) {
        if (currentHexagon.center.x > screen.left
            && currentHexagon.center.x < screen.right
            && currentHexagon.center.y > screen.top
            && currentHexagon.center.y < screen.bottom) {
          currentHexagon.renderHexagon(canvas, variation);
        }
      }
    }
  }
}

