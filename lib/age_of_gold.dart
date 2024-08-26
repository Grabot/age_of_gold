import 'dart:math';

import 'package:age_of_gold/component/hexagon.dart';
import 'package:age_of_gold/services/auth_service_world.dart';
import 'package:age_of_gold/services/settings.dart';
import 'package:age_of_gold/services/socket_services.dart';
import 'package:age_of_gold/util/util.dart';
import 'package:age_of_gold/util/web_storage.dart';
import 'package:age_of_gold/views/login_view/login_window_change_notifier.dart';
import 'package:age_of_gold/views/user_interface/ui_views/profile_box/profile_change_notifier.dart';
import 'package:age_of_gold/world/hex_world.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:universal_html/html.dart' as html;

import 'constants/global.dart';
import 'util/game_start_login.dart';
import 'util/tapped_map.dart';


// flutter run -d chrome --release --web-hostname localhost --web-port 7357
class AgeOfGold extends FlameGame with DragCallbacks, KeyboardEvents, ScrollDetector, TapDetector {

  bool playFieldFocus = true;
  FocusNode gameFocus;
  AgeOfGold(this.gameFocus);
  SocketServices? socket;

  Vector2 cameraVelocity = Vector2.zero();

  late Settings settings;
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    socket = SocketServices();
    socket!.addListener(socketListener);
    settings = Settings();
    html.window.onBeforeUnload.listen((event) async {
      if (settings.getUser() != null) {
        socket!.leaveRoom(settings.getUser()!.id);
      }
    });
    // Start the game!
    // This can be done before the login check is done.
    // If the user can log in we will do it anyway and everything will update.
    startGame();
    // automatically log in using (possibly) stored tokens
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      loginCheck().then((loggedIn) {
        if (!loggedIn) {
          LoginWindowChangeNotifier().setLoginWindowVisible(true);
        }
      });
    });
  }

  HexWorld? gameWorld;
  startGame() async {
    gameWorld = HexWorld(0, 0);
    world.add(gameWorld!);
    gameSize = camera.viewport.size / camera.viewfinder.zoom;
    checkHexagonArraySize();
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

  @override
  void render(Canvas canvas) {
    super.render(canvas);
  }

  @override
  void onScroll(PointerScrollInfo info) {
    super.onScroll(info);
    double zoomIncrease = (info.raw.scrollDelta.dy/1000);
    camera.viewfinder.zoom *= (1 - zoomIncrease);

    clampZoom();

    gameSize = camera.viewport.size / camera.viewfinder.zoom;
    checkHexagonArraySize();
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

  double maxSpeed = 1000;
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
    tapPos.add(camera.viewfinder.position);
    // Screen position will be used to display the tile info box.
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

    gameWorld!.resetClick();
    gameWorld!.focusWorld();

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
      checkHexagonArraySize();
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
    List<int> tileProperties = getTileFromPos(camera.viewfinder.position.x, camera.viewfinder.position.y);
    int q = tileProperties[0];
    int r = tileProperties[1];

    Hexagon? hexagon = gameWorld!.getHexFromTile(q, r);
    if (hexagon != null) {
      int hexQ = hexagon.hexQArray;
      int hexR = hexagon.hexRArray;
      return [hexQ, hexR, q, r];
    }
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
      gameWorld!.resetClick();
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

  @override
  void onGameResize(Vector2 size) {
    // This needs to be done to position the HUD margin components correctly.
    double previousZoom = camera.viewfinder.zoom;
    camera.viewfinder.zoom = 1;
    super.onGameResize(size);
    camera.viewfinder.zoom = previousZoom;
    gameSize = camera.viewport.size / camera.viewfinder.zoom;
    checkHexagonArraySize();
  }

  int currentHexSize = 0;
  checkHexagonArraySize() {
    double currentZoom = camera.viewfinder.zoom;
    double currentWidth = gameSize.x;
    double currentHeight = gameSize.y;
    print("current zoom: $currentZoom  currentWidth: $currentWidth  currentHeight: $currentHeight");
    if (gameWorld != null) {
      int hexArraySize = 0;
      if (currentWidth < 2000 && currentHeight < 1100) {
        // tiny monitor resolution
        hexArraySize = 10 + (4 - currentZoom.floor()) * 4;
        if (currentZoom < 0.2) {
          hexArraySize += 20;
        } else if (currentZoom < 0.5) {
          hexArraySize += 8;
        }
        print("small: $hexArraySize");
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
        gameWorld!.setHexagonArraySize(hexArraySize);
      }
    }
  }

  List<int> getWraparounds(int hexQ, int hexR) {
    int wrapQ = 0;
    int wrapR = 0;

    if (hexQ < -mapSize) {
      while (hexQ < -mapSize) {
        hexQ += (2 * mapSize + 1);
        wrapQ -= 1;
      }
    }

    if (hexQ > mapSize) {
      while (hexQ > mapSize) {
        hexQ -= (2 * mapSize + 1);
        wrapQ += 1;
      }
    }

    if (hexR < -mapSize) {
      while (hexR < -mapSize) {
        hexR += (2 * mapSize + 1);
        wrapR -= 1;
      }
    }

    if (hexR > mapSize) {
      while (hexR > mapSize) {
        hexR -= (2 * mapSize + 1);
        wrapR += 1;
      }
    }

    return [hexQ, wrapQ, hexR, wrapR];
  }


  jumpToCoordinates(int tileQ, int tileR) {
    if (gameWorld != null) {
      // reset the camera zoom and hexagon array size.
      camera.viewfinder.zoom = 1;
      gameSize = camera.viewport.size / camera.viewfinder.zoom;
      checkHexagonArraySize();
      // Revert the transformations applied in getTileFromPos

      int hexQ = convertTileToHexQ(tileQ, tileR);
      int hexR = convertTileToHexR(tileQ, tileR);

      int newTileQ = tileQ;
      int newTileR = tileR;

      List<int> wraparounds1 = getWraparounds(hexQ, hexR);
      int actualHexQ = wraparounds1[0];
      int wrapQ = wraparounds1[1];
      int actualHexR = wraparounds1[2];
      int wrapR = wraparounds1[3];
      print("hexQ: $hexQ  hexR: $hexR  actualHexQ: $actualHexQ  actualHexR: $actualHexR  wrapQ: $wrapQ  wrapR: $wrapR");

      if (wrapQ != 0 || wrapR != 0) {
        // `wrapQ` or `wrapR` are not 0 so we are jumping to the point on the map that is wrapped around.
        // So we will subtract the wraparound values from the new tile values.
        // This is the opposite of when the camera is off the map and we get tiles and
        // calculate the wraparound values in a similar method but reversed in `addHexagon`
        if (wrapQ != 0) {
          newTileQ -= (mapSize * 2 + 1) * 9 * wrapQ;
          newTileR -= (mapSize * 2 + 1) * -4 * wrapQ;
        }
        if (wrapR  != 0) {
          newTileQ -= (mapSize * 2 + 1) * 5 * wrapR;
          newTileR -= (mapSize * 2 + 1) * -9 * wrapR;
        }
        showToastMessage("Given coordinates q: $tileQ and r: $tileR are out of bounds, jumping to wrapped coordinates: $newTileQ, $newTileR");
      }

      // We use the tile values to calculate the camera position.
      double cameraX = xSize * ((3/2) * newTileQ) + xSize;
      double cameraY = ySize * (sqrt(3)/2 * newTileQ + sqrt(3) * newTileR) * -1;

      // We position the camera to that position and also the dragTo position.
      camera.viewfinder.position = Vector2(cameraX, cameraY);
      dragTo = Vector2(cameraX, cameraY);
      // We reset the world to the new position so that it will retrieve the new hexagons.
      gameWorld!.resetWorld(actualHexQ, actualHexR);
    }
  }

}

// 123, 321
