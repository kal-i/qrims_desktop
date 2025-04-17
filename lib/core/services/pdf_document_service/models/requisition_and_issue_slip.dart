import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../features/item_inventory/domain/entities/inventory_item.dart';
import '../../../../features/item_issuance/domain/entities/requisition_and_issue_slip.dart';
import '../../../../features/officer/domain/entities/officer.dart';
import '../../../../init_dependencies.dart';
import '../../../utils/capitalizer.dart';
import '../../../utils/document_date_formatter.dart';
import '../../../utils/extract_specification.dart';
import '../../../utils/format_position.dart';
import '../../../utils/fund_cluster_to_readable_string.dart';
import '../../../utils/readable_enum_converter.dart';
import '../document_service.dart';
import '../font_service.dart';
import '../utils/document_components.dart';
import '../utils/document_page_util.dart';
import 'base_document.dart';

class RequisitionAndIssueSlip implements BaseDocument {
  @override
  Future<pw.Document> generate({
    required PdfPageFormat pageFormat,
    required data,
    required bool withQr,
  }) async {
    final pdf = pw.Document();

    // data from the passed obj
    // we'll create RIS from that
    // things to get: ent, fc, division, office, rcc, iss_items, req_off?, app_off?, issng_off?, rec_off?, purpose?
    // we will get the bool stock_available from qty

    final ris = data as RequisitionAndIssueSlipEntity;
    final risId = ris.risId;
    final division = ris.division ?? '\n';

    final purchaseRequestEntity = ris.purchaseRequestEntity;
    // we get this during the data from ics/par when there is associated alr
    OfficerEntity? issuingOfficerEntity = ris.issuingOfficerEntity;
    OfficerEntity? receivingOfficerEntity = ris.receivingOfficerEntity;

    final String entity;
    final String office;
    final String fundCluster;
    final String responsibilityCenterCode;
    final String purpose;

    OfficerEntity? requestingOfficerEntity;
    OfficerEntity? approvingOfficerEntity;

    if (purchaseRequestEntity != null) {
      entity = purchaseRequestEntity.entity.name;
      office = purchaseRequestEntity.officeEntity.officeName;
      fundCluster = purchaseRequestEntity.fundCluster.toReadableString();
      responsibilityCenterCode =
          purchaseRequestEntity.responsibilityCenterCode ?? '\n';
      purpose = purchaseRequestEntity.purpose;

      requestingOfficerEntity = purchaseRequestEntity.requestingOfficerEntity;
      approvingOfficerEntity = purchaseRequestEntity.approvingOfficerEntity;
    } else {
      entity = ris.entity?.name ?? '\n';
      office = ris.office?.officeName ?? '\n';
      fundCluster = ris.fundCluster?.toReadableString() ?? '\n';
      responsibilityCenterCode = ris.responsibilityCenterCode ?? '\n';
      purpose = ris.purpose ?? '\n\n\n\n';

      requestingOfficerEntity = ris.requestingOfficerEntity;
      approvingOfficerEntity = ris.approvingOfficerEntity;
    }

    List<pw.TableRow> tableRows = [
      pw.TableRow(
        children: [
          DocumentComponents.buildHeaderContainerCell(
            data: 'Stock No.',
            verticalPadding: 3.0,
            borderTop: false,
            borderRight: false,
            font: serviceLocator<FontService>().getFont('calibriRegular'),
          ),
          DocumentComponents.buildHeaderContainerCell(
            data: 'Unit',
            verticalPadding: 3.0,
            borderTop: false,
            borderRight: false,
            font: serviceLocator<FontService>().getFont('calibriRegular'),
          ),
          DocumentComponents.buildHeaderContainerCell(
            data: 'Description',
            verticalPadding: 3.0,
            borderTop: false,
            borderRight: false,
            font: serviceLocator<FontService>().getFont('calibriRegular'),
          ),
          DocumentComponents.buildHeaderContainerCell(
            data: 'Quantity',
            verticalPadding: 3.0,
            borderTop: false,
            borderRight: false,
            font: serviceLocator<FontService>().getFont('calibriRegular'),
          ),
          DocumentComponents.buildHeaderContainerCell(
            data: 'Yes',
            verticalPadding: 3.0,
            borderTop: false,
            borderRight: false,
            font: serviceLocator<FontService>().getFont('calibriRegular'),
          ),
          DocumentComponents.buildHeaderContainerCell(
            data: 'No',
            verticalPadding: 3.0,
            borderTop: false,
            borderRight: false,
            font: serviceLocator<FontService>().getFont('calibriRegular'),
          ),
          DocumentComponents.buildHeaderContainerCell(
            data: 'Quantity',
            verticalPadding: 3.0,
            borderTop: false,
            borderRight: false,
            font: serviceLocator<FontService>().getFont('calibriRegular'),
          ),
          DocumentComponents.buildHeaderContainerCell(
            data: 'Remarks',
            verticalPadding: 3.0,
            borderTop: false,
            font: serviceLocator<FontService>().getFont('calibriRegular'),
          ),
        ],
      ),
    ];

    // Loop through each item to generate rows
    for (int i = 0; i < ris.items.length; i++) {
      final issuanceItemEntity = ris.items[i];
      final itemEntity = issuanceItemEntity.itemEntity;
      final productStockEntity = itemEntity.productStockEntity;
      final productNameEntity = productStockEntity.productName;
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
          cellWidth: 300.0,
        );
      }).toList();

      final productNameId = productNameEntity.id;
      final productDescriptionId = productDescriptionEntity?.id;
      final stockNo = '$productNameId$productDescriptionId';
      final unit = shareableItemInformationEntity.unit;
      final stockQuantity = shareableItemInformationEntity.quantity;
      final issuedQuantity = issuanceItemEntity.quantity;

      int? requestedQuantity;
      if (purchaseRequestEntity != null) {
        for (final requestedItem
            in purchaseRequestEntity.requestedItemEntities) {
          final requestedProductNameId = requestedItem.productNameEntity.id;
          final requestedProductDescriptionId =
              requestedItem.productDescriptionEntity.id;
          final requestedUnit = requestedItem.unit;

          if (productNameId == requestedProductNameId &&
              productDescriptionId == requestedProductDescriptionId &&
              unit == requestedUnit) {
            requestedQuantity = requestedItem.quantity;
          }
        }
      } else {
        requestedQuantity = issuedQuantity;
      }

      for (int j = 0; j < descriptionColumn.length; j++) {
        tableRows.add(
          DocumentComponents.buildRISTableRow(
            stockNo: j == 0 ? stockNo : '\n',
            unit: j == 0 ? readableEnumConverter(unit) : '\n',
            description: descriptionColumn[j],
            requestQuantity: j == 0 ? requestedQuantity.toString() : '\n',
            yes: j == 0
                ? stockQuantity > 0
                    ? '/'
                    : '\n'
                : '\n',
            no: j == 0
                ? stockQuantity == 0
                    ? '/'
                    : '\n'
                : '\n',
            issueQuantity: j == 0 ? issuedQuantity.toString() : '\n',
            remarks: j == 0 ? '\n' : '\n',
            rowHeight: rowHeights[j],
            borderBottom: j == descriptionColumn.length - 1 ? false : true,
          ),
        );
      }

      if (i == ris.items.length - 1) {
        if (purchaseRequestEntity != null) {}
      }
    }

    pdf.addPage(
      pw.MultiPage(
        pageTheme: DocumentPageUtil.getPageTheme(
          pageFormat: pageFormat,
          orientation: pw.PageOrientation.portrait,
          marginTop: 1.9,
          marginRight: 1.2,
          marginBottom: 0.8,
          marginLeft: 0.9,
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
                  'REQUISITION AND ISSUE SLIP',
                  style: pw.TextStyle(
                    font: serviceLocator<FontService>()
                        .getFont('timesNewRomanBold'),
                    fontSize: 14.0,
                  ),
                ),
              ],
            ),
          ),

          pw.SizedBox(
            height: 20.0,
          ),

          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              DocumentComponents.buildRowTextValue(
                text: 'Entity Name:',
                value: capitalizeWord(entity),
                font: serviceLocator<FontService>().getFont('calibriBold'),
              ),
              DocumentComponents.buildRowTextValue(
                text: 'Fund Cluster:',
                value: fundCluster,
                font: serviceLocator<FontService>().getFont('calibriBold'),
              ),
            ],
          ),

          pw.SizedBox(
            height: 6.0,
          ),

          /// Table Header Section
          pw.Table(
            columnWidths: {
              0: const pw.FixedColumnWidth(825.0),
              1: const pw.FixedColumnWidth(450.0),
            },
            children: [
              pw.TableRow(
                children: [
                  DocumentComponents().buildRISHeaderContainer(
                    row1Title: 'Division:',
                    row1Value: division.toUpperCase(),
                    row2Title: 'Office:',
                    row2Value: capitalizeWord(office),
                    borderRight: false,
                  ),
                  DocumentComponents().buildRISHeaderContainer(
                    row1Title: 'Responsibility Center Code:',
                    row1Value: responsibilityCenterCode,
                    row2Title: 'RIS No.:',
                    row2Value: risId,
                    isRow1Underlined: true,
                  ),
                ],
              ),
            ],
          ),

          pw.Table(
            columnWidths: {
              0: const pw.FixedColumnWidth(675),
              1: const pw.FixedColumnWidth(275),
              2: const pw.FixedColumnWidth(325),
            },
            children: [
              pw.TableRow(
                children: [
                  DocumentComponents.buildHeaderContainerCell(
                    data: 'Requisition',
                    verticalPadding: 3.0,
                    borderTop: false,
                    borderRight: false,
                    font: serviceLocator<FontService>()
                        .getFont('calibriBoldItalic'),
                  ),
                  DocumentComponents.buildHeaderContainerCell(
                    data: 'Stock Available?',
                    verticalPadding: 3.0,
                    borderTop: false,
                    borderRight: false,
                    font: serviceLocator<FontService>()
                        .getFont('calibriBoldItalic'),
                  ),
                  DocumentComponents.buildHeaderContainerCell(
                    data: 'Issue',
                    verticalPadding: 3.0,
                    borderTop: false,
                    font: serviceLocator<FontService>()
                        .getFont('calibriBoldItalic'),
                  ),
                ],
              ),
            ],
          ),

          pw.Table(
            columnWidths: {
              0: const pw.FixedColumnWidth(100),
              1: const pw.FixedColumnWidth(125),
              2: const pw.FixedColumnWidth(300),
              3: const pw.FixedColumnWidth(150),
              4: const pw.FixedColumnWidth(150),
              5: const pw.FixedColumnWidth(125),
              6: const pw.FixedColumnWidth(100),
              7: const pw.FixedColumnWidth(225),
            },
            children: tableRows,
          ),

          pw.Table(
            children: [
              pw.TableRow(
                children: [
                  DocumentComponents.buildContainer(
                    horizontalPadding: 5.0,
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        DocumentComponents.buildTableRowColumn(
                          data: 'Purpose:',
                          borderRight: false,
                          borderBottom: false,
                          borderLeft: false,
                        ),
                        DocumentComponents.buildTableRowColumn(
                          data: purpose,
                          borderRight: false,
                          borderLeft: false,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          pw.Table(
            columnWidths: {
              0: const pw.FixedColumnWidth(225),
              1: const pw.FixedColumnWidth(300),
              2: const pw.FixedColumnWidth(300),
              3: const pw.FixedColumnWidth(225),
              4: const pw.FixedColumnWidth(225),
            },
            children: [
              DocumentComponents.buildRISFooterTableHeader(),
              DocumentComponents.buildRISFooterTableRow(
                title: 'Printed Name:',
                dataRowColumnOne: requestingOfficerEntity?.name,
                dataRowColumnTwo: approvingOfficerEntity?.name,
                dataRowColumnThree: issuingOfficerEntity?.name,
                dataRowColumnFour: receivingOfficerEntity?.name,
              ),
              DocumentComponents.buildRISFooterTableRow(
                title: 'Designation:',
                dataRowColumnOne: formatPosition(
                  requestingOfficerEntity?.positionName ?? '\n',
                ),
                dataRowColumnTwo: formatPosition(
                  approvingOfficerEntity?.positionName ?? '\n',
                ),
                dataRowColumnThree: formatPosition(
                  issuingOfficerEntity?.positionName ?? '\n',
                ),
                dataRowColumnFour: formatPosition(
                  requestingOfficerEntity?.positionName ?? '\n',
                ),
              ),
              DocumentComponents.buildRISFooterTableRow(
                title: 'Date:',
                dataRowColumnOne: ris.requestDate != null
                    ? documentDateFormatter(ris.requestDate!)
                    : '\n',
                dataRowColumnTwo: ris.approvedDate != null
                    ? documentDateFormatter(ris.approvedDate!)
                    : '\n',
                dataRowColumnThree: documentDateFormatter(ris.issuedDate),
                dataRowColumnFour: ris.receivedDate != null
                    ? documentDateFormatter(ris.receivedDate!)
                    : '\n',
              ),
            ],
          ),
        ],
      ),
    );

    return pdf;
  }
}
