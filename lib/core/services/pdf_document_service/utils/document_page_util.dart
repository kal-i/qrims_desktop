import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class DocumentPageUtil {
  static pw.PageTheme getPageTheme({
    required PdfPageFormat pageFormat,
    required pw.PageOrientation orientation,
    double? marginTop,
    double? marginRight,
    double? marginBottom,
    double? marginLeft,
  }) {
    return pw.PageTheme(
      pageFormat: pageFormat,
      orientation: orientation,
      margin: pw.EdgeInsets.only(
        top: marginTop != null
            ? marginTop * PdfPageFormat.cm
            : 1.2 * PdfPageFormat.cm,
        right: marginRight != null
            ? marginRight * PdfPageFormat.cm
            : 1.2 * PdfPageFormat.cm,
        bottom: marginBottom != null
            ? marginBottom * PdfPageFormat.cm
            : 1.3 * PdfPageFormat.cm,
        left: marginLeft != null
            ? marginLeft * PdfPageFormat.cm
            : 1.2 * PdfPageFormat.cm,
      ),
    );
  }
}
