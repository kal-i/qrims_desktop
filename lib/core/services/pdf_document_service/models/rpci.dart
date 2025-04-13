import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../init_dependencies.dart';
import '../../../utils/capitalizer.dart';
import '../../../utils/currency_formatter.dart';
import '../document_service.dart';
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

    final accountableOfficer =
        data['accountable_officer'] as Map<String, String>?;
    final inventorySupplies = data['inventory_report'];
    final approvingEntityOrAuthorizedRepresentative =
        data['approving_entity_or_authorized_representative'] as String?;
    final coaRepresentative = data['coa_representative'] as String?;
    final certifyingOfficers =
        data['certifying_officers'] as List<Map<String, dynamic>>?;

    List<pw.TableRow> tableRows = [];
    List<pw.TableRow> tableFooterRows = [
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
              style: pw.TextStyle(
                font: serviceLocator<FontService>()
                    .getFont('timesNewRomanRegular'),
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
              style: pw.TextStyle(
                font: serviceLocator<FontService>()
                    .getFont('timesNewRomanRegular'),
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
              style: pw.TextStyle(
                font: serviceLocator<FontService>()
                    .getFont('timesNewRomanRegular'),
                fontSize: 8.0,
              ),
            ),
          ),
        ],
      ),
    ];

    tableRows.add(
      _buildFirstPageHeaderTableRow(),
    );

    for (final inventorySupply in inventorySupplies) {
      final article = inventorySupply['article'].toString().toUpperCase();
      final description = inventorySupply['description'];
      final stockNumber = inventorySupply['stock_number'];
      final unit = inventorySupply['unit'];
      final unitValue = double.parse(inventorySupply['unit_value'].toString());

      // check 1st if we have bal from prev issue, if 0, check if totaal qty avail and issued is not empty, otherwise use current stock
      final totalQuantity =
          inventorySupply['balance_from_previous_row_after_issuance'] == 0
              ? inventorySupply['total_quantity_available_and_issued'] != null
                  ? int.tryParse(
                      inventorySupply['total_quantity_available_and_issued']
                              ?.toString() ??
                          '0')
                  : inventorySupply['current_quantity_in_stock']
              : inventorySupply['balance_from_previous_row_after_issuance'];

      final balanceAfterIssue = int.tryParse(
              inventorySupply['balance_per_row_after_issuance']?.toString() ??
                  '0') ??
          0;

      final remarks = inventorySupply['receiving_officer_name'] != null
          ? '${capitalizeWord(inventorySupply['receiving_officer_name'])} - ${inventorySupply['total_quantity_issued_for_a_particular_row']}'
          : '\n';

      final rowHeight = DocumentService.getRowHeight(
        description,
        fontSize: 8.0,
        cellWidth: pageFormat == PdfPageFormat.a4
            ? 450.0
            : pageFormat == PdfPageFormat.letter
                ? 475.0
                : 475.0,
      );

      tableRows.add(
        _buildFirstPageTableRow(
          article: article,
          description: description,
          stockNumber: stockNumber,
          unit: unit,
          unitValue: unitValue,
          totalQuantity: totalQuantity,
          quantityAfterIssued: balanceAfterIssue,
          remarks: remarks,
          rowHeight: rowHeight,
        ),
      );
    }

    if (certifyingOfficers != null && certifyingOfficers.isNotEmpty) {
      for (int i = 0; i < certifyingOfficers.length; i++) {
        final certifyingOfficer = certifyingOfficers[i];

        if (i == 0) {
          tableFooterRows.add(
            pw.TableRow(
              children: [
                DocumentComponents.buildContainer(
                  borderTop: false,
                  borderRight: false,
                  borderBottom:
                      i == certifyingOfficers.length - 1 ? true : false,
                  verticalPadding: 5.0,
                  child: _buildAssociatedOfficerField(
                    title: certifyingOfficer['position'],
                    officerName: certifyingOfficer['name'],
                  ),
                ),
                DocumentComponents.buildContainer(
                  borderTop: false,
                  borderRight: false,
                  borderBottom:
                      i == certifyingOfficers.length - 1 ? true : false,
                  borderLeft: false,
                  verticalPadding: 5.0,
                  child: _buildAssociatedOfficerField(
                    title: 'Entity or Authorized Representative',
                    officerName: approvingEntityOrAuthorizedRepresentative,
                  ),
                ),
                DocumentComponents.buildContainer(
                  borderTop: false,
                  borderBottom:
                      i == certifyingOfficers.length - 1 ? true : false,
                  borderLeft: false,
                  verticalPadding: 5.0,
                  child: _buildAssociatedOfficerField(
                    title: 'COA Representative',
                    officerName: coaRepresentative,
                  ),
                ),
              ],
            ),
          );
        } else {
          tableFooterRows.add(
            pw.TableRow(
              children: [
                DocumentComponents.buildContainer(
                  borderTop: false,
                  borderRight: false,
                  borderBottom:
                      i == certifyingOfficers.length - 1 ? true : false,
                  verticalPadding: 5.0,
                  child: _buildAssociatedOfficerField(
                    title: certifyingOfficer['position'],
                    officerName: certifyingOfficer['name'],
                  ),
                ),
                DocumentComponents.buildContainer(
                  borderTop: false,
                  borderRight: false,
                  borderBottom:
                      i == certifyingOfficers.length - 1 ? true : false,
                  borderLeft: false,
                  verticalPadding: 20.7,
                  child: pw.SizedBox.shrink(),
                ),
                DocumentComponents.buildContainer(
                  borderTop: false,
                  borderBottom:
                      i == certifyingOfficers.length - 1 ? true : false,
                  borderLeft: false,
                  verticalPadding: 20.7,
                  child: pw.SizedBox.shrink(),
                ),
              ],
            ),
          );
        }
      }
    } else {
      tableFooterRows.add(
        pw.TableRow(
          children: [
            DocumentComponents.buildContainer(
              borderTop: false,
              borderRight: false,
              verticalPadding: 20.7,
              child: pw.SizedBox.shrink(),
            ),
            DocumentComponents.buildContainer(
              borderTop: false,
              borderRight: false,
              borderLeft: false,
              verticalPadding: 5.0,
              child: _buildAssociatedOfficerField(
                title: 'Entity or Authorized Representative',
              ),
            ),
            DocumentComponents.buildContainer(
              borderTop: false,
              borderLeft: false,
              verticalPadding: 5.0,
              child: _buildAssociatedOfficerField(
                title: 'COA Representative',
              ),
            ),
          ],
        ),
      );
    }

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
                  style: pw.TextStyle(
                    font: serviceLocator<FontService>()
                        .getFont('timesNewRomanBold'),
                    fontSize: 10.0,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(
                  height: 5.0,
                ),
                pw.Text(
                  '(Type of Inventory Item)',
                  style: pw.TextStyle(
                    font: serviceLocator<FontService>()
                        .getFont('timesNewRomanRegular'),
                    fontSize: 8.0,
                  ),
                ),
                pw.SizedBox(
                  height: 10.0,
                ),
                pw.Text(
                  'As at ${data['as_at_date']}',
                  style: pw.TextStyle(
                    font: serviceLocator<FontService>()
                        .getFont('timesNewRomanBold'),
                    fontSize: 9.0,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(
            height: 10.0,
          ),
          pw.Text(
            'Fund Cluster: ${data['fund_cluster']}',
            style: pw.TextStyle(
              font: serviceLocator<FontService>().getFont('timesNewRomanBold'),
              fontSize: 8.0,
            ),
          ),
          pw.SizedBox(
            height: 10.0,
          ),
          pw.RichText(
            text: pw.TextSpan(
              text: 'For which ',
              style: pw.TextStyle(
                font:
                    serviceLocator<FontService>().getFont('timesNewRomanBold'),
                fontSize: 8.0,
              ),
              children: [
                pw.TextSpan(
                  text: accountableOfficer?['name'] != null &&
                          accountableOfficer!['name']!.isNotEmpty
                      ? '${accountableOfficer['name']}'
                      : '_______________________',
                  style: pw.TextStyle(
                    font: serviceLocator<FontService>()
                        .getFont('timesNewRomanRegular'),
                    fontSize: 7.5,
                    decoration: pw.TextDecoration.underline,
                  ),
                ),
                pw.TextSpan(
                  text: ', ',
                  style: pw.TextStyle(
                    font: serviceLocator<FontService>()
                        .getFont('timesNewRomanBold'),
                    fontSize: 8.0,
                  ),
                ),
                pw.TextSpan(
                  text: accountableOfficer?['position'] != null &&
                          accountableOfficer!['position']!.isNotEmpty
                      ? '${accountableOfficer['position']}'
                      : '_______________________',
                  style: pw.TextStyle(
                    font: serviceLocator<FontService>()
                        .getFont('timesNewRomanRegular'),
                    fontSize: 7.5,
                    decoration: pw.TextDecoration.underline,
                  ),
                ),
                pw.TextSpan(
                  text: ', ',
                  style: pw.TextStyle(
                    font: serviceLocator<FontService>()
                        .getFont('timesNewRomanBold'),
                    fontSize: 8.0,
                  ),
                ),
                pw.TextSpan(
                  text: accountableOfficer?['location'] != null &&
                          accountableOfficer!['location']!.isNotEmpty
                      ? '${accountableOfficer['location']}'
                      : '_______________________',
                  style: pw.TextStyle(
                    font: serviceLocator<FontService>()
                        .getFont('timesNewRomanRegular'),
                    fontSize: 7.5,
                    decoration: pw.TextDecoration.underline,
                  ),
                ),
                pw.TextSpan(
                  text: ', ',
                  style: pw.TextStyle(
                    font: serviceLocator<FontService>()
                        .getFont('timesNewRomanBold'),
                    fontSize: 8.0,
                  ),
                ),
                pw.TextSpan(
                  text:
                      'is accountable, having assumed such accountability on ',
                  style: pw.TextStyle(
                    font: serviceLocator<FontService>()
                        .getFont('timesNewRomanBold'),
                    fontSize: 8.0,
                  ),
                ),
                pw.TextSpan(
                  text: accountableOfficer?['accountability_date'] != null
                      ? '${accountableOfficer?['accountability_date']}'
                      : '_______________________',
                  style: pw.TextStyle(
                    font: serviceLocator<FontService>()
                        .getFont('timesNewRomanRegular'),
                    fontSize: 7.5,
                    decoration: pw.TextDecoration.underline,
                  ),
                ),
                pw.TextSpan(
                  text: '.',
                  style: pw.TextStyle(
                    font: serviceLocator<FontService>()
                        .getFont('timesNewRomanBold'),
                    fontSize: 8.0,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(
            height: 10.0,
          ),
          pw.Table(
            columnWidths: pageFormat == PdfPageFormat.a4
                ? {
                    0: const pw.FixedColumnWidth(250.0),
                    1: const pw.FixedColumnWidth(450.0),
                    2: const pw.FixedColumnWidth(150.0),
                    3: const pw.FixedColumnWidth(150.0),
                    4: const pw.FixedColumnWidth(130.0),
                    5: const pw.FixedColumnWidth(185.0),
                    6: const pw.FixedColumnWidth(185.0),
                    7: const pw.FixedColumnWidth(300.0),
                    8: const pw.FixedColumnWidth(375.0),
                  }
                : pageFormat == PdfPageFormat.letter
                    ? {
                        0: const pw.FixedColumnWidth(250.0),
                        1: const pw.FixedColumnWidth(475.0),
                        2: const pw.FixedColumnWidth(150.0),
                        3: const pw.FixedColumnWidth(125.0),
                        4: const pw.FixedColumnWidth(125.0),
                        5: const pw.FixedColumnWidth(200.0),
                        6: const pw.FixedColumnWidth(200.0),
                        7: const pw.FixedColumnWidth(310.0),
                        8: const pw.FixedColumnWidth(375.0),
                      }
                    : {
                        0: const pw.FixedColumnWidth(250.0),
                        1: const pw.FixedColumnWidth(475.0),
                        2: const pw.FixedColumnWidth(150.0),
                        3: const pw.FixedColumnWidth(120.0),
                        4: const pw.FixedColumnWidth(120.0),
                        5: const pw.FixedColumnWidth(145.0),
                        6: const pw.FixedColumnWidth(145.0),
                        7: const pw.FixedColumnWidth(300.0),
                        8: const pw.FixedColumnWidth(375.0),
                      },
            children: tableRows,
          ),
          _buildTableFooter(
            pageFormat,
            tableFooterRows,
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
          fontSize: 8.0,
          verticalPadding: 14.9,
          borderRight: false,
        ),
        DocumentComponents.buildHeaderContainerCell(
          data: 'Description',
          fontSize: 8.0,
          verticalPadding: 14.9,
          borderRight: false,
        ),
        DocumentComponents.buildHeaderContainerCell(
          data: 'Stock Number',
          fontSize: 8.0,
          verticalPadding: 14.9,
          borderRight: false,
        ),
        DocumentComponents.buildHeaderContainerCell(
          data: 'Unit of Measure',
          fontSize: 8.0,
          verticalPadding: 10.4,
          borderRight: false,
        ),
        DocumentComponents.buildHeaderContainerCell(
          data: 'Unit Value',
          fontSize: 8.0,
          verticalPadding: 14.9,
          borderRight: false,
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            DocumentComponents.buildHeaderContainerCell(
              data: '\nBalance Per Card',
              fontSize: 8.0,
              horizontalPadding: 3.0,
              borderRight: false,
              verticalPadding: 3.0,
              borderWidthBottom: 2.0,
            ),
            DocumentComponents.buildHeaderContainerCell(
              data: '(Quantity)',
              font:
                  serviceLocator<FontService>().getFont('timesNewRomanRegular'),
              fontSize: 8.0,
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
              fontSize: 8.0,
              borderRight: false,
              verticalPadding: 3.0,
              borderWidthBottom: 2.0,
            ),
            DocumentComponents.buildHeaderContainerCell(
              data: '(Quantity)',
              font:
                  serviceLocator<FontService>().getFont('timesNewRomanRegular'),
              fontSize: 8.0,
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
              fontSize: 8.0,
              borderRight: false,
              borderWidthBottom: 2.0,
              verticalPadding: 7.4,
            ),
            pw.Row(
              children: [
                pw.Expanded(
                  child: DocumentComponents.buildHeaderContainerCell(
                    data: 'Quantity',
                    font: serviceLocator<FontService>()
                        .getFont('timesNewRomanRegular'),
                    fontSize: 8.0,
                    borderTop: false,
                    borderRight: false,
                    horizontalPadding: 3.0,
                    verticalPadding: 3.0,
                  ),
                ),
                pw.Expanded(
                  child: DocumentComponents.buildHeaderContainerCell(
                    data: 'Value',
                    font: serviceLocator<FontService>()
                        .getFont('timesNewRomanRegular'),
                    fontSize: 8.0,
                    borderTop: false,
                    borderRight: false,
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
        DocumentComponents.buildHeaderContainerCell(
          data: 'Remarks',
          fontSize: 8.0,
          verticalPadding: 14.9,
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

  pw.TableRow _buildFirstPageTableRow({
    String? article,
    String? description,
    String? stockNumber,
    String? unit,
    double? unitValue,
    int? totalQuantity,
    int? quantityAfterIssued,
    String? remarks,
    double? rowHeight,
  }) {
    return pw.TableRow(
      children: [
        DocumentComponents.buildTableRowColumn(
          data: article ?? '\n',
          borderRight: false,
          fontSize: 8.0,
          rowHeight: rowHeight,
        ),
        DocumentComponents.buildTableRowColumn(
          data: description ?? '\n',
          borderRight: false,
          fontSize: 8.0,
          rowHeight: rowHeight,
        ),
        DocumentComponents.buildTableRowColumn(
          data: stockNumber ?? '\n',
          borderRight: false,
          fontSize: 8.0,
          rowHeight: rowHeight,
        ),
        DocumentComponents.buildTableRowColumn(
          data: unit ?? '\n',
          borderRight: false,
          fontSize: 8.0,
          rowHeight: rowHeight,
        ),
        DocumentComponents.buildTableRowColumn(
          data: formatCurrency(unitValue ?? 0),
          borderRight: false,
          fontSize: 8.0,
          rowHeight: rowHeight,
        ),
        DocumentComponents.buildTableRowColumn(
          data: totalQuantity.toString(),
          borderRight: false,
          fontSize: 8.0,
          rowHeight: rowHeight,
        ),
        DocumentComponents.buildTableRowColumn(
          data: quantityAfterIssued.toString(),
          borderRight: false,
          fontSize: 8.0,
          rowHeight: rowHeight,
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
                    fontSize: 8.0,
                    rowHeight: rowHeight,
                  ),
                ),
                pw.Expanded(
                  child: DocumentComponents.buildTableRowColumn(
                    data: '\n',
                    borderRight: false,
                    solidBorderWidth: 2.0,
                    fontSize: 8.0,
                    rowHeight: rowHeight,
                  ),
                ),
              ],
            ),
          ],
        ),
        DocumentComponents.buildTableRowColumn(
          data: remarks ?? '\n',
          fontSize: 8.0,
          rowHeight: rowHeight,
        ),
      ],
    );
  }

  pw.Table _buildTableFooter(
    PdfPageFormat pageFormat,
    List<pw.TableRow> tableRows,
  ) {
    return pw.Table(
      columnWidths: pageFormat == PdfPageFormat.a4
          ? {
              0: const pw.FixedColumnWidth(865.0),
              1: const pw.FixedColumnWidth(800.0),
              2: const pw.FixedColumnWidth(375.0),
            }
          : pageFormat == PdfPageFormat.letter
              ? {
                  0: const pw.FixedColumnWidth(1000.0),
                  1: const pw.FixedColumnWidth(835.0),
                  2: const pw.FixedColumnWidth(375.0),
                }
              : {
                  0: const pw.FixedColumnWidth(995.0),
                  1: const pw.FixedColumnWidth(710.0),
                  2: const pw.FixedColumnWidth(375.0),
                },
      children: tableRows,
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
          officerName != null && officerName.isNotEmpty
              ? officerName
              : '___________________________',
          style: pw.TextStyle(
            font: serviceLocator<FontService>().getFont('timesNewRomanRegular'),
            fontSize: 8.0,
            decoration: pw.TextDecoration.underline,
          ),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(
          height: 5.0,
        ),
        pw.Text(
          'Signature over Printed Name of\n$title',
          style: pw.TextStyle(
            font: serviceLocator<FontService>().getFont('timesNewRomanRegular'),
            fontSize: 8.0,
          ),
          textAlign: pw.TextAlign.center,
        ),
      ],
    );
  }
}
