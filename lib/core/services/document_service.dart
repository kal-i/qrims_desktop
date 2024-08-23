import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../constants/assets_path.dart';

class DocumentService {
  DocumentService() {
    _initializeFonts();
    _initializeImageSeal();
  }

  Future<void> initialize() async {
    await _initializeFonts();
    await _initializeImageSeal();
  }

  late final pw.Font oldEnglish;
  late final pw.Font trajanProRegular;
  late final pw.Font trajanProBold;
  late final pw.Font tahomaRegular;
  late final pw.Font tahomaBold;
  late final pw.Font timesNewRomanRegular;
  late final pw.Font timesNewRomanBold;
  late final pw.Image depedSeal;

  Future<pw.Font> _loadFont(String path) async {
    return pw.Font.ttf(await rootBundle.load(path));
  }

  Future<void> _initializeFonts() async {
    oldEnglish = await _loadFont(FontPath.oldEnglish);
    trajanProRegular = await _loadFont(FontPath.trajanProRegular);
    trajanProBold = await _loadFont(FontPath.trajanProBold);
    tahomaRegular = await _loadFont(FontPath.tahomaRegular);
    tahomaBold = await _loadFont(FontPath.tahomaBold);
    timesNewRomanRegular = await _loadFont(FontPath.timesNewRomanRegular);
    timesNewRomanBold = await _loadFont(FontPath.timesNewRomanBold);
  }

  Future<void> _initializeImageSeal() async {
    final img = await rootBundle.load(ImagePath.depedSeal);
    final imageBytes = img.buffer.asUint8List();
    depedSeal = pw.Image(pw.MemoryImage(imageBytes));
  }

  Future<pw.Document> generateICS(
    PdfPageFormat pageFormat,
    pw.PageOrientation orientation,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageTheme: pw.PageTheme(
          pageFormat: pageFormat,
          orientation: orientation,
          margin: const pw.EdgeInsets.only(
            top: 1.2 * PdfPageFormat.cm,
            right: 1.2 * PdfPageFormat.cm,
            bottom: 1.3 * PdfPageFormat.cm,
            left: 1.2 * PdfPageFormat.cm,
          ),
        ),
        build: (context) => pw.Column(
          children: [
            _buildHeader(),
            pw.SizedBox(height: 20),
            pw.Text('INVENTORY CUSTODIAN SLIP',
                style: pw.TextStyle(
                  font: timesNewRomanBold,
                  fontSize: 14,
                  //fontWeight: pw.FontWeight.bold,
                )),
            pw.SizedBox(height: 20),

            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Entity Name:',
                  style: pw.TextStyle(
                    font: timesNewRomanRegular,
                    fontSize: 12.0,
                    //fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(
                  width: 10.0,
                ),
                pw.Text(
                  'SDO LEGAZPI CITY - OASDS',
                  style: pw.TextStyle(
                    font: timesNewRomanRegular,
                    fontSize: 12.0,
                    //fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),

            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Row(
                  children: [
                    pw.Text(
                      'Fund Cluster:',
                      style: pw.TextStyle(
                        font: timesNewRomanRegular,
                        fontSize: 12.0,
                        //fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(
                      width: 10.0,
                    ),
                    pw.Text(
                      'DIVISION MOOE',
                      style: pw.TextStyle(
                        font: timesNewRomanRegular,
                        fontSize: 12.0,
                        //fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                pw.Row(
                  children: [
                    pw.Text(
                      'ICS No:',
                      style: pw.TextStyle(
                        font: timesNewRomanRegular,
                        fontSize: 12.0,
                        //fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(
                      width: 10.0,
                    ),
                    pw.Text(
                      'SPHV-2024-03-175',
                      style: pw.TextStyle(
                        font: timesNewRomanRegular,
                        fontSize: 12.0,
                        //fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            /// Table

            pw.Table(
              border: pw.TableBorder.all(width: 1), // Adds borders to all cells
              columnWidths: {
                0: const pw.FixedColumnWidth(50), // Quantity column width
                1: const pw.FixedColumnWidth(50), // Unit column width
                2: const pw.FixedColumnWidth(
                    150), // Amount column width (including sub-columns)
                3: const pw.FixedColumnWidth(200), // Description column width
                4: const pw.FixedColumnWidth(
                    100), // Inventory Item No. column width
                5: const pw.FixedColumnWidth(
                    100), // Estimated Useful column width
              },
              children: [
                // Header part
                pw.TableRow(
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(
                        'Quantity',
                        style: pw.TextStyle(
                          font: timesNewRomanRegular,
                          fontSize: 12.0,
                          fontWeight: pw.FontWeight.bold,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(
                        'Unit',
                        style: pw.TextStyle(
                          font: timesNewRomanRegular,
                          fontSize: 12.0,
                          fontWeight: pw.FontWeight.bold,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Column(
                      children: [
                        pw.Container(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(
                            'Amount',
                            style: pw.TextStyle(
                              font: timesNewRomanRegular,
                              fontSize: 12.0,
                              fontWeight: pw.FontWeight.bold,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Row(
                          children: [
                            pw.Expanded(
                              child: pw.Container(
                                padding: const pw.EdgeInsets.all(4),
                                child: pw.Text(
                                  'Unit Cost',
                                  style: pw.TextStyle(
                                    font: timesNewRomanRegular,
                                    fontSize: 12.0,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                  textAlign: pw.TextAlign.center,
                                ),
                                decoration: pw.BoxDecoration(
                                  border: pw.Border.all(width: 1),
                                ),
                              ),
                            ),
                            pw.Expanded(
                              child: pw.Container(
                                padding: const pw.EdgeInsets.all(4),
                                child: pw.Text(
                                  'Total Cost',
                                  style: pw.TextStyle(
                                    font: timesNewRomanRegular,
                                    fontSize: 12.0,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                  textAlign: pw.TextAlign.center,
                                ),
                                decoration: pw.BoxDecoration(
                                  border: pw.Border.all(width: 1),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(
                        'Description',
                        style: pw.TextStyle(
                          font: timesNewRomanRegular,
                          fontSize: 12.0,
                          fontWeight: pw.FontWeight.bold,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(
                        'Inventory Item No.',
                        style: pw.TextStyle(
                          font: timesNewRomanRegular,
                          fontSize: 12.0,
                          fontWeight: pw.FontWeight.bold,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(
                        'Estimated Useful',
                        style: pw.TextStyle(
                          font: timesNewRomanRegular,
                          fontSize: 12.0,
                          fontWeight: pw.FontWeight.bold,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                  ],
                ),
                // Add more rows for your table data here...
              ],
            ),

            pw.Table(
              border: pw.TableBorder.all(),
              children: [
                /// Header part
                pw.TableRow(
                  children: [
                    pw.Text(
                      'Quantity',
                      style: pw.TextStyle(
                        font: timesNewRomanRegular,
                        fontSize: 12.0,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      'Unit',
                      style: pw.TextStyle(
                        font: timesNewRomanRegular,
                        fontSize: 12.0,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Column(
                      children: [
                        pw.Text(
                          'Amount',
                          style: pw.TextStyle(
                            font: timesNewRomanRegular,
                            fontSize: 12.0,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(
                                'Unit Cost',
                                style: pw.TextStyle(
                                  font: timesNewRomanRegular,
                                  fontSize: 12.0,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                              pw.Text(
                                'Quantity',
                                style: pw.TextStyle(
                                  font: timesNewRomanRegular,
                                  fontSize: 12.0,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ]),
                      ],
                    ),
                    pw.Text(
                      'Description',
                      style: pw.TextStyle(
                        font: timesNewRomanRegular,
                        fontSize: 12.0,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      'Inventory Item No.',
                      style: pw.TextStyle(
                        font: timesNewRomanRegular,
                        fontSize: 12.0,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      'Estimated Useful ',
                      style: pw.TextStyle(
                        font: timesNewRomanRegular,
                        fontSize: 12.0,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );

    return pdf;
  }

  pw.Widget _buildHeader() {
    return pw.Column(
      children: [
        pw.Container(
          height: 37.79,
          width: 37.79,
          child: depedSeal,
        ),
        pw.Text(
          'Republic of the Philippines',
          style: pw.TextStyle(
            font: oldEnglish,
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Text('Department of Education',
            style: pw.TextStyle(
              font: oldEnglish,
              fontSize: 18,
              // fontWeight: pw.FontWeight.bold,
            )),
        pw.SizedBox(height: 10),
        pw.Text('Region V - Bicol',
            style: pw.TextStyle(
              font: trajanProBold,
              fontSize: 10,
              //fontWeight: pw.FontWeight.bold,
            )),
        pw.SizedBox(height: 10),
        pw.Text('SCHOOLS DIVISION OF LEGAZPI CITY',
            style: pw.TextStyle(
              font: tahomaBold,
              fontSize: 10,
              //fontWeight: pw.FontWeight.bold,
            )),
      ],
    );
  }
}
