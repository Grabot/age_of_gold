
import 'dart:ui';

var flatSmallDirt1 = const Rect.fromLTWH(1, 1, 32, 14);
var flatSmallDirt2 = const Rect.fromLTWH(1, 1, 32, 14);

var flatSmallGrass1 = const Rect.fromLTWH(35, 1, 32, 14);
var flatSmallGrass2 = const Rect.fromLTWH(35, 1, 32, 14);

var flatSmallWater1 = const Rect.fromLTWH(69, 1, 32, 14);
var flatSmallWater2 = const Rect.fromLTWH(69, 1, 32, 14);

var pointSmallDirt1 = const Rect.fromLTWH(1, 1, 28, 16);
var pointSmallDirt2 = const Rect.fromLTWH(1, 1, 28, 16);

var pointSmallGrass1 = const Rect.fromLTWH(1, 19, 28, 16);
var pointSmallGrass2 = const Rect.fromLTWH(1, 19, 28, 16);

var pointSmallWater1 = const Rect.fromLTWH(1, 37, 28, 16);
var pointSmallWater2 = const Rect.fromLTWH(1, 37, 28, 16);

// They are the same, but they should be able to be different.
// So we define them all
List tileTextures = [
  tileAmethyst,
  tileBlack,
  tileBondiBlue,
  tileBrightSun,
  tileCaribbeanGreen,
  tileCeruleanBlue,
  tileConifer,
  tileCornflowerBlue,
  tileGovernorBay,
  tileGreenHaze,
  tileIron,
  tileMonza,
  tileOsloGray,
  tilePaarl,
  tilePictonBlue,
  tilePineGreen,
  tilePinkSalmon,
  tileSeance,
  tileSpice,
  tileSpray,
  tileVermillion,
  tileWebOrange,
  tileWhite,
  tileWildStrawberry,
];

// b44ac0
List tileAmethyst = [
  const Rect.fromLTWH(911, 59, 128, 56),
  const Rect.fromLTWH(511, 1, 32, 14),
  const Rect.fromLTWH(511, 1, 32, 14),
  const Rect.fromLTWH(511, 1, 32, 14),
  const Rect.fromLTWH(511, 1, 32, 14),
  const Rect.fromLTWH(511, 1, 32, 14),
  const Rect.fromLTWH(511, 1, 32, 14),
  const Rect.fromLTWH(511, 1, 32, 14),
  const Rect.fromLTWH(511, 1, 32, 14),
  const Rect.fromLTWH(511, 1, 32, 14),
  const Rect.fromLTWH(511, 1, 32, 14),
  const Rect.fromLTWH(511, 1, 32, 14),
  const Rect.fromLTWH(511, 1, 32, 14)
];

// 000000
List tileBlack = [
  const Rect.fromLTWH(1, 1, 128, 56),
  const Rect.fromLTWH(1, 1, 32, 14),
  const Rect.fromLTWH(1, 1, 32, 14),
  const Rect.fromLTWH(1, 1, 32, 14),
  const Rect.fromLTWH(1, 1, 32, 14),
  const Rect.fromLTWH(1, 1, 32, 14),
  const Rect.fromLTWH(1, 1, 32, 14),
  const Rect.fromLTWH(1, 1, 32, 14),
  const Rect.fromLTWH(1, 1, 32, 14),
  const Rect.fromLTWH(1, 1, 32, 14),
  const Rect.fromLTWH(1, 1, 32, 14),
  const Rect.fromLTWH(1, 1, 32, 14)
];

// 009eaa
List tileBondiBlue = [
  const Rect.fromLTWH(391, 59, 128, 56),
  const Rect.fromLTWH(69, 1, 32, 14),
  const Rect.fromLTWH(69, 1, 32, 14),
  const Rect.fromLTWH(69, 1, 32, 14),
  const Rect.fromLTWH(69, 1, 32, 14),
  const Rect.fromLTWH(69, 1, 32, 14),
  const Rect.fromLTWH(69, 1, 32, 14),
  const Rect.fromLTWH(69, 1, 32, 14),
  const Rect.fromLTWH(69, 1, 32, 14),
  const Rect.fromLTWH(69, 1, 32, 14),
  const Rect.fromLTWH(69, 1, 32, 14),
  const Rect.fromLTWH(69, 1, 32, 14)
];

// ffd635
List tileBrightSun = [
  const Rect.fromLTWH(1431, 1, 128, 56),
  const Rect.fromLTWH(749, 1, 32, 14),
  const Rect.fromLTWH(749, 1, 32, 14),
  const Rect.fromLTWH(749, 1, 32, 14),
  const Rect.fromLTWH(749, 1, 32, 14),
  const Rect.fromLTWH(749, 1, 32, 14),
  const Rect.fromLTWH(749, 1, 32, 14),
  const Rect.fromLTWH(749, 1, 32, 14),
  const Rect.fromLTWH(749, 1, 32, 14),
  const Rect.fromLTWH(749, 1, 32, 14),
  const Rect.fromLTWH(749, 1, 32, 14),
  const Rect.fromLTWH(749, 1, 32, 14)
];

// 00cc78
List tileCaribbeanGreen = [
  const Rect.fromLTWH(131, 1, 128, 56),
  const Rect.fromLTWH(137, 1, 32, 14),
  const Rect.fromLTWH(137, 1, 32, 14),
  const Rect.fromLTWH(137, 1, 32, 14),
  const Rect.fromLTWH(137, 1, 32, 14),
  const Rect.fromLTWH(137, 1, 32, 14),
  const Rect.fromLTWH(137, 1, 32, 14),
  const Rect.fromLTWH(137, 1, 32, 14),
  const Rect.fromLTWH(137, 1, 32, 14),
  const Rect.fromLTWH(137, 1, 32, 14),
  const Rect.fromLTWH(137, 1, 32, 14),
  const Rect.fromLTWH(137, 1, 32, 14)
];

// 2450a4
List tileCeruleanBlue = [
  const Rect.fromLTWH(781, 59, 128, 56),
  const Rect.fromLTWH(171, 1, 32, 14),
  const Rect.fromLTWH(171, 1, 32, 14),
  const Rect.fromLTWH(171, 1, 32, 14),
  const Rect.fromLTWH(171, 1, 32, 14),
  const Rect.fromLTWH(171, 1, 32, 14),
  const Rect.fromLTWH(171, 1, 32, 14),
  const Rect.fromLTWH(171, 1, 32, 14),
  const Rect.fromLTWH(171, 1, 32, 14),
  const Rect.fromLTWH(171, 1, 32, 14),
  const Rect.fromLTWH(171, 1, 32, 14),
  const Rect.fromLTWH(171, 1, 32, 14)
];

// 6a5cff
List tileCornflowerBlue = [
  const Rect.fromLTWH(131, 59, 128, 56),
  const Rect.fromLTWH(307, 1, 32, 14),
  const Rect.fromLTWH(307, 1, 32, 14),
  const Rect.fromLTWH(307, 1, 32, 14),
  const Rect.fromLTWH(307, 1, 32, 14),
  const Rect.fromLTWH(307, 1, 32, 14),
  const Rect.fromLTWH(307, 1, 32, 14),
  const Rect.fromLTWH(307, 1, 32, 14),
  const Rect.fromLTWH(307, 1, 32, 14),
  const Rect.fromLTWH(307, 1, 32, 14),
  const Rect.fromLTWH(307, 1, 32, 14),
  const Rect.fromLTWH(307, 1, 32, 14)
];

// 7eed56
List tileConifer = [
  const Rect.fromLTWH(261, 59, 128, 56),
  const Rect.fromLTWH(375, 1, 32, 14),
  const Rect.fromLTWH(375, 1, 32, 14),
  const Rect.fromLTWH(375, 1, 32, 14),
  const Rect.fromLTWH(375, 1, 32, 14),
  const Rect.fromLTWH(375, 1, 32, 14),
  const Rect.fromLTWH(375, 1, 32, 14),
  const Rect.fromLTWH(375, 1, 32, 14),
  const Rect.fromLTWH(375, 1, 32, 14),
  const Rect.fromLTWH(375, 1, 32, 14),
  const Rect.fromLTWH(375, 1, 32, 14),
  const Rect.fromLTWH(375, 1, 32, 14)
];

// 493ac1
List tileGovernorBay = [
  const Rect.fromLTWH(521, 59, 128, 56),
  const Rect.fromLTWH(239, 1, 32, 14),
  const Rect.fromLTWH(239, 1, 32, 14),
  const Rect.fromLTWH(239, 1, 32, 14),
  const Rect.fromLTWH(239, 1, 32, 14),
  const Rect.fromLTWH(239, 1, 32, 14),
  const Rect.fromLTWH(239, 1, 32, 14),
  const Rect.fromLTWH(239, 1, 32, 14),
  const Rect.fromLTWH(239, 1, 32, 14),
  const Rect.fromLTWH(239, 1, 32, 14),
  const Rect.fromLTWH(239, 1, 32, 14),
  const Rect.fromLTWH(239, 1, 32, 14)
];

// 00a368
List tileGreenHaze = [
  const Rect.fromLTWH(1, 59, 128, 56),
  const Rect.fromLTWH(103, 1, 32, 14),
  const Rect.fromLTWH(103, 1, 32, 14),
  const Rect.fromLTWH(103, 1, 32, 14),
  const Rect.fromLTWH(103, 1, 32, 14),
  const Rect.fromLTWH(103, 1, 32, 14),
  const Rect.fromLTWH(103, 1, 32, 14),
  const Rect.fromLTWH(103, 1, 32, 14),
  const Rect.fromLTWH(103, 1, 32, 14),
  const Rect.fromLTWH(103, 1, 32, 14),
  const Rect.fromLTWH(103, 1, 32, 14),
  const Rect.fromLTWH(103, 1, 32, 14)
];

// d4d7d9
List tileIron = [
  const Rect.fromLTWH(1041, 59, 128, 56),
  const Rect.fromLTWH(579, 1, 32, 14),
  const Rect.fromLTWH(579, 1, 32, 14),
  const Rect.fromLTWH(579, 1, 32, 14),
  const Rect.fromLTWH(579, 1, 32, 14),
  const Rect.fromLTWH(579, 1, 32, 14),
  const Rect.fromLTWH(579, 1, 32, 14),
  const Rect.fromLTWH(579, 1, 32, 14),
  const Rect.fromLTWH(579, 1, 32, 14),
  const Rect.fromLTWH(579, 1, 32, 14),
  const Rect.fromLTWH(579, 1, 32, 14),
  const Rect.fromLTWH(579, 1, 32, 14)
];

// be0039
List tileMonza = [
  const Rect.fromLTWH(1041, 1, 128, 56),
  const Rect.fromLTWH(545, 1, 32, 14),
  const Rect.fromLTWH(545, 1, 32, 14),
  const Rect.fromLTWH(545, 1, 32, 14),
  const Rect.fromLTWH(545, 1, 32, 14),
  const Rect.fromLTWH(545, 1, 32, 14),
  const Rect.fromLTWH(545, 1, 32, 14),
  const Rect.fromLTWH(545, 1, 32, 14),
  const Rect.fromLTWH(545, 1, 32, 14),
  const Rect.fromLTWH(545, 1, 32, 14),
  const Rect.fromLTWH(545, 1, 32, 14),
  const Rect.fromLTWH(545, 1, 32, 14)
];

// 898d90
List tileOsloGray = [
  const Rect.fromLTWH(781, 1, 128, 56),
  const Rect.fromLTWH(443, 1, 32, 14),
  const Rect.fromLTWH(443, 1, 32, 14),
  const Rect.fromLTWH(443, 1, 32, 14),
  const Rect.fromLTWH(443, 1, 32, 14),
  const Rect.fromLTWH(443, 1, 32, 14),
  const Rect.fromLTWH(443, 1, 32, 14),
  const Rect.fromLTWH(443, 1, 32, 14),
  const Rect.fromLTWH(443, 1, 32, 14),
  const Rect.fromLTWH(443, 1, 32, 14),
  const Rect.fromLTWH(443, 1, 32, 14),
  const Rect.fromLTWH(443, 1, 32, 14)
];

// 9c6926
List tilePaarl = [
  const Rect.fromLTWH(391, 1, 128, 56),
  const Rect.fromLTWH(477, 1, 32, 14),
  const Rect.fromLTWH(477, 1, 32, 14),
  const Rect.fromLTWH(477, 1, 32, 14),
  const Rect.fromLTWH(477, 1, 32, 14),
  const Rect.fromLTWH(477, 1, 32, 14),
  const Rect.fromLTWH(477, 1, 32, 14),
  const Rect.fromLTWH(477, 1, 32, 14),
  const Rect.fromLTWH(477, 1, 32, 14),
  const Rect.fromLTWH(477, 1, 32, 14),
  const Rect.fromLTWH(477, 1, 32, 14),
  const Rect.fromLTWH(477, 1, 32, 14)
];

// 3690ea
List tilePictonBlue = [
  const Rect.fromLTWH(911, 1, 128, 56),
  const Rect.fromLTWH(205, 1, 32, 14),
  const Rect.fromLTWH(205, 1, 32, 14),
  const Rect.fromLTWH(205, 1, 32, 14),
  const Rect.fromLTWH(205, 1, 32, 14),
  const Rect.fromLTWH(205, 1, 32, 14),
  const Rect.fromLTWH(205, 1, 32, 14),
  const Rect.fromLTWH(205, 1, 32, 14),
  const Rect.fromLTWH(205, 1, 32, 14),
  const Rect.fromLTWH(205, 1, 32, 14),
  const Rect.fromLTWH(205, 1, 32, 14),
  const Rect.fromLTWH(205, 1, 32, 14)
];

// 00756f
List tilePineGreen = [
  const Rect.fromLTWH(651, 1, 128, 56),
  const Rect.fromLTWH(35, 1, 32, 14),
  const Rect.fromLTWH(35, 1, 32, 14),
  const Rect.fromLTWH(35, 1, 32, 14),
  const Rect.fromLTWH(35, 1, 32, 14),
  const Rect.fromLTWH(35, 1, 32, 14),
  const Rect.fromLTWH(35, 1, 32, 14),
  const Rect.fromLTWH(35, 1, 32, 14),
  const Rect.fromLTWH(35, 1, 32, 14),
  const Rect.fromLTWH(35, 1, 32, 14),
  const Rect.fromLTWH(35, 1, 32, 14),
  const Rect.fromLTWH(35, 1, 32, 14)
];

// ff99aa
List tilePinkSalmon = [
  const Rect.fromLTWH(1171, 1, 128, 56),
  const Rect.fromLTWH(681, 1, 32, 14),
  const Rect.fromLTWH(681, 1, 32, 14),
  const Rect.fromLTWH(681, 1, 32, 14),
  const Rect.fromLTWH(681, 1, 32, 14),
  const Rect.fromLTWH(681, 1, 32, 14),
  const Rect.fromLTWH(681, 1, 32, 14),
  const Rect.fromLTWH(681, 1, 32, 14),
  const Rect.fromLTWH(681, 1, 32, 14),
  const Rect.fromLTWH(681, 1, 32, 14),
  const Rect.fromLTWH(681, 1, 32, 14),
  const Rect.fromLTWH(681, 1, 32, 14)
];

// 811e9f
List tileSeance = [
  const Rect.fromLTWH(651, 59, 128, 56),
  const Rect.fromLTWH(409, 1, 32, 14),
  const Rect.fromLTWH(409, 1, 32, 14),
  const Rect.fromLTWH(409, 1, 32, 14),
  const Rect.fromLTWH(409, 1, 32, 14),
  const Rect.fromLTWH(409, 1, 32, 14),
  const Rect.fromLTWH(409, 1, 32, 14),
  const Rect.fromLTWH(409, 1, 32, 14),
  const Rect.fromLTWH(409, 1, 32, 14),
  const Rect.fromLTWH(409, 1, 32, 14),
  const Rect.fromLTWH(409, 1, 32, 14),
  const Rect.fromLTWH(409, 1, 32, 14)
];

// 6d482f
List tileSpice = [
  const Rect.fromLTWH(261, 1, 128, 56),
  const Rect.fromLTWH(341, 1, 32, 14),
  const Rect.fromLTWH(341, 1, 32, 14),
  const Rect.fromLTWH(341, 1, 32, 14),
  const Rect.fromLTWH(341, 1, 32, 14),
  const Rect.fromLTWH(341, 1, 32, 14),
  const Rect.fromLTWH(341, 1, 32, 14),
  const Rect.fromLTWH(341, 1, 32, 14),
  const Rect.fromLTWH(341, 1, 32, 14),
  const Rect.fromLTWH(341, 1, 32, 14),
  const Rect.fromLTWH(341, 1, 32, 14),
  const Rect.fromLTWH(341, 1, 32, 14)
];

// 51e9f4
List tileSpray = [
  const Rect.fromLTWH(521, 1, 128, 56),
  const Rect.fromLTWH(273, 1, 32, 14),
  const Rect.fromLTWH(273, 1, 32, 14),
  const Rect.fromLTWH(273, 1, 32, 14),
  const Rect.fromLTWH(273, 1, 32, 14),
  const Rect.fromLTWH(273, 1, 32, 14),
  const Rect.fromLTWH(273, 1, 32, 14),
  const Rect.fromLTWH(273, 1, 32, 14),
  const Rect.fromLTWH(273, 1, 32, 14),
  const Rect.fromLTWH(273, 1, 32, 14),
  const Rect.fromLTWH(273, 1, 32, 14),
  const Rect.fromLTWH(273, 1, 32, 14)
];

// ff4500
List tileVermillion = [
  const Rect.fromLTWH(1301, 1, 128, 56),
  const Rect.fromLTWH(647, 1, 32, 14),
  const Rect.fromLTWH(647, 1, 32, 14),
  const Rect.fromLTWH(647, 1, 32, 14),
  const Rect.fromLTWH(647, 1, 32, 14),
  const Rect.fromLTWH(647, 1, 32, 14),
  const Rect.fromLTWH(647, 1, 32, 14),
  const Rect.fromLTWH(647, 1, 32, 14),
  const Rect.fromLTWH(647, 1, 32, 14),
  const Rect.fromLTWH(647, 1, 32, 14),
  const Rect.fromLTWH(647, 1, 32, 14),
  const Rect.fromLTWH(647, 1, 32, 14)
];

// ffa800
List tileWebOrange = [
  const Rect.fromLTWH(1301, 59, 128, 56),
  const Rect.fromLTWH(715, 1, 32, 14),
  const Rect.fromLTWH(715, 1, 32, 14),
  const Rect.fromLTWH(715, 1, 32, 14),
  const Rect.fromLTWH(715, 1, 32, 14),
  const Rect.fromLTWH(715, 1, 32, 14),
  const Rect.fromLTWH(715, 1, 32, 14),
  const Rect.fromLTWH(715, 1, 32, 14),
  const Rect.fromLTWH(715, 1, 32, 14),
  const Rect.fromLTWH(715, 1, 32, 14),
  const Rect.fromLTWH(715, 1, 32, 14),
  const Rect.fromLTWH(715, 1, 32, 14)
];

// ffffff
List tileWhite = [
  const Rect.fromLTWH(1431, 59, 128, 56),
  const Rect.fromLTWH(783, 1, 32, 14),
  const Rect.fromLTWH(783, 1, 32, 14),
  const Rect.fromLTWH(783, 1, 32, 14),
  const Rect.fromLTWH(783, 1, 32, 14),
  const Rect.fromLTWH(783, 1, 32, 14),
  const Rect.fromLTWH(783, 1, 32, 14),
  const Rect.fromLTWH(783, 1, 32, 14),
  const Rect.fromLTWH(783, 1, 32, 14),
  const Rect.fromLTWH(783, 1, 32, 14),
  const Rect.fromLTWH(783, 1, 32, 14),
  const Rect.fromLTWH(783, 1, 32, 14)
];

// ff3881
List tileWildStrawberry = [
  const Rect.fromLTWH(1171, 59, 128, 56),
  const Rect.fromLTWH(613, 1, 32, 14),
  const Rect.fromLTWH(613, 1, 32, 14),
  const Rect.fromLTWH(613, 1, 32, 14),
  const Rect.fromLTWH(613, 1, 32, 14),
  const Rect.fromLTWH(613, 1, 32, 14),
  const Rect.fromLTWH(613, 1, 32, 14),
  const Rect.fromLTWH(613, 1, 32, 14),
  const Rect.fromLTWH(613, 1, 32, 14),
  const Rect.fromLTWH(613, 1, 32, 14),
  const Rect.fromLTWH(613, 1, 32, 14),
  const Rect.fromLTWH(613, 1, 32, 14)
];
