
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
List tileAmethyst = [
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

List tileBlack = [
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
  const Rect.fromLTWH(1, 1, 32, 14),
  const Rect.fromLTWH(1, 1, 32, 14)
];

List tileBondiBlue = [
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
  const Rect.fromLTWH(69, 1, 32, 14),
  const Rect.fromLTWH(69, 1, 32, 14)
];

List tileBrightSun = [
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
  const Rect.fromLTWH(749, 1, 32, 14),
  const Rect.fromLTWH(749, 1, 32, 14)
];

List tileCaribbeanGreen = [
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
  const Rect.fromLTWH(137, 1, 32, 14),
  const Rect.fromLTWH(137, 1, 32, 14)
];

List tileCeruleanBlue = [
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
  const Rect.fromLTWH(171, 1, 32, 14),
  const Rect.fromLTWH(171, 1, 32, 14)
];

List tileCornflowerBlue = [
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
  const Rect.fromLTWH(307, 1, 32, 14),
  const Rect.fromLTWH(307, 1, 32, 14)
];

List tileConifer = [
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
  const Rect.fromLTWH(375, 1, 32, 14),
  const Rect.fromLTWH(375, 1, 32, 14)
];

List tileGovernorBay = [
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
  const Rect.fromLTWH(239, 1, 32, 14),
  const Rect.fromLTWH(239, 1, 32, 14)
];

List tileGreenHaze = [
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
  const Rect.fromLTWH(103, 1, 32, 14),
  const Rect.fromLTWH(103, 1, 32, 14)
];

List tileIron = [
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
  const Rect.fromLTWH(579, 1, 32, 14),
  const Rect.fromLTWH(579, 1, 32, 14)
];

List tileMonza = [
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
  const Rect.fromLTWH(545, 1, 32, 14),
  const Rect.fromLTWH(545, 1, 32, 14)
];

List tileOsloGray = [
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
  const Rect.fromLTWH(443, 1, 32, 14),
  const Rect.fromLTWH(443, 1, 32, 14)
];

List tilePaarl = [
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
  const Rect.fromLTWH(477, 1, 32, 14),
  const Rect.fromLTWH(477, 1, 32, 14)
];

List tilePictonBlue = [
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
  const Rect.fromLTWH(205, 1, 32, 14),
  const Rect.fromLTWH(205, 1, 32, 14)
];

List tilePineGreen = [
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
  const Rect.fromLTWH(35, 1, 32, 14),
  const Rect.fromLTWH(35, 1, 32, 14)
];

List tilePinkSalmon = [
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
  const Rect.fromLTWH(681, 1, 32, 14),
  const Rect.fromLTWH(681, 1, 32, 14)
];

List tileSeance = [
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
  const Rect.fromLTWH(409, 1, 32, 14),
  const Rect.fromLTWH(409, 1, 32, 14)
];

List tileSpice = [
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
  const Rect.fromLTWH(341, 1, 32, 14),
  const Rect.fromLTWH(341, 1, 32, 14)
];

List tileSpray = [
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
  const Rect.fromLTWH(273, 1, 32, 14),
  const Rect.fromLTWH(273, 1, 32, 14)
];

List tileVermillion = [
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
  const Rect.fromLTWH(647, 1, 32, 14),
  const Rect.fromLTWH(647, 1, 32, 14)
];

List tileWebOrange = [
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
  const Rect.fromLTWH(715, 1, 32, 14),
  const Rect.fromLTWH(715, 1, 32, 14)
];

List tileWhite = [
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
  const Rect.fromLTWH(783, 1, 32, 14),
  const Rect.fromLTWH(783, 1, 32, 14)
];

List tileWildStrawberry = [
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
  const Rect.fromLTWH(613, 1, 32, 14),
  const Rect.fromLTWH(613, 1, 32, 14)
];
