import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../utils/document_components.dart';
import '../utils/document_page_util.dart';
import 'base_document.dart';

class RSPI implements BaseDocument {
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
            child: pw.Text(
              'REPORT OF SEMI-EXPENDABLE PROPERTY ISSUED',
              style: const pw.TextStyle(
                //font: FontService().getFont('timesNewRomanBold'),
                fontSize: 12.0,
              ),
            ),
          ),
          pw.SizedBox(
            height: 20.0,
          ),
          pw.Table(
            columnWidths: {
              0: const pw.FixedColumnWidth(825.0),
              1: const pw.FixedColumnWidth(440.0),
            },
            children: [
              pw.TableRow(
                children: [
                  pw.Text(
                    'Entity Name: __________________',
                    style: const pw.TextStyle(
                      //font: FontService().getFont('timesNewRomanBold'),
                      fontSize: 10.0,
                    ),
                  ),
                  pw.Text(
                    'Serial No.: __________________',
                    style: const pw.TextStyle(
                      //font: FontService().getFont('timesNewRomanBold'),
                      fontSize: 10.0,
                    ),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Text(
                    'Fund Cluster: __________________',
                    style: const pw.TextStyle(
                      //font: FontService().getFont('timesNewRomanBold'),
                      fontSize: 10.0,
                    ),
                  ),
                  pw.Text(
                    'Date: ______________________',
                    style: const pw.TextStyle(
                      //font: FontService().getFont('timesNewRomanBold'),
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
          _buildTableHeader(),
          for (int i = 0; i < 25; i++)
            _buildTableRow(isLast: i == 25 - 1 ? true : false),
          _buildTableFooter(),
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
          fontSize: 8.0,
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
            0: const pw.FixedColumnWidth(830.0),
            1: const pw.FixedColumnWidth(440.0),
          },
          children: [
            pw.TableRow(
              children: [
                DocumentComponents.buildContainer(
                  child: pw.Text(
                    'To be filled out by Property and/or Supply Division/Unit',
                    style: pw.TextStyle(
                      fontSize: 8.0,
                      fontStyle: pw.FontStyle.italic,
                      fontWeight: pw.FontWeight.bold,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                  verticalPadding: 3.0,
                  horizontalPadding: 3.0,
                  borderRight: false,
                  borderBottom: false,
                ),
                DocumentComponents.buildContainer(
                  child: pw.Text(
                    'To be filled out by the Accounting Division/Unit',
                    style: pw.TextStyle(
                      fontSize: 8.0,
                      fontStyle: pw.FontStyle.italic,
                      fontWeight: pw.FontWeight.bold,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                  verticalPadding: 3.0,
                  horizontalPadding: 3.0,
                  borderBottom: false,
                ),
              ],
            ),
          ],
        ),
        pw.Table(
          columnWidths: {
            0: const pw.FixedColumnWidth(95),
            1: const pw.FixedColumnWidth(162),
            2: const pw.FixedColumnWidth(183),
            3: const pw.FixedColumnWidth(200),
            4: const pw.FixedColumnWidth(90),
            5: const pw.FixedColumnWidth(100),
            6: const pw.FixedColumnWidth(210),
            7: const pw.FixedColumnWidth(230),
          },
          children: [
            pw.TableRow(
              children: [
                _buildCell(
                  text: 'ICS No.',
                  borderRight: false,
                  borderBottom: false,
                  verticalPadding: 9.0,
                ),
                _buildCell(
                  text: 'Responsibility Center Code',
                  borderRight: false,
                  borderBottom: false,
                ),
                _buildCell(
                  text: 'Semi-Expendable Property No.',
                  borderRight: false,
                  borderBottom: false,
                ),
                _buildCell(
                  text: 'Item Description',
                  borderRight: false,
                  borderBottom: false,
                  verticalPadding: 9.0,
                ),
                _buildCell(
                  text: 'Unit',
                  borderRight: false,
                  borderBottom: false,
                  verticalPadding: 9.0,
                ),
                _buildCell(
                  text: 'Quantity Issued',
                  borderRight: false,
                  borderBottom: false,
                ),
                _buildCell(
                  text: 'Unit Cost',
                  borderRight: false,
                  borderBottom: false,
                  verticalPadding: 9.0,
                ),
                _buildCell(
                  text: 'Amount',
                  borderBottom: false,
                  verticalPadding: 9.0,
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
        0: const pw.FixedColumnWidth(95),
        1: const pw.FixedColumnWidth(162),
        2: const pw.FixedColumnWidth(183),
        3: const pw.FixedColumnWidth(200),
        4: const pw.FixedColumnWidth(90),
        5: const pw.FixedColumnWidth(100),
        6: const pw.FixedColumnWidth(210),
        7: const pw.FixedColumnWidth(230),
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
        0: const pw.FixedColumnWidth(825.0),
        1: const pw.FixedColumnWidth(440.0),
      },
      children: [
        pw.TableRow(
          children: [
            _buildCell(
              borderTop: false,
              borderRight: false,
              borderBottom: false,
            ),
            DocumentComponents.buildContainer(
              child: pw.Text(
                'Posted by:',
                style: const pw.TextStyle(
                  fontSize: 8.0,
                ),
              ),
              borderTop: false,
              borderBottom: false,
              verticalPadding: 3.0,
              horizontalPadding: 3.0,
            ),
          ],
        ),
        pw.TableRow(
          children: [
            DocumentComponents.buildContainer(
              child: pw.Text(
                'I hereby certify to the correctness of the above information',
                style: const pw.TextStyle(
                  fontSize: 8.0,
                ),
              ),
              borderTop: false,
              borderRight: false,
              borderBottom: false,
              verticalPadding: 3.0,
              horizontalPadding: 3.0,
            ),
            _buildCell(
              borderTop: false,
              borderBottom: false,
            ),
          ],
        ),
        pw.TableRow(
          children: [
            DocumentComponents.buildContainer(
              child: pw.Text(
                '\n_________________________________________________',
                style: const pw.TextStyle(
                  fontSize: 8.0,
                ),
                textAlign: pw.TextAlign.center,
              ),
              borderTop: false,
              borderRight: false,
              borderBottom: false,
              verticalPadding: 3.0,
              horizontalPadding: 3.0,
            ),
            DocumentComponents.buildContainer(
              child: pw.Text(
                '\n_______________________________',
                style: const pw.TextStyle(
                  fontSize: 8.0,
                ),
                textAlign: pw.TextAlign.center,
              ),
              borderTop: false,
              borderBottom: false,
              verticalPadding: 3.0,
              horizontalPadding: 3.0,
            ),
          ],
        ),
        pw.TableRow(
          children: [
            _buildCell(
              text:
                  'Signature over Printed Name of property and/or Supply Custodian',
              borderTop: false,
              borderRight: false,
              borderBottom: false,
              verticalPadding: 7.5,
            ),
            _buildCell(
              text: 'Signature over Printed Name of Designated Account Staff',
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
