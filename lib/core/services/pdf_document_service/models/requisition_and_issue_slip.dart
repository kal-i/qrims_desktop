import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../features/item_inventory/domain/entities/inventory_item.dart';
import '../../../../features/item_issuance/data/models/inventory_custodian_slip.dart';
import '../../../../features/item_issuance/data/models/property_acknowledgement_receipt.dart';
import '../../../../features/item_issuance/domain/entities/issuance_item.dart';
import '../../../../features/item_issuance/domain/entities/requisition_and_issue_slip.dart';
import '../../../../init_dependencies.dart';
import '../../../enums/unit.dart';
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
    print(data);

    final List<IssuanceItemEntity> issuedItems;

    final String entityName;
    final String fundCluster;
    String risId = '\n';
    String division = '\n';
    String rcc = '\n';
    String office = '\n';
    String purpose = '\n\n\n\n';

    final String pr;
    final List<String>
        stockNo; // combination of product_name_id and product_description_id
    final int requestQuantity;

    final String receivingOfficerName;
    final String receivingOfficerPosition;
    final String issuingOfficerName;
    final String issuingOfficerPosition;
    final String approvingOfficerName;
    final String approvingOfficerPosition;
    final String requestingOfficerName;
    final String requestingOfficerPosition;

    // will remove these conditions later cause we will change the way we geenerate ris
    if (data is InventoryCustodianSlipModel) {
      final ics = data;
      final purchaseRequestEntity = ics.purchaseRequestEntity;
      final receivingOfficerEntity = ics.receivingOfficerEntity;
      final issuingOfficerEntity = ics.issuingOfficerEntity;

      if (purchaseRequestEntity != null) {
        pr = purchaseRequestEntity.id;
        entityName = purchaseRequestEntity.entity.name;
        fundCluster = purchaseRequestEntity.fundCluster.toReadableString();
        rcc = purchaseRequestEntity.responsibilityCenterCode ?? '\n';
        office = purchaseRequestEntity.officeEntity.officeName;
        purpose = purchaseRequestEntity.purpose;

        approvingOfficerName =
            purchaseRequestEntity.approvingOfficerEntity.name;
        approvingOfficerPosition =
            purchaseRequestEntity.approvingOfficerEntity.positionName;
        requestingOfficerName =
            purchaseRequestEntity.requestingOfficerEntity.name;
        requestingOfficerPosition =
            purchaseRequestEntity.requestingOfficerEntity.positionName;
      } else {
        entityName = ics.entity?.name ?? '\n';
        fundCluster = ics.fundCluster!.toReadableString();

        approvingOfficerName = '\n';
        approvingOfficerPosition = '\n';
        requestingOfficerName = '\n';
        requestingOfficerPosition = '\n';
      }

      issuedItems = ics.items;

      //stockNo = data.purchaseRequestEntity.productNameEntity.id;
      //requestQuantity = data.purchaseRequestEntity.quantity;

      receivingOfficerName = receivingOfficerEntity?.name ?? 'N/A';
      receivingOfficerPosition = receivingOfficerEntity?.positionName ?? 'N/A';
      issuingOfficerName = issuingOfficerEntity?.name ?? 'N/A';
      issuingOfficerPosition = issuingOfficerEntity?.positionName ?? 'N/A';
    } else if (data is PropertyAcknowledgementReceiptModel) {
      final par = data;
      final purchaseRequestEntity = par.purchaseRequestEntity;
      final receivingOfficerEntity = par.receivingOfficerEntity;
      final issuingOfficerEntity = par.issuingOfficerEntity;

      if (purchaseRequestEntity != null) {
        pr = purchaseRequestEntity.id;
        entityName = purchaseRequestEntity.entity.name;
        fundCluster = purchaseRequestEntity.fundCluster.toReadableString();
        rcc = purchaseRequestEntity.responsibilityCenterCode ?? '\n';
        office = purchaseRequestEntity.officeEntity.officeName;
        purpose = purchaseRequestEntity.purpose;

        approvingOfficerName =
            purchaseRequestEntity.approvingOfficerEntity.name;
        approvingOfficerPosition =
            purchaseRequestEntity.approvingOfficerEntity.positionName;
        requestingOfficerName =
            purchaseRequestEntity.requestingOfficerEntity.name;
        requestingOfficerPosition =
            purchaseRequestEntity.requestingOfficerEntity.positionName;
      } else {
        entityName = par.entity?.name ?? '\n';
        fundCluster = par.fundCluster != null
            ? par.fundCluster!.toReadableString()
            : '\n';

        approvingOfficerName = '\n';
        approvingOfficerPosition = '\n';
        requestingOfficerName = '\n';
        requestingOfficerPosition = '\n';
      }

      issuedItems = par.items;

      //stockNo = data.purchaseRequestEntity.productNameEntity.id;
      //requestQuantity = data.purchaseRequestEntity.quantity;

      receivingOfficerName = receivingOfficerEntity?.name ?? 'N/A';
      receivingOfficerPosition = receivingOfficerEntity?.positionName ?? 'N\A';
      issuingOfficerName = issuingOfficerEntity?.name ?? 'N/A';
      issuingOfficerPosition = issuingOfficerEntity?.positionName ?? 'N/A';
    } else if (data is RequisitionAndIssueSlipEntity) {
      final ris = data;
      risId = ris.risId;
      print(ris);
      final purchaseRequestEntity = ris.purchaseRequestEntity;
      final receivingOfficerEntity = ris.receivingOfficerEntity;
      final issuingOfficerEntity = ris.issuingOfficerEntity;

      rcc = ris.responsibilityCenterCode ?? '\n';
      division = ris.division ?? '\n';

      if (purchaseRequestEntity != null) {
        pr = purchaseRequestEntity.id;
        entityName = purchaseRequestEntity.entity.name;
        fundCluster = purchaseRequestEntity.fundCluster.toReadableString();
        office = purchaseRequestEntity.officeEntity.officeName;
        purpose = purchaseRequestEntity.purpose;

        approvingOfficerName =
            purchaseRequestEntity.approvingOfficerEntity.name;
        approvingOfficerPosition =
            purchaseRequestEntity.approvingOfficerEntity.positionName;
        requestingOfficerName =
            purchaseRequestEntity.requestingOfficerEntity.name;
        requestingOfficerPosition =
            purchaseRequestEntity.requestingOfficerEntity.positionName;
      } else {
        final approvingOfficerEntity = ris.approvingOfficerEntity;
        final requestingOfficerEntity = ris.requestingOfficerEntity;

        entityName = ris.entity?.name ?? '\n';
        fundCluster = ris.fundCluster != null
            ? ris.fundCluster!.toReadableString()
            : '\n';
        office = ris.office?.officeName ?? '\n';
        purpose = ris.purpose ?? '\n';

        approvingOfficerName = approvingOfficerEntity?.name ?? '\n';
        approvingOfficerPosition = approvingOfficerEntity?.positionName ?? '\n';
        requestingOfficerName = requestingOfficerEntity?.name ?? '\n';
        requestingOfficerPosition =
            requestingOfficerEntity?.positionName ?? '\n';
      }

      issuedItems = ris.items;

      //stockNo = data.purchaseRequestEntity.productNameEntity.id;
      //requestQuantity = data.purchaseRequestEntity.quantity;

      receivingOfficerName = receivingOfficerEntity?.name ?? 'N/A';
      receivingOfficerPosition = receivingOfficerEntity?.positionName ?? 'N/A';
      issuingOfficerName = issuingOfficerEntity?.name ?? 'N/A';
      issuingOfficerPosition = issuingOfficerEntity?.positionName ?? 'N/A';
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
      if (issuedItem is InventoryItemEntity) {
        final equipmentItem = issuedItem as InventoryItemEntity;

        if (equipmentItem.manufacturerBrandEntity?.brand.name != null) {
          descriptionColumn.add(
              'Brand: ${equipmentItem.manufacturerBrandEntity!.brand.name}');
        }

        if (equipmentItem.modelEntity?.modelName != null) {
          descriptionColumn
              .add('Model: ${equipmentItem.modelEntity!.modelName}');
        }

        if (equipmentItem.serialNo != null) {
          descriptionColumn.add('SN: ${equipmentItem.serialNo}');
        }

        if (issuedItem.itemEntity.shareableItemInformationEntity.acquiredDate !=
            null) {
          descriptionColumn.add(
            'Date Acquired: ${documentDateFormatter(issuedItem.itemEntity.shareableItemInformationEntity.acquiredDate!)}',
          );
        }
      }

      // Add PR information
      if (data.purchaseRequestEntity != null) {
        descriptionColumn.add('PR: ${data.purchaseRequestEntity.id}');
      }

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
            stockNo: i == 0 ? '$productNameId$productDescriptionId' : '\n',
            unit: i == 0 ? unit : '\n',
            description: descriptionColumn[i],
            requestQuantity: i == 0 ? requestQuantity : '\n',
            yes: i == 0 ? '\n' : '\n',
            no: i == 0 ? '\n' : '\n',
            issueQuantity: i == 0 ? issuedQuantity : '\n',
            remarks: i == 0 ? '\n' : '\n',
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
                value: capitalizeWord(entityName),
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
                    row1Value: rcc,
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
                dataRowColumnOne: requestingOfficerName,
                dataRowColumnTwo: approvingOfficerName,
                dataRowColumnThree: issuingOfficerName,
                dataRowColumnFour: receivingOfficerName,
              ),
              DocumentComponents.buildRISFooterTableRow(
                title: 'Designation:',
                dataRowColumnOne: formatPosition(
                  '\n',
                ),
                dataRowColumnTwo: formatPosition(
                  '\n',
                ),
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
