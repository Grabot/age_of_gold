import 'package:age_of_gold/age_of_gold.dart';
import 'package:age_of_gold/views/user_interface/ui_function/user_interface_util/loading_box_change_notifier.dart';
import 'package:age_of_gold/views/user_interface/ui_function/user_interface_util/user_box_change_notifier.dart';
import 'package:flutter/material.dart';


class LoadingBox extends StatefulWidget {

  final AgeOfGold game;

  const LoadingBox({
    required Key key,
    required this.game
  }) : super(key: key);

  @override
  LoadingBoxState createState() => LoadingBoxState();
}

class LoadingBoxState extends State<LoadingBox> with TickerProviderStateMixin {

  final FocusNode _focusLoadingBox = FocusNode();
  bool showLoading = false;

  late LoadingBoxChangeNotifier loadingBoxChangeNotifier;

  @override
  void initState() {
    loadingBoxChangeNotifier = LoadingBoxChangeNotifier();
    loadingBoxChangeNotifier.addListener(loadingBoxChangeListener);

    _focusLoadingBox.addListener(_onFocusChange);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  loadingBoxChangeListener() {
    if (mounted) {
      if (!showLoading && loadingBoxChangeNotifier.getLoadingBoxVisible()) {
        setState(() {
          showLoading = true;
        });
      }
      if (showLoading && !loadingBoxChangeNotifier.getLoadingBoxVisible()) {
        setState(() {
          showLoading = false;
        });
      }
    }
  }

  void _onFocusChange() {
    widget.game.loadingBoxFocus(_focusLoadingBox.hasFocus);
  }

  Widget loadingBox(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      )
    );
  }

  Widget build(BuildContext context) {
    return Align(
      alignment: FractionalOffset.center,
      child: showLoading ? loadingBox(context) : Container()
    );
  }
}
