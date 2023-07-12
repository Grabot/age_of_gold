import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';


Widget getAvatar(double avatarBoxWidth, double avatarBoxHeight, Uint8List? avatar) {
  if (avatar != null) {
    return Image.memory(
      avatar,
      width: avatarBoxWidth * 0.785,  // some scale that I determined by trial and error
      height: avatarBoxHeight * 0.785,  // some scale that I determined by trial and error
      gaplessPlayback: true,
      fit: BoxFit.cover,
    );
  } else {
    return Image.asset(
      "assets/images/default_avatar.png",
      width: avatarBoxWidth,
      height: avatarBoxHeight,
      gaplessPlayback: true,
      fit: BoxFit.cover,
    );
  }
}

Widget avatarBox(double avatarBoxWidth, double avatarBoxHeight, Uint8List? avatar) {
  return Stack(
    children: [
      SizedBox(
        width: avatarBoxWidth,
        height: avatarBoxHeight,
        child: Center(
          child: ClipPath(
              clipper: HexagonClipper(),
              child: getAvatar(avatarBoxWidth, avatarBoxHeight, avatar)
          )
        ),
      ),
      SizedBox(
          width: avatarBoxWidth,
          height: avatarBoxHeight,
          child: Center(
            child: Image.asset(
              "assets/images/ui/hexagon_frame_small_fill.png",
              width: avatarBoxWidth,
              height: avatarBoxHeight,
              fit: BoxFit.cover,
            ),
          )
      ),
    ],
  );
}

Widget getGuildAvatar(double avatarBoxWidth, double avatarBoxHeight, Uint8List? avatar) {
  if (avatar != null) {
    return Image.memory(
      avatar,
      width: avatarBoxWidth * 0.835,  // some scale that I determined by trial and error
      height: avatarBoxHeight * 0.835,  // some scale that I determined by trial and error
      gaplessPlayback: true,
      fit: BoxFit.cover,
    );
  } else {
    return Image.asset(
      "assets/images/ui/icon/shield_default_temp.png",
      width: avatarBoxWidth,
      height: avatarBoxHeight,
      gaplessPlayback: true,
      fit: BoxFit.cover,
    );
  }
}

Widget guildAvatarBox(double avatarBoxWidth, double avatarBoxHeight, Uint8List? avatar) {
  return Stack(
    children: [
      SizedBox(
        width: avatarBoxWidth,
        height: avatarBoxHeight,
        child: Center(
            child: ClipPath(
                clipper: GuildClipper(),
                child: getGuildAvatar(avatarBoxWidth, avatarBoxHeight, avatar)
            )
        ),
      ),
      SizedBox(
          width: avatarBoxWidth,
          height: avatarBoxHeight,
          child: Center(
            child: Image.asset(
              "assets/images/ui/gold_shield_frame.png",
              width: avatarBoxWidth,
              height: avatarBoxHeight,
              fit: BoxFit.cover,
            ),
          )
      ),
    ],
  );
}


class HexagonClipper extends CustomClipper<Path> {

  @override
  Path getClip(Size size) {
    final path = Path();
    List point1 = getPointyHexCorner(size, 0);
    List point2 = getPointyHexCorner(size, 1);
    List point3 = getPointyHexCorner(size, 2);
    List point4 = getPointyHexCorner(size, 3);
    List point5 = getPointyHexCorner(size, 4);
    List point6 = getPointyHexCorner(size, 5);

    point2[1] = size.height;
    point3[1] = size.height;
    point5[1] = 0.0;
    point6[1] = 0.0;

    path.moveTo(point1[0], point1[1]);
    path.lineTo(point2[0], point2[1]);
    path.lineTo(point3[0], point3[1]);
    path.lineTo(point4[0], point4[1]);
    path.lineTo(point5[0], point5[1]);
    path.lineTo(point6[0], point6[1]);
    path.close();
    return path;
  }

  List getPointyHexCorner(Size size, double i) {
    double angleDeg = 60 * i;

    double angleRad = pi/180 * angleDeg;
    double pointX = (size.width/2 * cos(angleRad)) + size.width/2;
    double pointY = (size.height/2 * sin(angleRad)) + size.height/2;
    return [pointX, pointY];
  }

  @override
  bool shouldReclip(HexagonClipper oldClipper) => false;
}

class GuildClipper extends CustomClipper<Path> {

  @override
  Path getClip(Size size) {
    final path = Path();
    double width = size.width;
    double height = size.height;

    List point1 = [width/2, height/93,875];
    List point2 = [width/4.90441, height/8.94047];
    List point3 = [width/27.79166, height/11.734375];
    List point4 = [width/83.375, height/1.61853];
    List point5 = [width/5.05303, height/1.19586];
    List point6 = [width/2.41666, height/1.03159];
    List point7 = [(width/2)-2, height];
    List point8 = [(width/2)+2, height];
    List point9 = [width/1.70153, height/1.03159];
    List point10 = [width/1.24440, height/1.19586];
    List point11 = [width/1.010606, height/1.61853];
    List point12 = [width/1.035714, height/11.734375];
    List point13 = [width/1.253759, height/8.94047];

    path.moveTo(point1[0], point1[1]);
    path.lineTo(point2[0], point2[1]);
    path.lineTo(point3[0], point3[1]);
    path.lineTo(point4[0], point4[1]);
    path.lineTo(point5[0], point5[1]);
    path.lineTo(point6[0], point6[1]);
    path.lineTo(point7[0], point7[1]);
    path.lineTo(point8[0], point8[1]);
    path.lineTo(point9[0], point9[1]);
    path.lineTo(point10[0], point10[1]);
    path.lineTo(point11[0], point11[1]);
    path.lineTo(point12[0], point12[1]);
    path.lineTo(point13[0], point13[1]);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(GuildClipper oldClipper) => false;
}
