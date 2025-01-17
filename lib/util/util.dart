import 'dart:convert';
import 'dart:math';
import 'package:age_of_gold/age_of_gold.dart';
import 'package:age_of_gold/constants/route_paths.dart' as routes;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:oktoast/oktoast.dart';
import 'package:tuple/tuple.dart';
import '../component/hexagon.dart';
import '../component/tile.dart';
import '../constants/global.dart';
import '../services/auth_service_guild.dart';
import '../services/auth_service_login.dart';
import '../services/models/login_response.dart';
import '../services/models/user.dart';
import '../services/settings.dart';
import '../services/socket_services.dart';
import '../views/user_interface/ui_util/chat_messages.dart';
import '../views/user_interface/ui_views/are_you_sure_box/are_you_sure_change_notifier.dart';
import '../views/user_interface/ui_views/guild_window/guild_information.dart';
import '../views/user_interface/ui_views/profile_box/profile_change_notifier.dart';
import 'hexagon_list.dart';
import 'navigation_service.dart';
import 'web_storage.dart';


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


Vector2 getTilePosition(int q, int r, int rotation) {
  double xPos = 0;
  double yPos = 0;
  int s = -q - r;

  if (rotation % 2 == 0) {

    if (rotation == 2) {
      int rTemp = r;
      r = -s;
      q = -rTemp;
    } else if (rotation == 4) {
      // // s,  q
      int qTemp = q;
      q = s;
      r = qTemp;
    } else if (rotation == 6) {
      // s,  q
      q = -q;
      r = -r;
    } else if (rotation == 8) {
      int rTemp = r;
      r = s;
      q = rTemp;
    } else if (rotation == 10) {
      r = -q;
      q = -s;
    }

    xPos = xSize * 3 / 2 * q - xSize;
    double yTr1 = ySize * (sqrt(3) / 2) * q;
    double yTr2 = ySize * (sqrt(3) * r);
    yPos = yTr1 + yTr2 - ySize;
    xPos *= -1;
    yPos *= -1;
    yPos -= (ySize * 2);
    xPos -= (xSize * 2);
  } else {

    // We calculate as if [q, s]
    int rTemp = r;
    r = s;
    s = rTemp;
    if (rotation == 1) {
    } else if (rotation == 3) {
      r = -q;
      q = -rTemp;
    } else if (rotation == 5) {
      q = r;
      r = s;
    } else if (rotation == 7) {
      q = -q;
      r = -r;
    } else if (rotation == 9) {
      r = q;
      q = s;
    } else if (rotation == 11) {
      q = -r;
      r = -rTemp;
    }

    double xTr1Point = xSize * sqrt(3) * q;
    double xTr2Point = xSize * (sqrt(3) / 2) * r;
    double xPosPoint = xTr1Point + xTr2Point - xSize;
    double yPosPoint = ySize * 3 / 2 * r - ySize;
    xPos = xPosPoint * -1;
    yPos = yPosPoint;
    xPos -= (xSize * 2);
  }

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

additionalLoginInformation(User me) {
  // Retrieve some other user specific data
  // If the user is part of a guild and he has a high enough rank,
  // we want to know if there are member join request
  // If the user is not part of a guild we want to know if he has guild invites.
  if (me.getGuild() == null) {
    AuthServiceGuild().getRequestedUserGot(true).then((response) {
      if (response != null) {
        me.setGuildInvites(response);
        ProfileChangeNotifier().notify();
      }
    });
  } else {
    AuthServiceGuild().getRequestedGuildSend(me.getGuild()!.getGuildId(), true).then((response) {
      if (response != null) {
        GuildInformation().requestedMembers = response;
        ProfileChangeNotifier().notify();
      }
    });
  }
}

successfulLogin(LoginResponse loginResponse) async {
  SecureStorage secureStorage = SecureStorage();
  Settings settings = Settings();

  String? accessToken = loginResponse.getAccessToken();
  if (accessToken != null) {
    // the access token will be set in memory and local storage.
    settings.setAccessToken(accessToken);
    settings.setAccessTokenExpiration(Jwt.parseJwt(accessToken)['exp']);
    await secureStorage.setAccessToken(accessToken);
  }

  String? refreshToken = loginResponse.getRefreshToken();
  if (refreshToken != null) {
    // the refresh token will only be set in memory.
    settings.setRefreshToken(refreshToken);
    settings.setRefreshTokenExpiration(Jwt.parseJwt(refreshToken)['exp']);
    await secureStorage.setRefreshToken(refreshToken);
  }

  User? user = loginResponse.getUser();
  if (user != null) {
    settings.setUser(user);
    if (user.getAvatar() != null) {
      settings.setAvatar(user.getAvatar()!);
    }
    SocketServices().login(user.id);
    additionalLoginInformation(user);
  }
  ChatMessages().login();
  settings.setLoggingIn(false);
  ProfileChangeNotifier().notify();
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

logoutUser(Settings settings, NavigationService navigationService) async {
  if (settings.getUser() != null) {
    await AuthServiceLogin().logout();  // we assume it will work, but it doesn't matter if it doesn't
    SocketServices().logout(settings.getUser()!.id);
    if (settings.getUser()!.getGuild() != null) {
      SocketServices().leaveGuildRoom(settings.getUser()!.getGuild()!.getGuildId());
    }
  }
  GuildInformation().clearInformation();
  ChatMessages().clearPersonalMessages();
  ProfileChangeNotifier().setProfileVisible(false);
  settings.logout();
  SecureStorage().logout().then((value) {
    AreYouSureBoxChangeNotifier().setAreYouSureBoxVisible(false);
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

  hexagon.updateHexagon(Settings().getRotation());
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

ButtonStyle buttonStyle(bool active, MaterialColor buttonColor) {
  return ButtonStyle(
      overlayColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
          if (states.contains(WidgetState.hovered)) {
            return buttonColor.shade600;
          }
          if (states.contains(WidgetState.pressed)) {
            return buttonColor.shade300;
          }
          return null;
        },
      ),
      backgroundColor: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) {
            return active? buttonColor.shade800 : buttonColor;
          }),
      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          )
      )
  );
}

TextStyle simpleTextStyle(double fontSize) {
  return TextStyle(color: Colors.white, fontSize: fontSize);
}

InputDecoration textFieldInputDecoration(String hintText) {
  return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: Colors.white54,
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
      ),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white54),
      ));
}

String getTileColour(int tileType) {
  if (tileType == 0) {
    return "Amethyst";
  } else if (tileType == 1) {
    return "Black";
  } else if (tileType == 2) {
    return "Bondi Blue";
  } else if (tileType == 3) {
    return "Bright Sun";
  } else if (tileType == 4) {
    return "Caribbean Green";
  } else if (tileType == 5) {
    return "Cerulean Blue";
  } else if (tileType == 6) {
    return "Conifer";
  } else if (tileType == 7) {
    return "Cornflower Blue";
  } else if (tileType == 8) {
    return "Governor Bay";
  } else if (tileType == 9) {
    return "Green Haze";
  } else if (tileType == 10) {
    return "Iron";
  } else if (tileType == 11) {
    return "Monza";
  } else if (tileType == 12) {
    return "Oslo Gray";
  } else if (tileType == 13) {
    return "Paarl";
  } else if (tileType == 14) {
    return "Picton Blue";
  } else if (tileType == 15) {
    return "Pine Green";
  } else if (tileType == 16) {
    return "Pink Salmon";
  } else if (tileType == 17) {
    return "Seance";
  } else if (tileType == 18) {
    return "Spice";
  } else if (tileType == 19) {
    return "Spray";
  } else if (tileType == 20) {
    return "Vermillion";
  } else if (tileType == 21) {
    return "Web Orange";
  } else if (tileType == 22) {
    return "White";
  } else if (tileType == 23) {
    return "Wild Strawberry";
  } else {
    return "Type unknown";
  }
}

goToGame(NavigationService navigationService, AgeOfGold game) {
  // If the game was already mounted we want to reload the initialization
  // If it is not mounted it will be loaded in the onLoad
  navigationService.navigateTo(routes.HomeRoute);
}

Color getDetailColour(int detailColour) {
  if (detailColour == 0) {
    return Colors.cyan.shade600;
  } else if (detailColour == 1) {
    return Colors.cyan.shade700;
  } else {
    return Colors.cyan.shade300;
  }
}

Widget addIcon(double profileButtonSize, IconData icon, Color iconColour) {
  return SizedBox(
    width: profileButtonSize,
    height: profileButtonSize,
    child: ClipOval(
      child: Material(
          color: iconColour,
          child: Icon(icon)
      ),
    ),
  );
}

Color overviewColour(int state, Color colour0, Color colour1, Color colour2) {
  if (state == 0) {
    return colour0;
  } else if (state == 1) {
    return colour1;
  } else {
    return colour2;
  }
}

int getRankId(String guildRank) {
  if (guildRank == "Trader") {
    return 3;
  } else if (guildRank == "Merchant") {
    return 2;
  } else if (guildRank == "Officer") {
    return 1;
  } else if (guildRank == "Guildmaster") {
    return 0;
  } else {
    return 4;
  }
}

Widget ageOfGoldLogo(double width, bool normalMode) {
  return Container(
      padding: normalMode
          ? EdgeInsets.only(left: width/3, right: width/3)
          : EdgeInsets.only(left: width/8, right: width/8),
      alignment: Alignment.center,
      child: Image.asset("assets/images/hex_place_logo.png")
  );
}
