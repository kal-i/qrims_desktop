import 'dart:convert';
import 'dart:io';
import 'package:qr/qr.dart';
import 'package:image/image.dart' as img;

class QrCodeUtils {
  static Future<String> generateQRCode(String encryptedId) async {
    /// Generate QR
    final qr = QrCode.fromData(data: encryptedId, errorCorrectLevel: QrErrorCorrectLevel.L,);
    final qrImage = QrImage(qr);

    // size of each module (in px)
    const moduleSize = 10;

    /// Create an image canvas
    final image = img.Image(width: qrImage.moduleCount * moduleSize, height: qrImage.moduleCount * moduleSize,);

    // Draw QR on image
    for (var x = 0; x < qrImage.moduleCount; x++) {
      for (var y = 0; y < qrImage.moduleCount; y++) {
        final color = qrImage.isDark(y, x) ? img.ColorRgb8(0, 0, 0) : img.ColorRgb8(255, 255, 255);

        // Draw each module as a square of size `moduleSize`
        for (var dx = 0; dx < moduleSize; dx++) {
          for (var dy = 0; dy < moduleSize; dy++) {
            image.setPixel(x * moduleSize + dx, y * moduleSize + dy, color);
          }
        }
      }
    }

    // Encode image as PNG
    final pngImageData = img.encodePng(image);

    // Convert PNG to base64
    final base64Image = base64Encode(pngImageData);

    // Save the image file
    final filePath = 'D:/qr_code_${encryptedId.hashCode}.png';
    final file = File(filePath);
    await file.writeAsBytes(img.encodePng(image));

    print('QR code image saved to: $filePath');

    return base64Image;
  }
}