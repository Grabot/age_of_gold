import 'dart:math';
import 'package:age_of_gold/services/models/login_response.dart';
import 'package:age_of_gold/util/web_storage.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:jwt_decode/jwt_decode.dart';
import '../services/models/user.dart';
import '../services/settings.dart';
import 'global.dart';


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
