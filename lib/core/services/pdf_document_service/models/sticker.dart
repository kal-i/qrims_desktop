import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../features/item_inventory/domain/entities/inventory_item.dart';
import '../../../../features/item_issuance/domain/entities/inventory_custodian_slip.dart';
import '../../../../features/item_issuance/domain/entities/issuance_item.dart';
import '../../../../features/item_issuance/domain/entities/property_acknowledgement_receipt.dart';
import '../../../../init_dependencies.dart';
import '../../../utils/capitalizer.dart';
import '../../../utils/currency_formatter.dart';
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
    if (data is! InventoryCustodianSlipEntity &&
        data is! PropertyAcknowledgementReceiptEntity) {
      throw ArgumentError('Unsupported data type for sticker generation');
    }

    final pdf = pw.Document();
    final itemIdTitle = data is InventoryCustodianSlipEntity
        ? 'SEMI-EXPENDABLE PROPERTY NUMBER'
        : 'PROPERTY NUMBER';
    final List<IssuanceItemEntity> items = data.items;
    final personAccountable = data.receivingOfficerEntity?.name ?? '';

    final allStickers = <pw.Widget>[];

    for (final item in items) {
      final inventoryEntity = item.itemEntity as InventoryItemEntity;
      final productStockEntity = inventoryEntity.productStockEntity;
      final shareableItemInformationEntity =
          inventoryEntity.shareableItemInformationEntity;
      final manufacturerBrandEntity = inventoryEntity.manufacturerBrandEntity;
      final modelEntity = inventoryEntity.modelEntity;

      final productName = capitalizeWord(productStockEntity.productName.name);
      final brandName = manufacturerBrandEntity?.brand.name.toUpperCase() ?? '';
      final modelName = capitalizeWord(modelEntity?.modelName ?? '');

      final itemLabel = [
        if (productName.isNotEmpty) productName,
        if (brandName.trim().isNotEmpty) brandName,
        if (modelName.trim().isNotEmpty) modelName,
      ].join(', ');

      final serialNo = inventoryEntity.serialNo ?? '';
      final assetClassification = inventoryEntity.assetClassification != null
          ? readableEnumConverter(inventoryEntity.assetClassification)
          : '';
      final unitCost = formatCurrency(shareableItemInformationEntity.unitCost);
      final itemId = shareableItemInformationEntity.id;
      final encryptedId = shareableItemInformationEntity.encryptedId;
      final fundSource = shareableItemInformationEntity.fundCluster != null
          ? shareableItemInformationEntity.fundCluster!.toReadableString()
          : '';

      final acquisitionDate =
          documentDateFormatter(shareableItemInformationEntity.acquiredDate!);

      allStickers.add(
        buildStickerWidget(
          itemIdTitle,
          itemId,
          assetClassification,
          fundSource,
          itemLabel,
          serialNo,
          unitCost,
          acquisitionDate,
          capitalizeWord(personAccountable),
          withQr ? encryptedId : null,
        ),
      );
    }

    pdf.addPage(
      pw.MultiPage(
        pageTheme: DocumentPageUtil.getPageTheme(
          pageFormat: pageFormat,
          orientation: pw.PageOrientation.portrait,
        ),
        build: (context) {
          final rows = <pw.Widget>[];

          for (int i = 0; i < allStickers.length; i += 2) {
            final row = <pw.Widget>[
              pw.Container(width: 250, child: allStickers[i]),
            ];

            if (i + 1 < allStickers.length) {
              row.add(pw.SizedBox(width: 20));
              row.add(pw.Container(width: 250, child: allStickers[i + 1]));
            }

            rows.add(
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: row,
              ),
            );

            rows.add(pw.SizedBox(height: 20));

            // Insert a page break after 3 rows (6 items)
            if (((i ~/ 2) + 1) % 3 == 0 && (i + 1) < allStickers.length) {
              rows.add(pw.NewPage());
            }
          }

          return rows;
        },
      ),
    );

    return pdf;
  }

  pw.Widget buildStickerWidget(
    String itemIdTitle,
    String itemId,
    String classification,
    String fundSource,
    String fullName,
    String serialNo,
    String cost,
    String date,
    String accountable, [
    String? encryptedId,
  ]) {
    final rowHeights = [
      DocumentService.getStickerRowHeight(
        itemId,
        fontSize: 8.0,
        cellWidth: 67.999,
      ),
      DocumentService.getRowHeight(
        classification,
        fontSize: 8.0,
        cellWidth: 165.0,
      ),
      DocumentService.getRowHeight(
        fundSource,
        fontSize: 8.0,
        cellWidth: 165.0,
      ),
      DocumentService.getStickerRowHeight(
        fullName,
        fontSize: 8.0,
        cellWidth: 67.999,
      ),
      DocumentService.getRowHeight(
        serialNo,
        fontSize: 8.0,
        cellWidth: 165.0,
      ),
      DocumentService.getRowHeight(
        cost,
        fontSize: 8.0,
        cellWidth: 165.0,
      ),
      DocumentService.getRowHeight(
        date,
        fontSize: 8.0,
        cellWidth: 165.0,
      ),
      DocumentService.getRowHeight(
        accountable,
        fontSize: 8.0,
        cellWidth: 165.0,
      ),
      DocumentService.getRowHeight(
        '\n\n',
        fontSize: 8.0,
        cellWidth: 165.0,
      ),
    ];

    return pw.Container(
      width: 225,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(width: 2),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          DocumentComponents.buildStickerHeader(),
          pw.SizedBox(height: 5),
          pw.Container(
            margin: const pw.EdgeInsets.symmetric(horizontal: 1),
            padding: const pw.EdgeInsets.all(3),
            color: PdfColors.lightBlue,
            child: pw.Text(
              'PHYSICAL PROPERTY INVENTORY',
              style: pw.TextStyle(
                font: serviceLocator<FontService>().getFont('calibriBold'),
                fontSize: 10.0,
                color: PdfColors.white,
              ),
              textAlign: pw.TextAlign.center,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Table(
            columnWidths: {
              0: const pw.FixedColumnWidth(150.0),
              1: const pw.FixedColumnWidth(165.0),
            },
            children: [
              DocumentComponents.buildStickerTableRow(
                title: itemIdTitle,
                value: itemId,
                height: rowHeights[0],
              ),
              DocumentComponents.buildStickerTableRow(
                title: 'ASSET CLASSIFICATION',
                value: classification,
                height: rowHeights[1],
                borderTop: false,
              ),
              DocumentComponents.buildStickerTableRow(
                title: 'FUND SOURCE',
                value: fundSource,
                height: rowHeights[2],
                borderTop: false,
              ),
              DocumentComponents.buildStickerTableRow(
                title: 'ITEM/BRAND/MODEL',
                value: fullName,
                height: rowHeights[3],
                borderTop: false,
              ),
              DocumentComponents.buildStickerTableRow(
                title: 'SERIAL NUMBER',
                value: serialNo,
                height: rowHeights[4],
                borderTop: false,
              ),
              DocumentComponents.buildStickerTableRow(
                title: 'ACQUISITION COST',
                value: cost,
                height: rowHeights[5],
                borderTop: false,
              ),
              DocumentComponents.buildStickerTableRow(
                title: 'ACQUISITION DATE',
                value: date,
                height: rowHeights[6],
                borderTop: false,
              ),
              DocumentComponents.buildStickerTableRow(
                title: 'PERSON ACCOUNTABLE',
                value: accountable,
                height: rowHeights[7],
                borderTop: false,
              ),
              DocumentComponents.buildStickerTableRow(
                title: 'VALIDATION/SIGNATURE',
                value: '\n',
                height: rowHeights[8],
                borderTop: false,
              ),
            ],
          ),
          // if (encryptedId != null)
          //   pw.Container(
          //     padding: const pw.EdgeInsets.all(8),
          //     alignment: pw.Alignment.bottomRight,
          //     child: DocumentComponents.buildQrContainer(data: encryptedId),
          //   ),
        ],
      ),
    );
  }
}
