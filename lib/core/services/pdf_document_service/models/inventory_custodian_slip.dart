import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../features/item_inventory/domain/entities/equipment.dart';
import '../../../../features/item_issuance/domain/entities/inventory_custodian_slip.dart';
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

class InventoryCustodianSlip implements BaseDocument {
  @override
  Future<pw.Document> generate({
    required PdfPageFormat pageFormat,
    required data,
    required bool withQr,
  }) async {
    final pdf = pw.Document();

    final ics = data as InventoryCustodianSlipEntity;
    final purchaseRequestEntity = data.purchaseRequestEntity;
    final supplierEntity = data.supplierEntity;
    print('issued items length: ${ics.items.length}');

    // List to store all rows for the table
    List<pw.TableRow> tableRows = [];

    // Add table header
    tableRows.add(
      pw.TableRow(
        children: [
          DocumentComponents.buildHeaderContainerCell(
            data: 'Quantity',
            verticalPadding: 13.2,
            borderRight: false,
          ),
          DocumentComponents.buildHeaderContainerCell(
            data: 'Unit',
            verticalPadding: 13.2,
            borderRight: false,
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              DocumentComponents.buildHeaderContainerCell(
                data: 'Amount',
                verticalPadding: 1.0,
                borderWidthBottom: 2.0,
                borderRight: false,
              ),
              pw.Row(
                children: [
                  pw.SizedBox(
                    width: 45.0,
                    child: DocumentComponents.buildHeaderContainerCell(
                      data: 'Unit Cost',
                      horizontalPadding: 6.0,
                      verticalPadding: 1.0,
                      isBold: false,
                      borderTop: false,
                      borderRight: false,
                    ),
                  ),
                  pw.Expanded(
                    child: DocumentComponents.buildHeaderContainerCell(
                      data: 'Total Cost',
                      horizontalPadding: 1.0,
                      verticalPadding: 5.7,
                      isBold: false,
                      borderWidthLeft: 1.5,
                      borderWidthBottom: 2.0,
                      borderTop: false,
                      borderRight: false,
                    ),
                  ),
                ],
              ),
            ],
          ),
          DocumentComponents.buildHeaderContainerCell(
            data: 'Description',
            verticalPadding: 13.2,
            borderRight: false,
          ),
          DocumentComponents.buildHeaderContainerCell(
            data: 'Inventory Item No.',
            verticalPadding: 13.2,
            borderRight: false,
          ),
          DocumentComponents.buildHeaderContainerCell(
            data: 'Estimated Useful Life',
            verticalPadding: 7.7,
          ),
        ],
      ),
    );

    // Loop through each item to generate rows
    for (int i = 0; i < ics.items.length; i++) {
      final issuedItem = ics.items[i];

      // Reinitialize descriptionColumn for each item
      final descriptionColumn = [
        issuedItem.itemEntity.productStockEntity.productDescription
                ?.description ??
            'No Description',
        'Specifications',
      ];

      // Add specifications
      descriptionColumn.addAll(
        extractSpecification(
          issuedItem.itemEntity.shareableItemInformationEntity.specification ??
              'N/A',
          ' - ',
        ),
      );

      // Add equipment-specific details if the item is EquipmentEntity
      if (issuedItem is EquipmentEntity) {
        final equipmentItem = issuedItem as EquipmentEntity;
        descriptionColumn.addAll(
          [
            'Brand: ${equipmentItem.manufacturerBrandEntity.brand.name}',
            'Model: ${equipmentItem.modelEntity.modelName}',
            'SN: ${equipmentItem.serialNo}',
            'Date Acquired: ${documentDateFormatter(issuedItem.itemEntity.shareableItemInformationEntity.acquiredDate!)}',
          ],
        );
      }

      print(
          'Item ID: ${issuedItem.itemEntity.shareableItemInformationEntity.id}');
      print('Description Column: $descriptionColumn');

      // Calculate row heights for description
      final rowHeights = descriptionColumn.map((row) {
        return DocumentService.getRowHeight(row, fontSize: 8.5);
      }).toList();

      // Add rows for this item
      for (int j = 0; j < descriptionColumn.length; j++) {
        tableRows.add(
          DocumentComponents.buildIcsTableRow(
            quantity: j == 0 ? issuedItem.quantity.toString() : '\n',
            unit: j == 0
                ? readableEnumConverter(
                    issuedItem.itemEntity.shareableItemInformationEntity.unit)
                : '\n',
            unitCost: j == 0
                ? formatCurrency(issuedItem
                    .itemEntity.shareableItemInformationEntity.unitCost)
                : '\n',
            totalCost: j == 0
                ? formatCurrency(issuedItem
                    .itemEntity.shareableItemInformationEntity.unitCost)
                : '\n',
            description: descriptionColumn[j],
            itemId: j == 0
                ? issuedItem.itemEntity.shareableItemInformationEntity.id
                : '\n',
            estimatedUsefulLife: j == 0
                ? issuedItem is EquipmentEntity
                    ? (issuedItem as EquipmentEntity).estimatedUsefulLife
                    : null
                : null,
            rowHeight: rowHeights[j],
            borderTop: i == 0 ? false : true,
            isTopBorderSlashed: i == 0 ? false : true,
            borderBottom: j == descriptionColumn.length - 1 ? false : true,
          ),
        );
      }

      if (i == ics.items.length - 1) {
        if (purchaseRequestEntity != null ||
            ics.supplierEntity != null ||
            ics.inspectionAndAcceptanceReportId != null ||
            ics.contractNumber != null ||
            ics.purchaseOrderNumber != null) {
          tableRows.add(
            _buildIcsTableRowFooter(
              data: '\n',
            ),
          );
        }

        if (purchaseRequestEntity != null) {
          tableRows.add(
            _buildIcsTableRowFooter(
              data: 'PR: ${purchaseRequestEntity.id}',
            ),
          );
        }

        if (supplierEntity != null) {
          tableRows.add(
            _buildIcsTableRowFooter(
              data: 'Supplier: ${supplierEntity.name}',
            ),
          );
        }

        if (ics.inspectionAndAcceptanceReportId != null) {
          tableRows.add(
            _buildIcsTableRowFooter(
              data: 'IAR: ${ics.inspectionAndAcceptanceReportId}',
            ),
          );
        }

        if (ics.contractNumber != null) {
          tableRows.add(
            _buildIcsTableRowFooter(
              data: 'CN: ${ics.contractNumber}',
            ),
          );
        }

        if (ics.purchaseOrderNumber != null) {
          tableRows.add(
            _buildIcsTableRowFooter(
              data: 'PO: ${ics.purchaseOrderNumber}',
            ),
          );
        }
      }
    }

    // Add the table to the PDF
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
                pw.SizedBox(height: 20.0),
                pw.Text(
                  'INVENTORY CUSTODIAN SLIP',
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
          DocumentComponents.buildRowTextValue(
            text: 'Entity Name:',
            value: purchaseRequestEntity != null
                ? capitalizeWord(purchaseRequestEntity.entity.name)
                : ics.entity != null
                    ? capitalizeWord(ics.entity?.name ?? '\n')
                    : '\n',
          ),
          pw.SizedBox(height: 3.0),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              DocumentComponents.buildRowTextValue(
                text: 'Fund Cluster:',
                value: purchaseRequestEntity != null
                    ? purchaseRequestEntity.fundCluster.toReadableString()
                    : ics.fundCluster != null
                        ? ics.fundCluster?.toReadableString() ?? '\n'
                        : '\n',
              ),
              DocumentComponents.buildRowTextValue(
                text: 'ICS No:',
                value: data.icsId,
              ),
            ],
          ),
          pw.SizedBox(height: 3.0),
          pw.Table(
            columnWidths: {
              0: const pw.FixedColumnWidth(75),
              1: const pw.FixedColumnWidth(50),
              2: const pw.FixedColumnWidth(150),
              3: const pw.FixedColumnWidth(240),
              4: const pw.FixedColumnWidth(150),
              5: const pw.FixedColumnWidth(100),
            },
            children: tableRows,
          ),
          pw.Table(
            columnWidths: {
              0: const pw.FixedColumnWidth(515.0),
              1: const pw.FixedColumnWidth(250.0),
            },
            children: [
              pw.TableRow(
                children: [
                  DocumentComponents.buildReusableIssuanceFooterContainer(
                    title: 'Received from:',
                    officerName: data.issuingOfficerEntity?.name ?? '\n',
                    officerPosition:
                        data.issuingOfficerEntity?.positionName ?? '\n',
                    officerOffice:
                        data.issuingOfficerEntity?.officeName ?? '\n',
                    date: DateTime.now(),
                    borderRight: false,
                  ),
                  DocumentComponents.buildReusableIssuanceFooterContainer(
                    title: 'Received by:',
                    officerName: data.receivingOfficerEntity?.name ?? '\n',
                    officerPosition:
                        data.receivingOfficerEntity?.positionName ?? '\n',
                    officerOffice:
                        data.receivingOfficerEntity?.officeName ?? '\n',
                  ),
                ],
              ),
            ],
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

  pw.TableRow _buildIcsTableRowFooter({
    required String data,
  }) {
    return DocumentComponents.buildIcsTableRow(
      quantity: '\n',
      unit: '\n',
      unitCost: '\n',
      totalCost: '\n',
      description: data,
      itemId: '\n',
      estimatedUsefulLife: null,
      borderTop: true,
      isTopBorderSlashed: true,
      borderBottom: false,
      rowHeight: 13.0,
    );
  }
}
