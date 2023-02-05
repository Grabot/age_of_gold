import 'dart:convert';
import 'dart:math';
import 'package:age_of_gold/component/tile.dart';
import 'package:age_of_gold/services/models/login_response.dart';
import 'package:age_of_gold/services/socket_services.dart';
import 'package:age_of_gold/util/hexagon_list.dart';
import 'package:age_of_gold/util/web_storage.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:tuple/tuple.dart';
import '../component/hexagon.dart';
import '../services/models/user.dart';
import '../services/settings.dart';
import '../constants/global.dart';
import 'package:age_of_gold/constants/route_paths.dart' as routes;

import 'navigation_service.dart';


List removeDuplicates(List hexToRetrieve) {
  List hexToRetrieveUnique = [];
  // If coordinates were found to retrieve
  if (hexToRetrieve.isNotEmpty) {
    for (int x = 0; x < hexToRetrieve.length; x++) {
      bool noRepeat = true;
      List value1 = hexToRetrieve[x];
      for (int y = x + 1; y < hexToRetrieve.length; y++) {
        List value2 = hexToRetrieve[y];
        if (value1[0] == value2[0] && value1[1] == value2[1]) {
          noRepeat = false;
          break;
        }
      }
      if (noRepeat) {
        hexToRetrieveUnique.add(value1);
      }
    }
  }
  return hexToRetrieveUnique;
}


getTilePosition(int q, int r) {
  double xPos = xSize * 3 / 2 * q - xSize;
  double yTr1 = ySize * (sqrt(3) / 2 * q);
  yTr1 *= -1; // The y axis gets positive going down, so we flip it.
  double yTr2 = ySize * (sqrt(3) * r);
  yTr2 *= -1; // The y axis gets positive going down, so we flip it.
  double yPos = yTr1 + yTr2 - ySize;

  // slight offset to put the center in the center and not a corner.
  xPos += xSize;
  yPos += ySize;

  return Vector2(xPos, yPos);
}

// All these conversions are based on the radius of 4.
int convertHexToTileQ(int hexQ, int hexR) {
  int tileQ = 9 * hexQ;
  tileQ += 5 * hexR;
  return tileQ;
}

int convertHexToTileR(int hexQ, int hexR) {
  int tileR = -4 * hexQ;
  tileR += -9 * hexR;
  return tileR;
}

int convertTileToHexQ(int tileQ, int tileR) {
  // q = 9x + 5y
  // r = -4x + -9y
  int q_2 = tileQ * 4;
  int r_2 = tileR * -9;
  int hexR = ((q_2 - r_2) / -61).round();
  int hexQ = ((tileQ - (5 * hexR)) / 9).round();
  return hexQ;
}

int convertTileToHexR(int tileQ, int tileR) {
  // q = 9x + 5y
  // r = -4x + -9y
  int q_2 = tileQ * 4;
  int r_2 = tileR * -9;
  int hexR = ((q_2 - r_2) / -61).round();
  return hexR;
}

bool emailValid(String possibleEmail) {
  return RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
      .hasMatch(possibleEmail);
}

successfulLogin(LoginResponse loginResponse) {
  SecureStorage secureStorage = SecureStorage();
  Settings settings = Settings();

  String? accessToken = loginResponse.getAccessToken();
  if (accessToken != null) {
    // the access token will be set in memory and local storage.
    settings.setAccessToken(accessToken);
    secureStorage.setAccessToken(accessToken);
    settings.setAccessTokenExpiration(Jwt.parseJwt(accessToken)['exp']);
  }

  String? refreshToken = loginResponse.getRefreshToken();
  if (refreshToken != null) {
    // the refresh token will only be set in memory.
    settings.setRefreshToken(refreshToken);
  }

  User? user = loginResponse.getUser();
  if (user != null) {
    settings.setUser(user);
    SocketServices().setUser(user);
  }
}

showToastMessage(String message) {
  showToast(
    message,
    duration: const Duration(milliseconds: 2000),
    position: ToastPosition.top,
    backgroundColor: Colors.white,
    radius: 1.0,
    textStyle: const TextStyle(fontSize: 30.0, color: Colors.black),
  );
}

Tile? getTile(HexagonList hexagonList, List<Tuple2> wrapCoordinates, data) {
  // We just need the q and r to find the tile and change type on the old tile
  int newTileQ = data["q"];
  int newTileR = data["r"];

  int tileQ = hexagonList.tileQ;
  int tileR = hexagonList.tileR;
  int qArray = tileQ + newTileQ - hexagonList.currentQ;
  int rArray = tileR + newTileR - hexagonList.currentR;

  // return hexagonList.tiles[qArray][rArray];
  if (qArray >= 0 &&
      qArray <= hexagonList.tiles.length &&
      rArray >= 0 &&
      rArray <= hexagonList.tiles[0].length) {
    Tile? test = hexagonList.tiles[qArray][rArray];
    return test;
  } else {
    return getTileWrap(hexagonList, qArray, rArray, newTileQ, newTileR, wrapCoordinates);
  }
}

Tile? getTileWrap(HexagonList hexagonList, int qArray, int rArray, int newTileQ, int newTileR, List<Tuple2> wrapCoordinates) {

  int tileQ = hexagonList.tileQ;
  int tileR = hexagonList.tileR;

  for (Tuple2 coordinates in wrapCoordinates) {
    int q = coordinates.item1;
    int r = coordinates.item2;

    int qAdded1 = (18 * mapSize + 9) * q;
    int rAdded1 = (-8 * mapSize - 4) * q;

    int qAdded2 = (10 * mapSize + 5) * r;
    int rAdded2 = (-18 * mapSize - 9) * r;

    int qAdded = qAdded1 + qAdded2;
    int rAdded = rAdded1 + rAdded2;

    int qTileOffset = newTileQ + qAdded;
    int rTileOffset = newTileR + rAdded;
    if (tileQ + qTileOffset - hexagonList.currentQ >= 0 &&
        tileQ + qTileOffset - hexagonList.currentQ <= hexagonList.tiles.length &&
        tileR + rTileOffset - hexagonList.currentR >= 0 &&
        tileR + rTileOffset - hexagonList.currentR <= hexagonList.tiles[0].length) {
      return hexagonList.tiles[tileQ + qTileOffset - hexagonList.currentQ][tileR + rTileOffset - hexagonList.currentR];
    }
  }

  return null;
}

logoutUser(Settings settings, NavigationService navigationService) {
  settings.logout();
  SecureStorage().logout().then((value) {
    navigationService.navigateTo(routes.HomeRoute, arguments: {'message': "Logged out"});
  });
}

addHexagon(HexagonList hexagonList, SocketServices socketServices, data) {
  Hexagon hexagon = Hexagon.fromJson(data);
  int tileQ = hexagonList.tileQ;
  int tileR = hexagonList.tileR;
  for (var tileData in jsonDecode(data["tiles"])) {
    int tileDataQ = tileData["q"];
    int tileDataR = tileData["r"];
    if (data.containsKey("wraparound")) {
      if (hexagon.getWrapQ() != 0) {
        tileDataQ += (mapSize * 2 + 1) * 9 * hexagon.getWrapQ();
        tileDataR += (mapSize * 2 + 1) * -4 * hexagon.getWrapQ();
      }
      if (hexagon.getWrapR() != 0) {
        tileDataQ += (mapSize * 2 + 1) * 5 * hexagon.getWrapR();
        tileDataR += (mapSize * 2 + 1) * -9 * hexagon.getWrapR();
      }

      Tuple2 coordinates = Tuple2<int, int>(hexagon.getWrapQ(), hexagon.getWrapR());
      if (!socketServices.getWrapCoordinates().contains(coordinates)) {
        socketServices.addWrapCoordinates(coordinates);
      }
    }

    Tile tile = Tile(
        tileDataQ,
        tileDataR,
        tileData["type"],
        tileData["q"],
        tileData["r"]
    );

    tile.hexagon = hexagon;
    hexagon.addTile(tile);
    int qTile = tileQ + tile.q - hexagonList.currentQ;
    int rTile = tileR + tile.r - hexagonList.currentR;
    if (qTile >= 0 && qTile < hexagonList.tiles.length &&
        rTile >= 0 && rTile < hexagonList.tiles[0].length) {
      hexagonList.tiles[qTile][rTile] = tile;
    }
  }

  hexagon.updateHexagon();
  int qHex = hexagonList.hexQ + hexagon.hexQArray - hexagonList.currentHexQ;
  int rHex = hexagonList.hexR + hexagon.hexRArray - hexagonList.currentHexR;
  if (qHex < 0 || qHex >= hexagonList.hexagons.length
      || rHex < 0 || rHex >= hexagonList.hexagons[0].length) {
    return;
  }
  hexagonList.hexagons[qHex][rHex] = hexagon;

  // check if the left hexagon is initialized and if it does not have it's right hexagon initialized
  int qHexLeft = qHex - 1;
  int rHexLeft = rHex;
  if (qHexLeft >= 0) {
    if (hexagonList.hexagons[qHexLeft][rHexLeft] != null
        && hexagonList.hexagons[qHexLeft][rHexLeft]!.right == null) {
      // If that is the case than set these two hexagons as neighbors
      hexagonList.hexagons[qHexLeft][rHexLeft]!.right = hexagon;
      hexagon.left = hexagonList.hexagons[qHexLeft][rHexLeft];
    }
  }
  // check if the right hexagon is initialized and if it does not have it's left hexagon initialized
  int qHexRight = qHex + 1;
  int rHexRight = rHex;
  if (qHexRight < hexagonList.hexagons.length) {
    if (hexagonList.hexagons[qHexRight][rHexRight] != null
        && hexagonList.hexagons[qHexRight][rHexRight]!.left == null) {
      hexagonList.hexagons[qHexRight][rHexRight]!.left = hexagon;
      hexagon.right = hexagonList.hexagons[qHexRight][rHexRight];
    }
  }
  // check if the top right hexagon is initialized and if it does not have it's bottom left hexagon initialized
  int qHexTopRight = qHex + 1;
  int rHexTopRight = rHex - 1;
  if (rHexTopRight >= 0 && qHexTopRight < hexagonList.hexagons.length) {
    if (hexagonList.hexagons[qHexTopRight][rHexTopRight] != null
        && hexagonList.hexagons[qHexTopRight][rHexTopRight]!.bottomLeft ==
            null) {
      // If that is the case than set these two hexagons as neighbors
      hexagonList.hexagons[qHexTopRight][rHexTopRight]!.bottomLeft = hexagon;
      hexagon.topRight = hexagonList.hexagons[qHexTopRight][rHexTopRight];
    }
  }
  // check if the bottom left hexagon is initialized and if it does not have it's top right hexagon initialized
  int qHexBottomLeft = qHex - 1;
  int rHexBottomLeft = rHex + 1;
  if (qHexBottomLeft >= 0 && rHexBottomLeft < hexagonList.hexagons.length) {
    if (hexagonList.hexagons[qHexBottomLeft][rHexBottomLeft] != null &&
        hexagonList.hexagons[qHexBottomLeft][rHexBottomLeft]!.topRight ==
            null) {
      // If that is the case than set these two hexagons as neighbors
      hexagonList.hexagons[qHexBottomLeft][rHexBottomLeft]!.topRight =
          hexagon;
      hexagon.bottomLeft =
      hexagonList.hexagons[qHexBottomLeft][rHexBottomLeft];
    }
  }
  // check if the bottom right hexagon is initialized and if it does not have it's bottom top left initialized
  int qHexBottomRight = qHex;
  int rHexBottomRight = rHex - 1;
  if (rHexBottomRight >= 0) {
    if (hexagonList.hexagons[qHexBottomRight][rHexBottomRight] != null &&
        hexagonList.hexagons[qHexBottomRight][rHexBottomRight]!.bottomRight ==
            null) {
      // If that is the case than set these two hexagons as neighbors
      hexagonList.hexagons[qHexBottomRight][rHexBottomRight]!.bottomRight =
          hexagon;
      hexagon.topLeft =
      hexagonList.hexagons[qHexBottomRight][rHexBottomRight];
    }
  }
  // check if the top left hexagon is initialized and if it does not have it's bottom right hexagon initialized
  int qHexTopLeft = qHex;
  int rHexTopLeft = rHex + 1;
  if (rHexTopLeft < hexagonList.hexagons.length) {
    if (hexagonList.hexagons[qHexTopLeft][rHexTopLeft] != null
        && hexagonList.hexagons[qHexTopLeft][rHexTopLeft]!.topLeft == null) {
      // If that is the case than set these two hexagons as neighbors
      hexagonList.hexagons[qHexTopLeft][rHexTopLeft]!.topLeft = hexagon;
      hexagon.bottomRight = hexagonList.hexagons[qHexTopLeft][rHexTopLeft];
    }
  }
}
