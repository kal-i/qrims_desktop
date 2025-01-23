import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../utils/document_components.dart';
import '../utils/document_page_util.dart';
import 'base_document.dart';

class AnnexA8 implements BaseDocument {
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
            child: _buildHeader(),
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
          _buildTableHeader(pageFormat),
          for (int i = 0; i < 5; i++) _buildTableContent(pageFormat),
          pw.Table(
            columnWidths: pageFormat == PdfPageFormat.a4
                ? {
                    0: const pw.FixedColumnWidth(1250.0),
                    1: const pw.FixedColumnWidth(960.0),
                    2: const pw.FixedColumnWidth(775.0),
                  }
                : pageFormat == PdfPageFormat.letter
                    ? {
                        0: const pw.FixedColumnWidth(300.0),
                        1: const pw.FixedColumnWidth(400.0),
                        2: const pw.FixedColumnWidth(200.0),
                        3: const pw.FixedColumnWidth(190.0),
                        4: const pw.FixedColumnWidth(125.0),
                        5: const pw.FixedColumnWidth(250.0),
                        6: const pw.FixedColumnWidth(250.0),
                        7: const pw.FixedColumnWidth(240.0),
                        8: const pw.FixedColumnWidth(240.0),
                      }
                    : {
                        0: const pw.FixedColumnWidth(360.0),
                        1: const pw.FixedColumnWidth(470.0),
                        2: const pw.FixedColumnWidth(200.0),
                        3: const pw.FixedColumnWidth(150.0),
                        4: const pw.FixedColumnWidth(100.0),
                        5: const pw.FixedColumnWidth(200.0),
                        6: const pw.FixedColumnWidth(200.0),
                        7: const pw.FixedColumnWidth(240.0),
                        8: const pw.FixedColumnWidth(470.0),
                      },
            children: [
              pw.TableRow(
                children: [
                  DocumentComponents.buildContainer(
                    borderTop: false,
                    borderRight: false,
                    borderBottom: false,
                    verticalPadding: 3.0,
                    horizontalPadding: 3.0,
                    child: pw.Text(
                      'Certified Correct by:',
                      style: const pw.TextStyle(
                        fontSize: 8.0,
                      ),
                    ),
                  ),
                  DocumentComponents.buildContainer(
                    borderTop: false,
                    borderRight: false,
                    borderBottom: false,
                    borderLeft: false,
                    verticalPadding: 3.0,
                    horizontalPadding: 3.0,
                    child: pw.Text(
                      'Approved by:',
                      style: const pw.TextStyle(
                        fontSize: 8.0,
                      ),
                    ),
                  ),
                  DocumentComponents.buildContainer(
                    borderTop: false,
                    borderBottom: false,
                    borderLeft: false,
                    verticalPadding: 3.0,
                    horizontalPadding: 3.0,
                    child: pw.Text(
                      'Witnessed by:',
                      style: const pw.TextStyle(
                        fontSize: 8.0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          pw.Table(
            columnWidths: pageFormat == PdfPageFormat.a4
                ? {
                    0: const pw.FixedColumnWidth(1250.0),
                    1: const pw.FixedColumnWidth(960.0),
                    2: const pw.FixedColumnWidth(775.0),
                  }
                : pageFormat == PdfPageFormat.letter
                    ? {
                        0: const pw.FixedColumnWidth(300.0),
                        1: const pw.FixedColumnWidth(400.0),
                        2: const pw.FixedColumnWidth(200.0),
                        3: const pw.FixedColumnWidth(190.0),
                        4: const pw.FixedColumnWidth(125.0),
                        5: const pw.FixedColumnWidth(250.0),
                        6: const pw.FixedColumnWidth(250.0),
                        7: const pw.FixedColumnWidth(240.0),
                        8: const pw.FixedColumnWidth(240.0),
                      }
                    : {
                        0: const pw.FixedColumnWidth(360.0),
                        1: const pw.FixedColumnWidth(470.0),
                        2: const pw.FixedColumnWidth(200.0),
                        3: const pw.FixedColumnWidth(150.0),
                        4: const pw.FixedColumnWidth(100.0),
                        5: const pw.FixedColumnWidth(200.0),
                        6: const pw.FixedColumnWidth(200.0),
                        7: const pw.FixedColumnWidth(240.0),
                        8: const pw.FixedColumnWidth(470.0),
                      },
            children: [
              pw.TableRow(
                children: [
                  DocumentComponents.buildContainer(
                    borderTop: false,
                    borderRight: false,
                    borderBottom: false,
                    verticalPadding: 5.0,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        _buildAssociatedOfficerField(
                          title: 'Inventory Committee Chair',
                        ),
                      ],
                    ),
                  ),
                  DocumentComponents.buildContainer(
                    borderTop: false,
                    borderRight: false,
                    borderBottom: false,
                    borderLeft: false,
                    verticalPadding: 5.0,
                    child: pw.Column(
                      children: [
                        _buildAssociatedOfficerField(
                          title:
                              'head of Agency/Entity or Authorized Representative',
                        ),
                      ],
                    ),
                  ),
                  DocumentComponents.buildContainer(
                    borderTop: false,
                    borderBottom: false,
                    borderLeft: false,
                    verticalPadding: 5.0,
                    child: pw.Column(
                      children: [
                        _buildAssociatedOfficerField(
                          title: 'COA Representative',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          pw.Table(
            columnWidths: pageFormat == PdfPageFormat.a4
                ? {
                    0: const pw.FixedColumnWidth(1250.0),
                    1: const pw.FixedColumnWidth(960.0),
                    2: const pw.FixedColumnWidth(775.0),
                  }
                : pageFormat == PdfPageFormat.letter
                    ? {
                        0: const pw.FixedColumnWidth(300.0),
                        1: const pw.FixedColumnWidth(400.0),
                        2: const pw.FixedColumnWidth(200.0),
                        3: const pw.FixedColumnWidth(190.0),
                        4: const pw.FixedColumnWidth(125.0),
                        5: const pw.FixedColumnWidth(250.0),
                        6: const pw.FixedColumnWidth(250.0),
                        7: const pw.FixedColumnWidth(240.0),
                        8: const pw.FixedColumnWidth(240.0),
                      }
                    : {
                        0: const pw.FixedColumnWidth(360.0),
                        1: const pw.FixedColumnWidth(470.0),
                        2: const pw.FixedColumnWidth(200.0),
                        3: const pw.FixedColumnWidth(150.0),
                        4: const pw.FixedColumnWidth(100.0),
                        5: const pw.FixedColumnWidth(200.0),
                        6: const pw.FixedColumnWidth(200.0),
                        7: const pw.FixedColumnWidth(240.0),
                        8: const pw.FixedColumnWidth(470.0),
                      },
            children: [
              pw.TableRow(
                children: [
                  DocumentComponents.buildContainer(
                    borderTop: false,
                    borderRight: false,
                    borderBottom: false,
                    verticalPadding: 5.0,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        _buildAssociatedOfficerField(
                          title: 'Inventory Committee Co-Chair',
                        ),
                      ],
                    ),
                  ),
                  DocumentComponents.buildContainer(
                    borderTop: false,
                    borderRight: false,
                    borderBottom: false,
                    borderLeft: false,
                    verticalPadding: 5.0,
                  ),
                  DocumentComponents.buildContainer(
                    borderTop: false,
                    borderLeft: false,
                    borderBottom: false,
                    verticalPadding: 21.4,
                  ),
                ],
              ),
            ],
          ),
          pw.Table(
            columnWidths: pageFormat == PdfPageFormat.a4
                ? {
                    0: const pw.FixedColumnWidth(1250.0),
                    1: const pw.FixedColumnWidth(960.0),
                    2: const pw.FixedColumnWidth(775.0),
                  }
                : pageFormat == PdfPageFormat.letter
                    ? {
                        0: const pw.FixedColumnWidth(300.0),
                        1: const pw.FixedColumnWidth(400.0),
                        2: const pw.FixedColumnWidth(200.0),
                        3: const pw.FixedColumnWidth(190.0),
                        4: const pw.FixedColumnWidth(125.0),
                        5: const pw.FixedColumnWidth(250.0),
                        6: const pw.FixedColumnWidth(250.0),
                        7: const pw.FixedColumnWidth(240.0),
                        8: const pw.FixedColumnWidth(240.0),
                      }
                    : {
                        0: const pw.FixedColumnWidth(360.0),
                        1: const pw.FixedColumnWidth(470.0),
                        2: const pw.FixedColumnWidth(200.0),
                        3: const pw.FixedColumnWidth(150.0),
                        4: const pw.FixedColumnWidth(100.0),
                        5: const pw.FixedColumnWidth(200.0),
                        6: const pw.FixedColumnWidth(200.0),
                        7: const pw.FixedColumnWidth(240.0),
                        8: const pw.FixedColumnWidth(470.0),
                      },
            children: [
              pw.TableRow(
                children: [
                  DocumentComponents.buildContainer(
                    borderTop: false,
                    borderRight: false,
                    borderBottom: false,
                    verticalPadding: 5.0,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        _buildAssociatedOfficerField(
                          title: 'Inventory Committee Member',
                        ),
                      ],
                    ),
                  ),
                  DocumentComponents.buildContainer(
                    borderTop: false,
                    borderRight: false,
                    borderBottom: false,
                    borderLeft: false,
                    verticalPadding: 5.0,
                  ),
                  DocumentComponents.buildContainer(
                    borderTop: false,
                    borderBottom: false,
                    borderLeft: false,
                    verticalPadding: 21.4,
                  ),
                ],
              ),
            ],
          ),
          pw.Table(
            columnWidths: pageFormat == PdfPageFormat.a4
                ? {
                    0: const pw.FixedColumnWidth(1250.0),
                    1: const pw.FixedColumnWidth(960.0),
                    2: const pw.FixedColumnWidth(775.0),
                  }
                : pageFormat == PdfPageFormat.letter
                    ? {
                        0: const pw.FixedColumnWidth(300.0),
                        1: const pw.FixedColumnWidth(400.0),
                        2: const pw.FixedColumnWidth(200.0),
                        3: const pw.FixedColumnWidth(190.0),
                        4: const pw.FixedColumnWidth(125.0),
                        5: const pw.FixedColumnWidth(250.0),
                        6: const pw.FixedColumnWidth(250.0),
                        7: const pw.FixedColumnWidth(240.0),
                        8: const pw.FixedColumnWidth(240.0),
                      }
                    : {
                        0: const pw.FixedColumnWidth(360.0),
                        1: const pw.FixedColumnWidth(470.0),
                        2: const pw.FixedColumnWidth(200.0),
                        3: const pw.FixedColumnWidth(150.0),
                        4: const pw.FixedColumnWidth(100.0),
                        5: const pw.FixedColumnWidth(200.0),
                        6: const pw.FixedColumnWidth(200.0),
                        7: const pw.FixedColumnWidth(240.0),
                        8: const pw.FixedColumnWidth(470.0),
                      },
            children: [
              pw.TableRow(
                children: [
                  DocumentComponents.buildContainer(
                    borderTop: false,
                    borderRight: false,
                    borderBottom: false,
                    verticalPadding: 5.0,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        _buildAssociatedOfficerField(
                          title: 'Inventory Committee Member',
                        ),
                      ],
                    ),
                  ),
                  DocumentComponents.buildContainer(
                    borderTop: false,
                    borderRight: false,
                    borderBottom: false,
                    borderLeft: false,
                    verticalPadding: 5.0,
                  ),
                  DocumentComponents.buildContainer(
                    borderTop: false,
                    borderBottom: false,
                    borderLeft: false,
                    verticalPadding: 21.4,
                  ),
                ],
              ),
            ],
          ),
          pw.Table(
            columnWidths: pageFormat == PdfPageFormat.a4
                ? {
                    0: const pw.FixedColumnWidth(1250.0),
                    1: const pw.FixedColumnWidth(960.0),
                    2: const pw.FixedColumnWidth(775.0),
                  }
                : pageFormat == PdfPageFormat.letter
                    ? {
                        0: const pw.FixedColumnWidth(300.0),
                        1: const pw.FixedColumnWidth(400.0),
                        2: const pw.FixedColumnWidth(200.0),
                        3: const pw.FixedColumnWidth(190.0),
                        4: const pw.FixedColumnWidth(125.0),
                        5: const pw.FixedColumnWidth(250.0),
                        6: const pw.FixedColumnWidth(250.0),
                        7: const pw.FixedColumnWidth(240.0),
                        8: const pw.FixedColumnWidth(240.0),
                      }
                    : {
                        0: const pw.FixedColumnWidth(360.0),
                        1: const pw.FixedColumnWidth(470.0),
                        2: const pw.FixedColumnWidth(200.0),
                        3: const pw.FixedColumnWidth(150.0),
                        4: const pw.FixedColumnWidth(100.0),
                        5: const pw.FixedColumnWidth(200.0),
                        6: const pw.FixedColumnWidth(200.0),
                        7: const pw.FixedColumnWidth(240.0),
                        8: const pw.FixedColumnWidth(470.0),
                      },
            children: [
              pw.TableRow(
                children: [
                  DocumentComponents.buildContainer(
                    borderTop: false,
                    borderRight: false,
                    borderBottom: false,
                    verticalPadding: 5.0,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        _buildAssociatedOfficerField(
                          title: 'Inventory Committee Member',
                        ),
                      ],
                    ),
                  ),
                  DocumentComponents.buildContainer(
                    borderTop: false,
                    borderRight: false,
                    borderBottom: false,
                    borderLeft: false,
                    verticalPadding: 5.0,
                  ),
                  DocumentComponents.buildContainer(
                    borderTop: false,
                    borderBottom: false,
                    borderLeft: false,
                    verticalPadding: 21.4,
                  ),
                ],
              ),
            ],
          ),
          pw.Table(
            columnWidths: pageFormat == PdfPageFormat.a4
                ? {
                    0: const pw.FixedColumnWidth(1250.0),
                    1: const pw.FixedColumnWidth(960.0),
                    2: const pw.FixedColumnWidth(775.0),
                  }
                : pageFormat == PdfPageFormat.letter
                    ? {
                        0: const pw.FixedColumnWidth(300.0),
                        1: const pw.FixedColumnWidth(400.0),
                        2: const pw.FixedColumnWidth(200.0),
                        3: const pw.FixedColumnWidth(190.0),
                        4: const pw.FixedColumnWidth(125.0),
                        5: const pw.FixedColumnWidth(250.0),
                        6: const pw.FixedColumnWidth(250.0),
                        7: const pw.FixedColumnWidth(240.0),
                        8: const pw.FixedColumnWidth(240.0),
                      }
                    : {
                        0: const pw.FixedColumnWidth(360.0),
                        1: const pw.FixedColumnWidth(470.0),
                        2: const pw.FixedColumnWidth(200.0),
                        3: const pw.FixedColumnWidth(150.0),
                        4: const pw.FixedColumnWidth(100.0),
                        5: const pw.FixedColumnWidth(200.0),
                        6: const pw.FixedColumnWidth(200.0),
                        7: const pw.FixedColumnWidth(240.0),
                        8: const pw.FixedColumnWidth(470.0),
                      },
            children: [
              pw.TableRow(
                children: [
                  DocumentComponents.buildContainer(
                    borderTop: false,
                    borderRight: false,
                    borderBottom: false,
                    verticalPadding: 5.0,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        _buildAssociatedOfficerField(
                          title: 'Inventory Committee Member',
                        ),
                      ],
                    ),
                  ),
                  DocumentComponents.buildContainer(
                    borderTop: false,
                    borderRight: false,
                    borderBottom: false,
                    borderLeft: false,
                    verticalPadding: 5.0,
                  ),
                  DocumentComponents.buildContainer(
                    borderTop: false,
                    borderBottom: false,
                    borderLeft: false,
                    verticalPadding: 21.4,
                  ),
                ],
              ),
            ],
          ),
          pw.Table(
            columnWidths: pageFormat == PdfPageFormat.a4
                ? {
                    0: const pw.FixedColumnWidth(1250.0),
                    1: const pw.FixedColumnWidth(960.0),
                    2: const pw.FixedColumnWidth(775.0),
                  }
                : pageFormat == PdfPageFormat.letter
                    ? {
                        0: const pw.FixedColumnWidth(300.0),
                        1: const pw.FixedColumnWidth(400.0),
                        2: const pw.FixedColumnWidth(200.0),
                        3: const pw.FixedColumnWidth(190.0),
                        4: const pw.FixedColumnWidth(125.0),
                        5: const pw.FixedColumnWidth(250.0),
                        6: const pw.FixedColumnWidth(250.0),
                        7: const pw.FixedColumnWidth(240.0),
                        8: const pw.FixedColumnWidth(240.0),
                      }
                    : {
                        0: const pw.FixedColumnWidth(360.0),
                        1: const pw.FixedColumnWidth(470.0),
                        2: const pw.FixedColumnWidth(200.0),
                        3: const pw.FixedColumnWidth(150.0),
                        4: const pw.FixedColumnWidth(100.0),
                        5: const pw.FixedColumnWidth(200.0),
                        6: const pw.FixedColumnWidth(200.0),
                        7: const pw.FixedColumnWidth(240.0),
                        8: const pw.FixedColumnWidth(470.0),
                      },
            children: [
              pw.TableRow(
                children: [
                  DocumentComponents.buildContainer(
                    borderTop: false,
                    borderRight: false,
                    verticalPadding: 5.0,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        _buildAssociatedOfficerField(
                          title: 'Inventory Committee Member',
                        ),
                      ],
                    ),
                  ),
                  DocumentComponents.buildContainer(
                    borderTop: false,
                    borderRight: false,
                    borderLeft: false,
                    verticalPadding: 21.4,
                  ),
                  DocumentComponents.buildContainer(
                    borderTop: false,
                    borderLeft: false,
                    verticalPadding: 21.4,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    return pdf;
  }

  pw.Widget _buildHeader() {
    return pw.Column(
      children: [
        pw.Text(
          'REPORT ON THE PHYSICAL COUNT OF SEMI-EXPENDABLE PROPERTY',
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
          '__________________________________',
          style: const pw.TextStyle(
            //font: FontService().getFont('timesNewRomanBold'),
            fontSize: 12.0,
          ),
        ),
        pw.SizedBox(
          height: 5.0,
        ),
        pw.Text(
          '(Type of Semi-expendable Property)',
          style: const pw.TextStyle(
            //font: FontService().getFont('timesNewRomanRegular'),
            fontSize: 10.0,
          ),
        ),
        pw.SizedBox(
          height: 5.0,
        ),
        pw.Text(
          'As at _______________________',
          style: const pw.TextStyle(
            //font: FontService().getFont('timesNewRomanBold'),
            fontSize: 12.0,
          ),
        ),
      ],
    );
  }

  pw.Table _buildTableHeader(PdfPageFormat pageFormat) {
    return pw.Table(
      columnWidths: pageFormat == PdfPageFormat.a4
          ? {
              0: const pw.FixedColumnWidth(300.0),
              1: const pw.FixedColumnWidth(600.0),
              2: const pw.FixedColumnWidth(350.0),
              3: const pw.FixedColumnWidth(180.0),
              4: const pw.FixedColumnWidth(125.0),
              5: const pw.FixedColumnWidth(240.0),
              6: const pw.FixedColumnWidth(240.0),
              7: const pw.FixedColumnWidth(350.0),
              8: const pw.FixedColumnWidth(600.0),
            }
          : pageFormat == PdfPageFormat.letter
              ? {
                  0: const pw.FixedColumnWidth(210.0),
                  1: const pw.FixedColumnWidth(500.0),
                  2: const pw.FixedColumnWidth(310.0),
                  3: const pw.FixedColumnWidth(180.0),
                  4: const pw.FixedColumnWidth(115.0),
                  5: const pw.FixedColumnWidth(210.0),
                  6: const pw.FixedColumnWidth(210.0),
                  7: const pw.FixedColumnWidth(320.0),
                  8: const pw.FixedColumnWidth(500.0),
                }
              : {
                  0: const pw.FixedColumnWidth(360.0),
                  1: const pw.FixedColumnWidth(470.0),
                  2: const pw.FixedColumnWidth(200.0),
                  3: const pw.FixedColumnWidth(150.0),
                  4: const pw.FixedColumnWidth(100.0),
                  5: const pw.FixedColumnWidth(200.0),
                  6: const pw.FixedColumnWidth(200.0),
                  7: const pw.FixedColumnWidth(240.0),
                  8: const pw.FixedColumnWidth(470.0),
                },
      children: [
        _buildHeaderTableRow(),
        //for (int i = 0; i < 20; i++) _buildFirstPageTableRow(),
      ],
    );
  }

  pw.Table _buildTableContent(PdfPageFormat pageFormat) {
    return pw.Table(
      columnWidths: pageFormat == PdfPageFormat.a4
          ? {
              0: const pw.FixedColumnWidth(300.0),
              1: const pw.FixedColumnWidth(600.0),
              2: const pw.FixedColumnWidth(350.0),
              3: const pw.FixedColumnWidth(180.0),
              4: const pw.FixedColumnWidth(125.0),
              5: const pw.FixedColumnWidth(240.0),
              6: const pw.FixedColumnWidth(240.0),
              7: const pw.FixedColumnWidth(350.0),
              8: const pw.FixedColumnWidth(600.0),
            }
          : pageFormat == PdfPageFormat.letter
              ? {
                  0: const pw.FixedColumnWidth(210.0),
                  1: const pw.FixedColumnWidth(500.0),
                  2: const pw.FixedColumnWidth(310.0),
                  3: const pw.FixedColumnWidth(180.0),
                  4: const pw.FixedColumnWidth(115.0),
                  5: const pw.FixedColumnWidth(210.0),
                  6: const pw.FixedColumnWidth(210.0),
                  7: const pw.FixedColumnWidth(320.0),
                  8: const pw.FixedColumnWidth(500.0),
                }
              : {
                  0: const pw.FixedColumnWidth(360.0),
                  1: const pw.FixedColumnWidth(470.0),
                  2: const pw.FixedColumnWidth(200.0),
                  3: const pw.FixedColumnWidth(150.0),
                  4: const pw.FixedColumnWidth(100.0),
                  5: const pw.FixedColumnWidth(200.0),
                  6: const pw.FixedColumnWidth(200.0),
                  7: const pw.FixedColumnWidth(240.0),
                  8: const pw.FixedColumnWidth(470.0),
                },
      children: [
        _buildContentTableRow(),
        //for (int i = 0; i < 20; i++) _buildFirstPageTableRow(),
      ],
    );
  }

  pw.TableRow _buildHeaderTableRow() {
    return pw.TableRow(
      children: [
        DocumentComponents.buildHeaderContainerCell(
          data: 'Article',
          verticalPadding: 17.4,
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            DocumentComponents.buildHeaderContainerCell(
              data: 'Description (Specification, Brand, Model, Serial #, Etc.)',
              verticalPadding: 3.0,
              horizontalPadding: 3.0,
              borderRight: false,
              borderLeft: false,
              borderWidthBottom: 2.0,
            ),
            pw.Row(
              children: [
                pw.Expanded(
                  child: DocumentComponents.buildHeaderContainerCell(
                    data: 'Specs',
                    verticalPadding: 3.0,
                    borderTop: false,
                    borderRight: false,
                    borderLeft: false,
                  ),
                ),
                pw.Expanded(
                  child: DocumentComponents.buildHeaderContainerCell(
                    data: 'Brand',
                    verticalPadding: 3.0,
                    borderTop: false,
                    borderRight: false,
                    borderWidthLeft: 2.0,
                  ),
                ),
                pw.Expanded(
                  child: DocumentComponents.buildHeaderContainerCell(
                    data: 'Model',
                    verticalPadding: 3.0,
                    borderTop: false,
                    borderRight: false,
                    borderWidthLeft: 2.0,
                  ),
                ),
                pw.Expanded(
                  child: DocumentComponents.buildHeaderContainerCell(
                    data: 'Serial #',
                    verticalPadding: 3.0,
                    borderTop: false,
                    borderRight: false,
                    borderWidthLeft: 2.0,
                  ),
                ),
              ],
            ),
          ],
        ),
        DocumentComponents.buildHeaderContainerCell(
          data: 'Semi-expendable Property No.',
          verticalPadding: 11.8,
          horizontalPadding: 3.0,
          borderRight: false,
        ),
        DocumentComponents.buildHeaderContainerCell(
          data: 'Unit of Measure',
          verticalPadding: 11.8,
          horizontalPadding: 3.0,
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
              data: 'On Hand Per Count',
              verticalPadding: 3.0,
              horizontalPadding: 3.0,
              borderWidthBottom: 2.0,
            ),
            DocumentComponents.buildHeaderContainerCell(
              data: '(Quantity)',
              borderTop: false,
              verticalPadding: 3.0,
            ),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            DocumentComponents.buildHeaderContainerCell(
              data: 'Shortage/Overage',
              borderRight: false,
              borderLeft: false,
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
                    borderLeft: false,
                    horizontalPadding: 3.0,
                    verticalPadding: 2.0,
                    borderWidthBottom: 2.0,
                  ),
                ),
                pw.Expanded(
                  child: DocumentComponents.buildHeaderContainerCell(
                    data: 'Value',
                    borderTop: false,
                    borderRight: false,
                    horizontalPadding: 3.0,
                    verticalPadding: 3.0,
                    borderWidthLeft: 2.0,
                  ),
                ),
              ],
            ),
          ],
        ),
        DocumentComponents.buildHeaderContainerCell(
          data: 'Remarks (State whereabouts, conditions, Accountable Officer)',
          verticalPadding: 11.8,
        ),
      ],
    );
  }

  pw.TableRow _buildContentTableRow() {
    return pw.TableRow(
      children: [
        DocumentComponents.buildHeaderContainerCell(
          data: '\n',
          verticalPadding: 3.0,
          borderTop: false,
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            pw.Row(
              children: [
                pw.Expanded(
                  child: DocumentComponents.buildHeaderContainerCell(
                    data: '\n',
                    verticalPadding: 3.0,
                    borderTop: false,
                    borderRight: false,
                    borderLeft: false,
                  ),
                ),
                pw.Expanded(
                  child: DocumentComponents.buildHeaderContainerCell(
                    data: '\n',
                    verticalPadding: 3.0,
                    borderTop: false,
                    borderRight: false,
                    borderWidthLeft: 2.0,
                  ),
                ),
                pw.Expanded(
                  child: DocumentComponents.buildHeaderContainerCell(
                    data: '\n',
                    verticalPadding: 3.0,
                    borderTop: false,
                    borderRight: false,
                    borderWidthLeft: 2.0,
                  ),
                ),
                pw.Expanded(
                  child: DocumentComponents.buildHeaderContainerCell(
                    data: '\n',
                    verticalPadding: 3.0,
                    borderTop: false,
                    borderRight: false,
                    borderWidthLeft: 2.0,
                  ),
                ),
              ],
            ),
          ],
        ),
        DocumentComponents.buildHeaderContainerCell(
          data: '\n',
          verticalPadding: 3.0,
          horizontalPadding: 3.0,
          borderTop: false,
          borderRight: false,
        ),
        DocumentComponents.buildHeaderContainerCell(
          data: '\n',
          verticalPadding: 3.0,
          horizontalPadding: 3.0,
          borderTop: false,
          borderRight: false,
        ),
        DocumentComponents.buildHeaderContainerCell(
          data: '\n',
          verticalPadding: 3.0,
          borderTop: false,
          borderRight: false,
        ),
        DocumentComponents.buildHeaderContainerCell(
          data: '\n',
          borderTop: false,
          borderRight: false,
          verticalPadding: 3.0,
        ),
        DocumentComponents.buildHeaderContainerCell(
          data: '\n',
          borderTop: false,
          verticalPadding: 3.0,
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            pw.Row(
              children: [
                pw.Expanded(
                  child: DocumentComponents.buildHeaderContainerCell(
                    data: '\n',
                    borderTop: false,
                    borderRight: false,
                    borderLeft: false,
                    horizontalPadding: 3.0,
                    verticalPadding: 3.0,
                  ),
                ),
                pw.Expanded(
                  child: DocumentComponents.buildHeaderContainerCell(
                    data: '\n',
                    borderTop: false,
                    borderRight: false,
                    horizontalPadding: 3.0,
                    verticalPadding: 3.0,
                    borderWidthLeft: 2.0,
                    borderWidthBottom: 3.0,
                  ),
                ),
              ],
            ),
          ],
        ),
        DocumentComponents.buildHeaderContainerCell(
          data: '\n',
          borderTop: false,
          verticalPadding: 3.0,
        ),
      ],
    );
  }

  pw.Widget _buildAssociatedOfficerField({
    String? officerName,
    required String title,
  }) {
    return pw.Column(
      mainAxisAlignment: pw.MainAxisAlignment.center,
      children: [
        pw.Text(
          officerName ?? '___________________________________',
          style: const pw.TextStyle(
            fontSize: 8.0,
          ),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(
          height: 5.0,
        ),
        pw.Text(
          'Signature over Printed Name of\n$title',
          style: const pw.TextStyle(
            fontSize: 8.0,
          ),
          textAlign: pw.TextAlign.center,
        ),
      ],
    );
  }
}
