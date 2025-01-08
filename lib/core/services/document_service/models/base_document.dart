import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

abstract class BaseDocument {
  Future<pw.Document> generate({
    required PdfPageFormat pageFormat,
    required pw.PageOrientation orientation,
    required dynamic data,
    required bool withQr,
  });
}
