import 'package:age_of_gold/constants/route_paths.dart' as routes;
import 'package:age_of_gold/locator.dart';
import 'package:age_of_gold/services/auth_service_login.dart';
import 'package:age_of_gold/services/settings.dart';
import 'package:age_of_gold/constants/global.dart';
import 'package:age_of_gold/services/socket_services.dart';
import 'package:age_of_gold/user_interface/user_interface_util/profile_change_notifier.dart';
import 'package:age_of_gold/util/navigation_service.dart';
import 'package:age_of_gold/util/tapped_map.dart';
import 'package:age_of_gold/util/util.dart';
import 'package:age_of_gold/util/web_storage.dart';
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

  final NavigationService _navigationService = locator<NavigationService>();

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

  int currentHexSize = 0;

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

  SocketServices? socket;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    camera.followVector2(cameraPosition, relativeOffset: Anchor.center);
    camera.zoom = 4;

    int startHexQ = 0;
    int startHexR = 0;
    calculateStartPosition(startHexQ, startHexR);
    _world = World(startHexQ, startHexR);
    add(_world!);

    checkHexagonArraySize();

    socket = SocketServices();
    socket!.joinRoom();
    socket!.addListener(socketListener);
    html.window.onBeforeUnload.listen((event) async {
      socket!.leaveRoom();
    });

    checkLogIn(_navigationService);
  }

  checkLogIn(NavigationService navigationService) {
    Settings settings = Settings();
    if (settings.getUser() != null) {
      socket!.setUser(settings.getUser()!);
    } else {
      // User was not found, maybe not logged in?! or refreshed?!
      // Find accessToken to quickly fix this.
      String accessToken = settings.getAccessToken();
      if (accessToken != "") {
        logIn(navigationService, settings, accessToken);
      } else {
        // Also no accessToken found in settings. Check the storage.
        SecureStorage secureStorage = SecureStorage();
        secureStorage.getAccessToken().then((accessToken) {
          if (accessToken == null || accessToken == "") {
            print("just checking out the world?");
          } else {
            logIn(navigationService, settings, accessToken);
          }
        });
      }
    }
  }

  logIn(NavigationService navigationService, Settings settings, String accessToken) {
    AuthServiceLogin authService = AuthServiceLogin();
    authService.getTokenLogin(accessToken).then((loginResponse) {
      if (loginResponse.getResult()) {
        print("successfully logged in!");
        socket!.setUser(settings.getUser()!);
      }
    });
  }

  socketListener() {
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
    Vector2 tapPos = Vector2(info.eventPosition.game.x, info.eventPosition.game.y);
    _world!.onTappedUp(tapPos);
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

    // This will determine 12 variants in a 60fps game loop
    // int newVariant = (frameTimes / 0.084).floor();
    // // It should never exceed 11 (only 12 variants (including 0) for now)
    // if (variant <= 11) {
    //   if (variant != newVariant) {
    //     variant = newVariant;
    //     _world!.updateVariant(variant);
    //   }
    // }
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
      double mouseSpeed = 40;
      if (event.logicalKey == LogicalKeyboardKey.keyA) {
        dragAccelerateKey.x = isKeyDown ? -mouseSpeed : 0;
      } else if (event.logicalKey == LogicalKeyboardKey.keyD) {
        dragAccelerateKey.x = isKeyDown ? mouseSpeed : 0;
      } else if (event.logicalKey == LogicalKeyboardKey.keyW) {
        dragAccelerateKey.y = isKeyDown ? -mouseSpeed : 0;
      } else if (event.logicalKey == LogicalKeyboardKey.keyS) {
        dragAccelerateKey.y = isKeyDown ? mouseSpeed : 0;
      }

      if (event.logicalKey == LogicalKeyboardKey.keyI && isKeyDown) {
        AuthServiceLogin authService = AuthServiceLogin();
        authService.getTest().then((loginResponse) {
          if (loginResponse.getResult()) {
            print("it worked");
          } else if (!loginResponse.getResult()) {
            print("it failed");
          }
        }).onError((error, stackTrace) {
          print("BIG ERROR! Going straight back to the login screen");
          _navigationService.navigateTo(routes.HomeRoute);
        });
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
      } else {
        // large 4k monitor resolution on full screen
        hexArraySize = 14 + (4 - currentZoom.floor()) * 6;
        if (currentZoom < 0.2) {
          hexArraySize += 36;
        } else if (currentZoom < 0.5) {
          hexArraySize += 10;
        }
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

}
