import 'package:age_of_gold/component/hexagon.dart';
import 'package:age_of_gold/constants/global.dart';
import 'package:age_of_gold/services/settings.dart';
import 'package:age_of_gold/services/socket_services.dart';
import 'package:age_of_gold/util/tapped_map.dart';
import 'package:age_of_gold/util/util.dart';
import 'package:age_of_gold/world/hex_world.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:universal_html/html.dart' as html;

import 'views/user_interface/ui_views/profile_box/profile_change_notifier.dart';


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
  Vector2 cameraAcceleration = Vector2.zero();

  Vector2 dragAccelerateKey = Vector2.zero();
  Vector2 dragTo = Vector2.zero();
  Vector2 dragFrom = Vector2.zero();

  double frameTimes = 0.0;
  int frames = 0;
  int fps = 0;
  int variant = 0;

  int currentHexSize = 0;

  HexWorld? _world;

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
  bool pinched = false;
  double? distanceBetweenFingers;

  SocketServices? socket;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    startGame();
  }

  startGame() {
    camera.followVector2(cameraPosition, relativeOffset: Anchor.center);
    camera.zoom = 1;

    int startHexQ = 0;
    int startHexR = 0;
    calculateStartPosition(startHexQ, startHexR);
    _world = HexWorld(startHexQ, startHexR);
    add(_world!);

    checkHexagonArraySize();

    socket = SocketServices();

    socket!.addListener(socketListener);
    html.window.onBeforeUnload.listen((event) async {
      Settings settings = Settings();
      if (settings.getUser() != null) {
        socket!.leaveRoom(settings.getUser()!.id);
      }
    });
  }

  endGame() {
    remove(_world!);
  }

  socketListener() {
  }

  chatWindowFocus(bool chatWindowFocus) {
    playFieldFocus = !chatWindowFocus;
    if (playFieldFocus) {
      gameFocus.requestFocus();
    }
  }

  guildWindowFocus(bool guildFocus) {
    playFieldFocus = !guildFocus;
    if (playFieldFocus) {
      gameFocus.requestFocus();
    }
  }

  userBoxFocus(bool userFocus) {
    playFieldFocus = !userFocus;
    if (playFieldFocus) {
      gameFocus.requestFocus();
    }
  }

  friendWindowFocus(bool friendFocus) {
    playFieldFocus = !friendFocus;
    if (playFieldFocus) {
      gameFocus.requestFocus();
    }
  }

  loadingBoxFocus(bool loadingFocus) {
    playFieldFocus = !loadingFocus;
    if (playFieldFocus) {
      gameFocus.requestFocus();
    }
  }

  chatBoxFocus(bool chatFocus) {
    playFieldFocus = !chatFocus;
    if (playFieldFocus) {
      gameFocus.requestFocus();
    }
  }

  profileFocus(bool profileFocus) {
    playFieldFocus = !profileFocus;
    if (playFieldFocus) {
      gameFocus.requestFocus();
    }
  }

  addFriendFocus(bool addFriendFocus) {
    playFieldFocus = !addFriendFocus;
    if (playFieldFocus) {
      gameFocus.requestFocus();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
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
    camera.zoom = camera.zoom.clamp(0.1, 4);
  }

  @override
  void onTapUp(int pointerId, TapUpInfo info) {
    Vector2 tapPos = info.eventPosition.game;
    Vector2 screenPos = info.eventPosition.global;
    _world!.onTappedUp(tapPos, screenPos);
    _world!.focusWorld();
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
    _world!.focusWorld();
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
    pinched = true;
    if (distanceBetweenFingers == null) {
      distanceBetweenFingers = firstFinger!.distanceTo(secondFinger!);
    } else {
      double currentDistance = distanceBetweenFingers!;
      distanceBetweenFingers = firstFinger!.distanceTo(secondFinger!);
      double movementFingers = currentDistance - distanceBetweenFingers!;
      double zoomIncrease = (movementFingers / 200).clamp(-0.04, 0.04);
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
    if (pinched) {
      checkHexagonArraySize();
      pinched = false;
    }
    start = null;
    firstFinger = null;
    secondFinger = null;
    finger1 = false;
    finger2 = false;
    distanceBetweenFingers = null;
    pointerId1 = -1;
    pointerId2 = -1;
    // dragTo = cameraPosition;
    _world!.focusWorld();
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
      print("fps: $fps");
      frameTimes = 0;
      frames = 0;
      worldCheck();
    }
  }

  calculateStartPosition(int startHexQ, int startHexR) {
    // Similar to what is done in Hexagon constructor
    int tileQ = convertHexToTileQ(startHexQ, startHexR);
    int tileR = convertHexToTileR(startHexQ, startHexR);

    Vector2 startPos = getTilePosition(tileQ, tileR);
    // This will be the topRight of the tile, so we add an offset to get the center
    // The tile is 2*xSize, so we add xSize to get the center
    startPos.x += xSize;
    startPos.y += ySize;

    cameraPosition.add(startPos);
    dragTo.add(startPos);
  }

  void updateMapScroll() {
    // First limit the dragTo position
    // This is to ensure that scroll speed won't be too high.
    double newVelX = dragTo.x - cameraPosition.x;
    double newVelY = dragTo.y - cameraPosition.y;
    if (newVelX.abs() > maxSpeed) {
      double scalarSize = maxSpeed / newVelX.abs();
      newVelX *= scalarSize;
      newVelY += scalarSize;
    }
    if (newVelY.abs() > maxSpeed) {
      double scalarSize = maxSpeed / newVelY.abs();
      newVelY *= scalarSize;
      newVelY += scalarSize;
    }
    dragTo.x += newVelX - (dragTo.x - cameraPosition.x);
    dragTo.y += newVelY - (dragTo.y - cameraPosition.y);

    // Update the camera speed.
    if ((dragTo.x - cameraPosition.x).abs() < 0.2) {
      cameraPosition.x = dragTo.x;
      cameraVelocity.x = 0;
    } else {
      double newX = dragTo.x - cameraPosition.x;
      cameraVelocity.x = newX;
    }

    if ((dragTo.y - cameraPosition.y).abs() < 0.2) {
      cameraPosition.y = dragTo.y;
      cameraVelocity.y = 0;
    } else {
      double newY = dragTo.y - cameraPosition.y;
      cameraVelocity.y = newY;
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
      print("zoom ${camera.zoom}");
      // mousespeed between 10 and 140 for camera.zoom between 0.1 and 4
      double mouseSpeed = (40 / camera.zoom);
      if (camera.zoom < 1) {
        mouseSpeed = 40 + 10 / camera.zoom;
      }

      if (event.logicalKey == LogicalKeyboardKey.keyA) {
        dragAccelerateKey.x = isKeyDown ? -mouseSpeed : 0;
      } else if (event.logicalKey == LogicalKeyboardKey.keyD) {
        dragAccelerateKey.x = isKeyDown ? mouseSpeed : 0;
      } else if (event.logicalKey == LogicalKeyboardKey.keyW) {
        dragAccelerateKey.y = isKeyDown ? -mouseSpeed : 0;
      } else if (event.logicalKey == LogicalKeyboardKey.keyS) {
        dragAccelerateKey.y = isKeyDown ? mouseSpeed : 0;
      }

      if (event.logicalKey == LogicalKeyboardKey.keyP && isKeyDown) {
        ProfileChangeNotifier profileChangeNotifier = ProfileChangeNotifier();
        profileChangeNotifier.setProfileVisible(!profileChangeNotifier.getProfileVisible());
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
    print("current zoom: $currentZoom");
    double currentWidth = camera.canvasSize.x;
    double currentHeight = camera.canvasSize.y;
    if (_world != null) {
      int hexArraySize = 0;
      if (currentWidth < 2000 && currentHeight < 1100) {
        // tiny monitor resolution
        hexArraySize = 10 + (4 - currentZoom.floor()) * 4;
        if (currentZoom < 0.2) {
          hexArraySize += 20;
        } else if (currentZoom < 0.5) {
          hexArraySize += 8;
        }
        print("small: $hexArraySize  width: $currentWidth  height: $currentHeight");
      } else {
        // large 4k monitor resolution on full screen
        hexArraySize = 14 + (4 - currentZoom.floor()) * 6;
        if (currentZoom < 0.2) {
          hexArraySize += 36;
        } else if (currentZoom < 0.5) {
          hexArraySize += 10;
        }
        print("large: $hexArraySize");
      }
      if (currentHexSize != hexArraySize) {
        currentHexSize = hexArraySize;
        print("changing hexSize: $currentHexSize  zoom: $currentZoom");
        _world!.setHexagonArraySize(hexArraySize);
      }
    }
  }

  int problems = 0;
  worldCheck() {
    List<int> tileProperties = getTileFromPos(cameraPosition.x, cameraPosition.y);
    int q = tileProperties[0];
    int r = tileProperties[1];

    if (!_world!.worldCheck(q, r)) {
      if (problems == 20) {
        // This should only be a last resort, so after 20 seconds of no tile
        // we will attempt to fix the camera position
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

  List<int>? getCameraPos() {
    List<int> tileProperties = getTileFromPos(cameraPosition.x, cameraPosition.y);
    int q = tileProperties[0];
    int r = tileProperties[1];

    Hexagon? hexagon = _world!.getHexFromTile(q, r);
    if (hexagon != null) {
      int hexQ = hexagon.hexQArray;
      int hexR = hexagon.hexRArray;
      return [hexQ, hexR, q, r];
    }
    return null;
  }
}
