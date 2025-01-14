import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../constants/assets_path.dart';

class FontService {
  final Map<String, pw.Font> _fonts = {};

  Future<void> initialize() async {
    try {
      final fontPaths = {
        'algeria': FontPath.algeria,
        'arial': FontPath.arial,
        'calibriRegular': FontPath.calibriRegular,
        'calibriBold': FontPath.calibriBold,
        'calibriItalic': FontPath.calibriItalic,
        'calibriBoldItalic': FontPath.calibriBoldItalic,
        'oldEnglish': FontPath.oldEnglish,
        'popvlvs': FontPath.popvlvs,
        'trajanProRegular': FontPath.trajanProRegular,
        'trajanProBold': FontPath.trajanProBold,
        'tahomaRegular': FontPath.tahomaRegular,
        'tahomaBold': FontPath.tahomaBold,
        'timesNewRomanRegular': FontPath.timesNewRomanRegular,
        'timesNewRomanBold': FontPath.timesNewRomanBold,
      };

      for (var entry in fontPaths.entries) {
        _fonts[entry.key] = await _loadFont(entry.value);
      }
    } catch (e) {
      print('Error initializing FontService: $e');
      rethrow;
    }
  }

  Future<pw.Font> _loadFont(String path) async {
    final data = await rootBundle.load(path);
    return pw.Font.ttf(data);
  }

  pw.Font getFont(String fontName) {
    print('fonts: ${_fonts.length}');
    if (!_fonts.containsKey(fontName)) {
      throw ArgumentError('Font not found: $fontName');
    }
    return _fonts[fontName]!;
  }
}
