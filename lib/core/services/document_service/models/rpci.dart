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
    required data,
    required bool withQr,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageTheme: DocumentPageUtil.getPageTheme(
          pageFormat: pageFormat,
          orientation: pw.PageOrientation.landscape,
        ),
        build: (context) => [
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
            'For which __________________, ________________, __________________ is accountable, having assumed such accountability on ______________.',
            style: const pw.TextStyle(
              //font: FontService().getFont('timesNewRomanBold'),
              fontSize: 10.0,
            ),
          ),
          pw.SizedBox(
            height: 10.0,
          ),
          pw.Table(
            columnWidths: pageFormat == PdfPageFormat.a4
                ? {
                    0: const pw.FixedColumnWidth(300.0),
                    1: const pw.FixedColumnWidth(425.0),
                    2: const pw.FixedColumnWidth(200.0),
                    3: const pw.FixedColumnWidth(175.0),
                    4: const pw.FixedColumnWidth(125.0),
                    5: const pw.FixedColumnWidth(240.0),
                    6: const pw.FixedColumnWidth(240.0),
                    7: const pw.FixedColumnWidth(425.0),
                  }
                : pageFormat == PdfPageFormat.letter
                    ? {
                        0: const pw.FixedColumnWidth(300.0),
                        1: const pw.FixedColumnWidth(400.0),
                        2: const pw.FixedColumnWidth(200.0),
                        3: const pw.FixedColumnWidth(175.0),
                        4: const pw.FixedColumnWidth(125.0),
                        5: const pw.FixedColumnWidth(250.0),
                        6: const pw.FixedColumnWidth(250.0),
                        7: const pw.FixedColumnWidth(400.0),
                      }
                    : {
                        0: const pw.FixedColumnWidth(360.0),
                        1: const pw.FixedColumnWidth(470.0),
                        2: const pw.FixedColumnWidth(200.0),
                        3: const pw.FixedColumnWidth(150.0),
                        4: const pw.FixedColumnWidth(100.0),
                        5: const pw.FixedColumnWidth(200.0),
                        6: const pw.FixedColumnWidth(200.0),
                        7: const pw.FixedColumnWidth(470.0),
                      },
            children: [
              _buildFirstPageHeaderTableRow(),
              for (int i = 0; i < 20; i++) _buildFirstPageTableRow(),
            ],
          ),
        ],
      ),
    );

    pdf.addPage(
      pw.MultiPage(
        pageTheme: DocumentPageUtil.getPageTheme(
          pageFormat: pageFormat,
          orientation: pw.PageOrientation.landscape,
        ),
        build: (context) => [
          pw.Table(
            columnWidths: pageFormat == PdfPageFormat.a4
                ? {
                    0: const pw.FixedColumnWidth(300.0),
                    1: const pw.FixedColumnWidth(425.0),
                    2: const pw.FixedColumnWidth(200.0),
                    3: const pw.FixedColumnWidth(175.0),
                    4: const pw.FixedColumnWidth(125.0),
                  }
                : pageFormat == PdfPageFormat.letter
                    ? {
                        0: const pw.FixedColumnWidth(300.0),
                        1: const pw.FixedColumnWidth(400.0),
                        2: const pw.FixedColumnWidth(200.0),
                        3: const pw.FixedColumnWidth(175.0),
                        4: const pw.FixedColumnWidth(125.0),
                      }
                    : {
                        0: const pw.FixedColumnWidth(360.0),
                        1: const pw.FixedColumnWidth(470.0),
                        2: const pw.FixedColumnWidth(200.0),
                        3: const pw.FixedColumnWidth(150.0),
                        4: const pw.FixedColumnWidth(100.0),
                      },
            children: [
              _buildSecondPageHeaderTableRow(),
              for (int i = 0; i < 20; i++) _buildSecondPageTableRow(),
            ],
          ),
        ],
      ),
    );

    return pdf;
  }

  pw.TableRow _buildFirstPageHeaderTableRow() {
    return pw.TableRow(
      children: [
        DocumentComponents.buildHeaderContainerCell(
          data: 'Article',
          //horizontalPadding: 3.0,
          verticalPadding: 17.5,
          borderRight: false,
        ),
        DocumentComponents.buildHeaderContainerCell(
          data: 'Description',
          verticalPadding: 17.5,
          borderRight: false,
        ),
        DocumentComponents.buildHeaderContainerCell(
          data: 'Stock Number',
          verticalPadding: 17.5,
          borderRight: false,
        ),
        DocumentComponents.buildHeaderContainerCell(
          data: 'Unit of Measure',
          verticalPadding: 11.8,
          borderRight: false,
        ),
        DocumentComponents.buildHeaderContainerCell(
          data: 'Unit Value',
          verticalPadding: 11.8,
          borderRight: false,
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            DocumentComponents.buildHeaderContainerCell(
              data: 'Balance Per Card',
              horizontalPadding: 3.0,
              borderRight: false,
              verticalPadding: 8.8,
              borderWidthBottom: 2.0,
            ),
            DocumentComponents.buildHeaderContainerCell(
              data: '(Quantity)',
              borderTop: false,
              borderRight: false,
              verticalPadding: 3.0,
            ),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            DocumentComponents.buildHeaderContainerCell(
              data: 'On Hand Per Count',
              borderRight: false,
              verticalPadding: 3.0,
              borderWidthBottom: 2.0,
            ),
            DocumentComponents.buildHeaderContainerCell(
              data: '(Quantity)',
              borderTop: false,
              borderRight: false,
              verticalPadding: 3.0,
            ),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            DocumentComponents.buildHeaderContainerCell(
              data: 'Shortage/Overage',
              borderWidthBottom: 2.0,
              verticalPadding: 8.8,
            ),
            pw.Row(
              children: [
                pw.Expanded(
                  child: DocumentComponents.buildHeaderContainerCell(
                    data: 'Quantity',
                    borderTop: false,
                    borderRight: false,
                    horizontalPadding: 3.0,
                    verticalPadding: 3.0,
                  ),
                ),
                pw.Expanded(
                  child: DocumentComponents.buildHeaderContainerCell(
                    data: 'Value',
                    borderTop: false,
                    horizontalPadding: 15.0,
                    verticalPadding: 3.0,
                    borderWidthLeft: 2.0,
                    borderWidthBottom: 3.0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  pw.TableRow _buildSecondPageHeaderTableRow() {
    return pw.TableRow(
      children: [
        DocumentComponents.buildHeaderContainerCell(
          data: 'Remarks (Accountable Officer, Location)',
          borderRight: false,
          verticalPadding: 17.5,
        ),
        DocumentComponents.buildHeaderContainerCell(
          data: 'Date Acquired',
          borderRight: false,
          verticalPadding: 17.5,
        ),
        DocumentComponents.buildHeaderContainerCell(
          data: 'Accountable Officer',
          borderRight: false,
          verticalPadding: 17.5,
        ),
        DocumentComponents.buildHeaderContainerCell(
          data: 'Location',
          borderRight: false,
          verticalPadding: 17.5,
        ),
        DocumentComponents.buildHeaderContainerCell(
          data: 'Fund Cluster',
          verticalPadding: 17.5,
        ),
      ],
    );
  }

  pw.TableRow _buildFirstPageTableRow() {
    return pw.TableRow(
      children: [
        DocumentComponents.buildTableRowColumn(
          data: '\n',
          borderRight: false,
        ),
        DocumentComponents.buildTableRowColumn(
          data: '\n',
          borderRight: false,
        ),
        DocumentComponents.buildTableRowColumn(
          data: '\n',
          borderRight: false,
        ),
        DocumentComponents.buildTableRowColumn(
          data: '\n',
          borderRight: false,
        ),
        DocumentComponents.buildTableRowColumn(
          data: '\n',
          borderRight: false,
        ),
        DocumentComponents.buildTableRowColumn(
          data: '\n',
          borderRight: false,
        ),
        DocumentComponents.buildTableRowColumn(
          data: '\n',
          borderRight: false,
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            pw.Row(
              children: [
                pw.Expanded(
                  child: DocumentComponents.buildTableRowColumn(
                    data: '\n',
                    borderRight: false,
                  ),
                ),
                pw.Expanded(
                  child: DocumentComponents.buildTableRowColumn(
                    data: '\n',
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  pw.TableRow _buildSecondPageTableRow() {
    return pw.TableRow(
      children: [
        DocumentComponents.buildTableRowColumn(
          data: '\n',
          borderRight: false,
        ),
        DocumentComponents.buildTableRowColumn(
          data: '\n',
          borderRight: false,
        ),
        DocumentComponents.buildTableRowColumn(
          data: '\n',
          borderRight: false,
        ),
        DocumentComponents.buildTableRowColumn(
          data: '\n',
          borderRight: false,
        ),
        DocumentComponents.buildTableRowColumn(
          data: '\n',
        ),
      ],
    );
  }
}
