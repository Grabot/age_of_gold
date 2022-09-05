import 'package:age_of_gold/component/tile.dart';
import 'package:age_of_gold/util/tapped_map.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:age_of_gold/util/render_hexagons.dart';
import '../user_interface/selected_tile_info.dart';
import '../user_interface/tile_box.dart';
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

    final shapeBounds = Rect.fromLTRB(cameraPosition.x - 10, cameraPosition.y - 10, cameraPosition.x + 10, cameraPosition.y + 10);
    final paintCenterCamera = Paint()..color = Colors.green;
    canvas.drawRect(shapeBounds, paintCenterCamera);

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
    int s = tileProperties[2];

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

    // We draw the border a bit further (about 1 tile) than what you're seeing, this is so the sections load before you scroll on them.
    double borderOffset = -32;
    double hudLeft = 200 / zoomLevel;
    double hudBottom = 100 / zoomLevel;
    //debugging TODO: remove
    hudLeft = 0;
    hudBottom = 0;

    double leftScreen = cameraPosition.x - (worldSize.x / 2) - borderOffset + hudLeft;
    double rightScreen = cameraPosition.x + (worldSize.x / 2) + borderOffset;
    double topScreen = cameraPosition.y - (worldSize.y / 2) - borderOffset;
    double bottomScreen = cameraPosition.y + (worldSize.y / 2) + borderOffset - hudBottom;
    screen = Rect.fromLTRB(leftScreen, topScreen, rightScreen, bottomScreen);
  }

  socketListener() {
    print("socket listener");
  }

  setHexagonArraySize(int arraySize) {
    hexagonList.changeArraySize(arraySize);
  }
}