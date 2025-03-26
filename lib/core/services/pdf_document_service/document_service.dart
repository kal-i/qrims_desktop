import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../enums/document_type.dart';
import 'document_factory.dart';
import 'font_service.dart';
import 'image_service.dart';

class DocumentService {
  const DocumentService({
    required this.fontService,
    required this.imageService,
  });

  final FontService fontService;
  final ImageService imageService;

  Future<void> initialize() async {
    try {
      await fontService.initialize();
      await imageService.initialize();
    } catch (e, stackTrace) {
      print('Error during DocumentService initialization: $e');
      print(stackTrace);
      rethrow;
    }
  }

  // static double getRowHeight(
  //   String text, {
  //   double fontSize = 8.5,
  // }) {
  //   // Trim the text to remove leading/trailing whitespace and check if it's non-empty
  //   if (text.trim().isNotEmpty) {
  //     final lines = (text.length / 20)
  //         .ceil(); // Calculate the number of lines based on text length
  //     return lines * fontSize * 1.5; // Return the calculated row height
  //   }
  //   // If the text is empty or only whitespace, return 0 or a minimal height (optional)
  //   return fontSize * 1.5; // Minimal row height in case of empty input
  // }

  static double getRowHeight(
    String text, {
    double fontSize = 8.5,
    double cellWidth = 100.0, // Add cellWidth to calculate based on cell size
  }) {
    if (text.trim().isNotEmpty) {
      // Estimate characters per line based on cellWidth and fontSize
      final charsPerLine = (cellWidth / (fontSize * 0.6)).floor();

      // Calculate the number of lines needed, rounding up for partially filled lines
      final lines = (text.length / charsPerLine).ceil();

      // Return the calculated height based on the number of lines
      return lines * fontSize * 1.5;
    }

    // Return minimal row height for empty or whitespace-only text
    return fontSize * 1.5;
  }

  Future<pw.Document> generateDocument({
    required PdfPageFormat pageFormat,
    required pw.PageOrientation orientation,
    required dynamic data,
    required DocumentType docType,
    bool withQR = true,
  }) async {
    /// todo: continue implementing later
    return DocumentFactory().createDocument(
      pageFormat: pageFormat,
      orientation: orientation,
      data: data,
      docType: docType,
      withQR: withQR,
    );
  }
}
