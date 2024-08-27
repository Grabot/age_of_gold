import 'package:age_of_gold/age_of_gold.dart';
import 'package:age_of_gold/services/settings.dart';
import 'package:age_of_gold/views/user_interface/ui_views/map_coordinates/map_coordinates_change_notifier.dart';
import 'package:age_of_gold/views/user_interface/ui_views/map_coordintes_window/map_coordinates_change_notifier.dart';
import 'package:flutter/material.dart';


class MapCoordinates extends StatefulWidget {

  final AgeOfGold game;

  const MapCoordinates({
    required Key key,
    required this.game
  }) : super(key: key);

  @override
  MapCoordinatesState createState() => MapCoordinatesState();
}

class MapCoordinatesState extends State<MapCoordinates> {

  int qCoordinate = 0;
  int rCoordinate = 0;

  late MapCoordinatesChangeNotifier mapCoordinatesChangeNotifier;

  @override
  void initState() {
    mapCoordinatesChangeNotifier = MapCoordinatesChangeNotifier();
    mapCoordinatesChangeNotifier.addListener(mapCoordinateChangeListener);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  mapCoordinateChangeListener() {
    if (mounted) {
      List<int> coordinates = mapCoordinatesChangeNotifier.getCoordinates();
      setState(() {
        qCoordinate = coordinates[0];
        rCoordinate = coordinates[1];
      });
    }
  }

  Widget showLocationIcon() {
    return const Icon(
      Icons.location_on,
      color: Colors.white,
      shadows: <Shadow>[Shadow(color: Colors.black, blurRadius: 3.0)],
    );
  }

  Widget showCoordinate(String coordinate) {
    return Stack(
        children: [
          Text(
            coordinate,
            style: TextStyle(
              fontSize: 20,
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 4
                ..color = Colors.black45,
            ),
          ),
          Text(
            coordinate,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
        ]
    );
  }

  Widget mapCoordinatesBox(BuildContext context, double widthMapCoordinates) {
    return GestureDetector(
      onTap: () {
        if (Settings().getUser() != null) {
          MapCoordinatesWindowChangeNotifier().setMapCoordinatesVisible(true);
        }
      },
      child: SizedBox(
        width: widthMapCoordinates,
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            showLocationIcon(),
            const SizedBox(width: 20),
            showCoordinate("Q: $qCoordinate"),
            const SizedBox(width: 10),
            showCoordinate("R: $rCoordinate"),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double widthMapCoordinates = 250;
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Positioned(
        left: width / 2 - (widthMapCoordinates/2),
        bottom: height/10,
        child: mapCoordinatesBox(context, widthMapCoordinates)
    );
  }
}
