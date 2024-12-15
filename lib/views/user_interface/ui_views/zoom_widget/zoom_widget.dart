import 'package:age_of_gold/age_of_gold.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

import '../../../../services/settings.dart';
import 'zoom_widget_change_notifier.dart';


class ZoomWidget extends StatefulWidget {

  final AgeOfGold game;

  const ZoomWidget({
    required Key key,
    required this.game
  }) : super(key: key);

  @override
  ZoomWidgetState createState() => ZoomWidgetState();
}

class ZoomWidgetState extends State<ZoomWidget> with TickerProviderStateMixin {

  Settings settings = Settings();
  late ZoomWidgetChangeNotifier zoomWidgetChangeNotifier;

  bool showZoom = false;

  @override
  void initState() {
    zoomWidgetChangeNotifier = ZoomWidgetChangeNotifier();
    zoomWidgetChangeNotifier.addListener(zoomListener);

    super.initState();
  }

  zoomListener() {
    if (mounted) {
      if (!showZoom && zoomWidgetChangeNotifier.getZoomWidgetVisible()) {
        setState(() {
          showZoom = true;
        });
      }
      if (showZoom && !zoomWidgetChangeNotifier.getZoomWidgetVisible()) {
        setState(() {
          showZoom = false;
        });
      }
    }
  }

  goBack() {
    setState(() {
      ZoomWidgetChangeNotifier().setZoomWidgetVisible(false);
    });
  }

  changeZoomValue(double newValue) {
    widget.game.setZoomValue(newValue);
    setState(() {
      zoomWidgetChangeNotifier.setZoomValue(newValue);
    });
  }

  changeZoomEnded(double newValue) {
    widget.game.setZoomValueEnd(newValue);
    setState(() {
      zoomWidgetChangeNotifier.setZoomValue(newValue);
      goBack();
    });
  }

  Widget zoomWidget() {
    return TapRegion(
      onTapOutside: (tap) {
        goBack();
      },
      child: Container(
        color: Colors.yellow,
        width: 50,
        height: 300,
        child: SfSlider.vertical(
          min: zoomWidgetChangeNotifier.minZoom,
          max: zoomWidgetChangeNotifier.maxZoom,
          value: zoomWidgetChangeNotifier.getZoomValue(),
          onChanged: (newValue) {
            changeZoomValue(newValue);
          },
          onChangeEnd: (newValue) {
            changeZoomEnded(newValue);
          },
        ),
      )
    );
  }

  Widget zoomWidgetBoxNormal(double widgetHeight, double widgetWidth, double fontSize) {
    return Row(
      children: [
        SizedBox(width: (widgetWidth - (50 + 10))),
        Column(
          children: [
            SizedBox(height: widgetHeight - 300),
            zoomWidget()
          ],
        )
      ],
    );
  }

  Widget zoomWidgetBoxMobile(double widgetHeight, double widgetWidth, double fontSize) {
    return Row(
      children: [
        SizedBox(width: (widgetWidth - (50 + 10))),
        Column(
          children: [
            SizedBox(height: widgetHeight - 300),
            zoomWidget()
          ],
        )
      ],
    );
  }

  Widget zoomBoxWidget() {
    double fontSize = 16;
    double topButtonAreaHeight = 100;
    topButtonAreaHeight += 10; // padding
    topButtonAreaHeight += 300;  // Actual height of zoomWidget
    double topButtonAreaWidth = 10 + 50 + 10 + 50 + 10 + 50;
    bool normalMode = true;
    if (MediaQuery.of(context).size.width <= 800) {
      double statusBarPadding = MediaQuery.of(context).viewPadding.top;
      topButtonAreaWidth = MediaQuery.of(context).size.width;

      topButtonAreaHeight = statusBarPadding + 10;  // padding
      topButtonAreaHeight += 30; // button
      topButtonAreaHeight += 10; // padding
      topButtonAreaHeight += 30; // button
      topButtonAreaHeight += 10; // padding
      topButtonAreaHeight += 300;  // Actual height of zoomWidget

      normalMode = false;
    }

    return SingleChildScrollView(
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.black.withOpacity(0.7),
        child: SizedBox(
          width: topButtonAreaWidth,
          height: topButtonAreaHeight,
          child: Align(
              alignment: FractionalOffset.topLeft,
              child: normalMode
                  ? zoomWidgetBoxNormal(topButtonAreaHeight, topButtonAreaWidth, fontSize)
                  : zoomWidgetBoxMobile(topButtonAreaHeight, topButtonAreaWidth, fontSize)
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return showZoom ? zoomBoxWidget() : Container();
  }
}

