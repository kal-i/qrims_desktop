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
    await fontService.initialize();
    await imageService.initialize();
  }

  double getRowHeight(String text, {double fontSize = 8.5}) {
    final lines = (text.length / 20).ceil();
    return lines * fontSize * 1.5;
  }

  Future<pw.Document> generateDocument({
    required PdfPageFormat pageFormat,
    required pw.PageOrientation orientation,
    required dynamic data,
    required DocumentType docType,
    bool withQR = true,
  }) async {
    return DocumentFactory().createDocument(
      pageFormat: pageFormat,
      orientation: orientation,
      data: data,
      docType: docType,
      withQR: withQR,
    );
  }
}
