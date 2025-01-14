import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../font_service.dart';
import '../utils/document_components.dart';
import '../utils/document_page_util.dart';
import 'base_document.dart';

class RPCI implements BaseDocument {
  @override
  Future<pw.Document> generate({
    required PdfPageFormat pageFormat,
    required pw.PageOrientation orientation,
    required data,
    required bool withQr,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageTheme: DocumentPageUtil.getPageTheme(
          pageFormat: pageFormat,
          orientation: pw.PageOrientation.landscape,
        ),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(
              child: pw.Column(
                children: [
                  pw.Text(
                    'REPORT ON THE PHYSICAL COUNT OF INVENTORIES\nOFFICE SUPPLIES',
                    style: const pw.TextStyle(
                      //font: FontService().getFont('timesNewRomanBold'),
                      fontSize: 14.0,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                  pw.SizedBox(
                    height: 5.0,
                  ),
                  pw.Text(
                    '(Type of Inventory Item)',
                    style: const pw.TextStyle(
                      //font: FontService().getFont('timesNewRomanRegular'),
                      fontSize: 10.0,
                    ),
                  ),
                  pw.SizedBox(
                    height: 10.0,
                  ),
                  pw.Text(
                    'As at ________________',
                    style: const pw.TextStyle(
                      //font: FontService().getFont('timesNewRomanBold'),
                      fontSize: 12.0,
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(
              height: 10.0,
            ),
            pw.Text(
              'Fund Cluster: ',
              style: const pw.TextStyle(
                //font: FontService().getFont('timesNewRomanBold'),
                fontSize: 10.0,
              ),
            ),
            pw.SizedBox(
              height: 10.0,
            ),
            pw.Text(
              'For which __________________, ________________, __________________ is accountable, having assumed such account on ______________.',
              style: const pw.TextStyle(
                //font: FontService().getFont('timesNewRomanBold'),
                fontSize: 10.0,
              ),
            ),
            pw.SizedBox(
              height: 10.0,
            ),
            pw.Table(
              columnWidths: {
                0: const pw.FixedColumnWidth(200.0),
                1: const pw.FixedColumnWidth(600.0),
                2: const pw.FixedColumnWidth(300.0),
                3: const pw.FixedColumnWidth(300.0),
                4: const pw.FixedColumnWidth(125.0),
                5: const pw.FixedColumnWidth(200.0),
                6: const pw.FixedColumnWidth(200.0),
                7: const pw.FixedColumnWidth(325.0),
                8: const pw.FixedColumnWidth(400.0),
                9: const pw.FixedColumnWidth(175.0),
                10: const pw.FixedColumnWidth(200.0),
                11: const pw.FixedColumnWidth(125.0),
                12: const pw.FixedColumnWidth(200.0),
              },
              children: [
                _buildHeaderTableRow(),
              ],
            ),
          ],
        ),
      ),
    );

    return pdf;
  }

  pw.TableRow _buildHeaderTableRow() {
    return pw.TableRow(
      children: [
        DocumentComponents.buildHeaderContainerCell(
          data: 'Article',
          //horizontalPadding: 3.0,
          verticalPadding: 15.0,
          borderRight: false,
        ),
        DocumentComponents.buildHeaderContainerCell(
          data: 'Description',
          verticalPadding: 15.0,
          borderRight: false,
        ),
        DocumentComponents.buildHeaderContainerCell(
          data: 'Stock Number',
          verticalPadding: 15.0,
          borderRight: false,
        ),
        DocumentComponents.buildHeaderContainerCell(
          data: 'Unit of Measure',
          verticalPadding: 15.0,
          borderRight: false,
        ),
        DocumentComponents.buildHeaderContainerCell(
          data: 'Unit Value',
          verticalPadding: 15.0,
          borderRight: false,
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            DocumentComponents.buildHeaderContainerCell(
              data: 'Balance Per Card',
              borderRight: false,
            ),
            DocumentComponents.buildHeaderContainerCell(
              data: '(Quantity)',
              borderTop: false,
              borderRight: false,
            ),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            DocumentComponents.buildHeaderContainerCell(
              data: 'Balance Per Card',
              borderRight: false,
            ),
            DocumentComponents.buildHeaderContainerCell(
              data: '(Quantity)',
              borderTop: false,
              borderRight: false,
            ),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            DocumentComponents.buildHeaderContainerCell(
              data: 'Shortage/Overage',
              borderRight: false,
            ),
            pw.Row(
              children: [
                DocumentComponents.buildHeaderContainerCell(
                  data: 'Quantity',
                  borderTop: false,
                  borderRight: false,
                ),
                DocumentComponents.buildHeaderContainerCell(
                  data: 'Value',
                  borderTop: false,
                  borderRight: false,
                ),
              ],
            ),
          ],
        ),
        DocumentComponents.buildHeaderContainerCell(
          data: 'Remarks (Accountable Officer, Location)',
          borderRight: false,
        ),
        DocumentComponents.buildHeaderContainerCell(
          data: 'Date Acquired',
          borderRight: false,
        ),
        DocumentComponents.buildHeaderContainerCell(
          data: 'Accountable Officer',
          borderRight: false,
        ),
        DocumentComponents.buildHeaderContainerCell(
          data: 'Location',
          borderRight: false,
        ),
        DocumentComponents.buildHeaderContainerCell(
          data: 'Fund Cluster',
        ),
      ],
    );
  }
}
