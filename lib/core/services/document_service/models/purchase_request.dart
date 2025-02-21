import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../features/officer/domain/entities/officer.dart';
import '../../../../features/purchase_request/domain/entities/purchase_request.dart';
import '../../../../init_dependencies.dart';
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
            data: 'Stock/ Propert No.',
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

    // Loop through each item to generate rows
    for (final requestedItem in pr.requestedItemEntities) {
      // Extract common information
      final descriptionColumn = [
        requestedItem.productDescriptionEntity.description ?? 'No Description',
        'Specifications',
      ];

      // Add specifications
      // descriptionColumn.addAll(
      //   extractSpecification(
      //     issuedItem.itemEntity.shareableItemInformationEntity.specification,
      //     ' - ',
      //   ),
      // );

      // Add equipment-specific details if the item is EquipmentEntity
      // if (issuedItem is EquipmentEntity) {
      //   final equipmentItem = issuedItem as EquipmentEntity;
      //   descriptionColumn.addAll(
      //     [
      //       'Brand: ${equipmentItem.manufacturerBrandEntity.brand.name}',
      //       'Model: ${equipmentItem.modelEntity.modelName}',
      //       'SN: ${equipmentItem.serialNo}',
      //       'Date Acquired: ${documentDateFormatter(equipmentItem.acquiredDate!)}',
      //     ],
      //   );
      // }

      // Add PR information
      //descriptionColumn.add('PR: ${ics.purchaseRequestEntity.id}');

      // Calculate row heights for description
      final rowHeights = descriptionColumn.map((row) {
        return DocumentService.getRowHeight(row, fontSize: 8.5);
      }).toList();

      // Add rows for this item
      // for (int i = 0; i < descriptionColumn.length; i++) {
      //   tableRows.add(
      //     DocumentComponents.buildIcsTableRow(
      //       quantity: i == 0 ? issuedItem.quantity.toString() : '\n',
      //       unit: i == 0
      //           ? readableEnumConverter(
      //               issuedItem.itemEntity.shareableItemInformationEntity.unit)
      //           : '\n',
      //       unitCost: i == 0
      //           ? issuedItem is EquipmentEntity
      //               ? (issuedItem as EquipmentEntity).unitCost.toString()
      //               : '\n'
      //           : '\n',
      //       totalCost: i == 0
      //           ? issuedItem is EquipmentEntity
      //               ? (issuedItem as EquipmentEntity).unitCost.toString()
      //               : '\n'
      //           : '\n',
      //       description: descriptionColumn[i],
      //       itemId: i == 0
      //           ? issuedItem.itemEntity.shareableItemInformationEntity.id
      //           : '\n',
      //       estimatedUsefulLife: i == 0
      //           ? issuedItem is EquipmentEntity
      //               ? (issuedItem as EquipmentEntity).estimatedUsefulLife
      //               : null
      //           : null,
      //       rowHeight: rowHeights[i],
      //       borderBottom: i == descriptionColumn.length - 1 ? false : true,
      //     ),
      //   );
      // }
    }

    // Add the table to the PDF
    pdf.addPage(
      pw.MultiPage(
        pageTheme: DocumentPageUtil.getPageTheme(
          pageFormat: pageFormat,
          orientation: pw.PageOrientation.portrait,
          marginTop: 2.5,
          marginRight: 2.5,
          marginBottom: 1.3,
          marginLeft: 3.2,
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
                value: pr.entity.name,
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
          _buildTopMostTableHeader(),
          pw.Table(
            columnWidths: {
              0: const pw.FixedColumnWidth(100),
              1: const pw.FixedColumnWidth(75),
              2: const pw.FixedColumnWidth(250),
              3: const pw.FixedColumnWidth(75),
              4: const pw.FixedColumnWidth(75),
              5: const pw.FixedColumnWidth(75),
            },
            children: tableRows,
          ),
          pw.Table(
            children: [
              pw.TableRow(
                children: [
                  _buildCell(
                    data:
                        '''Purpose: _____________________________________________________________________________________________________________________________________________________________________________________________________________________
                          ''',
                    font: serviceLocator<FontService>()
                        .getFont('timesNewRomanRegular'),
                    isCenter: false,
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
          pw.SizedBox(height: 30.0),
          if (withQr)
            pw.Align(
              alignment: pw.AlignmentDirectional.bottomEnd,
              child: DocumentComponents.buildQrContainer(
                data: data.id,
              ),
            ),
        ],
      ),
    );

    return pdf;
  }

  pw.Table _buildTopMostTableHeader() {
    return pw.Table(
      columnWidths: {
        0: const pw.FixedColumnWidth(175),
        1: const pw.FixedColumnWidth(325),
        2: const pw.FixedColumnWidth(225),
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
            _buildCell(
              data: 'PR No.: __________________',
              isCenter: false,
              borderRight: false,
              borderBottom: false,
            ),
            _buildCell(
              data: 'Date: __________________',
              isCenter: false,
              borderBottom: false,
            ),
          ],
        ),
        pw.TableRow(
          children: [
            _buildCell(
              data: '__________',
              isCenter: false,
              borderTop: false,
              borderRight: false,
              borderBottom: false,
            ),
            _buildCell(
              data: 'Responsibility Center Code: _____________',
              isCenter: false,
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

  pw.Table _buildTableFooter({
    required OfficerEntity requestingOfficerEntity,
    required OfficerEntity approvingOfficerEntity,
  }) {
    return pw.Table(
      columnWidths: {
        0: const pw.FixedColumnWidth(100),
        1: const pw.FixedColumnWidth(200),
        2: const pw.FixedColumnWidth(490),
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
              data: requestingOfficerEntity.name,
              isCenter: false,
              borderTop: false,
              borderRight: false,
              borderBottom: false,
            ),
            _buildCell(
              data: approvingOfficerEntity.name,
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
              data: requestingOfficerEntity.positionName,
              font:
                  serviceLocator<FontService>().getFont('timesNewRomanRegular'),
              isCenter: false,
              borderTop: false,
              borderRight: false,
            ),
            _buildCell(
              data: approvingOfficerEntity.positionName,
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
}
