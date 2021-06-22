import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:image/image.dart';

/// Methods to crop images.
/// 
/// This is a wrapper around the `image` library.
abstract class ImageCropper {
  /// Crop a slice of an image corresponding to one of 9 parts ([row]: 0-2, [col]: 0-2).
  static Future<Uint8List> cropFileImageThird(File file, int row, int col) async {
    return await ImageCropper.cropFileImage(file, col * (1 / 3), row * (1 / 3), 1 / 3, 1 / 3);
  }

  /// Crop a slice of an image using percentages as coordinates and dimensions.
  static Future<Uint8List> cropFileImage(File file, double xPercent, double yPercent, double wPercent, double hPercent) async {
    var receivePort = ReceivePort();

    await Isolate.spawn(
      ImageCropper._cropImageIsolate,
      _CropImageIsolateParams(
        file: file,
        xPercent: xPercent,
        yPercent: yPercent,
        wPercent: wPercent,
        hPercent: hPercent,
        sendPort: receivePort.sendPort,
      ),
    );

    // Get the processed image from the isolate.
    return await receivePort.first as Uint8List;
  }

  static void _cropImageIsolate(_CropImageIsolateParams params) {
    Image sourceImage = decodeImage(params.file.readAsBytesSync())!;
    Image croppedImage = copyCrop(
      sourceImage,
      (params.xPercent * sourceImage.width).toInt(),
      (params.yPercent * sourceImage.width).toInt(),
      (params.wPercent * sourceImage.width).toInt(),
      (params.hPercent * sourceImage.width).toInt(),
    );
    params.sendPort.send(Uint8List.fromList(encodePng(croppedImage)));
  }
}

class _CropImageIsolateParams {
  final File file;
  final double xPercent;
  final double yPercent;
  final double wPercent;
  final double hPercent;
  final SendPort sendPort;

  _CropImageIsolateParams({
    required this.file,
    required this.xPercent,
    required this.yPercent,
    required this.wPercent,
    required this.hPercent,
    required this.sendPort,
  });
}
