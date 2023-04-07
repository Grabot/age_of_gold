import 'package:age_of_gold/age_of_gold.dart';
import 'package:age_of_gold/views/user_interface/ui_function/user_interface_util/change_avatar_change_notifier.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';


class ChangeAvatarBox extends StatefulWidget {

  final AgeOfGold game;

  const ChangeAvatarBox({
    required Key key,
    required this.game
  }) : super(key: key);

  @override
  ChangeAvatarBoxState createState() => ChangeAvatarBoxState();
}

class ChangeAvatarBoxState extends State<ChangeAvatarBox> with TickerProviderStateMixin {

  late ChangeAvatarChangeNotifier changeAvatarChangeNotifier;

  bool showChangeAvatar = false;

  @override
  void initState() {
    changeAvatarChangeNotifier = ChangeAvatarChangeNotifier();
    changeAvatarChangeNotifier.addListener(changeAvatarChangeListener);
    super.initState();
  }

  changeAvatarChangeListener() {
    if (mounted) {
      if (!showChangeAvatar && changeAvatarChangeNotifier.getChangeAvatarVisible()) {
        setState(() {
          showChangeAvatar = true;
        });
      }
      if (showChangeAvatar && !changeAvatarChangeNotifier.getChangeAvatarVisible()) {
        setState(() {
          showChangeAvatar = false;
        });
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  CropController cropController = CropController();

  Widget changeAvatarBox() {
    return Container(
      width: 800,
      height: 800,
      color: Colors.cyan,
      child: Crop(
          image: changeAvatarChangeNotifier.getAvatar(),
          controller: cropController,
          onCropped: (image) {
            // do something with image data
          }
      ),
    );
  }

  Widget build(BuildContext context) {
    return Align(
      alignment: FractionalOffset.center,
      child: showChangeAvatar ?  changeAvatarBox() : Container()
    );
  }
}
