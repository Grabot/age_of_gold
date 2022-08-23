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
  // The camera position will always be in the center of the screen
  Vector2 cameraPosition = Vector2.zero();
  Vector2 cameraVelocity = Vector2.zero();

  Vector2 dragAccelerateKey = Vector2.zero();

  Vector2 dragFrom = Vector2.zero();
  Vector2 dragTo = Vector2.zero();

  double frameTimes = 0.0;
  int frames = 0;
  int fps = 0;
  int variant = 0;

  late final World _world;

  double maxZoom = 4;
  double minZoom = 1;

  TextPaint textPaint = TextPaint(
    style: const TextStyle(
      fontSize: 48.0,
      fontFamily: 'Awesome Font',
      color: Colors.white
    ),
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    SocketServices socket = SocketServices();
    socket.setUserId(0);
    socket.joinRoom();

    camera.followVector2(cameraPosition, relativeOffset: Anchor.center);
    camera.zoom = 4;

    _world = World();
    add(_world);


    html.window.onBeforeUnload.listen((event) async {
      socket.leaveRoom();
    });
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    textPaint.render(canvas, "Age of Gold!\nFPS: $fps", Vector2(10, 10));
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
  }

  @override
  void onTapUp(int pointerId, TapUpInfo info) {
    Vector2 tapPos = Vector2(info.eventPosition.game.x, info.eventPosition.game.y);
    _world.onTappedUp(tapPos);
    super.onTapUp(pointerId, info);
  }

  @override
  void onTapDown(int pointerId, TapDownInfo info) {
    super.onTapDown(pointerId, info);
  }

  @override
  void onDragStart(int pointerId, DragStartInfo info) {
    super.onDragStart(pointerId, info);
  }

  @override
  void onDragUpdate(int pointerId, DragUpdateInfo info) {
    super.onDragUpdate(pointerId, info);
  }

  @override
  void onDragEnd(int pointerId, DragEndInfo info) {
    super.onDragEnd(pointerId, info);
  }

  @override
  void update(double dt) {
    super.update(dt);

    frameTimes += dt;
    frames += 1;

    if ((frameTimes > 0 && frameTimes <= 0.5) && variant != 0) {
      variant = 0;
      _world.updateVariant(variant);
    } else if ((frameTimes > 0.5 && frameTimes <= 1) && variant != 1) {
      variant = 1;
      _world.updateVariant(variant);
    }
    if (frameTimes > 1) {
      fps = frames;
      print("fps: $frames");
      print("cameraPosition: $cameraPosition");
      frameTimes = 0;
      frames = 0;
    }

    _world.updateWorld(cameraPosition, camera.zoom, size);

    dragTo += dragAccelerateKey;
    cameraPosition.add(cameraVelocity * dt * 10);
    updateMapScroll();
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
  }

  @override
  KeyEventResult onKeyEvent(
      RawKeyEvent event,
      Set<LogicalKeyboardKey> keysPressed,
      ) {
    final isKeyDown = event is RawKeyDownEvent;

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

  @override
  void onGameResize(Vector2 canvasSize) {
    // This needs to be done to position the HUD margin components correctly.
    double previousZoom = camera.zoom;
    camera.zoom = 1;
    super.onGameResize(canvasSize);
    camera.zoom = previousZoom;
  }
}
