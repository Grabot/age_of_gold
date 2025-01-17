import 'dart:convert';
import 'package:age_of_gold/age_of_gold.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as image;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../../services/auth_service_guild.dart';
import '../../../../services/models/user.dart';
import '../../../../services/settings.dart';
import '../../../../util/render_objects.dart';
import '../../../../util/util.dart';
import '../../ui_util/crop/controller.dart';
import '../../ui_util/crop/crop.dart';
import '../guild_window/guild_information.dart';
import '../guild_window/guild_window_change_notifier.dart';
import '../loading_box/loading_box_change_notifier.dart';
import 'change_guild_crest_change_notifier.dart';


class ChangeGuildCrestBox extends StatefulWidget {

  final AgeOfGold game;

  const ChangeGuildCrestBox({
    required Key key,
    required this.game
  }) : super(key: key);

  @override
  ChangeGuildCrestBoxState createState() => ChangeGuildCrestBoxState();
}

class ChangeGuildCrestBoxState extends State<ChangeGuildCrestBox> with TickerProviderStateMixin {

  late ChangeGuildCrestChangeNotifier changeGuildCrestChangeNotifier;

  bool showChangeGuildCrest = false;

  CropController cropController = CropController();

  Uint8List? imageMain;
  Uint8List? imageCrop;

  @override
  void initState() {
    changeGuildCrestChangeNotifier = ChangeGuildCrestChangeNotifier();
    changeGuildCrestChangeNotifier.addListener(changeGuildCrestChangeListener);
    super.initState();
  }

  changeGuildCrestChangeListener() {
    if (mounted) {
      if (!showChangeGuildCrest && changeGuildCrestChangeNotifier.getChangeGuildCrestVisible()) {
        // set the correct image
        setState(() {
          showChangeGuildCrest = true;
          imageMain = changeGuildCrestChangeNotifier.getGuildCrest();
          imageCrop = changeGuildCrestChangeNotifier.getGuildCrest();
          if (imageMain == null) {
            rootBundle.load('assets/images/ui/icon/shield_default.png').then((data) {
              Uint8List defaultImage = data.buffer.asUint8List();
              changeGuildCrestChangeNotifier.setDefault(true);
              setState(() {
                imageMain = defaultImage;
                imageCrop = defaultImage;
              });
            });
          }
        });
      }
      if (showChangeGuildCrest && !changeGuildCrestChangeNotifier.getChangeGuildCrestVisible()) {
        setState(() {
          showChangeGuildCrest = false;
        });
      }
    }
  }


  imageLoaded() async {
    LoadingBoxChangeNotifier loadingBoxChangeNotifier = LoadingBoxChangeNotifier();
    // Set the loading screen. It will be removed when cropping status is done
    loadingBoxChangeNotifier.setWithBlackout(true);
    loadingBoxChangeNotifier.setLoadingBoxVisible(true);
    FilePickerResult? picked = await FilePicker.platform.pickFiles(withData: true);

    if (picked != null) {
      String? extension = picked.files.first.extension;
      if (extension != "png" && extension != "jpg" && extension != "jpeg") {
        showToastMessage("Please pick a png or jpeg file");
        setState(() {
          loadingBoxChangeNotifier.setLoadingBoxVisible(false);
        });
      } else {
        setState(() {
          imageCrop = picked.files.first.bytes!;
          imageMain = picked.files.first.bytes!;
          cropController.image = imageMain!;
          changeGuildCrestChangeNotifier.setDefault(false);
        });
      }
    } else {
      setState(() {
        loadingBoxChangeNotifier.setLoadingBoxVisible(false);
      });
    }
  }

  goBack() {
    setState(() {
      changeGuildCrestChangeNotifier.setChangeGuildCrestVisible(false);
    });
  }

  selectNewAvatar() {
    setState(() {
      LoadingBoxChangeNotifier loadingBoxChangeNotifier = LoadingBoxChangeNotifier();
      loadingBoxChangeNotifier.setWithBlackout(true);
      loadingBoxChangeNotifier.setLoadingBoxVisible(true);
    });
    // Again a very slight delay, too get the loading screen visible.
    Future.delayed(const Duration(milliseconds: 50), () {
      // first downsize to 512 x 512
      // and create another even more downsized small variant.
      // This cropped version should be a perfect square
      image.Image regular = image.decodePng(imageCrop!)!;
      int width = regular.width;
      if (width > 512) {
        regular = image.copyResize(regular, width: 512);
      }
      GuildInformation guildInformation = GuildInformation();
      User? me = Settings().getUser();
      if (!changeGuildCrestChangeNotifier.getDefault()) {
        Uint8List regularImage = image.encodePng(regular);
        changeGuildCrestChangeNotifier.setGuildCrest(regularImage);
        guildInformation.setGuildCrest(regularImage);
        guildInformation.setCrestIsDefault(false);
        if (!changeGuildCrestChangeNotifier.getCreateCrest()) {
          if (me != null && me.getGuild() != null) {
            // Set the image, but also send it to the server
            String newAvatarRegular = base64Encode(regularImage);
            me.getGuild()!.setGuildCrest(regularImage);
            AuthServiceGuild().changeGuildCrest(me.getGuild()!.getGuildId(), newAvatarRegular).then((value) {
              if (value.getResult()) {
                me.getGuild()!.setGuildCrest(regularImage);
                LoadingBoxChangeNotifier().setLoadingBoxVisible(false);
                GuildWindowChangeNotifier().notify();
              } else {
                showToastMessage("Error changing guild crest");
              }
            });
          }
        }
      } else {
        guildInformation.setGuildCrest(null);
        guildInformation.setCrestIsDefault(true);
        if (!changeGuildCrestChangeNotifier.getCreateCrest()) {
          if (me != null && me.getGuild() != null) {
            // Set the default image, but also send it to the server
            AuthServiceGuild().changeGuildCrest(me.getGuild()!.getGuildId(), null).then((value) {
              if (value.getResult()) {
                me.getGuild()!.setGuildCrest(null);
                LoadingBoxChangeNotifier().setLoadingBoxVisible(false);
                GuildWindowChangeNotifier().notify();
              } else {
                showToastMessage("Error changing guild crest");
              }
            });
          }
        }
      }
      if (changeGuildCrestChangeNotifier.getCreateCrest()) {
        LoadingBoxChangeNotifier().setLoadingBoxVisible(false);
        GuildWindowChangeNotifier().notify();
      }
      goBack();
    });
  }

  resetDefaultImage() {
    rootBundle.load('assets/images/ui/icon/shield_default.png').then((data) {
      Uint8List defaultImage = data.buffer.asUint8List();
      changeGuildCrestChangeNotifier.setDefault(true);
      setState(() {
        imageMain = defaultImage;
        imageCrop = defaultImage;
        cropController.reset();
      });
    });
  }

  Widget changeGuildCrestNormal(double width, double fontSize) {
    double sidePadding = 20;
    double headerWidth = width - 2 * sidePadding;
    double cropWidth = (width - 2 * sidePadding) / 2;
    double buttonWidth = cropWidth - 50;
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.only(left: sidePadding, right: sidePadding),
        width: width,
        child: Column(
          children: [
            changeGuildCrestHeader(headerWidth, 50, fontSize),
            Row(
              children: [
                Column(
                  children: [
                    const SizedBox(height: 20),
                    cropWidget(cropWidth),
                    const SizedBox(height: 20),
                    uploadNewImageButton(buttonWidth, 50, fontSize),
                    const SizedBox(height: 20),
                  ],
                ),
                Column(
                  children: [
                    SizedBox(
                      height: 20,
                      child: Text(
                        "Result:",
                        style: TextStyle(
                            fontSize: fontSize,
                            color: Colors.white
                        ),
                      )
                    ),
                    guildAvatarBox(
                        cropWidth,
                        cropWidth * 1.125,
                        imageCrop
                    ),
                    const SizedBox(height: 20),
                    selectImageButton(buttonWidth, 50, fontSize),
                    const SizedBox(height: 20),
                    resetDefaultImageButton(buttonWidth, 50, fontSize),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget cropWidget(double cropHeight) {
    return Container(
      width: cropHeight,
      height: cropHeight,
      child: imageMain != null ? Crop(
        image: imageMain!,
        controller: cropController,
        hexCrop: false,
        onStatusChanged: (status) {
          if (status == CropStatus.cropping || status == CropStatus.loading) {
            LoadingBoxChangeNotifier loadingBoxChangeNotifier = LoadingBoxChangeNotifier();
            loadingBoxChangeNotifier.setWithBlackout(true);
            loadingBoxChangeNotifier.setLoadingBoxVisible(true);
          } else if (status == CropStatus.ready) {
            LoadingBoxChangeNotifier().setLoadingBoxVisible(false);
          }
        },
        onResize: (imageData) {
          showToastMessage("Image too large, resizing...");
          setState(() {
            imageCrop = imageData;
            imageMain = imageData;
            cropController.image = imageData;
            changeGuildCrestChangeNotifier.setDefault(false);
          });
        },
        onCropped: (image) {
          setState(() {
            imageCrop = image;
            changeGuildCrestChangeNotifier.setDefault(false);
          });
        },
      ) : Container(),
    );
  }

  Widget uploadNewImageButton(double buttonWidth, double buttonHeight, double fontSize) {
    return SizedBox(
      width: buttonWidth,
      height: buttonHeight,
      child: ElevatedButton(
        style: buttonStyle(false, Colors.blue),
        child: Container(
          alignment: Alignment.center,
          child: Text(
            'Upload a new image',
            style: simpleTextStyle(fontSize)
          )
        ),
        onPressed: () async {
          imageLoaded();
        },
      ),
    );
  }

  Widget resetDefaultImageButton(double buttonWidth, double buttonHeight, double fontSize) {
    return changeGuildCrestChangeNotifier.getDefault() == false ? SizedBox(
      width: buttonWidth,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: () {
          resetDefaultImage();
        },
        style: buttonStyle(false, Colors.blueGrey),
        child: Container(
          alignment: Alignment.center,
          child: Text(
            'Reset to default',
            style: simpleTextStyle(fontSize),
          ),
        ),
      ),
    ) : Container();
  }

  Widget selectImageButton(double buttonWidth, double buttonHeight, double fontSize) {
    String saveText = "Select new guild crest";
    if (!changeGuildCrestChangeNotifier.getCreateCrest()) {
      saveText = "Save new guild crest image";
    }
    return SizedBox(
      width: buttonWidth,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: () {
          selectNewAvatar();
        },
        style: buttonStyle(false, Colors.blue),
        child: Container(
          alignment: Alignment.center,
          child: Text(
            saveText,
            style: simpleTextStyle(fontSize),
          ),
        ),
      ),
    );
  }

  Widget changeGuildCrestMobile(double width, double height, double fontSize) {
    double sidePadding = 20;
    double headerHeight = height / 9;
    double buttonWidth = (width - 2 * sidePadding) / 2;
    double cropResultWidth = width/2;
    double avatarHeight = cropResultWidth * 1.125;
    double totalButtonHeight = avatarHeight;
    double buttonHeight = totalButtonHeight / 4;

    return Container(
      margin: EdgeInsets.only(left: sidePadding, right: sidePadding),
      child: Column(
        children: [
          changeGuildCrestHeader(width, headerHeight, fontSize),
          cropWidget(cropResultWidth),
          SizedBox(
              width: cropResultWidth,
              height: 40,
              child: const Text("Result:")
          ),
          guildAvatarBox(
              cropResultWidth,
              cropResultWidth * 1.125,
              imageCrop
          ),
          SizedBox(height: buttonHeight/3),
          uploadNewImageButton(buttonWidth, buttonHeight, 16),
          SizedBox(height: buttonHeight/3),
          selectImageButton(buttonWidth, buttonHeight, 16),
          SizedBox(height: buttonHeight/3),
          resetDefaultImageButton(buttonWidth, buttonHeight, 16),
        ]
      ),
    );
  }

  Widget changeGuildCrestHeader(double headerWidth, double headerHeight, double fontSize) {
    return SizedBox(
      width: headerWidth,
      height: headerHeight,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              child: Text(
                "Change guild crest",
                style: simpleTextStyle(fontSize),
              ),
            ),
            IconButton(
                icon: const Icon(Icons.close),
                color: Colors.orangeAccent.shade200,
                tooltip: 'cancel',
                onPressed: () {
                  goBack();
                }
            ),
          ]
      ),
    );
  }

  Widget changeGuildCrestBox() {
    // normal mode is for desktop, mobile mode is for mobile.
    double fontSize = 16;
    double width = 800;
    double height = (MediaQuery.of(context).size.height / 10) * 9;
    // When the width is smaller than this we assume it's mobile.
    bool normalMode = true;
    if (MediaQuery.of(context).size.width <= 800) {
      width = MediaQuery.of(context).size.width;
      fontSize = 10;
      normalMode = false;
    }

    return Container(
        width: width,
        height: height,
        color: Colors.cyan,
        child: SingleChildScrollView(
          child: normalMode
                ? changeGuildCrestNormal(width, fontSize)
                : changeGuildCrestMobile(width, height, fontSize),
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: FractionalOffset.center,
      child: showChangeGuildCrest ? changeGuildCrestBox() : Container()
    );
  }
}
