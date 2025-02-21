import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../features/item_inventory/domain/entities/equipment.dart';
import '../../../../features/item_inventory/domain/entities/product_stock.dart';
import '../../../../features/item_issuance/data/models/inventory_custodian_slip.dart';
import '../../../../features/item_issuance/data/models/issuance_item.dart';
import '../../../../features/item_issuance/data/models/property_acknowledgement_receipt.dart';
import '../../../../features/item_issuance/domain/entities/issuance_item.dart';
import '../../../../features/item_issuance/domain/entities/requisition_and_issue_slip.dart';
import '../../../../init_dependencies.dart';
import '../../../enums/unit.dart';
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

    final List<IssuanceItemEntity> issuedItems;

    final String entityName;
    final String fundCluster;

    final String division;
    final String office;
    final String rcc;
    final String pr;
    final List<String>
        stockNo; // combination of product_name_id and product_description_id
    final int requestQuantity;
    final String purpose;

    final String requestingOfficerName;
    final String requestingOfficerPosition;
    final String approvingOfficerName;
    final String approvingOfficerPosition;
    final String issuingOfficerName;
    final String issuingOfficerPosition;
    final String receivingOfficerName;
    final String receivingOfficerPosition;

    if (data is InventoryCustodianSlipModel) {
      final ics = data;
      final purchaseRequestEntity = ics.purchaseRequestEntity;

      pr = purchaseRequestEntity.id;
      rcc = purchaseRequestEntity.responsibilityCenterCode ?? '\n';
      office = purchaseRequestEntity.officeEntity.officeName;
      entityName = purchaseRequestEntity.entity.name;
      fundCluster = readableEnumConverter(purchaseRequestEntity.fundCluster);
      purpose = data.purchaseRequestEntity.purpose;

      issuedItems = ics.items;

      //stockNo = data.purchaseRequestEntity.productNameEntity.id;
      //requestQuantity = data.purchaseRequestEntity.quantity;

      requestingOfficerName =
          purchaseRequestEntity.requestingOfficerEntity.name;
      requestingOfficerPosition =
          purchaseRequestEntity.requestingOfficerEntity.positionName;
      approvingOfficerName = purchaseRequestEntity.approvingOfficerEntity.name;
      approvingOfficerPosition =
          purchaseRequestEntity.approvingOfficerEntity.positionName;
      //issuingOfficerName = data.sendingOfficerEntity.name;
      //issuingOfficerPosition = data.sendingOfficerEntity.positionName;
      //receivingOfficerName = data.receivingOfficerEntity.name;
      //receivingOfficerPosition = data.receivingOfficerEntity.positionName;
    } else if (data is PropertyAcknowledgementReceiptModel) {
      final par = data;
      final purchaseRequestEntity = par.purchaseRequestEntity;
      final requestingOfficerEntity =
          purchaseRequestEntity.requestingOfficerEntity;
      final receivingOfficerEntity = par.receivingOfficerEntity;
      final sendingOfficerEntity = par
          .sendingOfficerEntity; // not sure if sending can be issuing officer or approving off

      pr = purchaseRequestEntity.id;
      rcc = purchaseRequestEntity.responsibilityCenterCode ?? '\n';
      office = purchaseRequestEntity.officeEntity.officeName;
      entityName = purchaseRequestEntity.entity.name;
      fundCluster = readableEnumConverter(purchaseRequestEntity.fundCluster);
      purpose = data.purchaseRequestEntity.purpose;

      issuedItems = par.items;

      //stockNo = data.purchaseRequestEntity.productNameEntity.id;
      //requestQuantity = data.purchaseRequestEntity.quantity;

      requestingOfficerName =
          purchaseRequestEntity.requestingOfficerEntity.name;
      requestingOfficerPosition =
          purchaseRequestEntity.requestingOfficerEntity.positionName;
      approvingOfficerName = purchaseRequestEntity.approvingOfficerEntity.name;
      approvingOfficerPosition =
          purchaseRequestEntity.approvingOfficerEntity.positionName;
      //issuingOfficerName = data.sendingOfficerEntity.name;
      //issuingOfficerPosition = data.sendingOfficerEntity.positionName;
      //receivingOfficerName = data.receivingOfficerEntity.name;
      //receivingOfficerPosition = data.receivingOfficerEntity.positionName;
    } else if (data is RequisitionAndIssueSlipEntity) {
      final ris = data;
      final purchaseRequestEntity = ris.purchaseRequestEntity;
      final requestingOfficerEntity =
          purchaseRequestEntity.requestingOfficerEntity;
      final receivingOfficerEntity = ris.receivingOfficerEntity;
      final approvingOfficerEntity =
          purchaseRequestEntity.approvingOfficerEntity;
      final issuingOfficerEntity = ris.issuingOfficerEntity;

      pr = purchaseRequestEntity.id;
      rcc = purchaseRequestEntity.responsibilityCenterCode ?? '\n';
      office = purchaseRequestEntity.officeEntity.officeName;
      entityName = purchaseRequestEntity.entity.name;
      fundCluster = purchaseRequestEntity.fundCluster.toReadableString();
      purpose = data.purchaseRequestEntity.purpose;

      issuedItems = ris.items;

      requestingOfficerName = requestingOfficerEntity.name;
      requestingOfficerPosition = requestingOfficerEntity.positionName;
      receivingOfficerName = receivingOfficerEntity.name;
      receivingOfficerPosition = receivingOfficerEntity.positionName;
      approvingOfficerName = approvingOfficerEntity.name;
      approvingOfficerPosition = approvingOfficerEntity.positionName;
      issuingOfficerName = issuingOfficerEntity.name;
      issuingOfficerPosition = issuingOfficerEntity.positionName;
    } else {
      throw ArgumentError('Unsupported data type for RIS generation');
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

    List<Map<String, dynamic>> issuedItemsMap = [];
    List<String> descriptionColumn = [];
    Unit? unit;
    double? unitCost;
    double? totalCost;
    int? estimatedUsefulLife;

    // Loop through each item to generate rows
    for (final issuedItem in issuedItems) {
      // Extract common information
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

      // Add PR information
      descriptionColumn.add('PR: ${data.purchaseRequestEntity.id}');

      // Calculate row heights for description
      final rowHeights = descriptionColumn.map((row) {
        return DocumentService.getRowHeight(row, fontSize: 8.5);
      }).toList();

      for (int i = 0; i < descriptionColumn.length; i++) {
        final issuedItemEntity = issuedItem;
        final itemEntity = issuedItemEntity.itemEntity;
        final productStockEntity = itemEntity.productStockEntity;
        final productNameEntity = productStockEntity.productName;
        final productDescriptionEntity = productStockEntity.productDescription;
        final shareableItemInformationEntity =
            itemEntity.shareableItemInformationEntity;

        // Stock No.
        final productNameId = productNameEntity.id;
        final productDescriptionId = productDescriptionEntity!.id;

        final unit = readableEnumConverter(shareableItemInformationEntity.unit);

        // to be implement, I need to think of a way to determine the requested qty
        // for that, I will access the pr requested items, but I must match the item being issued to the curr req
        final requestQuantity = '0';

        final issuedQuantity = issuedItemEntity.quantity.toString();

        // the yes or no can be tricky, I must clarify this one
        tableRows.add(
          DocumentComponents.buildRISTableRow(
            stockNo: i == 0 ? '$productNameId-$productDescriptionId' : '\n',
            unit: i == 0 ? unit : '\n',
            description: descriptionColumn[i],
            requestQuantity: i == 0 ? requestQuantity : '\n',
            yes: i == 0 ? '/' : '\n',
            no: i == 0 ? 'X' : '\n',
            issueQuantity: i == 0 ? issuedQuantity : '\n',
            remarks: i == 0 ? 'To be clarify' : '\n',
            rowHeight: rowHeights[i],
            borderBottom: i == descriptionColumn.length - 1 ? false : true,
          ),
        );
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
                value: entityName,
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
                    row2Title: 'Office:',
                    borderRight: false,
                  ),
                  DocumentComponents().buildRISHeaderContainer(
                    row1Title: 'Responsibility Center Code:',
                    row2Title: 'RIS No.:',
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
                          data: '\n\n\n\n',
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
                dataRowColumnOne: requestingOfficerName,
                dataRowColumnTwo: approvingOfficerName,
                dataRowColumnThree: '\n', // issuingOfficerName,
                dataRowColumnFour: '\n', // receivingOfficerName,
              ),
              DocumentComponents.buildRISFooterTableRow(
                title: 'Designation:',
                dataRowColumnOne: formatPosition(requestingOfficerPosition),
                dataRowColumnTwo: formatPosition(approvingOfficerPosition),
                dataRowColumnThree: formatPosition('\n'),
                dataRowColumnFour: formatPosition('\n'),
              ),
              DocumentComponents.buildRISFooterTableRow(
                title: 'Date:',
              ),
            ],
          ),
        ],
      ),
    );

    return pdf;
  }
}
