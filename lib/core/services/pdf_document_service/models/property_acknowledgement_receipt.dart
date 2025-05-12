import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../features/item_inventory/domain/entities/inventory_item.dart';
import '../../../../features/item_issuance/domain/entities/issuance_item.dart';
import '../../../../features/item_issuance/domain/entities/property_acknowledgement_receipt.dart';
import '../../../../init_dependencies.dart';
import '../../../utils/capitalizer.dart';
import '../../../utils/currency_formatter.dart';
import '../../../utils/document_date_formatter.dart';
import '../../../utils/fund_cluster_to_readable_string.dart';
import '../../../utils/generate_compression_key.dart';
import '../../../utils/get_position_at.dart';
import '../../../utils/group_specification_by_section.dart';
import '../../../utils/readable_enum_converter.dart';
import '../document_service.dart';
import '../font_service.dart';
import '../utils/document_components.dart';
import '../utils/document_page_util.dart';
import 'base_document.dart';

class PropertyAcknowledgementReceipt implements BaseDocument {
  @override
  Future<pw.Document> generate({
    required PdfPageFormat pageFormat,
    //required pw.PageOrientation orientation,
    required data,
    required bool withQr,
  }) async {
    final pdf = pw.Document();

    final par = data as PropertyAcknowledgementReceiptEntity;
    final purchaseRequestEntity = data.purchaseRequestEntity;
    final supplierEntity = data.supplierEntity;
    final issuingOfficerPositionHistory =
        par.issuingOfficerEntity?.getPositionAt(
      par.issuedDate,
    );
    final receivingOfficerPositonHistory =
        par.receivingOfficerEntity?.getPositionAt(
      par.issuedDate,
    );

    // List to store all rows for the table
    List<pw.TableRow> tableRows = [];

    tableRows.add(
      pw.TableRow(
        children: [
          DocumentComponents.buildHeaderContainerCell(
            data: 'Quantity',
            horizontalPadding: 3.0,
            verticalPadding: 8.6,
            borderRight: false,
          ),
          DocumentComponents.buildHeaderContainerCell(
            data: 'Unit',
            verticalPadding: 8.6,
            borderRight: false,
          ),
          DocumentComponents.buildHeaderContainerCell(
            data: 'Description',
            verticalPadding: 8.6,
            borderRight: false,
          ),
          DocumentComponents.buildHeaderContainerCell(
            data: 'Property Number',
            horizontalPadding: 3.0,
            verticalPadding: 3.0,
            borderRight: false,
          ),
          DocumentComponents.buildHeaderContainerCell(
            data: 'Date Acquired',
            horizontalPadding: 3.0,
            verticalPadding: 3.0,
            borderRight: false,
          ),
          DocumentComponents.buildHeaderContainerCell(
            data: 'Amount',
            horizontalPadding: 3.0,
            verticalPadding: 8.6,
          ),
        ],
      ),
    );

    final compressedItems = <String, List<IssuanceItemEntity>>{};

    for (var item in par.items) {
      final key = IssuanceItemCompressor.generateKey(item);
      compressedItems.putIfAbsent(key, () => []).add(item);
    }

    // Step 2: Generate rows from compressed data
    final itemGroups = compressedItems.values.toList();
    for (int i = 0; i < itemGroups.length; i++) {
      final group = itemGroups[i];
      final representative = group.first;

      final itemEntity = representative.itemEntity;
      final productStockEntity = itemEntity.productStockEntity;
      final productDescriptionEntity = productStockEntity.productDescription;
      final shareableItemInformationEntity =
          itemEntity.shareableItemInformationEntity;

      final descriptionColumn = [
        productDescriptionEntity?.description ?? 'No description defined'
      ];

      final specification = shareableItemInformationEntity.specification;
      if (specification != null && specification.isNotEmpty) {
        descriptionColumn.addAll(groupSpecificationBySection(specification));

        // descriptionColumn.addAll([
        //   'Specifications:',
        //   ...extractSpecification(specification, ','),
        // ]);
      }

      if (itemEntity is InventoryItemEntity) {
        final inventoryItem = itemEntity;
        final manufacturerBrandEntity = inventoryItem.manufacturerBrandEntity;
        final brandEntity = manufacturerBrandEntity?.brand;
        final modelEntity = inventoryItem.modelEntity;
        final serialNo = inventoryItem.serialNo;

        if (brandEntity != null) {
          descriptionColumn.add('Brand: ${brandEntity.name}');
        }
        if (modelEntity != null) {
          descriptionColumn.add('Model: ${modelEntity.modelName}');
        }
        if (serialNo != null && serialNo.isNotEmpty) {
          descriptionColumn.add('SN: $serialNo');
        }
      }

      final rowHeights = descriptionColumn.map((row) {
        return DocumentService.getRowHeight(
          row,
          fontSize: 8.5,
          cellWidth: 380.0,
        );
      }).toList();

      // Sort group by ID
      group.sort(
          (a, b) => a.itemEntity.shareableItemInformationEntity.id.compareTo(
                b.itemEntity.shareableItemInformationEntity.id,
              ));

      final firstId = group.first.itemEntity.shareableItemInformationEntity.id;
      final lastId = group.last.itemEntity.shareableItemInformationEntity.id;

      final baseItemId = group.length == 1 ? firstId : '$firstId TO $lastId';

      final totalQuantity = group.fold<int>(0, (sum, e) => sum + e.quantity);
      final unit = shareableItemInformationEntity.unit;
      final unitCost = shareableItemInformationEntity.unitCost;
      final dateAcquired = shareableItemInformationEntity.acquiredDate;

      final totalCost = unitCost * totalQuantity;

      for (int j = 0; j < descriptionColumn.length; j++) {
        tableRows.add(
          DocumentComponents.buildParTableRow(
            quantity: j == 0 ? totalQuantity.toString() : '\n',
            unit: j == 0 ? readableEnumConverter(unit) : '\n',
            description: descriptionColumn[j],
            propertyNumber: j == 0 ? baseItemId : '\n',
            dateAcquired: j == 0 ? documentDateFormatter(dateAcquired!) : '\n',
            amount: j == 0 ? formatCurrency(totalCost) : '\n',
            rowHeight: rowHeights[j], // Fix: Use j instead of i
            borderTop: i == 0 ? false : true,
            borderBottom: j == descriptionColumn.length - 1 ? false : true,
          ),
        );
      }

      // Add footer rows on last item group
      if (i == itemGroups.length - 1) {
        if (purchaseRequestEntity != null ||
            par.supplierEntity != null ||
            par.inspectionAndAcceptanceReportId != null ||
            par.contractNumber != null ||
            par.purchaseOrderNumber != null) {
          tableRows.add(_buildParTableRowFooter(data: '\n'));
        }
        if (purchaseRequestEntity != null || par.prReferenceId != null) {
          final prValue = purchaseRequestEntity?.id ?? par.prReferenceId;
          tableRows.add(_buildParTableRowFooter(data: 'PR: $prValue'));
        }

        if (par.purchaseOrderNumber != null) {
          tableRows.add(
              _buildParTableRowFooter(data: 'PO: ${par.purchaseOrderNumber}'));
        }

        if (supplierEntity != null) {
          tableRows.add(_buildParTableRowFooter(
              data: 'Supplier: ${supplierEntity.name}'));
        }

        if (par.deliveryReceiptId != null) {
          tableRows.add(
              _buildParTableRowFooter(data: 'DR: ${par.deliveryReceiptId}'));
        }

        if (par.dateAcquired != null) {
          tableRows.add(_buildParTableRowFooter(
              data:
                  'Date Acquired: ${documentDateFormatter(par.dateAcquired!)}'));
        }

        if (par.inventoryTransferReportId != null) {
          tableRows.add(_buildParTableRowFooter(
              data: 'ITR: ${par.inventoryTransferReportId}'));
        }

        if (par.inspectionAndAcceptanceReportId != null) {
          tableRows.add(_buildParTableRowFooter(
              data: 'IAR: ${par.inspectionAndAcceptanceReportId}'));
        }

        if (par.contractNumber != null) {
          tableRows
              .add(_buildParTableRowFooter(data: 'CN: ${par.contractNumber}'));
        }
      }
    }

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
                  'PROPERTY ACKNOWLEDGEMENT RECEIPT',
                  style: pw.TextStyle(
                    font: serviceLocator<FontService>()
                        .getFont('timesNewRomanBold'),
                    fontSize: 14.0,
                    //fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          pw.SizedBox(
            height: 20.0,
          ),

          DocumentComponents.buildRowTextValue(
            text: 'Entity Name:',
            value: purchaseRequestEntity != null
                ? capitalizeWord(purchaseRequestEntity.entity.name)
                : par.entity != null
                    ? capitalizeWord(par.entity?.name ?? '\n')
                    : '\n',
            isUnderlined: true,
          ),

          pw.SizedBox(
            height: 3.0,
          ),

          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              DocumentComponents.buildRowTextValue(
                text: 'Fund Cluster:',
                value: purchaseRequestEntity != null
                    ? purchaseRequestEntity.fundCluster.toReadableString()
                    : par.fundCluster != null
                        ? par.fundCluster?.toReadableString() ?? '\n'
                        : '\n',
              ),
              DocumentComponents.buildRowTextValue(
                text: 'PAR No:',
                value: par.parId,
                isUnderlined: true,
              ),
            ],
          ),

          pw.SizedBox(
            height: 3.0,
          ),

          /// Table
          pw.Table(
            columnWidths: {
              0: const pw.FixedColumnWidth(80),
              1: const pw.FixedColumnWidth(70),
              2: const pw.FixedColumnWidth(380),
              3: const pw.FixedColumnWidth(100),
              4: const pw.FixedColumnWidth(100),
              5: const pw.FixedColumnWidth(100),
            },
            children: tableRows,
          ),

          /// footer
          pw.Table(
            columnWidths: {
              0: const pw.FixedColumnWidth(530.0),
              1: const pw.FixedColumnWidth(300.0),
            },
            children: [
              pw.TableRow(
                children: [
                  DocumentComponents.buildReusableIssuanceFooterContainer(
                    title: 'Received by:',
                    officerName: data.receivingOfficerEntity?.name,
                    officerPosition:
                        receivingOfficerPositonHistory?.positionName ??
                            data.receivingOfficerEntity?.positionName,
                    officerOffice: receivingOfficerPositonHistory?.officeName ??
                        data.receivingOfficerEntity?.officeName,
                    date: par.receivedDate,
                    borderRight: false,
                  ),
                  DocumentComponents.buildReusableIssuanceFooterContainer(
                    title: 'Received from:',
                    officerName: data.issuingOfficerEntity?.name,
                    officerPosition:
                        issuingOfficerPositionHistory?.positionName ??
                            data.issuingOfficerEntity?.positionName,
                    officerOffice: issuingOfficerPositionHistory?.officeName ??
                        data.issuingOfficerEntity?.officeName,
                    date: par.issuedDate,
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

  pw.TableRow _buildParTableRowFooter({
    required String data,
  }) {
    return DocumentComponents.buildParTableRow(
      quantity: '\n',
      unit: '\n',
      description: data,
      propertyNumber: '\n',
      dateAcquired: '\n',
      amount: '\n',
      borderTop: true,
      borderBottom: false,
      rowHeight: 13.0,
    );
  }
}
