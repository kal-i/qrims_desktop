import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../constants/assets_path.dart';

class FontService {
  late Map<String, pw.Font> fonts;

  Future<void> initialize() async {
    fonts = {
      'algeria': await _loadFont(FontPath.algeria),
      'arial': await _loadFont(FontPath.arial),
      'calibriRegular': await _loadFont(FontPath.calibriRegular),
      'calibriBold': await _loadFont(FontPath.calibriBold),
      'calibriItalic': await _loadFont(FontPath.calibriItalic),
      'calibriBoldItalic': await _loadFont(FontPath.calibriBoldItalic),
      'oldEnglish': await _loadFont(FontPath.oldEnglish),
      'popvlvs': await _loadFont(FontPath.popvlvs),
      'trajanProRegular': await _loadFont(FontPath.trajanProRegular),
      'trajanProBold': await _loadFont(FontPath.trajanProBold),
      'tahomaRegular': await _loadFont(FontPath.tahomaRegular),
      'tahomaBold': await _loadFont(FontPath.tahomaBold),
      'timesNewRomanRegular': await _loadFont(FontPath.timesNewRomanRegular),
      'timesNewRomanBold': await _loadFont(FontPath.timesNewRomanBold),
    };
  }

  Future<pw.Font> _loadFont(String path) async {
    return pw.Font.ttf(await rootBundle.load(path));
  }

  pw.Font getFont(String fontName) {
    return fonts[fontName] ?? (throw ArgumentError('Font not found'));
  }
}
