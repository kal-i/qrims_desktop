import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../features/item_inventory/domain/entities/inventory_item.dart';
import '../../../../features/item_issuance/domain/entities/inventory_custodian_slip.dart';
import '../../../../init_dependencies.dart';
import '../../../utils/capitalizer.dart';
import '../../../utils/currency_formatter.dart';
import '../../../utils/extract_specification.dart';
import '../../../utils/fund_cluster_to_readable_string.dart';
import '../../../utils/get_position_at.dart';
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
    final issuingOfficerPositionHistory =
        ics.issuingOfficerEntity?.getPositionAt(
      ics.issuedDate,
    );
    final receivingOfficerPositonHistory =
        ics.receivingOfficerEntity?.getPositionAt(
      ics.issuedDate,
    );

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
      final issuanceItemEntity = ics.items[i];
      final itemEntity = issuanceItemEntity.itemEntity;
      final productStockEntity = itemEntity.productStockEntity;
      final productDescriptionEntity = productStockEntity.productDescription;
      final shareableItemInformationEntity =
          itemEntity.shareableItemInformationEntity;

      // Reinitialize descriptionColumn for each item
      final descriptionColumn = [
        productDescriptionEntity?.description ?? 'No description defined'
      ];

      final specification = shareableItemInformationEntity.specification;
      if (specification != null && specification.isNotEmpty) {
        descriptionColumn.addAll(
          [
            'Specifications:',
            ...extractSpecification(specification, ','),
          ],
        );
      }

      // Add inventory-specific details if the item is EquipmentEntity
      if (itemEntity is InventoryItemEntity) {
        final inventoryItem = itemEntity;
        final manufacturerBrandEntity = inventoryItem.manufacturerBrandEntity;
        final brandEntity = manufacturerBrandEntity?.brand;
        final modelEntity = inventoryItem.modelEntity;
        final serialNo = inventoryItem.serialNo;

        if (brandEntity != null) {
          descriptionColumn.add(
            'Brand: ${brandEntity.name}',
          );
        }

        if (modelEntity != null) {
          descriptionColumn.add(
            'Model: ${modelEntity.modelName}',
          );
        }

        if (serialNo != null && serialNo.isNotEmpty) {
          descriptionColumn.add(
            'SN: $serialNo',
          );
        }
      }

      // Calculate row heights for description
      final rowHeights = descriptionColumn.map((row) {
        return DocumentService.getRowHeight(
          row,
          fontSize: 8.5,
          cellWidth: 240.0,
        );
      }).toList();

      final baseItemId = shareableItemInformationEntity.id;
      final quantity = issuanceItemEntity.quantity;
      final unit = shareableItemInformationEntity.unit;
      final unitCost = shareableItemInformationEntity.unitCost;
      final totalCost = unitCost * quantity;
      final estimatedUsefulLife =
          (itemEntity as InventoryItemEntity).estimatedUsefulLife;

      for (int j = 0; j < descriptionColumn.length; j++) {
        tableRows.add(
          DocumentComponents.buildIcsTableRow(
            quantity: j == 0 ? quantity.toString() : '\n',
            unit: j == 0 ? readableEnumConverter(unit) : '\n',
            unitCost: j == 0 ? formatCurrency(unitCost) : '\n',
            totalCost: j == 0 ? formatCurrency(totalCost) : '\n',
            description: descriptionColumn[j],
            itemId: j == 0 ? baseItemId : '\n',
            estimatedUsefulLife: j == 0 ? estimatedUsefulLife : null,
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
                value: ics.icsId,
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
                    officerName: data.issuingOfficerEntity?.name,
                    officerPosition:
                        issuingOfficerPositionHistory?.positionName,
                    officerOffice: issuingOfficerPositionHistory?.officeName,
                    date: ics.issuedDate,
                    borderRight: false,
                  ),
                  DocumentComponents.buildReusableIssuanceFooterContainer(
                    title: 'Received by:',
                    officerName: data.receivingOfficerEntity?.name,
                    officerPosition:
                        receivingOfficerPositonHistory?.positionName,
                    officerOffice: receivingOfficerPositonHistory?.officeName,
                    date: ics.receivedDate,
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
