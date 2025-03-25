import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../font_service.dart';
import '../image_service.dart';
import '../utils/document_components.dart';
import '../utils/document_page_util.dart';
import 'base_document.dart';

class PropertyCard implements BaseDocument {
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
            child: pw.Text(
              'PROPERTY CARD',
              style: const pw.TextStyle(
                //font: FontService().getFont('timesNewRomanBold'),
                fontSize: 14.0,
              ),
            ),
          ),
          pw.SizedBox(
            height: 50.0,
          ),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Entity Name: _________________________________________________',
                style: const pw.TextStyle(
                  //font: FontService().getFont('timesNewRomanBold'),
                  fontSize: 10.0,
                ),
              ),
              pw.Text(
                'Fund Cluster: _______________________________',
                style: const pw.TextStyle(
                  //font: FontService().getFont('timesNewRomanBold'),
                  fontSize: 10.0,
                ),
              ),
            ],
          ),
          pw.SizedBox(
            height: 5.0,
          ),
          _buildTableHeader(),
          for (int i = 0; i < 25; i++)
            _buildTableRow(isLast: i == 25 - 1 ? true : false),
        ],
      ),
    );
    return pdf;
  }

  pw.Widget _buildCell({
    String? text,
    double? horizontalPadding = 3.0,
    double? verticalPadding = 3.0,
    bool borderTop = true,
    bool borderRight = true,
    bool borderBottom = true,
    bool borderLeft = true,
    double borderWidthTop = 3.5,
    double borderWidthRight = 3.5,
    double borderWidthBottom = 3.5,
    double borderWitdhLeft = 3.5,
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
        text ?? '\n',
        style: const pw.TextStyle(
          fontSize: 10.0,
        ),
        textAlign: pw.TextAlign.center,
      ),
      verticalPadding: verticalPadding,
      horizontalPadding: horizontalPadding,
    );
  }

  pw.Widget _buildTableHeader() {
    return pw.Column(
      children: [
        pw.Table(
          columnWidths: {
            0: const pw.FixedColumnWidth(1375.0),
            1: const pw.FixedColumnWidth(540.0),
          },
          children: [
            pw.TableRow(
              children: [
                DocumentComponents.buildContainer(
                  child: pw.Text(
                    'Property:',
                    style: const pw.TextStyle(
                      fontSize: 10.0,
                    ),
                  ),
                  verticalPadding: 3.0,
                  horizontalPadding: 3.0,
                  borderRight: false,
                  borderBottom: false,
                ),
                DocumentComponents.buildContainer(
                  child: pw.Text(
                    'Property No:',
                    style: const pw.TextStyle(
                      fontSize: 10.0,
                    ),
                  ),
                  verticalPadding: 3.0,
                  horizontalPadding: 3.0,
                  borderBottom: false,
                ),
              ],
            ),
            pw.TableRow(
              children: [
                DocumentComponents.buildContainer(
                  child: pw.Text(
                    'Description:',
                    style: const pw.TextStyle(
                      fontSize: 10.0,
                    ),
                  ),
                  verticalPadding: 3.0,
                  horizontalPadding: 3.0,
                  borderRight: false,
                  borderBottom: false,
                ),
                DocumentComponents.buildContainer(
                  verticalPadding: 8.8,
                  horizontalPadding: 3.0,
                  borderTop: false,
                  borderBottom: false,
                ),
              ],
            ),
          ],
        ),
        pw.Table(
          columnWidths: {
            0: const pw.FixedColumnWidth(150.0),
            1: const pw.FixedColumnWidth(250.0),
            2: const pw.FixedColumnWidth(450.0),
            3: const pw.FixedColumnWidth(525.0),
            4: const pw.FixedColumnWidth(170.0),
            5: const pw.FixedColumnWidth(170.0),
            6: const pw.FixedColumnWidth(200.0),
          },
          children: [
            pw.TableRow(
              children: [
                _buildCell(
                  text: 'Date',
                  verticalPadding: 11.9,
                  borderRight: false,
                  borderBottom: false,
                ),
                _buildCell(
                  text: 'Reference',
                  verticalPadding: 11.9,
                  borderRight: false,
                  borderBottom: false,
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                  children: [
                    _buildCell(
                      text: 'Receipt',
                      borderRight: false,
                      borderWidthBottom: 2.0,
                    ),
                    pw.Row(
                      children: [
                        pw.Expanded(
                          child: _buildCell(
                            text: 'Qty.',
                            borderTop: false,
                            borderRight: false,
                            borderBottom: false,
                          ),
                        ),
                        pw.Expanded(
                          child: _buildCell(
                            text: 'Unit Cost',
                            borderTop: false,
                            borderRight: false,
                            borderBottom: false,
                            borderWitdhLeft: 2.0,
                          ),
                        ),
                        pw.Expanded(
                          child: _buildCell(
                            text: 'Total Cost',
                            borderTop: false,
                            borderRight: false,
                            borderBottom: false,
                            borderWitdhLeft: 2.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                  children: [
                    _buildCell(
                      text: 'Issued/Transfer/Disposal',
                      borderRight: false,
                      borderWidthBottom: 2.0,
                    ),
                    pw.Row(
                      children: [
                        pw.Expanded(
                          child: _buildCell(
                            text: 'Property No',
                            borderTop: false,
                            borderRight: false,
                            borderBottom: false,
                          ),
                        ),
                        pw.Expanded(
                          child: _buildCell(
                            text: 'Qty.',
                            borderTop: false,
                            borderRight: false,
                            borderBottom: false,
                            borderWitdhLeft: 2.0,
                          ),
                        ),
                        pw.Expanded(
                          child: _buildCell(
                            text: 'Office/Officer',
                            borderTop: false,
                            borderRight: false,
                            borderBottom: false,
                            borderWitdhLeft: 2.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                  children: [
                    _buildCell(
                      text: 'Balance',
                      borderRight: false,
                      borderWidthBottom: 2.0,
                    ),
                    _buildCell(
                      text: 'Qty.',
                      borderTop: false,
                      borderRight: false,
                      borderBottom: false,
                    ),
                  ],
                ),
                _buildCell(
                  text: 'Amount',
                  verticalPadding: 11.9,
                  borderRight: false,
                  borderBottom: false,
                ),
                _buildCell(
                  text: 'Remarks',
                  verticalPadding: 11.9,
                  borderBottom: false,
                ),
              ],
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
        0: const pw.FixedColumnWidth(150.0),
        1: const pw.FixedColumnWidth(250.0),
        2: const pw.FixedColumnWidth(450.0),
        3: const pw.FixedColumnWidth(525.0),
        4: const pw.FixedColumnWidth(170.0),
        5: const pw.FixedColumnWidth(170.0),
        6: const pw.FixedColumnWidth(200.0),
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
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                pw.Row(
                  children: [
                    pw.Expanded(
                      child: _buildCell(
                        borderRight: false,
                        borderBottom: isLast,
                      ),
                    ),
                    pw.Expanded(
                      child: _buildCell(
                        borderRight: false,
                        borderBottom: isLast,
                        borderWitdhLeft: 2.0,
                      ),
                    ),
                    pw.Expanded(
                      child: _buildCell(
                        borderRight: false,
                        borderBottom: isLast,
                        borderWitdhLeft: 2.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                pw.Row(
                  children: [
                    pw.Expanded(
                      child: _buildCell(
                        borderRight: false,
                        borderBottom: isLast,
                      ),
                    ),
                    pw.Expanded(
                      child: _buildCell(
                        borderRight: false,
                        borderBottom: isLast,
                        borderWitdhLeft: 2.0,
                      ),
                    ),
                    pw.Expanded(
                      child: _buildCell(
                        borderRight: false,
                        borderBottom: isLast,
                        borderWitdhLeft: 2.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                _buildCell(
                  borderRight: false,
                  borderBottom: isLast,
                ),
              ],
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
}
