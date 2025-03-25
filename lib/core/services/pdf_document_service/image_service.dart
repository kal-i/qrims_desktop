import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../constants/assets_path.dart';

class ImageService {
  final Map<String, pw.Image> _images = {};

  Future<void> initialize() async {
    try {
      final imagePaths = {
        'depedSeal': ImagePath.depedSeal,
        'sdoLogo': ImagePath.sdoLogo,
      };

      for (var entry in imagePaths.entries) {
        _images[entry.key] = await _loadImage(entry.value);
      }
    } catch (e) {
      print('Error initializing ImageService: $e');
      rethrow;
    }
  }

  Future<pw.Image> _loadImage(String path) async {
    final data = await rootBundle.load(path);
    return pw.Image(pw.MemoryImage(data.buffer.asUint8List()));
  }

  pw.Image getImage(String imageName) {
    if (!_images.containsKey(imageName)) {
      throw ArgumentError('Image not found: $imageName');
    }
    return _images[imageName]!;
  }
}
