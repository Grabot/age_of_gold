import 'dart:math';
import 'package:age_of_gold/util/socket_services.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:universal_html/html.dart' as html;
import 'package:age_of_gold/world/world.dart';
import 'dart:ui' hide TextStyle;

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

  bool chatFocus = false;

  TextPaint textPaint = TextPaint(
    style: const TextStyle(
      fontSize: 48.0,
      fontFamily: 'Awesome Font',
      color: Colors.white
    ),
  );

  List<String> randomNames = ["Max", "Nanne", "Chris", "Steve", "Harry", "Whazor", "Tessa"];
  late String userName;

  SocketServices socket = SocketServices();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    userName = randomNames[Random().nextInt(randomNames.length)];

    socket.setUser(0, userName);
    socket.joinRoom();

    camera.followVector2(cameraPosition, relativeOffset: Anchor.center);
    camera.zoom = 4;

    _world = World();
    add(_world!);

    html.window.onBeforeUnload.listen((event) async {
      socket.leaveRoom();
    });

    socket.addListener(socketListener);
    checkHexagonArraySize();
  }

  socketListener() {
    print("socket did something! 1");
  }

  chatBoxFocus(bool chatFocus) {
    print("focus? $chatFocus");
    this.chatFocus = chatFocus;
    if (!chatFocus) {
      gameFocus.requestFocus();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    textPaint.render(canvas, "Age of Gold!\nFPS: $fps\nUser: $userName", Vector2(10, 10));
  }

  @override
  void onMouseMove(PointerHoverInfo info) {
    super.onMouseMove(info);
  }

  @override
  void onScroll(PointerScrollInfo info) {
    super.onScroll(info);
    double zoomIncrease = (info.raw.scrollDelta.dy/1000);
    camera.zoom *= (1 - zoomIncrease);

    clampZoom();
    print("current zoom: ${camera.zoom}");

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
  void onTapDown(int pointerId, TapDownInfo info) {
    super.onTapDown(pointerId, info);
  }

  Vector2? start;
  Vector2? end;

  @override
  void onDragStart(int pointerId, DragStartInfo info) {
    super.onDragStart(pointerId, info);
    end = null;
    // All distances need to be normalized using the current zoom.
    start = (info.eventPosition.game) * camera.zoom;
    // We need to move the pointer to the center rather than the corner
    start!.add((size/2) * camera.zoom);
    // We need to move the pointer according to the current camera position
    start!.sub((cameraPosition) * camera.zoom);
    print("pointer $pointerId    start: $start");
  }

  @override
  void onDragUpdate(int pointerId, DragUpdateInfo info) {
    super.onDragUpdate(pointerId, info);
    end = (info.eventPosition.game) * camera.zoom;
    end!.add((size/2) * camera.zoom);
    end!.sub((cameraPosition) * camera.zoom);

    double lineDistanceX = (start!.x - end!.x) / camera.zoom;
    double lineDistanceY = (start!.y - end!.y) / camera.zoom;
    start = (info.eventPosition.game) * camera.zoom;
    start!.add((size/2) * camera.zoom);
    start!.sub((cameraPosition) * camera.zoom);
    dragTo.add(Vector2(lineDistanceX, lineDistanceY));
  }

  @override
  void onDragCancel(int pointerId) {
    super.onDragCancel(pointerId);
    end = null;
    start = null;
  }

  @override
  void onDragEnd(int pointerId, DragEndInfo info) {
    super.onDragEnd(pointerId, info);
    end = null;
    start = null;
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
      print("fps: $frames");
      print("zoom: ${camera.zoom}");
      frameTimes = 0;
      frames = 0;
    }

    // This will determine 12 variants in a 60fps game loop
    int newVariant = (frameTimes / 0.084).floor();
    // It should never exceed 11 (only 12 variants (including 0) for now)
    if (variant != newVariant) {
      variant = newVariant;
      _world!.updateVariant(variant);
    }
  }

  void updateMapScroll() {
    if ((dragTo.x - cameraPosition.x).abs() < 0.2) {
      cameraPosition.x = dragTo.x;
      cameraVelocity.x = 0;
    } else {
      cameraVelocity.x = (dragTo.x - cameraPosition.x);
      cameraVelocity.x.clamp(-100, 100);
    }

    if ((dragTo.y - cameraPosition.y).abs() < 0.2) {
      cameraPosition.y = dragTo.y;
      cameraVelocity.y = 0;
    } else {
      cameraVelocity.y = (dragTo.y - cameraPosition.y);
      cameraVelocity.y.clamp(-100, 100);
    }
  }

  @override
  KeyEventResult onKeyEvent(
      RawKeyEvent event,
      Set<LogicalKeyboardKey> keysPressed,
      ) {

    final isKeyDown = event is RawKeyDownEvent;

    if (chatFocus && isKeyDown) {
      return KeyEventResult.ignored;
    } else {
      // _world!.resetClick();
      if (event.logicalKey == LogicalKeyboardKey.keyA) {
        dragAccelerateKey.x = isKeyDown ? -5 : 0;
      } else if (event.logicalKey == LogicalKeyboardKey.keyD) {
        dragAccelerateKey.x = isKeyDown ? 5 : 0;
      } else if (event.logicalKey == LogicalKeyboardKey.keyW) {
        dragAccelerateKey.y = isKeyDown ? -5 : 0;
      } else if (event.logicalKey == LogicalKeyboardKey.keyS) {
        dragAccelerateKey.y = isKeyDown ? 5 : 0;
      }

      if (event.logicalKey == LogicalKeyboardKey.home) {
        userName = "Sander";
        socket.setUser(0, userName);
      }

      return KeyEventResult.handled;
    }
  }

  @override
  void onGameResize(Vector2 canvasSize) {
    // This needs to be done to position the HUD margin components correctly.
    double previousZoom = camera.zoom;
    camera.zoom = 1;
    print("canvasSize: $canvasSize");
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

}
