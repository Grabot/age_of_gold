import 'dart:math';
import 'package:age_of_gold/services/models/user.dart';
import 'package:age_of_gold/services/settings.dart';
import 'package:age_of_gold/util/global.dart';
import 'package:age_of_gold/services/socket_services.dart';
import 'package:age_of_gold/util/tapped_map.dart';
import 'package:age_of_gold/util/util.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:universal_html/html.dart' as html;
import 'package:age_of_gold/world/world.dart';


// flutter run -d chrome --release --web-hostname localhost --web-port 7357
class AgeOfGold extends FlameGame
    with
        HasTappables,
        HasDraggables,
        ScrollDetector,
        MouseMovementDetector,
        KeyboardEvents {

  FocusNode gameFocus;
  AgeOfGold(this.gameFocus);

  // The camera position will always be in the center of the screen
  Vector2 cameraPosition = Vector2.zero();
  Vector2 cameraVelocity = Vector2.zero();

  Vector2 dragAccelerateKey = Vector2.zero();
  Vector2 dragTo = Vector2.zero();
  Vector2 dragFrom = Vector2.zero();

  double frameTimes = 0.0;
  int frames = 0;
  int fps = 0;
  int variant = 0;

  World? _world;

  double maxZoom = 4;
  double minZoom = 1;

  bool playFieldFocus = true;

  // We use the pointer variables to determine regular or multidrag
  int pointerId1 = -1;
  int pointerId2 = -1;
  Vector2? start;

  Vector2? firstFinger;
  Vector2? secondFinger;

  bool finger1 = false;
  bool finger2 = false;
  double? distanceBetweenFingers;

  TextPaint textPaint = TextPaint(
    style: const TextStyle(
      fontSize: 48.0,
      fontFamily: 'Awesome Font',
      color: Colors.white
    ),
  );

  List<String> randomNames = ["Max", "Nanne", "Chris", "Steve", "Harry", "Whazor", "Tessa"];
  late String userName;

  SocketServices? socket;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    socket = SocketServices();

    camera.followVector2(cameraPosition, relativeOffset: Anchor.center);
    camera.zoom = 1;

    int startHexQ = 0;
    int startHexR = 0;
    calculateStartPosition(startHexQ, startHexR);
    _world = World(startHexQ, startHexR);
    add(_world!);

    html.window.onBeforeUnload.listen((event) async {
      socket!.leaveRoom();
    });

    socket!.addListener(socketListener);
    checkHexagonArraySize();

    Settings settings = Settings();
    User? user = settings.getUser();
    if (user != null) {
      userName = user.getUserName();
      socket!.setUser(0, user.getUserName());
    }

    socket!.joinRoom();
  }

  socketListener() {
  }

  chatBoxFocus(bool chatFocus) {
    playFieldFocus = !chatFocus;
    if (playFieldFocus) {
      gameFocus.requestFocus();
    }
  }

  loginFocus(bool loginFocus) {
    playFieldFocus = !loginFocus;
    if (playFieldFocus) {
      gameFocus.requestFocus();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    textPaint.render(canvas, "Age of Gold!\nFPS: $fps\nUser: $userName", Vector2(10, 10));
  }

  @override
  void onScroll(PointerScrollInfo info) {
    super.onScroll(info);
    double zoomIncrease = (info.raw.scrollDelta.dy/1000);
    camera.zoom *= (1 - zoomIncrease);

    clampZoom();

    checkHexagonArraySize();
  }

  void clampZoom() {
    camera.zoom = camera.zoom.clamp(1, 4);
  }

  @override
  void onTapUp(int pointerId, TapUpInfo info) {
    Vector2 tapPos = Vector2(info.eventPosition.game.x, info.eventPosition.game.y);
    _world!.onTappedUp(tapPos);
    super.onTapUp(pointerId, info);
  }

  @override
  void onDragStart(int pointerId, DragStartInfo info) {
    super.onDragStart(pointerId, info);
    // All distances need to be normalized using the current zoom.
    Vector2 dragStart = (info.eventPosition.game) * camera.zoom;
    // We need to move the pointer to the center rather than the corner
    dragStart.add((size / 2) * camera.zoom);
    // We need to move the pointer according to the current camera position
    dragStart.sub((cameraPosition) * camera.zoom);
    start = dragStart;

    _world!.resetClick();
    if (pointerId1 == -1) {
      pointerId1 = pointerId;
    } else if (pointerId1 != -1 && pointerId2 == -1) {
      pointerId2 = pointerId;
    }
  }

  @override
  void onDragUpdate(int pointerId, DragUpdateInfo info) {
    super.onDragUpdate(pointerId, info);
    Vector2 end = (info.eventPosition.game) * camera.zoom;
    end.add((size/2) * camera.zoom);
    end.sub((cameraPosition) * camera.zoom);

    if (pointerId1 != -1 && pointerId2 == -1) {
      double lineDistanceX = (start!.x - end.x) / camera.zoom;
      double lineDistanceY = (start!.y - end.y) / camera.zoom;
      start = (info.eventPosition.game) * camera.zoom;
      start!.add((size / 2) * camera.zoom);
      start!.sub((cameraPosition) * camera.zoom);

      dragTo.add(Vector2(lineDistanceX, lineDistanceY));
    } else if (pointerId1 != -1 && pointerId2 != -1) {

      if (pointerId == pointerId1) {
        firstFinger = (info.eventPosition.game) * camera.zoom;
        firstFinger!.add((size / 2) * camera.zoom);
        firstFinger!.sub((cameraPosition) * camera.zoom);
        finger1 = true;
      } else if (pointerId == pointerId2) {
        secondFinger = (info.eventPosition.game) * camera.zoom;
        secondFinger!.add((size / 2) * camera.zoom);
        secondFinger!.sub((cameraPosition) * camera.zoom);
        finger2 = true;
      }
      // Once 2 fingers have been detected and updated we do the pinch zoom
      if (finger1 && finger2) {
        pinchZoom();
      }
    }
  }

  pinchZoom() {
    if (distanceBetweenFingers == null) {
      distanceBetweenFingers = firstFinger!.distanceTo(secondFinger!);
    } else {
      double currentDistance = distanceBetweenFingers!;
      distanceBetweenFingers = firstFinger!.distanceTo(secondFinger!);
      double movementFingers = currentDistance - distanceBetweenFingers!;
      double zoomIncrease = movementFingers / 500;
      camera.zoom *= (1 - zoomIncrease);
      clampZoom();
    }
    finger1 = false;
    finger2 = false;
    firstFinger = null;
    secondFinger = null;
  }

  @override
  void onDragCancel(int pointerId) {
    super.onDragCancel(pointerId);
    resetDrag();
  }

  @override
  void onDragEnd(int pointerId, DragEndInfo info) {
    super.onDragEnd(pointerId, info);
    resetDrag();
  }

  resetDrag() {
    start = null;
    firstFinger = null;
    secondFinger = null;
    finger1 = false;
    finger2 = false;
    distanceBetweenFingers = null;
    pointerId1 = -1;
    pointerId2 = -1;
    dragTo = cameraPosition;
  }

  @override
  void update(double dt) {
    super.update(dt);

    updateFps(dt);

    _world!.updateWorld(cameraPosition, camera.zoom, size);

    dragTo += dragAccelerateKey;
    Vector2 movement = cameraVelocity * dt * 10;
    cameraPosition.add(movement);
    updateMapScroll();
  }

  updateFps(double dt) {
    frameTimes += dt;
    frames += 1;

    if (frameTimes >= 1) {
      fps = frames;
      frameTimes = 0;
      frames = 0;
      worldCheck();
    }

    // This will determine 12 variants in a 60fps game loop
    int newVariant = (frameTimes / 0.084).floor();
    // It should never exceed 11 (only 12 variants (including 0) for now)
    if (variant <= 11) {
      if (variant != newVariant) {
        variant = newVariant;
        _world!.updateVariant(variant);
      }
    }
  }

  calculateStartPosition(int startHexQ, int startHexR) {
    // Similar to what is done in Hexagon constructor
    int tileQ = convertHexToTileQ(startHexQ, startHexR);
    int tileR = convertHexToTileR(startHexQ, startHexR);

    Vector2 startPos = getTilePosition(tileQ, tileR);

    cameraPosition.add(startPos);
    dragTo.add(startPos);
  }

  void updateMapScroll() {
    if ((dragTo.x - cameraPosition.x).abs() < 0.2) {
      cameraPosition.x = dragTo.x;
      cameraVelocity.x = 0;
    } else {
      cameraVelocity.x = (dragTo.x - cameraPosition.x);
    }

    if ((dragTo.y - cameraPosition.y).abs() < 0.2) {
      cameraPosition.y = dragTo.y;
      cameraVelocity.y = 0;
    } else {
      cameraVelocity.y = (dragTo.y - cameraPosition.y);
    }
    clampSpeed();
  }

  clampSpeed() {
    if (cameraVelocity.x > cameraVelocity.y) {
      if (cameraVelocity.x.abs() > maxSpeed) {
        // If the speed is too large we want to slow it down.
        double scalarSize = maxSpeed / cameraVelocity.x.abs();
        cameraVelocity.x = cameraVelocity.x * scalarSize;
        cameraVelocity.y = cameraVelocity.y * scalarSize;
      }
    } else {
      if (cameraVelocity.y.abs() > maxSpeed) {
        // If the speed is too large we want to slow it down.
        double scalarSize = maxSpeed / cameraVelocity.y.abs();
        cameraVelocity.x = cameraVelocity.x * scalarSize;
        cameraVelocity.y = cameraVelocity.y * scalarSize;
      }
    }
  }

  @override
  KeyEventResult onKeyEvent(
      RawKeyEvent event,
      Set<LogicalKeyboardKey> keysPressed,
      ) {

    final isKeyDown = event is RawKeyDownEvent;

    if (!playFieldFocus && isKeyDown) {
      return KeyEventResult.ignored;
    } else {
      _world!.resetClick();
      double mouseSpeed = 10;
      if (event.logicalKey == LogicalKeyboardKey.keyA) {
        dragAccelerateKey.x = isKeyDown ? -mouseSpeed : 0;
      } else if (event.logicalKey == LogicalKeyboardKey.keyD) {
        dragAccelerateKey.x = isKeyDown ? mouseSpeed : 0;
      } else if (event.logicalKey == LogicalKeyboardKey.keyW) {
        dragAccelerateKey.y = isKeyDown ? -mouseSpeed : 0;
      } else if (event.logicalKey == LogicalKeyboardKey.keyS) {
        dragAccelerateKey.y = isKeyDown ? mouseSpeed : 0;
      }

      if (event.logicalKey == LogicalKeyboardKey.home) {
        userName = "Sander";
        socket!.setUser(0, userName);
      }

      return KeyEventResult.handled;
    }
  }

  @override
  void onGameResize(Vector2 canvasSize) {
    // This needs to be done to position the HUD margin components correctly.
    double previousZoom = camera.zoom;
    camera.zoom = 1;
    super.onGameResize(canvasSize);
    camera.zoom = previousZoom;
    checkHexagonArraySize();
  }

  checkHexagonArraySize() {
    double currentZoom = camera.zoom;
    double currentWidth = camera.canvasSize.x;
    double currentHeight = camera.canvasSize.y;
    if (_world != null) {
      if (currentZoom > 3.5 && (currentWidth < 2000 && currentHeight < 1100)) {
        _world!.setHexagonArraySize(8);
      } else if (currentZoom > 3.5 && (currentWidth > 2000 || currentHeight > 1100)) {
        _world!.setHexagonArraySize(12);
      } else if ((currentZoom < 3.5 && currentZoom > 2.5) && (currentWidth < 2000 && currentHeight < 1100)) {
        _world!.setHexagonArraySize(10);
      } else if ((currentZoom < 3.5 && currentZoom > 2.5) && (currentWidth > 2000 || currentHeight > 1100)) {
        _world!.setHexagonArraySize(14);
      } else if ((currentZoom < 2.5 && currentZoom > 1.5) && (currentWidth < 2000 && currentHeight < 1100)) {
        _world!.setHexagonArraySize(14);
      } else if ((currentZoom < 2.5 && currentZoom > 1.5) && (currentWidth > 2000 || currentHeight > 1100)) {
        _world!.setHexagonArraySize(18);
      } else if ((currentZoom < 1.5 && currentZoom > 0.5) && (currentWidth < 2000 && currentHeight < 1100)) {
        _world!.setHexagonArraySize(18);
      } else if ((currentZoom < 1.5 && currentZoom > 0.5) && (currentWidth > 2000 || currentHeight > 1100)) {
        _world!.setHexagonArraySize(26);
      }
    }
  }

  int problems = 0;
  worldCheck() {
    List<int> tileProperties = getTileFromPos(cameraPosition.x, cameraPosition.y);
    int q = tileProperties[0];
    int r = tileProperties[1];

    if (!_world!.worldCheck(q, r)) {
      if (problems == 10) {
        // This should only be a last resort, so after 10 seconds of
        // no tile we will attempt to fix the camera position
        int hexQ = convertTileToHexQ(q, r);
        int hexR = convertTileToHexR(q, r);
        _world!.resetWorld(hexQ, hexR);
        problems = 0;
      }
      problems += 1;
    } else {
      problems = 0;
    }
  }

}
