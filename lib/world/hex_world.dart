import 'package:flame/palette.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../component/hexagon.dart';
import '../component/tile.dart';
import '../constants/global.dart';
import '../services/auth_service_world.dart';
import '../services/settings.dart';
import '../services/socket_services.dart';
import '../util/hexagon_list.dart';
import '../util/render_hexagons.dart';
import '../util/selected_tile.dart';
import '../util/tapped_map.dart';
import '../views/user_interface/ui_util/clear_ui.dart';
import '../views/user_interface/ui_util/selected_tile_info.dart';
import '../views/user_interface/ui_views/map_coordinates/map_coordinates_change_notifier.dart';


class HexWorld extends Component {

  late HexagonList hexagonList;

  Rect screen = const Rect.fromLTRB(0, 0, 0, 0);
  late Vector2 cameraPosition;
  late double zoom;

  Tile? mouseTile;

  late SocketServices socketServices;
  late SelectedTileInfo selectedTileInfo;

  int startHexQ;
  int startHexR;

  late MapCoordinatesChangeNotifier mapCoordinatesChangeNotifier = MapCoordinatesChangeNotifier();

  HexWorld(this.startHexQ, this.startHexR);

  int rotation = 0;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    selectedTileInfo = SelectedTileInfo();

    socketServices = SocketServices();
    socketServices.addListener(socketListener);

    hexagonList = HexagonList();
    hexagonList.setSocketService(socketServices);
    hexagonList.retrieveHexagons(startHexQ, startHexR);

    rotation = Settings().getRotation();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    renderHexagons(canvas, cameraPosition, hexagonList, screen, socketServices, rotation);

    if (mouseTile != null) {
      tileSelected(mouseTile!, canvas, rotation);
    }
  }

  jumpToCoordinates(int q, int r) {
    hexagonList.retrieveHexagons(q, r);
  }

  resetClick() {
    mouseTile = null;
    selectedTileInfo.setCurrentTile(null);
    selectedTileInfo.notify();
  }

  void onTappedUp(Vector2 mouseTapped, Vector2 screenPos) {
    List<int> tileProperties = getTileFromPos(mouseTapped.x, mouseTapped.y, rotation);
    int q = tileProperties[0];
    int r = tileProperties[1];

    Tile? mouseTileTap = hexagonList.getTileFromCoordinates(q, r);
    selectedTileInfo.setCurrentTile(mouseTileTap);
    if (mouseTileTap != null) {
      mouseTile = mouseTileTap;
      getAdditionalTileInfo(mouseTile!, screenPos);
    }
  }

  focusWorld() {
    ClearUI().clearUserInterfaces();
  }

  getAdditionalTileInfo(Tile tile, Vector2 screenPos) {
    AuthServiceWorld().getTileInfo(tile, screenPos).then((value) {
      if (value != "success") {
        // TODO: What to do when it is not successful
      }
    }).onError((error, stackTrace) {
      // TODO: What to do on an error?
    });
  }

  int currentCameraQ = 0;
  int currentCameraR = 0;

  void checkCameraPos() {
    List<int> tileProperties = getTileFromPos(cameraPosition.x, cameraPosition.y, rotation);
    int q = tileProperties[0];
    int r = tileProperties[1];
    if (q != currentCameraQ || r != currentCameraR) {
      currentCameraQ = q;
      currentCameraR = r;

      Tile? cameraTile = hexagonList.getTileFromCoordinates(q, r);

      if (cameraTile != null) {
        mapCoordinatesChangeNotifier
            .setCoordinates([cameraTile.tileQ, cameraTile.tileR]);
      } else {
        mapCoordinatesChangeNotifier.setCoordinates([q, r]);
      }
    }
  }

  updateWorld(Vector2 cameraPos, double zoomLevel, Vector2 worldSize) {
    cameraPosition = cameraPos;
    checkCameraPos();

    zoom = zoomLevel;

    // We draw the border a bit further (about a hex) than what you're seeing,
    // this is so the sections load before you scroll on them.
    double borderOffsetX = ((radius * 2 + 1) * xSize);
    double borderOffsetY = ((radius * 2 + 1) * ySize);

    double leftScreen = cameraPosition.x - (worldSize.x / 2) - borderOffsetX;
    double rightScreen = cameraPosition.x + (worldSize.x / 2) + borderOffsetX;
    double topScreen = cameraPosition.y - (worldSize.y / 2) - borderOffsetY;
    double bottomScreen = cameraPosition.y + (worldSize.y / 2) + borderOffsetY;
    // double leftScreen = cameraPosition.x - (worldSize.x / 2) + 500;
    // double rightScreen = cameraPosition.x + (worldSize.x / 2) - 500;
    // double topScreen = cameraPosition.y - (worldSize.y / 2) + 500;
    // double bottomScreen = cameraPosition.y + (worldSize.y / 2) - 500;

    screen = Rect.fromLTRB(leftScreen, topScreen, rightScreen, bottomScreen);
  }

  socketListener() {
  }

  setHexagonArraySize(int arraySize) {
    hexagonList.changeArraySize(arraySize);
  }

  worldCheck(int q, int r) {
    Tile? mouseTileTap = hexagonList.getTileFromCoordinates(q, r);
    if (mouseTileTap == null) {
      return false;
    } else {
      return true;
    }
  }

  resetWorld(int hexQ, int hexR) {
    hexagonList.retrieveHexagons(hexQ, hexR);
  }

  Hexagon? getHexFromTile(int tileQ, int tileR) {
    Tile? tile = hexagonList.getTileFromCoordinates(tileQ, tileR);
    if (tile != null) {
      Hexagon? hexagon = tile.hexagon;
      if (hexagon != null) {
        return hexagon;
      }
    }
    return null;
  }

  bool checkForWrap() {
    List<int> tileProperties = getTileFromPos(cameraPosition.x, cameraPosition.y, rotation);
    int q = tileProperties[0];
    int r = tileProperties[1];

    Tile? cameraTile = hexagonList.getTileFromCoordinates(q, r);
    if (cameraTile != null) {
      if (cameraTile.q != cameraTile.tileQ || cameraTile.r != cameraTile.tileR) {
        // A simple wrap check is to see if the q is different from tileQ or r is different from tileR.
        return true;
      } else {
        return false;
      }
    } else {
      // Can't find a camera tile? Just do the reset by returning true.
      return true;
    }
  }

  rotateWorld(int rotation) {
    this.rotation = rotation;
    hexagonList.rotateHexagonsAndTiles(rotation);
  }
}