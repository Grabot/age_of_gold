import 'package:age_of_gold/component/tile.dart';
import 'package:age_of_gold/util/render_hexagons.dart';
import 'package:age_of_gold/util/tapped_map.dart';
import 'package:age_of_gold/views/user_interface/ui_util/clear_ui.dart';
import 'package:age_of_gold/views/user_interface/ui_util/selected_tile_info.dart';
import 'package:age_of_gold/views/user_interface/ui_views/change_avatar_box/change_avatar_change_notifier.dart';
import 'package:age_of_gold/views/user_interface/ui_views/chat_window/chat_window_change_notifier.dart';
import 'package:age_of_gold/views/user_interface/ui_views/loading_box/loading_box_change_notifier.dart';
import 'package:age_of_gold/views/user_interface/ui_views/profile_box/profile_change_notifier.dart';
import 'package:age_of_gold/views/user_interface/ui_views/user_box/user_box_change_notifier.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../component/hexagon.dart';
import '../services/auth_service_world.dart';
import '../constants/global.dart';
import '../util/hexagon_list.dart';
import '../util/selected_tile.dart';
import '../services/socket_services.dart';


class World extends Component {

  late HexagonList hexagonList;

  Rect screen = const Rect.fromLTRB(0, 0, 0, 0);
  late Vector2 cameraPosition;
  late double zoom;

  Tile? mouseTile;

  int currentVariant = 0;

  late SocketServices socketServices;
  late SelectedTileInfo selectedTileInfo;

  int startHexQ;
  int startHexR;

  World(this.startHexQ, this.startHexR);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    selectedTileInfo = SelectedTileInfo();

    socketServices = SocketServices();
    socketServices.addListener(socketListener);

    hexagonList = HexagonList();
    hexagonList.setSocketService(socketServices);
    hexagonList.retrieveHexagons(startHexQ, startHexR);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    renderHexagons(canvas, cameraPosition, hexagonList, screen, currentVariant, socketServices);

    if (mouseTile != null) {
      tileSelected(mouseTile!, canvas);
    }
  }

  resetClick() {
    mouseTile = null;
    selectedTileInfo.setCurrentTile(null);
    selectedTileInfo.notifyListeners();
  }

  void onTappedUp(Vector2 mouseTapped, Vector2 screenPos) {
    List<int> tileProperties = getTileFromPos(mouseTapped.x, mouseTapped.y);
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
      } else {
        print("success!");
      }
    }).onError((error, stackTrace) {
      // TODO: What to do on an error?
    });
  }

  updateVariant(int variant) {
    currentVariant = variant;
  }

  updateWorld(Vector2 cameraPos, double zoomLevel, Vector2 worldSize) {
    cameraPosition = cameraPos;

    zoom = zoomLevel;

    // We draw the border a bit further (about a hex) than what you're seeing,
    // this is so the sections load before you scroll on them.
    double borderOffsetX = -((radius * 2 + 1) * xSize);
    double borderOffsetY = -((radius * 2 + 1) * ySize);

    double leftScreen = cameraPosition.x - (worldSize.x / 2) + borderOffsetX;
    double rightScreen = cameraPosition.x + (worldSize.x / 2) - borderOffsetX;
    double topScreen = cameraPosition.y - (worldSize.y / 2) + borderOffsetY;
    double bottomScreen = cameraPosition.y + (worldSize.y / 2) - borderOffsetY;

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
    // Only use in emergencies
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
}