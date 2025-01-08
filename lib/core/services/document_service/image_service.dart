import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../constants/assets_path.dart';

class ImageService {
  late Map<String, pw.Image> images;

  Future<void> initialize() async {
    images = {
      'depedSeal': await _loadImage(ImagePath.depedSeal),
      'sdoLogo': await _loadImage(ImagePath.sdoLogo),
    };
  }

  Future<pw.Image> _loadImage(String path) async {
    final img = await rootBundle.load(path);
    final imageBytes = img.buffer.asUint8List();
    return pw.Image(pw.MemoryImage(imageBytes));
  }

  pw.Image getImage(String imageName) {
    return images[imageName] ?? (throw ArgumentError('Image not found'));
  }
}
