import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart';

class CropImageResult {
  final Uint8List cropImageBytes;

  const CropImageResult({
    required this.cropImageBytes,
  });
}

class ImageCropper {
  Future<CropImageResult?> crop({
    required String imagePath,
    required double cropHeight,
    required double cropWidth,
    required double parentHeight,
    required double parentWidth,
    required int quality,
  }) async {
    Uint8List imageBytes = await File(imagePath).readAsBytes();

    Image? image = decodeImage(imageBytes);

    double? increasedTimesW;
    double? increasedTimesH;
    if (image!.width > parentWidth) {
      increasedTimesW = image.width / parentWidth;
      increasedTimesH = image.height / parentHeight;
    } else {
      return null;
    }

    double sX = (parentWidth - cropWidth) / 2;
    double sY = (parentHeight - cropHeight) / 2;

    double x = sX * increasedTimesW;
    double y = sY * increasedTimesH;

    double w = cropWidth * increasedTimesW;
    double h = cropHeight * increasedTimesH;

    Image croppedImage =
        copyCrop(image, x.toInt(), y.toInt(), w.toInt(), h.toInt());
    List<int> croppedList = encodeJpg(croppedImage, quality: quality);
    Uint8List croppedBytes = Uint8List.fromList(croppedList);
    return CropImageResult(cropImageBytes: croppedBytes);
  }
}
