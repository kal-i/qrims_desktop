import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../init_dependencies.dart';
import '../font_service.dart';
import '../utils/document_components.dart';
import '../utils/document_page_util.dart';
import 'base_document.dart';

class StockCard implements BaseDocument {
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
                  'STOCK CARD',
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
              0: const pw.FixedColumnWidth(770.0),
              1: const pw.FixedColumnWidth(300.0),
            },
            children: [
              pw.TableRow(
                children: [
                  pw.Text(
                    'Entity Name:',
                    style: pw.TextStyle(
                      font: serviceLocator<FontService>()
                          .getFont('timesNewRomanBold'),
                      fontSize: 10.0,
                    ),
                  ),
                  pw.Text(
                    'Fund Cluster:',
                    style: pw.TextStyle(
                      font: serviceLocator<FontService>()
                          .getFont('timesNewRomanBold'),
                      fontSize: 10.0,
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
          for (int i = 0; i < 20; i++)
            _buildTableRow(isLast: i == 20 - 1 ? true : false),
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
            0: const pw.FixedColumnWidth(770.0),
            1: const pw.FixedColumnWidth(300.0),
          },
          children: [
            pw.TableRow(
              children: [
                _buildCell(
                  data: 'Item:',
                  borderRight: false,
                  borderBottom: false,
                  isCenter: false,
                ),
                _buildCell(
                  data: 'Stock No.:',
                  borderBottom: false,
                  isCenter: false,
                ),
              ],
            ),
            pw.TableRow(
              children: [
                _buildCell(
                  data: 'Description:',
                  borderRight: false,
                  borderBottom: false,
                  isCenter: false,
                ),
                _buildCell(
                  data: 'Re-order Point:',
                  borderBottom: false,
                  isCenter: false,
                ),
              ],
            ),
            pw.TableRow(
              children: [
                _buildCell(
                  data: 'Unit of Measurement:',
                  borderRight: false,
                  borderBottom: false,
                  isCenter: false,
                ),
                _buildCell(
                  borderBottom: false,
                ),
              ],
            ),
          ],
        ),
        pw.Table(columnWidths: {
          0: const pw.FixedColumnWidth(115),
          1: const pw.FixedColumnWidth(207),
          2: const pw.FixedColumnWidth(128),
          3: const pw.FixedColumnWidth(320),
          4: const pw.FixedColumnWidth(150),
          5: const pw.FixedColumnWidth(150),
        }, children: [
          pw.TableRow(
            children: [
              _buildCell(
                data: 'Date',
                borderRight: false,
                verticalPadding: 11.0,
              ),
              _buildCell(
                data: 'Reference',
                borderRight: false,
                verticalPadding: 11.0,
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  _buildCell(
                    data: 'Receipt',
                    borderRight: false,
                    borderBottom: false,
                  ),
                  _buildCell(
                    data: 'Qty.',
                    borderRight: false,
                    borderWidthTop: 1.5,
                    font: serviceLocator<FontService>()
                        .getFont('timesNewRomanRegular'),
                  ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  _buildCell(
                    data: 'Issue',
                    borderRight: false,
                    borderBottom: false,
                  ),
                  pw.Row(
                    children: [
                      pw.Expanded(
                        child: _buildCell(
                          data: 'Qty.',
                          borderRight: false,
                          borderWidthTop: 1.5,
                          font: serviceLocator<FontService>()
                              .getFont('timesNewRomanRegular'),
                        ),
                      ),
                      pw.Expanded(
                        child: _buildCell(
                          data: 'Office',
                          borderRight: false,
                          borderWidthTop: 1.5,
                          borderWitdhLeft: 1.5,
                          font: serviceLocator<FontService>()
                              .getFont('timesNewRomanRegular'),
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
                    data: 'Balance',
                    borderRight: false,
                    borderBottom: false,
                  ),
                  _buildCell(
                    data: 'Qty.',
                    borderRight: false,
                    borderWidthTop: 1.5,
                    font: serviceLocator<FontService>()
                        .getFont('timesNewRomanRegular'),
                  ),
                ],
              ),
              _buildCell(
                data: 'No. of Days to Consume',
                verticalPadding: 6.0,
              ),
            ],
          ),
        ]),
      ],
    );
  }

  pw.Table _buildTableRow({
    required bool isLast,
  }) {
    return pw.Table(
      columnWidths: {
        0: const pw.FixedColumnWidth(115),
        1: const pw.FixedColumnWidth(207),
        2: const pw.FixedColumnWidth(128),
        3: const pw.FixedColumnWidth(320),
        4: const pw.FixedColumnWidth(150),
        5: const pw.FixedColumnWidth(150),
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
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                pw.Row(
                  children: [
                    pw.Expanded(
                      child: _buildCell(
                        borderRight: false,
                        borderWidthTop: 1.5,
                      ),
                    ),
                    pw.Expanded(
                      child: _buildCell(
                        borderRight: false,
                        borderWidthTop: 1.5,
                        borderWitdhLeft: 1.5,
                      ),
                    ),
                  ],
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
