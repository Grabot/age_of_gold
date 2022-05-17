import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:age_of_gold/util/render_hexagons.dart';
import '../util/hexagon_list.dart';

class World extends Component {

  late HexagonList hexagonList;

  late int rotate;

  Rect screen = const Rect.fromLTRB(0, 0, 0, 0);
  late Vector2 cameraPosition;
  late double zoom;

  int currentVariant = 0;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    rotate = 0;

    hexagonList = HexagonList();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    renderHexagons(canvas, cameraPosition, hexagonList, screen, rotate, currentVariant);
  }


  updateWorld(Vector2 cameraPos, double zoomLevel, Vector2 worldSize) {
    cameraPosition = cameraPos;

    zoom = zoomLevel;

    // We draw the border a bit further (about 1 tile) than what you're seeing, this is so the sections load before you scroll on them.
    double borderOffset = 32;
    double hudLeft = 200 / zoomLevel;
    double hudBottom = 100 / zoomLevel;
    double leftScreen = cameraPosition.x - (worldSize.x / 2) - borderOffset + hudLeft;
    double rightScreen = cameraPosition.x + (worldSize.x / 2) + borderOffset;
    double topScreen = cameraPosition.y - (worldSize.y / 2) - borderOffset;
    double bottomScreen = cameraPosition.y + (worldSize.y / 2) + borderOffset - hudBottom;
    screen = Rect.fromLTRB(leftScreen, topScreen, rightScreen, bottomScreen);
  }
}