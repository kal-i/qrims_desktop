import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../features/officer/domain/entities/officer.dart';
import '../../../../features/purchase_request/domain/entities/purchase_request.dart';
import '../../../../init_dependencies.dart';
import '../../../utils/capitalizer.dart';
import '../../../utils/currency_formatter.dart';
import '../../../utils/document_date_formatter.dart';
import '../../../utils/extract_specification.dart';
import '../../../utils/fund_cluster_to_readable_string.dart';
import '../../../utils/readable_enum_converter.dart';
import '../document_service.dart';
import '../font_service.dart';
import '../utils/document_components.dart';
import '../utils/document_page_util.dart';
import 'base_document.dart';

class PurchaseRequest implements BaseDocument {
  @override
  Future<pw.Document> generate({
    required PdfPageFormat pageFormat,
    required data,
    required bool withQr,
  }) async {
    final pdf = pw.Document();

    final pr = data as PurchaseRequestEntity;
    final requestingOfficerEntity = pr.requestingOfficerEntity;
    final approvingOfficerEntity = pr.approvingOfficerEntity;

    // List to store all rows for the table
    List<pw.TableRow> tableRows = [];

    // Add table header
    tableRows.add(
      pw.TableRow(
        children: [
          _buildCell(
            data: 'Stock/ Property No.',
            verticalPadding: 3.55,
            borderRight: false,
          ),
          _buildCell(
            data: 'Unit',
            verticalPadding: 8.0,
            borderRight: false,
          ),
          _buildCell(
            data: 'Item Description',
            verticalPadding: 8.0,
            borderRight: false,
          ),
          _buildCell(
            data: 'Quantity',
            verticalPadding: 8.0,
            borderRight: false,
          ),
          _buildCell(
            data: 'Unit Cost',
            verticalPadding: 8.0,
            borderRight: false,
          ),
          _buildCell(
            data: 'Total Cost',
            verticalPadding: 8.0,
          ),
        ],
      ),
    );

    for (final requestedItem in pr.requestedItemEntities) {
      final descriptionColumn = [
        requestedItem.productDescriptionEntity.description ?? 'No Description',
      ];

      if (requestedItem.specification != null &&
          requestedItem.specification!.isNotEmpty &&
          requestedItem.specification!.toLowerCase() != 'na' &&
          requestedItem.specification!.toLowerCase() != 'n/a') {
        descriptionColumn.add('Specifications');
        descriptionColumn.addAll(
          extractSpecification(
            requestedItem.specification!,
            ' - ',
          ),
        );
      }

      final rowHeights = descriptionColumn.map((row) {
        return DocumentService.getRowHeight(
          row,
          fontSize: 8.5,
          cellWidth: 350.0,
        );
      }).toList();

      for (int i = 0; i < descriptionColumn.length; i++) {
        tableRows.add(
          _buildTableRows(
            stockOrPropertyNo: i == 0
                ? '${requestedItem.productNameEntity.id}${requestedItem.productDescriptionEntity.id}'
                : '\n',
            unit: i == 0 ? readableEnumConverter(requestedItem.unit) : '\n',
            itemDescription: descriptionColumn[i],
            quantity: i == 0 ? requestedItem.quantity.toString() : '\n',
            unitCost: i == 0 ? formatCurrency(requestedItem.unitCost) : '\n',
            totalCost: i == 0 ? formatCurrency(requestedItem.totalCost) : '\n',
            rowHeight: rowHeights[i],
          ),
        );
      }
    }

    // Add the table to the PDF
    pdf.addPage(
      pw.MultiPage(
        pageTheme: DocumentPageUtil.getPageTheme(
          pageFormat: pageFormat,
          orientation: pw.PageOrientation.portrait,
          marginTop: 2.5,
          marginRight: 2.5,
          marginBottom: 1.5,
          marginLeft: 2.5,
        ),
        build: (context) => [
          pw.Center(
            child: pw.Column(
              children: [
                DocumentComponents.buildDocumentHeader(),
                pw.SizedBox(height: 20.0),
                pw.Text(
                  'PURCHASE REQUEST',
                  style: pw.TextStyle(
                    font: serviceLocator<FontService>()
                        .getFont('timesNewRomanBold'),
                    fontSize: 14.0,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20.0),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              DocumentComponents.buildRowTextValue(
                text: 'Entity Name:',
                value: capitalizeWord(pr.entity.name),
              ),
              DocumentComponents.buildRowTextValue(
                text: 'Fund Cluster:',
                value: pr.fundCluster.toReadableString(),
              ),
            ],
          ),
          pw.SizedBox(
            height: 3.0,
          ),
          _buildTopMostTableHeader(
            prId: pr.id,
            date: pr.date,
            officeOrSection: pr.officeEntity.officeName,
            rcc: pr.responsibilityCenterCode,
          ),
          pw.Table(
            columnWidths: {
              0: const pw.FixedColumnWidth(100),
              1: const pw.FixedColumnWidth(50),
              2: const pw.FixedColumnWidth(350),
              3: const pw.FixedColumnWidth(60),
              4: const pw.FixedColumnWidth(90),
              5: const pw.FixedColumnWidth(90),
            },
            children: tableRows,
          ),
          pw.Table(
            children: [
              pw.TableRow(
                children: [
                  _buildRichTextCell(
                    title: 'Purpose: \t',
                    value: pr.purpose,
                    borderTop: false,
                  ),
                ],
              ),
            ],
          ),
          _buildTableFooter(
            requestingOfficerEntity: requestingOfficerEntity,
            approvingOfficerEntity: approvingOfficerEntity,
          ),
          // pw.SizedBox(height: 30.0),
          // if (withQr)
          //   pw.Align(
          //     alignment: pw.AlignmentDirectional.bottomEnd,
          //     child: DocumentComponents.buildQrContainer(
          //       data: data.id,
          //     ),
          //   ),
        ],
      ),
    );

    return pdf;
  }

  pw.Table _buildTopMostTableHeader({
    required String prId,
    required DateTime date,
    String? officeOrSection,
    String? rcc,
  }) {
    return pw.Table(
      columnWidths: {
        0: const pw.FixedColumnWidth(150),
        1: const pw.FixedColumnWidth(410),
        2: const pw.FixedColumnWidth(180),
      },
      children: [
        pw.TableRow(
          children: [
            _buildCell(
              data: 'Office/Section',
              isCenter: false,
              borderRight: false,
              borderBottom: false,
            ),
            _buildRichTextCell(
              title: 'PR No.: ',
              value: prId,
              borderRight: false,
              borderBottom: false,
            ),
            _buildRichTextCell(
              title: 'Date: ',
              value: documentDateFormatter(date),
              borderBottom: false,
            ),
          ],
        ),
        pw.TableRow(
          children: [
            _buildCell(
              data: capitalizeWord(officeOrSection ?? '____________'),
              font:
                  serviceLocator<FontService>().getFont('timesNewRomanRegular'),
              isCenter: false,
              borderTop: false,
              borderRight: false,
              borderBottom: false,
            ),
            _buildRichTextCell(
              title: 'Responsibility Center Code: ',
              value: rcc ?? '\n',
              borderTop: false,
              borderRight: false,
              borderBottom: false,
            ),
            _buildCell(
              data: '\n',
              isCenter: false,
              borderTop: false,
              borderBottom: false,
            ),
          ],
        ),
      ],
    );
  }

  pw.TableRow _buildTableRows({
    required String stockOrPropertyNo,
    required String unit,
    required String itemDescription,
    required String quantity,
    required String unitCost,
    required String totalCost,
    double? rowHeight,
  }) {
    return pw.TableRow(
      children: [
        _buildCell(
          data: stockOrPropertyNo,
          borderTop: false,
          borderRight: false,
          font: serviceLocator<FontService>().getFont('timesNewRomanRegular'),
          rowHeight: rowHeight,
        ),
        _buildCell(
          data: unit,
          borderTop: false,
          borderRight: false,
          font: serviceLocator<FontService>().getFont('timesNewRomanRegular'),
          rowHeight: rowHeight,
        ),
        _buildCell(
          data: itemDescription,
          borderTop: false,
          borderRight: false,
          font: serviceLocator<FontService>().getFont('timesNewRomanRegular'),
          rowHeight: rowHeight,
        ),
        _buildCell(
          data: quantity,
          borderTop: false,
          borderRight: false,
          font: serviceLocator<FontService>().getFont('timesNewRomanRegular'),
          rowHeight: rowHeight,
        ),
        _buildCell(
          data: unitCost,
          borderTop: false,
          borderRight: false,
          font: serviceLocator<FontService>().getFont('timesNewRomanRegular'),
          rowHeight: rowHeight,
        ),
        _buildCell(
          data: totalCost,
          borderTop: false,
          font: serviceLocator<FontService>().getFont('timesNewRomanRegular'),
          rowHeight: rowHeight,
        ),
      ],
    );
  }

  pw.Table _buildTableFooter({
    required OfficerEntity requestingOfficerEntity,
    required OfficerEntity approvingOfficerEntity,
  }) {
    return pw.Table(
      columnWidths: {
        0: const pw.FixedColumnWidth(100),
        1: const pw.FixedColumnWidth(400),
        2: const pw.FixedColumnWidth(240),
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
              data: 'Requested by:',
              font:
                  serviceLocator<FontService>().getFont('timesNewRomanRegular'),
              isCenter: false,
              borderTop: false,
              borderRight: false,
              borderBottom: false,
            ),
            _buildCell(
              data: 'Approved by:',
              font:
                  serviceLocator<FontService>().getFont('timesNewRomanRegular'),
              isCenter: false,
              borderTop: false,
              borderBottom: false,
            ),
          ],
        ),
        pw.TableRow(
          children: [
            _buildCell(
              data: 'Signature:',
              font:
                  serviceLocator<FontService>().getFont('timesNewRomanRegular'),
              isCenter: false,
              borderTop: false,
              borderRight: false,
              borderBottom: false,
            ),
            _buildCell(
              data: '_____________________',
              font:
                  serviceLocator<FontService>().getFont('timesNewRomanRegular'),
              isCenter: false,
              borderTop: false,
              borderRight: false,
              borderBottom: false,
            ),
            _buildCell(
              data: '_____________________',
              font:
                  serviceLocator<FontService>().getFont('timesNewRomanRegular'),
              isCenter: false,
              borderTop: false,
              borderBottom: false,
            ),
          ],
        ),
        pw.TableRow(
          children: [
            _buildCell(
              data: 'Printed Name:',
              font:
                  serviceLocator<FontService>().getFont('timesNewRomanRegular'),
              isCenter: false,
              borderTop: false,
              borderRight: false,
              borderBottom: false,
            ),
            _buildCell(
              data: capitalizeWord(requestingOfficerEntity.name),
              isCenter: false,
              borderTop: false,
              borderRight: false,
              borderBottom: false,
            ),
            _buildCell(
              data: capitalizeWord(approvingOfficerEntity.name),
              isCenter: false,
              borderTop: false,
              borderBottom: false,
            ),
          ],
        ),
        pw.TableRow(
          children: [
            _buildCell(
              data: 'Department:',
              font:
                  serviceLocator<FontService>().getFont('timesNewRomanRegular'),
              isCenter: false,
              borderTop: false,
              borderRight: false,
            ),
            _buildCell(
              data: capitalizeWord(requestingOfficerEntity.positionName),
              font:
                  serviceLocator<FontService>().getFont('timesNewRomanRegular'),
              isCenter: false,
              borderTop: false,
              borderRight: false,
            ),
            _buildCell(
              data: capitalizeWord(approvingOfficerEntity.positionName),
              font:
                  serviceLocator<FontService>().getFont('timesNewRomanRegular'),
              isCenter: false,
              borderTop: false,
            ),
          ],
        ),
      ],
    );
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
    double fontSize = 8.0,
    bool isCenter = true,
    double? rowHeight,
  }) {
    return DocumentComponents.buildContainer(
      height: rowHeight,
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

  pw.Widget _buildRichTextCell({
    required String title,
    required String value,
    bool borderTop = true,
    bool borderRight = true,
    bool borderBottom = true,
    bool borderLeft = true,
  }) {
    return DocumentComponents.buildContainer(
      horizontalPadding: 3.0,
      verticalPadding: 2.6,
      borderTop: borderTop,
      borderRight: borderRight,
      borderBottom: borderBottom,
      borderLeft: borderLeft,
      borderWidthTop: 2.0,
      borderWidthRight: 2.0,
      borderWidthBottom: 2.0,
      borderWidthLeft: 2.0,
      child: pw.RichText(
        text: pw.TextSpan(
          text: title,
          style: pw.TextStyle(
            fontSize: 8.0,
            font: serviceLocator<FontService>().getFont('timesNewRomanBold'),
          ),
          children: [
            pw.TextSpan(
              text: value,
              style: pw.TextStyle(
                fontSize: 9.0,
                font: serviceLocator<FontService>()
                    .getFont('timesNewRomanRegular'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
