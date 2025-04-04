import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../features/item_inventory/domain/entities/equipment.dart';
import '../../../../features/item_issuance/domain/entities/property_acknowledgement_receipt.dart';
import '../../../../init_dependencies.dart';
import '../../../utils/capitalizer.dart';
import '../../../utils/document_date_formatter.dart';
import '../../../utils/extract_specification.dart';
import '../../../utils/fund_cluster_to_readable_string.dart';
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
    print(par.issuingOfficerEntity);
    final purchaseRequestEntity = data.purchaseRequestEntity;

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

    // Loop through each item to generate rows
    for (final issuedItem in par.items) {
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
      if (purchaseRequestEntity != null) {
        descriptionColumn.add('PR: ${purchaseRequestEntity.id}');
      }

      // Calculate row heights for description
      final rowHeights = descriptionColumn.map((row) {
        return DocumentService.getRowHeight(row, fontSize: 8.5);
      }).toList();

      // Add rows for this item
      for (int i = 0; i < descriptionColumn.length; i++) {
        tableRows.add(
          DocumentComponents.buildParTableRow(
            quantity: i == 0 ? issuedItem.quantity.toString() : '\n',
            unit: i == 0
                ? readableEnumConverter(
                    issuedItem.itemEntity.shareableItemInformationEntity.unit)
                : '\n',
            description: descriptionColumn[i],
            propertyNumber: i == 0
                ? issuedItem.itemEntity.shareableItemInformationEntity.id
                : '\n',
            dateAcquired: i == 0
                ? issuedItem is EquipmentEntity
                    ? documentDateFormatter(issuedItem.itemEntity
                        .shareableItemInformationEntity.acquiredDate!)
                    : '\n'
                : '\n',
            amount: i == 0
                ? issuedItem.itemEntity.shareableItemInformationEntity.unitCost
                    .toString()
                : '\n',
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
                value: data.parId,
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
}
