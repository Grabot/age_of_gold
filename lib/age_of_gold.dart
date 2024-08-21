import 'dart:math';
import 'dart:ui';

import 'package:age_of_gold/component/get_texture.dart';
import 'package:age_of_gold/services/settings.dart';
import 'package:age_of_gold/services/socket_services.dart';
import 'package:age_of_gold/views/user_interface/ui_views/profile_box/profile_change_notifier.dart';
import 'package:age_of_gold/world/hex_world.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:universal_html/html.dart' as html;


// flutter run -d chrome --release --web-hostname localhost --web-port 7357
class AgeOfGold extends FlameGame with DragCallbacks, KeyboardEvents, ScrollDetector, TapDetector {

  bool playFieldFocus = true;
  FocusNode gameFocus;
  AgeOfGold(this.gameFocus);
  SocketServices? socket;

  Vector2 cameraVelocity = Vector2.zero();
  Vector2 cameraAcceleration = Vector2.zero();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    socket = SocketServices();
    socket!.addListener(socketListener);
    html.window.onBeforeUnload.listen((event) async {
      Settings settings = Settings();
      if (settings.getUser() != null) {
        socket!.leaveRoom(settings.getUser()!.id);
      }
    });
    startGame();
  }

  HexWorld? gameWorld;
  startGame() async {

    gameWorld = HexWorld(0, 0);
    world.add(gameWorld!);

    gameSize = camera.viewport.size / camera.viewfinder.zoom;
  }

  endGame() {
    world.remove(gameWorld!);
  }

  socketListener() {
  }

  windowFocus(bool chatWindowFocus) {
    playFieldFocus = !chatWindowFocus;
    if (playFieldFocus) {
      gameFocus.requestFocus();
    }
  }

  final Paint linePaint = Paint()..color = const Color(0xffff0000);
  @override
  void render(Canvas canvas) {
    super.render(canvas);
  }

  @override
  void onScroll(PointerScrollInfo info) {
    super.onScroll(info);
    double zoomIncrease = (info.raw.scrollDelta.dy/1000);
    camera.viewfinder.zoom *= (1 - zoomIncrease);

    gameSize = camera.viewport.size / camera.viewfinder.zoom;

    clampZoom();
  }

  Vector2 gameSize = Vector2(0, 0);

  @override
  void update(double dt) {
    super.update(dt);
    updateFps(dt);

    gameWorld!.updateWorld(camera.viewfinder.position, camera.viewfinder.zoom, gameSize);

    dragTo += dragAccelerateKey;
    Vector2 movement = cameraVelocity * dt * 10;
    camera.moveBy(movement);
    updateMapScroll();
  }

  double frameTimes = 0.0;
  int frames = 0;
  int fps = 0;
  updateFps(double dt) {
    frameTimes += dt;
    frames += 1;

    if (frameTimes >= 1) {
      fps = frames;
      print("fps: $fps");
      frameTimes = 0;
      frames = 0;
    }
  }

  double maxSpeed = 100000;
  void updateMapScroll() {
    // First limit the dragTo position
    // This is to ensure that scroll speed won't be too high.
    Vector2 newVel = dragTo - camera.viewfinder.position;

    if (newVel.x.abs() > maxSpeed) {
      double scalarSize = maxSpeed / newVel.x.abs();
      newVel.x *= scalarSize;
      newVel.y += scalarSize;
    }
    if (newVel.y.abs() > maxSpeed) {
      double scalarSize = maxSpeed / newVel.y.abs();
      newVel.y *= scalarSize;
      newVel.y += scalarSize;
    }
    dragTo += newVel - (dragTo - camera.viewfinder.position);

    // Update the camera speed.
    if ((dragTo.x - camera.viewfinder.position.x).abs() < 0.2) {
      camera.viewfinder.position.x = dragTo.x;
      cameraVelocity.x = 0;
    } else {
      double newX = dragTo.x - camera.viewfinder.position.x;
      cameraVelocity.x = newX;
    }

    if ((dragTo.y - camera.viewfinder.position.y).abs() < 0.2) {
      camera.viewfinder.position.y = dragTo.y;
      cameraVelocity.y = 0;
    } else {
      double newY = dragTo.y - camera.viewfinder.position.y;
      cameraVelocity.y = newY;
    }
  }

  @override
  void onTapUp(TapUpInfo info) {
    double cameraZoom = camera.viewfinder.zoom;
    Vector2 tapPos = info.eventPosition.widget / cameraZoom;
    tapPos.sub(gameSize / 2);
    Vector2 screenPos = info.eventPosition.global;
    gameWorld!.onTappedUp(tapPos, screenPos);
    gameWorld!.focusWorld();
    super.onTapUp(info);
  }

  // We use the pointer variables to determine regular or multidrag
  int pointerId1 = -1;
  int pointerId2 = -1;

  Vector2 dragAccelerateKey = Vector2.zero();
  Vector2 dragTo = Vector2.zero();
  Vector2 dragFrom = Vector2.zero();

  Vector2? firstFinger;
  Vector2? secondFinger;

  bool finger1 = false;
  bool finger2 = false;
  bool pinched = false;
  double? distanceBetweenFingers;

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);

    // All distances need to be normalized using the current zoom.
    double cameraZoom = camera.viewfinder.zoom;
    // Vector2 dragStart = (event.localPosition) * cameraZoom;
    start = event.localPosition / cameraZoom;
    start!.sub((gameSize / cameraZoom) / 2);
    // We need to move the pointer according to the current camera position

    // _world!.resetClick();
    // _world!.focusWorld();

    if (pointerId1 == -1) {
      pointerId1 = event.pointerId;
    } else if (pointerId1 != -1 && pointerId2 == -1) {
      pointerId2 = event.pointerId;
    }
  }

  Vector2? start;
  Vector2? end;

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);

    double cameraZoom = camera.viewfinder.zoom;
    end = event.localEndPosition / cameraZoom;
    end!.sub((gameSize / cameraZoom) / 2);

    if (pointerId1 != -1 && pointerId2 == -1) {
      Vector2 distance = (start! - end!);
      start = event.localEndPosition / cameraZoom;
      start!.sub((gameSize / cameraZoom) / 2);

      dragTo.add(distance);
    } else if (pointerId1 != -1 && pointerId2 != -1) {

      if (event.pointerId == pointerId1) {
        firstFinger = (event.localEndPosition) * cameraZoom;
        firstFinger!.sub((camera.viewfinder.position) * cameraZoom);
        finger1 = true;
      } else if (event.pointerId == pointerId2) {
        secondFinger = (event.localEndPosition) * cameraZoom;
        secondFinger!.sub((camera.viewfinder.position) * cameraZoom);
        finger2 = true;
      }
      // // Once 2 fingers have been detected and updated we do the pinch zoom
      // if (finger1 && finger2) {
      //   pinchZoom();
      // }
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    resetDrag();
  }

  resetDrag() {
    if (pinched) {
      // checkHexagonArraySize();
      pinched = false;
    }
    start = null;
    end = null;
    firstFinger = null;
    secondFinger = null;
    finger1 = false;
    finger2 = false;
    distanceBetweenFingers = null;
    pointerId1 = -1;
    pointerId2 = -1;
    // dragTo = cameraPosition;
    // _world!.focusWorld();
  }

  pinchZoom() {
    pinched = true;
    if (distanceBetweenFingers == null) {
      distanceBetweenFingers = firstFinger!.distanceTo(secondFinger!);
    } else {
      double currentDistance = distanceBetweenFingers!;
      distanceBetweenFingers = firstFinger!.distanceTo(secondFinger!);
      double movementFingers = currentDistance - distanceBetweenFingers!;
      double zoomIncrease = (movementFingers / 200).clamp(-0.04, 0.04);
      camera.viewfinder.zoom *= (1 - zoomIncrease);
      clampZoom();
    }
    finger1 = false;
    finger2 = false;
    firstFinger = null;
    secondFinger = null;
  }

  void clampZoom() {
    camera.viewfinder.zoom = camera.viewfinder.zoom.clamp(0.1, 4);
  }

  List<int>? getCameraPos() {

    return null;
  }

  @override
  KeyEventResult onKeyEvent(
      KeyEvent event,
      Set<LogicalKeyboardKey> keysPressed,
      ) {

    final isKeyDown = event is KeyDownEvent;

    if (!playFieldFocus && isKeyDown) {
      return KeyEventResult.ignored;
    } else {
      // _world!.resetClick();
      // mousespeed between 10 and 140 for camera.zoom between 0.1 and 4
      double mouseSpeed = (40 / camera.viewfinder.zoom);
      if (camera.viewfinder.zoom < 1) {
        mouseSpeed = 40 + 10 / camera.viewfinder.zoom;
      }

      if (event.logicalKey == LogicalKeyboardKey.keyA) {
        dragAccelerateKey.x = isKeyDown ? mouseSpeed : 0;
      } else if (event.logicalKey == LogicalKeyboardKey.keyD) {
        dragAccelerateKey.x = isKeyDown ? -mouseSpeed : 0;
      } else if (event.logicalKey == LogicalKeyboardKey.keyW) {
        dragAccelerateKey.y = isKeyDown ? mouseSpeed : 0;
      } else if (event.logicalKey == LogicalKeyboardKey.keyS) {
        dragAccelerateKey.y = isKeyDown ? -mouseSpeed : 0;
      }

      if (event.logicalKey == LogicalKeyboardKey.keyP && isKeyDown) {
        ProfileChangeNotifier profileChangeNotifier = ProfileChangeNotifier();
        profileChangeNotifier.setProfileVisible(!profileChangeNotifier.getProfileVisible());
      }

      return KeyEventResult.handled;
    }
  }
}

// class GameWorld extends Component {
//
//   SpriteBatch? spriteBatch;
//
//   Vector2? start;
//   Vector2? end;
//   updateTemp(Vector2? start, Vector2? end) {
//     this.start = start;
//     this.end = end;
//   }
//   @override
//   Future<void> onLoad() async {
//     await super.onLoad();
//     bgRect = const Rect.fromLTWH(-20, -20, 40, 40);
//
//     SpriteBatch.load('tile_variants/sprite_regular.png').then((SpriteBatch batch) {
//       spriteBatch = batch;
//
//       spriteBatch!.add(
//           source: tileTextures[0][0],
//           offset: Vector2(0, 0),
//           scale: 1
//       );
//     });
//   }
//
//   @override
//   void update(double dt) {
//   }
//
//   late final Rect bgRect;
//   final Paint bgPaint = Paint()..color = const Color(0xffff0000);
//   @override
//   void render(Canvas canvas) {
//
//     if (spriteBatch != null) {
//       spriteBatch!.render(canvas);
//     }
//
//     if (start != null && end != null) {
//       Offset offsetStart = Offset(start!.x, start!.y);
//       Offset offsetEnd = Offset(end!.x, end!.y);
//       canvas.drawLine(offsetStart, offsetEnd, bgPaint);
//     }
//   }
// }