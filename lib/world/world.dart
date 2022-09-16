import 'package:age_of_gold/component/tile.dart';
import 'package:age_of_gold/util/tapped_map.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:age_of_gold/util/render_hexagons.dart';
import '../user_interface/selected_tile_info.dart';
import '../util/global.dart';
import '../util/hexagon_list.dart';
import '../util/selected_tile.dart';
import '../util/socket_services.dart';

class World extends Component {

  late HexagonList hexagonList;

  late int rotate;

  Rect screen = const Rect.fromLTRB(0, 0, 0, 0);
  late Vector2 cameraPosition;
  late double zoom;

  Tile? mouseTile;

  int currentVariant = 0;

  late SocketServices socketServices;
  late SelectedTileInfo selectedTileInfo;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    selectedTileInfo = SelectedTileInfo();

    socketServices = SocketServices();
    socketServices.addListener(socketListener);

    rotate = 0;

    hexagonList = HexagonList();
    hexagonList.setSocketService(socketServices);
    hexagonList.retrieveHexagons();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    renderHexagons(canvas, cameraPosition, hexagonList, screen, rotate, currentVariant, socketServices);
    drawScreen(canvas);
  }

  drawScreen(Canvas canvas) {
    final paint = Paint()..color = Colors.lightBlue;
    paint.style = PaintingStyle.stroke;
    canvas.drawRect(screen, paint);

    if (mouseTile != null) {
      tileSelected(mouseTile!, canvas);
    }
  }

  resetClick() {
    mouseTile = null;
  }

  void onTappedUp(Vector2 mouseTapped) {
    print("on tapped up! $mouseTapped");

    List<int> tileProperties = getTileFromPos(mouseTapped.x, mouseTapped.y, 0);
    int q = tileProperties[0];
    int r = tileProperties[1];

    Tile? mouseTileTap = hexagonList.getTileFromCoordinates(q, r);
    if (mouseTileTap != null) {
      mouseTile = mouseTileTap;
      selectedTileInfo.setCurrentTile(mouseTileTap);
      print("tile tapped  q: ${mouseTileTap.q} r: ${mouseTileTap.r}");
    }
  }

  updateVariant(int variant) {
    currentVariant = variant;
  }

  updateWorld(Vector2 cameraPos, double zoomLevel, Vector2 worldSize) {
    cameraPosition = cameraPos;

    zoom = zoomLevel;

    // We draw the border a bit further (about 3 hex) than what you're seeing,
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
    print("socket listener world");
  }

  setHexagonArraySize(int arraySize) {
    hexagonList.changeArraySize(arraySize);
  }
}