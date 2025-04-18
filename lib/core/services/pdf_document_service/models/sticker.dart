import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../features/item_inventory/domain/entities/inventory_item.dart';
import '../../../../features/item_issuance/data/models/inventory_custodian_slip.dart';
import '../../../../features/item_issuance/domain/entities/inventory_custodian_slip.dart';
import '../../../../features/item_issuance/domain/entities/issuance_item.dart';
import '../../../../features/item_issuance/domain/entities/property_acknowledgement_receipt.dart';
import '../../../../init_dependencies.dart';
import '../../../utils/capitalizer.dart';
import '../../../utils/document_date_formatter.dart';
import '../../../utils/fund_cluster_to_readable_string.dart';
import '../../../utils/readable_enum_converter.dart';
import '../document_service.dart';
import '../font_service.dart';
import '../utils/document_components.dart';
import '../utils/document_page_util.dart';
import 'base_document.dart';

class Sticker implements BaseDocument {
  @override
  Future<pw.Document> generate({
    required PdfPageFormat pageFormat,
    required data,
    required bool withQr,
  }) async {
    final pdf = pw.Document();

    final List<IssuanceItemEntity> items;
    final List<String> mappableData = [];

    final String fundSource;
    final String acquisitionDate;
    final String personAccountable;

    if (data is InventoryCustodianSlipEntity) {
      items = data.items;
      fundSource = data.purchaseRequestEntity?.fundCluster.toReadableString() ??
          data.fundCluster!.toReadableString();
      personAccountable = data.receivingOfficerEntity?.name ?? '';
      acquisitionDate = documentDateFormatter(data.issuedDate);
    } else if (data is PropertyAcknowledgementReceiptEntity) {
      items = data.items;
      fundSource = data.purchaseRequestEntity?.fundCluster.toReadableString() ??
          data.fundCluster!.toReadableString();
      personAccountable = data.receivingOfficerEntity?.name ?? '';
      acquisitionDate = documentDateFormatter(data.issuedDate);
    } else {
      throw ArgumentError('Unsupported data type for RIS generation');
    }

    for (int i = 0; i < items.length; i++) {
      final equipmentEntity = items[i].itemEntity as InventoryItemEntity;
      final productStockEntity = equipmentEntity.productStockEntity;
      final shareableItemInformationEntity =
          equipmentEntity.shareableItemInformationEntity;
      final manufacturerBrandEntity = equipmentEntity.manufacturerBrandEntity;
      final modelEntity = equipmentEntity.modelEntity;

      final productNameEntity = productStockEntity.productName;
      final productName = productNameEntity.name;

      final brandEntity = manufacturerBrandEntity?.brand;
      final brandName = brandEntity?.name ?? 'N/A';

      final encryptedId = shareableItemInformationEntity.encryptedId;
      final baseItemId = shareableItemInformationEntity.id;
      final modelName = modelEntity?.modelName ?? 'N/A';

      final serialNo = equipmentEntity.serialNo;
      final assetClassification =
          readableEnumConverter(equipmentEntity.assetClassification);
      final unitCost = shareableItemInformationEntity.unitCost;

      mappableData.addAll([
        '\n$baseItemId',
        readableEnumConverter(assetClassification),
        fundSource,
        '$productName/ $brandName/ $modelName'.toUpperCase(),
        serialNo ?? 'N/A',
        unitCost.toString(),
        acquisitionDate,
        capitalizeWord(personAccountable),
      ]);

      final rowHeights = mappableData.map((row) {
        return DocumentService.getRowHeight(row, fontSize: 8.5);
      }).toList();

      pdf.addPage(
        pw.Page(
          pageTheme: DocumentPageUtil.getPageTheme(
            pageFormat: pageFormat,
            orientation: pw.PageOrientation.portrait,
            marginTop: 1.9,
            marginRight: 1.2,
            marginBottom: 0.8,
            marginLeft: 0.9,
          ),
          build: (context) => DocumentComponents.buildContainer(
            width: 225.0,
            borderTop: false,
            borderRight: false,
            borderBottom: false,
            borderLeft: false,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                DocumentComponents.buildContainer(
                  borderWidthTop: 2.0,
                  borderWidthRight: 2.0,
                  borderWidthBottom: 2.0,
                  borderWidthLeft: 0.0,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                    children: [
                      DocumentComponents.buildStickerHeader(),
                      pw.SizedBox(
                        height: 5.0,
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(3.0),
                        color: PdfColors.lightBlue,
                        child: pw.Text(
                          'PHYSICAL PROPERTY INVENTORY',
                          style: pw.TextStyle(
                            font: serviceLocator<FontService>()
                                .getFont('calibriBold'),
                            fontSize: 12.0,
                            color: PdfColors.white,
                            //fontWeight: pw.FontWeight.bold,
                          ),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                      pw.SizedBox(
                        height: 10.0,
                      ),
                    ],
                  ),
                ),
                pw.Table(
                  columnWidths: {
                    0: const pw.FixedColumnWidth(150.0),
                    1: const pw.FixedColumnWidth(165.0),
                  },
                  children: [
                    DocumentComponents.buildStickerTableRow(
                      title: data is InventoryCustodianSlipModel
                          ? 'SEMI-EXPENDABLE \nPROPERTY NUMBER'
                          : '\nPROPERTY NUMBER',
                      value: mappableData[i * 8 + 0],
                      height: rowHeights[i * 8 + 0],
                    ),
                    DocumentComponents.buildStickerTableRow(
                      title: 'ASSET CLASSIFICATION',
                      value: mappableData[i * 8 + 1],
                      height: rowHeights[i * 8 + 1],
                      borderTop: false,
                    ),
                    DocumentComponents.buildStickerTableRow(
                      title: 'FUND SOURCE',
                      value: mappableData[i * 8 + 2],
                      height: rowHeights[i * 8 + 2],
                      borderTop: false,
                    ),
                    DocumentComponents.buildStickerTableRow(
                      title: 'ITEM/BRAND/MODEL',
                      value: mappableData[i * 8 + 3],
                      height: rowHeights[i * 8 + 3],
                      borderTop: false,
                    ),
                    DocumentComponents.buildStickerTableRow(
                      title: 'SERIAL NUMBER',
                      value: mappableData[i * 8 + 4],
                      height: rowHeights[i * 8 + 4],
                      borderTop: false,
                    ),
                    DocumentComponents.buildStickerTableRow(
                      title: 'ACQUISITION COST',
                      value: mappableData[i * 8 + 5],
                      height: rowHeights[i * 8 + 5],
                      borderTop: false,
                    ),
                    DocumentComponents.buildStickerTableRow(
                      title: 'ACQUISITION DATE',
                      value: mappableData[i * 8 + 6],
                      height: rowHeights[i * 8 + 6],
                      borderTop: false,
                    ),
                    DocumentComponents.buildStickerTableRow(
                      title: 'PERSON ACCOUNTABLE',
                      value: mappableData[i * 8 + 7],
                      height: rowHeights[i * 8 + 7],
                      borderTop: false,
                    ),
                    DocumentComponents.buildStickerTableRow(
                      title: '\nVALIDATION/SIGNATURE',
                      value: '\n\n', // This row doesn't depend on the list
                      height: rowHeights[i],
                      borderTop: false,
                    ),
                  ],
                ),
                // if (withQr)
                //   DocumentComponents.buildContainer(
                //     horizontalPadding: 10.0,
                //     verticalPadding: 10.0,
                //     borderTop: false,
                //     borderWidthRight: 2.0,
                //     borderWidthBottom: 2.0,
                //     borderWidthLeft: 2.0,
                //     child: pw.Align(
                //       alignment: pw.AlignmentDirectional.bottomEnd,
                //       child: DocumentComponents.buildQrContainer(
                //         data: encryptedId,
                //       ),
                //     ),
                //   ),
              ],
            ),
          ),
        ),
      );
    }

    return pdf;
  }
}
