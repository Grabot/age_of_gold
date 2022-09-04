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

  bool singleTap = false;
  bool multiTap = false;
  int multiPointer1Id = -1;
  int multiPointer2Id = -1;
  Vector2 multiPointer1 = Vector2.zero();
  Vector2 multiPointer2 = Vector2.zero();
  double multiPointerDist = 0.0;

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

  List<String> randomNames = ["Sander", "Max", "Nanne", "Chris", "Steve", "Harry", "Whazor", "Tessa"];
  late String userName;

  SocketServices socket = SocketServices();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    socket.setUserId(0);
    socket.joinRoom();

    userName = randomNames[Random().nextInt(randomNames.length)];

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
    if (camera.zoom <= minZoom) {
      camera.zoom = minZoom;
    } else if (camera.zoom >= maxZoom) {
      camera.zoom = maxZoom;
    }
    print("current zoom: ${camera.zoom}");

    checkHexagonArraySize();
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

  @override
  void onDragStart(int pointerId, DragStartInfo info) {
    super.onDragStart(pointerId, info);
    if (singleTap) {
      multiTap = true;
      multiPointer2Id = pointerId;
    } else {
      singleTap = true;
      multiPointer1Id = pointerId;
    }
    dragFrom = info.eventPosition.game;
  }

  @override
  void onDragUpdate(int pointerId, DragUpdateInfo info) {
    super.onDragUpdate(pointerId, info);

    if (multiTap) {
      if (pointerId == multiPointer1Id) {
        multiPointer1 = info.eventPosition.game;
      } else if (pointerId == multiPointer2Id) {
        multiPointer2 = info.eventPosition.game;
      } else {
        // A third finger is touching the screen?
      }
      if ((multiPointer1.x != 0 && multiPointer1.y != 0) && (multiPointer2.x != 0 && multiPointer2.y != 0))  {
        handlePinchZoom();
      }
    } else {
      Vector2 currentPos = info.eventPosition.game.clone();
      currentPos.sub(dragFrom);
      dragFrom = info.eventPosition.game;
      dragTo.sub(currentPos);
    }
  }

  void handlePinchZoom() {
    double currentDistance = multiPointer1.distanceTo(multiPointer2);
    double zoomIncrease = (currentDistance - multiPointerDist);
    print("zoom increase: $zoomIncrease");
    double cameraZoom = 1;
    if (zoomIncrease > -50 && zoomIncrease <= -1) {
      cameraZoom += (zoomIncrease / 400);
    } else if (zoomIncrease < 50 && zoomIncrease >= 1) {
      cameraZoom += (zoomIncrease / 400);
    }
    camera.zoom *= cameraZoom;
    if (camera.zoom <= 1) {
      camera.zoom = 1;
    } else if (camera.zoom >= 4) {
      camera.zoom = 4;
    }
    multiPointerDist = currentDistance;
  }

  @override
  void onDragEnd(int pointerId, DragEndInfo info) {
    super.onDragEnd(pointerId, info);
    singleTap = false;
    if (multiTap) {
      multiTap = false;
    }
    multiPointer1Id = -1;
    multiPointer2Id = -1;
    multiPointer1 = Vector2.zero();
    multiPointer2 = Vector2.zero();
    multiPointerDist = 0.0;
  }

  @override
  void update(double dt) {
    super.update(dt);

    updateFps(dt);

    _world!.updateWorld(cameraPosition, camera.zoom, size);

    dragTo += dragAccelerateKey;
    cameraPosition.add(cameraVelocity * dt * 10);
    updateMapScroll();
  }

  updateFps(double dt) {
    frameTimes += dt;
    frames += 1;

    if ((frameTimes > 0 && frameTimes <= 0.5) && variant != 0) {
      variant = 0;
      _world!.updateVariant(variant);
    } else if ((frameTimes > 0.5 && frameTimes <= 1) && variant != 1) {
      variant = 1;
      _world!.updateVariant(variant);
    }
    if (frameTimes > 1) {
      fps = frames;
      print("fps: $frames");
      print("cameraPosition: $cameraPosition");
      frameTimes = 0;
      frames = 0;
    }
  }

  void updateMapScroll() {
    if ((dragTo.x - cameraPosition.x).abs() < 0.2) {
      cameraPosition.x = dragTo.x;
      cameraVelocity.x = 0;
    } else {
      cameraVelocity.x = (dragTo.x - cameraPosition.x);
      if (cameraVelocity.x > 100) {
        cameraVelocity.x = 100;
      } else if (cameraVelocity.x < -100) {
        cameraVelocity.x = -100;
      }
    }

    if ((dragTo.y - cameraPosition.y).abs() < 0.2) {
      cameraPosition.y = dragTo.y;
      cameraVelocity.y = 0;
    } else {
      cameraVelocity.y = (dragTo.y - cameraPosition.y);
      if (cameraVelocity.y > 100) {
        cameraVelocity.y = 100;
      } else if (cameraVelocity.y < -100) {
        cameraVelocity.y = -100;
      }
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
      if (event.logicalKey == LogicalKeyboardKey.keyA) {
        dragAccelerateKey.x = isKeyDown ? -5 : 0;
      } else if (event.logicalKey == LogicalKeyboardKey.keyD) {
        dragAccelerateKey.x = isKeyDown ? 5 : 0;
      } else if (event.logicalKey == LogicalKeyboardKey.keyW) {
        dragAccelerateKey.y = isKeyDown ? -5 : 0;
      } else if (event.logicalKey == LogicalKeyboardKey.keyS) {
        dragAccelerateKey.y = isKeyDown ? 5 : 0;
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
