import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';

import 'package:age_of_gold/world/world.dart';

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
  int variant = 0;

  late final World _world;

  double maxZoom = 4;
  double minZoom = 1;

  @override
  Future<void> onLoad() async {
    await super.onLoad();


    camera.followVector2(cameraPosition, relativeOffset: Anchor.center);
    camera.zoom = 1;

    _world = World();
    add(_world);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
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
    print("on tapped up! ${info.eventPosition.global}");
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
      dragAccelerateKey.x = isKeyDown ? -10 : 0;
    } else if (event.logicalKey == LogicalKeyboardKey.keyD) {
      dragAccelerateKey.x = isKeyDown ? 10 : 0;
    } else if (event.logicalKey == LogicalKeyboardKey.keyW) {
      dragAccelerateKey.y = isKeyDown ? -10 : 0;
    } else if (event.logicalKey == LogicalKeyboardKey.keyS) {
      dragAccelerateKey.y = isKeyDown ? 10 : 0;
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
