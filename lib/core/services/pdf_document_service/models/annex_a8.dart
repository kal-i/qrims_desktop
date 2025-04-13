import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../init_dependencies.dart';
import '../../../utils/capitalizer.dart';
import '../../../utils/currency_formatter.dart';
import '../../../utils/standardize_position_name.dart';
import '../document_service.dart';
import '../font_service.dart';
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

    final assetSubClass = data['asset_sub_class'] as String?;
    final accountableOfficer =
        data['accountable_officer'] as Map<String, String>?;
    final inventorySemiExpendableProperties = data['inventory_report'];
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
      _buildHeaderTableRow(),
    );

    for (final inventorySemiExpendableProperty
        in inventorySemiExpendableProperties) {
      final article =
          inventorySemiExpendableProperty['article'].toString().toUpperCase();
      final description =
          '${inventorySemiExpendableProperty['brand_name']} ${inventorySemiExpendableProperty['model_name']} with SN: ${inventorySemiExpendableProperty['serial_no']}';
      final semiExpendablePropertyNo =
          inventorySemiExpendableProperty['semi_expendable_property_no'];
      final unit = inventorySemiExpendableProperty['unit'];
      final unitValue = double.parse(
          inventorySemiExpendableProperty['unit_value'].toString());

      // check 1st if we have bal from prev issue, if 0, check if totaal qty avail and issued is not empty, otherwise use current stock
      final totalQuantity = inventorySemiExpendableProperty[
                  'balance_from_previous_row_after_issuance'] ==
              0
          ? inventorySemiExpendableProperty[
                      'total_quantity_available_and_issued'] !=
                  null
              ? int.tryParse(inventorySemiExpendableProperty[
                          'total_quantity_available_and_issued']
                      ?.toString() ??
                  '0')
              : inventorySemiExpendableProperty['current_quantity_in_stock']
          : inventorySemiExpendableProperty[
              'balance_from_previous_row_after_issuance'];

      final balanceAfterIssue = int.tryParse(
              inventorySemiExpendableProperty['balance_per_row_after_issuance']
                      ?.toString() ??
                  '0') ??
          0;

      final remarks = inventorySemiExpendableProperty[
                  'receiving_officer_name'] !=
              null
          ? '${capitalizeWord(inventorySemiExpendableProperty['receiving_officer_name'])}/${capitalizeWord(inventorySemiExpendableProperty['receiving_officer_office'])}-${standardizePositionName(inventorySemiExpendableProperty['receiving_officer_position'])}'
          : '\n';

      final rowHeight = DocumentService.getRowHeight(
        description,
        fontSize: 8.0,
        cellWidth: pageFormat == PdfPageFormat.a4
            ? 600.0
            : pageFormat == PdfPageFormat.letter
                ? 500.0
                : 500.0,
      );

      tableRows.add(
        _buildContentTableRow(
          article: article,
          description: description,
          semiExpendablePropertyNo: semiExpendablePropertyNo,
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
            child: _buildHeader(
              assetSubClass: assetSubClass != null && assetSubClass.isNotEmpty
                  ? assetSubClass
                  : null,
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
          _buildTableHeader(
            pageFormat,
            tableRows,
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

  pw.Widget _buildHeader({
    String? assetSubClass,
  }) {
    return pw.Column(
      children: [
        pw.Text(
          'REPORT ON THE PHYSICAL COUNT OF SEMI-EXPENDABLE PROPERTY',
          style: pw.TextStyle(
            font: serviceLocator<FontService>().getFont('timesNewRomanBold'),
            fontSize: 10.0,
          ),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(
          height: 5.0,
        ),
        pw.Text(
          assetSubClass?.toUpperCase() ?? '_________________________',
          style: pw.TextStyle(
            font: serviceLocator<FontService>().getFont('timesNewRomanBold'),
            fontSize: 8.0,
          ),
        ),
        pw.SizedBox(
          height: 5.0,
        ),
        pw.Text(
          '(Type of Semi-expendable Property)',
          style: pw.TextStyle(
            font: serviceLocator<FontService>().getFont('timesNewRomanRegular'),
            fontSize: 8.0,
          ),
        ),
        pw.SizedBox(
          height: 5.0,
        ),
        pw.Text(
          'As at _______________________',
          style: pw.TextStyle(
            font: serviceLocator<FontService>().getFont('timesNewRomanBold'),
            fontSize: 9.0,
          ),
        ),
      ],
    );
  }

  pw.Table _buildTableHeader(
    PdfPageFormat pageFormat,
    List<pw.TableRow> tableRows,
  ) {
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
                  1: const pw.FixedColumnWidth(500.0),
                  2: const pw.FixedColumnWidth(200.0),
                  3: const pw.FixedColumnWidth(120.0),
                  4: const pw.FixedColumnWidth(100.0),
                  5: const pw.FixedColumnWidth(160.0),
                  6: const pw.FixedColumnWidth(160.0),
                  7: const pw.FixedColumnWidth(240.0),
                  8: const pw.FixedColumnWidth(470.0),
                },
      children: tableRows,
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
                  3: const pw.FixedColumnWidth(80.0),
                  4: const pw.FixedColumnWidth(200.0),
                  5: const pw.FixedColumnWidth(80.0),
                  6: const pw.FixedColumnWidth(80.0),
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
          font: serviceLocator<FontService>().getFont('timesNewRomanBold'),
          fontSize: 8.0,
          verticalPadding: 14.8,
        ),
        DocumentComponents.buildHeaderContainerCell(
          data: 'Description (Specification, Brand, Model, Serial #, Etc.)',
          font: serviceLocator<FontService>().getFont('timesNewRomanBold'),
          fontSize: 8.0,
          verticalPadding: 10.6,
          horizontalPadding: 3.0,
          borderRight: false,
          borderLeft: false,
          borderWidthBottom: 2.0,
        ),
        // pw.Column(
        //   crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        //   children: [
        //     DocumentComponents.buildHeaderContainerCell(
        //       data: 'Description (Specification, Brand, Model, Serial #, Etc.)',
        //       font: serviceLocator<FontService>().getFont('timesNewRomanBold'),
        //       fontSize: 8.0,
        //       verticalPadding: 3.0,
        //       horizontalPadding: 3.0,
        //       borderRight: false,
        //       borderLeft: false,
        //       borderWidthBottom: 2.0,
        //     ),
        //     pw.Row(
        //       children: [
        //         pw.Expanded(
        //           child: DocumentComponents.buildHeaderContainerCell(
        //             data: 'Specs',
        //             font: serviceLocator<FontService>()
        //                 .getFont('timesNewRomanBold'),
        //             fontSize: 8.0,
        //             verticalPadding: 3.0,
        //             borderTop: false,
        //             borderRight: false,
        //             borderLeft: false,
        //           ),
        //         ),
        //         pw.Expanded(
        //           child: DocumentComponents.buildHeaderContainerCell(
        //             data: 'Brand',
        //             font: serviceLocator<FontService>()
        //                 .getFont('timesNewRomanBold'),
        //             fontSize: 8.0,
        //             verticalPadding: 3.0,
        //             borderTop: false,
        //             borderRight: false,
        //             borderWidthLeft: 2.0,
        //           ),
        //         ),
        //         pw.Expanded(
        //           child: DocumentComponents.buildHeaderContainerCell(
        //             data: 'Model',
        //             font: serviceLocator<FontService>()
        //                 .getFont('timesNewRomanBold'),
        //             fontSize: 8.0,
        //             verticalPadding: 3.0,
        //             borderTop: false,
        //             borderRight: false,
        //             borderWidthLeft: 2.0,
        //           ),
        //         ),
        //         pw.Expanded(
        //           child: DocumentComponents.buildHeaderContainerCell(
        //             data: 'Serial #',
        //             font: serviceLocator<FontService>()
        //                 .getFont('timesNewRomanBold'),
        //             fontSize: 8.0,
        //             verticalPadding: 3.0,
        //             borderTop: false,
        //             borderRight: false,
        //             borderWidthLeft: 2.0,
        //           ),
        //         ),
        //       ],
        //     ),
        //   ],
        // ),
        DocumentComponents.buildHeaderContainerCell(
          data: 'Semi-expendable Property No.',
          font: serviceLocator<FontService>().getFont('timesNewRomanBold'),
          fontSize: 8.0,
          verticalPadding: 10.6,
          horizontalPadding: 3.0,
          borderRight: false,
        ),
        DocumentComponents.buildHeaderContainerCell(
          data: 'Unit of Measure',
          font: serviceLocator<FontService>().getFont('timesNewRomanBold'),
          fontSize: 8.0,
          verticalPadding: 10.6,
          horizontalPadding: 3.0,
          borderRight: false,
        ),
        DocumentComponents.buildHeaderContainerCell(
          data: 'Unit Value',
          font: serviceLocator<FontService>().getFont('timesNewRomanBold'),
          fontSize: 8.0,
          verticalPadding: 10.6,
          borderRight: false,
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            DocumentComponents.buildHeaderContainerCell(
              data: 'Balance Per Card',
              font: serviceLocator<FontService>().getFont('timesNewRomanBold'),
              fontSize: 8.0,
              horizontalPadding: 3.0,
              borderRight: false,
              verticalPadding: 3.0,
              borderWidthBottom: 2.0,
            ),
            DocumentComponents.buildHeaderContainerCell(
              data: '(Quantity)',
              font: serviceLocator<FontService>().getFont('timesNewRomanBold'),
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
              font: serviceLocator<FontService>().getFont('timesNewRomanBold'),
              fontSize: 8.0,
              verticalPadding: 3.0,
              horizontalPadding: 3.0,
              borderWidthBottom: 2.0,
            ),
            DocumentComponents.buildHeaderContainerCell(
              data: '(Quantity)',
              font: serviceLocator<FontService>().getFont('timesNewRomanBold'),
              fontSize: 8.0,
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
              font: serviceLocator<FontService>().getFont('timesNewRomanBold'),
              fontSize: 8.0,
              borderRight: false,
              borderLeft: false,
              borderWidthBottom: 2.0,
              verticalPadding: 7.5,
            ),
            pw.Row(
              children: [
                pw.Expanded(
                  child: DocumentComponents.buildHeaderContainerCell(
                    data: 'Quantity',
                    font: serviceLocator<FontService>()
                        .getFont('timesNewRomanBold'),
                    fontSize: 8.0,
                    borderTop: false,
                    borderRight: false,
                    borderLeft: false,
                    horizontalPadding: 3.0,
                    verticalPadding: 3.0,
                    borderWidthBottom: 2.8,
                  ),
                ),
                pw.Expanded(
                  child: DocumentComponents.buildHeaderContainerCell(
                    data: 'Value',
                    font: serviceLocator<FontService>()
                        .getFont('timesNewRomanBold'),
                    fontSize: 8.0,
                    borderTop: false,
                    borderRight: false,
                    horizontalPadding: 3.0,
                    verticalPadding: 3.0,
                    borderWidthBottom: 2.8,
                    borderWidthLeft: 2.0,
                  ),
                ),
              ],
            ),
          ],
        ),
        DocumentComponents.buildHeaderContainerCell(
          data: 'Remarks (State whereabouts, conditions, Accountable Officer)',
          font: serviceLocator<FontService>().getFont('timesNewRomanBold'),
          fontSize: 8.0,
          verticalPadding: 10.6,
        ),
      ],
    );
  }

  pw.TableRow _buildContentTableRow({
    String? article,
    String? description,
    String? semiExpendablePropertyNo,
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
        // pw.Column(
        //   crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        //   children: [
        //     pw.Row(
        //       children: [
        //         pw.Expanded(
        //           child: DocumentComponents.buildTableRowColumn(
        //             data: '\n',
        //             verticalPadding: 3.0,
        //             borderTop: false,
        //             borderRight: false,
        //             borderLeft: false,
        //           ),
        //         ),
        //         pw.Expanded(
        //           child: DocumentComponents.buildTableRowColumn(
        //             data: '\n',
        //             verticalPadding: 3.0,
        //             borderTop: false,
        //             borderRight: false,
        //             borderWidthLeft: 2.0,
        //           ),
        //         ),
        //         pw.Expanded(
        //           child: DocumentComponents.buildTableRowColumn(
        //             data: '\n',
        //             verticalPadding: 3.0,
        //             borderTop: false,
        //             borderRight: false,
        //             borderWidthLeft: 2.0,
        //           ),
        //         ),
        //         pw.Expanded(
        //           child: DocumentComponents.buildTableRowColumn(
        //             data: '\n',
        //             verticalPadding: 3.0,
        //             borderTop: false,
        //             borderRight: false,
        //             borderWidthLeft: 2.0,
        //           ),
        //         ),
        //       ],
        //     ),
        //   ],
        // ),
        DocumentComponents.buildTableRowColumn(
          data: semiExpendablePropertyNo ?? '\n',
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
          data: totalQuantity.toString(),
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
