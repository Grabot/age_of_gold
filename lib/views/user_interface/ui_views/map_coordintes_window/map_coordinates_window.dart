import 'package:age_of_gold/age_of_gold.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../services/settings.dart';
import '../../../../util/util.dart';
import 'map_coordinates_change_notifier.dart';


class MapCoordinatesWindow extends StatefulWidget {

  final AgeOfGold game;

  const MapCoordinatesWindow({
    required Key key,
    required this.game
  }) : super(key: key);

  @override
  MapCoordinatesWindowState createState() => MapCoordinatesWindowState();
}

class MapCoordinatesWindowState extends State<MapCoordinatesWindow> with TickerProviderStateMixin {

  final formKeyMapCoordinates = GlobalKey<FormState>();

  final FocusNode _focusMapCoordinatesWindow = FocusNode();
  late MapCoordinatesWindowChangeNotifier mapCoordinatesWindowChangeNotifier;

  Settings settings = Settings();

  bool showMapCoordinatesWindow = false;

  TextEditingController qController = TextEditingController();
  TextEditingController rController = TextEditingController();

  @override
  void initState() {
    mapCoordinatesWindowChangeNotifier = MapCoordinatesWindowChangeNotifier();
    mapCoordinatesWindowChangeNotifier.addListener(mapCoordinatesChangeListener);

    _focusMapCoordinatesWindow.addListener(_onFocusChange);
    settings.addListener(settingsChangeListener);

    setState(() {});
    super.initState();
  }


  mapCoordinatesChangeListener() {
    if (mounted) {
      if (!showMapCoordinatesWindow && mapCoordinatesWindowChangeNotifier.getMapCoordinatesVisible()) {
        setState(() {
          showMapCoordinatesWindow = true;
        });
      }
      if (showMapCoordinatesWindow && !mapCoordinatesWindowChangeNotifier.getMapCoordinatesVisible()) {
        setState(() {
          showMapCoordinatesWindow = false;
        });
      }
    }
  }

  _onFocusChange() {
    widget.game.windowFocus(_focusMapCoordinatesWindow.hasFocus);
  }

  settingsChangeListener() {
    if (mounted) {
      setState(() {});
    }
  }

  goBack() {
    setState(() {
      mapCoordinatesWindowChangeNotifier.setMapCoordinatesVisible(false);
    });
  }

  jumpMapCoordinates() {
    if (formKeyMapCoordinates.currentState!.validate()) {
      int q = int.parse(qController.text);
      int r = int.parse(rController.text);
      qController.text = "";
      rController.text = "";
      widget.game.jumpToCoordinates(q, r, true);
      goBack();
    }
  }

  Widget mapCoordinatesHeader(double headerWidth, double headerHeight, double fontSize) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          margin: const EdgeInsets.all(10),
          child: Text(
            "Jump to map Coordinates",
            style: simpleTextStyle(fontSize)
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          color: Colors.orangeAccent.shade200,
          tooltip: 'cancel',
          onPressed: () {
            setState(() {
              goBack();
            });
          }
        ),
      ]
    );
  }

  Widget mapCoordinatesExplanation(double headerWidth, double headerHeight, double fontSize) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: RichText(
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                    children: [
                      TextSpan(
                          text: "Fill in a Q and R coordinate to jump to that corresponding map tile.",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: fontSize,
                              fontWeight: FontWeight.bold
                          )
                      )
                    ]
                )
            ),
          ),
        ]
    );
  }


  bool isInteger(String value) => int.tryParse(value) != null;

  Widget mapCoordinatesMobile(double width, double mapCoordinatesHeight, double fontSize) {
    return Form(
      key: formKeyMapCoordinates,
      child: Column(
        children: [
          SizedBox(
              width: width,
              height: mapCoordinatesHeight,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: width/12,
                      height: mapCoordinatesHeight,
                      child: Text("Q: ", style: simpleTextStyle(fontSize*1.5)),
                    ),
                    const SizedBox(width: 5),
                    SizedBox(
                      width: width/2,
                      height: mapCoordinatesHeight,
                      child: TextFormField(
                        controller: qController,
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return "Fill in a number";
                          } else {
                            if (isInteger(val)) {
                              return null;
                            } else {
                              return "Fill in a number";
                            }
                          }
                        },
                        style: simpleTextStyle(fontSize),
                        decoration: const InputDecoration(
                            errorStyle: TextStyle(color: Colors.red)),
                      ),
                    ),
                  ]
              )
          ),
          SizedBox(height: 20),
          SizedBox(
            width: width,
            height: mapCoordinatesHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: width/12,
                  height: mapCoordinatesHeight,
                  child: Text("R: ", style: simpleTextStyle(fontSize*1.5)),
                ),
                const SizedBox(width: 5),
                SizedBox(
                  width: width/2,
                  height: mapCoordinatesHeight,
                  child: TextFormField(
                    controller: rController,
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return "Fill in a number";
                      } else {
                        if (isInteger(val)) {
                          return null;
                        } else {
                          return "Fill in a number";
                        }
                      }
                    },
                    style: simpleTextStyle(fontSize),
                    decoration: const InputDecoration(
                        errorStyle: TextStyle(color: Colors.red)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget mapCoordinates(double width, double mapCoordinatesHeight, double fontSize) {
    return Form(
      key: formKeyMapCoordinates,
      child: Column(
        children: [
          SizedBox(
            width: width,
            height: mapCoordinatesHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: width/12,
                  height: mapCoordinatesHeight,
                  child: Text("Q: ", style: simpleTextStyle(fontSize*1.5)),
                ),
                const SizedBox(width: 5),
                SizedBox(
                  width: width/6,
                  height: mapCoordinatesHeight,
                  child: TextFormField(
                    controller: qController,
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return "Fill in a number";
                      } else {
                        if (isInteger(val)) {
                          return null;
                        } else {
                          return "Fill in a number";
                        }
                      }
                    },
                    style: simpleTextStyle(fontSize),
                    decoration: const InputDecoration(
                        errorStyle: TextStyle(color: Colors.red)),
                  ),
                ),
                const SizedBox(width: 40),
                SizedBox(
                  width: width/12,
                  height: mapCoordinatesHeight,
                  child: Text("R: ", style: simpleTextStyle(fontSize*1.5)),
                ),
                const SizedBox(width: 5),
                SizedBox(
                  width: width/6,
                  height: mapCoordinatesHeight,
                  child: TextFormField(
                    controller: rController,
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return "Fill in a number";
                      } else {
                        if (isInteger(val)) {
                          return null;
                        } else {
                          return "Fill in a number";
                        }
                      }
                    },
                    style: simpleTextStyle(fontSize),
                    decoration: const InputDecoration(
                        errorStyle: TextStyle(color: Colors.red)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget jumpToCoordinatesButton(double width, double jumpToCoordinatesButtonHeight, double fontSize) {
    return SizedBox(
        width: width/2,
        height: jumpToCoordinatesButtonHeight,
        child: ElevatedButton(
          onPressed: () {
            jumpMapCoordinates();
          },
          style: buttonStyle(false, Colors.blue),
          child: Text(
              "Jump to Coordinates",
              style: simpleTextStyle(fontSize)
          ),
        ),
      );
  }

  Widget mapCoordinatesWindow(double width, double loginBoxSize, double fontSize) {
    double coordinateButtonWidth = width/2;
    bool normalMode = true;
    if (width <= 800) {
      // Don't show social buttons when not logged in or on mobile
      normalMode = false;
      coordinateButtonWidth = width;
    }
    return SingleChildScrollView(
      child: Container(
        color: Colors.amber,
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            mapCoordinatesHeader(width, 40, fontSize),
            const SizedBox(height: 40),
            mapCoordinatesExplanation(width, 40, fontSize),
            const SizedBox(height: 40),
            normalMode ? mapCoordinates(width, 40, fontSize) : mapCoordinatesMobile(width, 40, fontSize),
            const SizedBox(height: 40),
            jumpToCoordinatesButton(coordinateButtonWidth, 60, fontSize),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget mapCoordinatesBox(double screenWidth, double screenHeight, double fontSize) {
    double loginBoxSize = 100;
    double width = 800;
    double height = (screenHeight / 10) * 6;
    // When the width is smaller than this we assume it's mobile.
    if (screenWidth <= 800 || screenHeight - 200 > screenWidth) {
      width = screenWidth - 50;
      loginBoxSize = 50;
    }
    return Align(
      alignment: FractionalOffset.center,
      child: SizedBox(
          width: width,
          height: height,
          child: mapCoordinatesWindow(width, loginBoxSize, fontSize)
      ),
    );
  }

  Widget mapCoordinatesBoxWindow(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double fontSize = 16;
    return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.black.withOpacity(0.7),
        child: Center(
            child: TapRegion(
                onTapOutside: (tap) {
                  goBack();
                },
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(),
                      mapCoordinatesBox(screenWidth, screenHeight, fontSize),
                    ]
                )
            )
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: FractionalOffset.center,
        child: showMapCoordinatesWindow ? mapCoordinatesBoxWindow(context) : Container()
    );
  }
}

