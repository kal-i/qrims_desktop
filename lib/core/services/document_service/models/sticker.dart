import 'package:pdf/src/pdf/page_format.dart';
import 'package:pdf/src/widgets/document.dart';
import 'package:pdf/src/widgets/page.dart';

import 'base_document.dart';

class Sticker implements BaseDocument {
  @override
  Future<Document> generate({
    required PdfPageFormat pageFormat,
    required PageOrientation orientation,
    required data,
    required bool withQr,
  }) async {
    // TODO: implement generate
    throw UnimplementedError();
  }
}
