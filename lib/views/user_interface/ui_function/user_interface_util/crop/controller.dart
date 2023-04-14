import 'package:flutter/foundation.dart';


class CropController {
  late CropControllerDelegate _delegate;

  set delegate(CropControllerDelegate value) => _delegate = value;
  void crop() => _delegate.onCrop();
  set image(Uint8List value) => _delegate.onImageChanged(value);

}

class CropControllerDelegate {
  late Function onCrop;
  late ValueChanged<Uint8List> onImageChanged;
}
