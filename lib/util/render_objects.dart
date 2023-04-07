import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';


Widget avatarBox(double width, double height, String avatar) {
  return Stack(
    children: [
      Container(
        width: width,
        height: height,
        child: Center(
          child: ClipPath(
              clipper: HexagonClipper(),
              child: Image.memory(
                base64Decode(avatar),
                width: width * 0.78,  // some scale that I determined by trial and error
                height: height * 0.78,  // some scale that I determined by trial and error
                gaplessPlayback: true,
                fit: BoxFit.cover,
              )
          )
        ),
      ),
      Container(
          width: width,
          height: height,
          child: Center(
            child: Image.asset(
              "assets/images/ui/hexagon_frame_small.png",
              width: width,
              height: height,
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
    // width = 250
    // height = 250
    final path = Path();
    List point1 = getPointyHexCorner(size, 0);
    List point2 = getPointyHexCorner(size, 1);
    List point3 = getPointyHexCorner(size, 2);
    List point4 = getPointyHexCorner(size, 3);
    List point5 = getPointyHexCorner(size, 4);
    List point6 = getPointyHexCorner(size, 5);

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