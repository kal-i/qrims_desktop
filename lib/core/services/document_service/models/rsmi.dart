import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../init_dependencies.dart';
import '../font_service.dart';
import '../utils/document_components.dart';
import '../utils/document_page_util.dart';
import 'base_document.dart';

class RSMI implements BaseDocument {
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
          orientation: pw.PageOrientation.portrait,
        ),
        build: (context) => [
          pw.Center(
            child: pw.Column(
              children: [
                DocumentComponents.buildDocumentHeader(),
                pw.SizedBox(
                  height: 20.0,
                ),
                pw.Text(
                  'REPORT OF SUPPLIES AND MATERIALS ISSUED',
                  style: pw.TextStyle(
                    font: serviceLocator<FontService>()
                        .getFont('timesNewRomanBold'),
                    fontSize: 12.0,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(
            height: 20.0,
          ),
          pw.Table(
            columnWidths: {
              0: const pw.FixedColumnWidth(920.0),
              1: const pw.FixedColumnWidth(350.0),
            },
            children: [
              pw.TableRow(
                children: [
                  pw.Text(
                    'Entity Name:',
                    style: pw.TextStyle(
                      font: serviceLocator<FontService>()
                          .getFont('timesNewRomanBold'),
                      fontSize: 8.0,
                    ),
                  ),
                  pw.Text(
                    'Serial No.:',
                    style: pw.TextStyle(
                      font: serviceLocator<FontService>()
                          .getFont('timesNewRomanBold'),
                      fontSize: 8.0,
                    ),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Text(
                    'Fund Cluster:',
                    style: pw.TextStyle(
                      font: serviceLocator<FontService>()
                          .getFont('timesNewRomanBold'),
                      fontSize: 8.0,
                    ),
                  ),
                  pw.Text(
                    'Date:',
                    style: pw.TextStyle(
                      font: serviceLocator<FontService>()
                          .getFont('timesNewRomanBold'),
                      fontSize: 8.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(
            height: 10.0,
          ),
          _buildTableHeader(pageFormat),
          for (int i = 0; i < 10; i++)
            _buildTableRow(isLast: i == 10 - 1 ? true : false),
          _buildRecapitulationHeader(),
          _buildRecapitulationSubHeader(),
          for (int i = 0; i < 5; i++)
            _buildTableRow(isLast: i == 5 - 1 ? true : false),
          _buildTableFooter(),
        ],
      ),
    );
    return pdf;
  }

  pw.Widget _buildCell({
    String? data,
    double? horizontalPadding = 3.0,
    double? verticalPadding = 3.0,
    bool borderTop = true,
    bool borderRight = true,
    bool borderBottom = true,
    bool borderLeft = true,
    double borderWidthTop = 2.0,
    double borderWidthRight = 2.0,
    double borderWidthBottom = 2.0,
    double borderWitdhLeft = 2.0,
    pw.Font? font,
    double fontSize = 9.0,
    bool isCenter = true,
  }) {
    return DocumentComponents.buildContainer(
      borderTop: borderTop,
      borderRight: borderRight,
      borderBottom: borderBottom,
      borderLeft: borderLeft,
      borderWidthTop: borderWidthTop,
      borderWidthRight: borderWidthRight,
      borderWidthBottom: borderWidthBottom,
      borderWidthLeft: borderWitdhLeft,
      child: pw.Text(
        data ?? '\n',
        style: pw.TextStyle(
          font: font ??
              serviceLocator<FontService>().getFont('timesNewRomanBold'),
          fontSize: fontSize,
        ),
        textAlign: isCenter ? pw.TextAlign.center : null,
      ),
      verticalPadding: verticalPadding,
      horizontalPadding: horizontalPadding,
    );
  }

  pw.Column _buildTableHeader(PdfPageFormat pageFormat) {
    return pw.Column(
      children: [
        pw.Table(
          columnWidths: {
            0: const pw.FixedColumnWidth(920.0),
            1: const pw.FixedColumnWidth(350.0),
          },
          children: [
            pw.TableRow(
              children: [
                _buildCell(
                  data:
                      'To be filled up by the Supply and/or Property Division/Unit',
                  font: serviceLocator<FontService>()
                      .getFont('timesNewRomanItalic'),
                  borderRight: false,
                  borderBottom: false,
                  verticalPadding: pageFormat == PdfPageFormat.a4 ? 9.0 : 8.0,
                  fontSize: 8.0,
                ),
                _buildCell(
                  data: 'To be filled up by the Accounting Division/Unit',
                  font: serviceLocator<FontService>()
                      .getFont('timesNewRomanItalic'),
                  borderBottom: false,
                  verticalPadding: pageFormat == PdfPageFormat.a4 ? 4.0 : 4.0,
                  fontSize: 8.0,
                ),
              ],
            ),
          ],
        ),
        pw.Table(columnWidths: {
          0: const pw.FixedColumnWidth(115),
          1: const pw.FixedColumnWidth(157),
          2: const pw.FixedColumnWidth(128),
          3: const pw.FixedColumnWidth(320),
          4: const pw.FixedColumnWidth(90),
          5: const pw.FixedColumnWidth(110),
          6: const pw.FixedColumnWidth(170),
          7: const pw.FixedColumnWidth(180),
        }, children: [
          pw.TableRow(
            children: [
              _buildCell(
                data: 'RIS No.',
                borderRight: false,
                verticalPadding: 8.0,
              ),
              _buildCell(
                data: 'Responsibility Center Code',
                borderRight: false,
              ),
              _buildCell(
                data: 'Stock No.',
                borderRight: false,
                verticalPadding: 8.0,
              ),
              _buildCell(
                data: 'Item',
                borderRight: false,
                verticalPadding: 8.0,
              ),
              _buildCell(
                data: 'Unit',
                borderRight: false,
                verticalPadding: 8.0,
              ),
              _buildCell(
                data: 'Quantity Issued',
                borderRight: false,
              ),
              _buildCell(
                data: 'Unit Cost',
                borderRight: false,
                verticalPadding: 8.0,
              ),
              _buildCell(
                data: 'Amount',
                verticalPadding: 8.0,
              ),
            ],
          ),
        ]),
      ],
    );
  }

  pw.Table _buildRecapitulationHeader() {
    return pw.Table(
      columnWidths: {
        0: const pw.FixedColumnWidth(115),
        1: const pw.FixedColumnWidth(285),
        2: const pw.FixedColumnWidth(320),
        3: const pw.FixedColumnWidth(90),
        4: const pw.FixedColumnWidth(460),
      },
      children: [
        pw.TableRow(
          children: [
            _buildCell(
              borderRight: false,
              borderTop: false,
            ),
            _buildCell(
              data: 'Recapitulation',
              borderRight: false,
              borderTop: false,
            ),
            _buildCell(
              borderRight: false,
              borderTop: false,
            ),
            _buildCell(
              borderRight: false,
              borderTop: false,
            ),
            _buildCell(
              data: 'Recapitulation',
              borderTop: false,
            ),
          ],
        ),
      ],
    );
  }

  pw.Table _buildRecapitulationSubHeader() {
    return pw.Table(
      columnWidths: {
        0: const pw.FixedColumnWidth(115),
        1: const pw.FixedColumnWidth(157),
        2: const pw.FixedColumnWidth(128),
        3: const pw.FixedColumnWidth(320),
        4: const pw.FixedColumnWidth(90),
        5: const pw.FixedColumnWidth(110),
        6: const pw.FixedColumnWidth(170),
        7: const pw.FixedColumnWidth(180),
      },
      children: [
        pw.TableRow(
          children: [
            _buildCell(
              borderTop: false,
              borderRight: false,
              verticalPadding: 8.0,
            ),
            _buildCell(
              data: 'Stock No.',
              borderTop: false,
              borderRight: false,
              verticalPadding: 8.0,
            ),
            _buildCell(
              data: 'Quantity',
              borderTop: false,
              borderRight: false,
              verticalPadding: 8.0,
            ),
            _buildCell(
              borderTop: false,
              borderRight: false,
              verticalPadding: 8.0,
            ),
            _buildCell(
              borderTop: false,
              borderRight: false,
              verticalPadding: 8.0,
            ),
            _buildCell(
              data: 'Unit Cost',
              borderTop: false,
              borderRight: false,
              verticalPadding: 8.0,
            ),
            _buildCell(
              data: 'Total Cost',
              borderTop: false,
              borderRight: false,
              verticalPadding: 8.0,
            ),
            _buildCell(
              data: 'UACS Object Code',
              borderTop: false,
            ),
          ],
        ),
      ],
    );
  }

  pw.Table _buildTableRow({
    required bool isLast,
  }) {
    return pw.Table(
      columnWidths: {
        0: const pw.FixedColumnWidth(115),
        1: const pw.FixedColumnWidth(157),
        2: const pw.FixedColumnWidth(128),
        3: const pw.FixedColumnWidth(320),
        4: const pw.FixedColumnWidth(90),
        5: const pw.FixedColumnWidth(110),
        6: const pw.FixedColumnWidth(170),
        7: const pw.FixedColumnWidth(180),
      },
      children: [
        pw.TableRow(
          children: [
            _buildCell(
              borderRight: false,
              borderBottom: isLast,
            ),
            _buildCell(
              borderRight: false,
              borderBottom: isLast,
            ),
            _buildCell(
              borderRight: false,
              borderBottom: isLast,
            ),
            _buildCell(
              borderRight: false,
              borderBottom: isLast,
            ),
            _buildCell(
              borderRight: false,
              borderBottom: isLast,
            ),
            _buildCell(
              borderRight: false,
              borderBottom: isLast,
            ),
            _buildCell(
              borderRight: false,
              borderBottom: isLast,
            ),
            _buildCell(
              borderBottom: isLast,
            ),
          ],
        ),
      ],
    );
  }

  pw.Table _buildTableFooter() {
    return pw.Table(
      columnWidths: {
        0: const pw.FixedColumnWidth(810.0),
        1: const pw.FixedColumnWidth(460.0),
      },
      children: [
        pw.TableRow(
          children: [
            _buildCell(
              borderTop: false,
              borderRight: false,
              borderBottom: false,
            ),
            _buildCell(
              data: 'Posted by:',
              borderTop: false,
              borderBottom: false,
              isCenter: false,
              font:
                  serviceLocator<FontService>().getFont('timesNewRomanRegular'),
            ),
          ],
        ),
        pw.TableRow(
          children: [
            _buildCell(
              data:
                  'I hereby certify to the correctness of the above information.',
              borderTop: false,
              borderRight: false,
              borderBottom: false,
              isCenter: false,
              font:
                  serviceLocator<FontService>().getFont('timesNewRomanRegular'),
            ),
            _buildCell(
              borderTop: false,
              borderBottom: false,
            ),
          ],
        ),
        pw.TableRow(
          children: [
            _buildCell(
              borderTop: false,
              borderRight: false,
              borderBottom: false,
            ),
            _buildCell(
              borderTop: false,
              borderBottom: false,
            ),
          ],
        ),
        pw.TableRow(
          children: [
            _buildCell(
              borderTop: false,
              borderRight: false,
              borderBottom: false,
            ),
            _buildCell(
              borderTop: false,
              borderBottom: false,
            ),
          ],
        ),
        pw.TableRow(
          children: [
            _buildCell(
              data: '____________________________________',
              borderTop: false,
              borderRight: false,
              borderBottom: false,
            ),
            _buildCell(
              data: '''_____________________   ______________''',
              borderTop: false,
              borderBottom: false,
            ),
          ],
        ),
        pw.TableRow(
          children: [
            _buildCell(
              data:
                  'Signature over Printed Name of Supply and/or Property Custodian',
              borderTop: false,
              borderRight: false,
              borderBottom: false,
              font:
                  serviceLocator<FontService>().getFont('timesNewRomanRegular'),
            ),
            _buildCell(
              data: '''Signature over Printed             Date''',
              borderTop: false,
              borderBottom: false,
              font:
                  serviceLocator<FontService>().getFont('timesNewRomanRegular'),
            ),
          ],
        ),
        pw.TableRow(
          children: [
            _buildCell(
              borderTop: false,
              borderRight: false,
            ),
            _buildCell(
              borderTop: false,
            ),
          ],
        ),
      ],
    );
  }
}
