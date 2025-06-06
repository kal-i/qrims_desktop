import 'package:excel/excel.dart';

import '../../../../features/item_inventory/domain/entities/inventory_item.dart';
import '../../../../features/item_issuance/domain/entities/inventory_custodian_slip.dart';
import '../../../../features/item_issuance/domain/entities/issuance_item.dart';
import '../../../utils/capitalizer.dart';
import '../../../utils/currency_formatter.dart';
import '../../../utils/document_date_formatter.dart';
import '../../../utils/fund_cluster_to_readable_string.dart';
import '../../../utils/generate_compression_key.dart';
import '../../../utils/get_position_at.dart';
import '../../../utils/group_specification_by_section.dart';
import '../../../utils/readable_enum_converter.dart';
import 'cell_info.dart';
import 'header_info.dart';

class ICSExcelDocument {
  static void modifyAndMapData(Sheet sheet, dynamic data) {
    final ics = data as InventoryCustodianSlipEntity;
    final issuingOfficerPositionHistory =
        ics.issuingOfficerEntity?.getPositionAt(
      ics.issuedDate,
    );
    final receivingOfficerPositonHistory =
        ics.receivingOfficerEntity?.getPositionAt(
      ics.issuedDate,
    );

    final generalCellStyle = sheet
        .cell(
          CellIndex.indexByString('C13'),
        )
        .cellStyle;

    final startHeaderTopCell = CellIndex.indexByColumnRow(
      columnIndex: 0,
      rowIndex: 0,
    );
    final endHeaderTopCell = CellIndex.indexByColumnRow(
      columnIndex: 8,
      rowIndex: 0,
    );
    for (int col = startHeaderTopCell.columnIndex;
        col <= endHeaderTopCell.columnIndex;
        col++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(
          columnIndex: col,
          rowIndex: 0,
        ),
      );
      cell.cellStyle = CellStyle(
        topBorder: Border(
          borderStyle: BorderStyle.Medium,
          borderColorHex: ExcelColor.white,
        ),
      );
    }

    final entityCell = sheet.cell(
      CellIndex.indexByString('B13'),
    );
    entityCell.value = TextCellValue(
      'Entity Name: ${ics.purchaseRequestEntity != null ? ics.purchaseRequestEntity!.entity.name.toUpperCase() : ics.entity?.name.toUpperCase() ?? ''}',
    );
    entityCell.cellStyle = generalCellStyle;

    final fundClusterCell = sheet.cell(
      CellIndex.indexByString('B14'),
    );
    fundClusterCell.value = TextCellValue(
        'Fund Cluster: ${ics.purchaseRequestEntity != null ? capitalizeWord(ics.purchaseRequestEntity!.fundCluster.toReadableString()) : capitalizeWord(ics.fundCluster?.toReadableString() ?? '')}');
    fundClusterCell.cellStyle = generalCellStyle?.copyWith(
      textWrappingVal: TextWrapping.Clip,
    );

    final icsNoCell = sheet.cell(
      CellIndex.indexByString('G14'),
    );
    icsNoCell.value = TextCellValue(
      'ICS No.: ${ics.icsId}',
    );
    icsNoCell.cellStyle = generalCellStyle;

    // Define the border style
    final borderStyle = Border(borderStyle: BorderStyle.Medium);

    // Apply headers and styles
    _applyHeadersAndStyles(sheet, borderStyle, generalCellStyle);

    int totalRowsInserted = _mapDataToCells(
      sheet,
      ics,
      generalCellStyle,
    );

    _addFooter(
      sheet,
      17 + totalRowsInserted + 1,
      ics.issuingOfficerEntity?.name ?? '',
      issuingOfficerPositionHistory?.positionName ??
          ics.issuingOfficerEntity?.positionName ??
          '',
      issuingOfficerPositionHistory?.officeName ??
          ics.issuingOfficerEntity?.officeName ??
          '',
      ics.issuedDate,
      ics.receivingOfficerEntity?.name ?? '',
      receivingOfficerPositonHistory?.positionName ??
          ics.receivingOfficerEntity?.positionName ??
          '',
      receivingOfficerPositonHistory?.officeName ??
          ics.receivingOfficerEntity?.officeName ??
          '',
      ics.receivedDate,
      generalCellStyle,
    );

    final startHeaderRightCell = CellIndex.indexByColumnRow(
      columnIndex: 8,
      rowIndex: 0,
    );
    final endHeaderRightCell = CellIndex.indexByColumnRow(
      columnIndex: 8,
      rowIndex: 14 + totalRowsInserted + 13,
    );
    for (int row = startHeaderRightCell.rowIndex;
        row <= endHeaderRightCell.rowIndex;
        row++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(
          columnIndex: 8,
          rowIndex: row,
        ),
      );
      cell.cellStyle = CellStyle(
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
        topBorder: row == 0
            ? Border(
                borderStyle: BorderStyle.Medium,
                borderColorHex: ExcelColor.white,
              )
            : null,
        rightBorder: Border(
          borderStyle: BorderStyle.Medium,
          borderColorHex: ExcelColor.white,
        ),
      );
    }

    final startHeaderLeftCell = CellIndex.indexByColumnRow(
      columnIndex: 0,
      rowIndex: 0,
    );
    final endHeaderLeftCell = CellIndex.indexByColumnRow(
      columnIndex: 0,
      rowIndex: 14 + totalRowsInserted + 13,
    );
    for (int row = startHeaderLeftCell.rowIndex;
        row <= endHeaderLeftCell.rowIndex;
        row++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(
          columnIndex: 0,
          rowIndex: row,
        ),
      );
      cell.cellStyle = generalCellStyle?.copyWith(
        topBorderVal: row == 0
            ? Border(
                borderStyle: BorderStyle.Medium,
                borderColorHex: ExcelColor.white,
              )
            : null,
        rightBorderVal: row == endHeaderLeftCell.rowIndex
            ? Border(
                borderStyle: BorderStyle.Medium,
                //borderColorHex: ExcelColor.white,
              )
            : null,
        bottomBorderVal: row == endHeaderLeftCell.rowIndex
            ? Border(
                borderStyle: BorderStyle.Medium,
                borderColorHex: ExcelColor.white,
              )
            : null,
        leftBorderVal: Border(
          borderStyle: BorderStyle.Medium,
          borderColorHex: ExcelColor.white,
        ),
      );
    }

    final headerBottomCellRowIndex = 14 + totalRowsInserted + 13;
    final startHeaderBottomCell = CellIndex.indexByColumnRow(
      columnIndex: 0,
      rowIndex: headerBottomCellRowIndex,
    );
    final endHeaderBottomCell = CellIndex.indexByColumnRow(
      columnIndex: 8,
      rowIndex: headerBottomCellRowIndex,
    );
    for (int col = startHeaderBottomCell.columnIndex;
        col <= endHeaderBottomCell.columnIndex;
        col++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(
          columnIndex: col,
          rowIndex: headerBottomCellRowIndex,
        ),
      );
      cell.cellStyle = CellStyle(
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
        rightBorder: Border(
          borderStyle: BorderStyle.Medium,
          borderColorHex: ExcelColor.white,
        ),
        bottomBorder: Border(
          borderStyle: BorderStyle.Medium,
          borderColorHex: ExcelColor.white,
        ),
        leftBorder: Border(
          borderStyle: BorderStyle.Medium,
          borderColorHex: ExcelColor.white,
        ),
      );
    }
  }

  static void _applyHeadersAndStyles(
      Sheet sheet, Border borderStyle, CellStyle? cellStyle) {
    final headers = [
      const HeaderInfo('B16', 'B18', 'Quantity'),
      const HeaderInfo('C16', 'C18', 'Unit'),
      const HeaderInfo('D16', 'E16', 'Quantity'),
      const HeaderInfo('D17', 'D18', 'Unit Cost'),
      const HeaderInfo('E17', 'E18', 'Total Cost'),
      const HeaderInfo('F16', 'F18', 'Description'),
      const HeaderInfo('G16', 'G18', 'Inventory Item No.'),
      const HeaderInfo('H16', 'H18', 'Estimated Useful Life'),
    ];

    for (var header in headers) {
      final startCellIndex = CellIndex.indexByString(header.startCell);
      final endCellIndex = CellIndex.indexByString(header.endCell);

      final startCell = sheet.cell(startCellIndex);
      startCell.value = TextCellValue(header.title);
      startCell.cellStyle = cellStyle;

      if (header.startCell != header.endCell) {
        sheet.merge(startCellIndex, endCellIndex);

        // Extract column and row numbers
        final startColumn = startCellIndex.columnIndex;
        final endColumn = endCellIndex.columnIndex;
        final startRow = startCellIndex.rowIndex;
        final endRow = endCellIndex.rowIndex;

        // Apply border to all cells within the merged range
        for (var row = startRow; row <= endRow; row++) {
          for (var col = startColumn; col <= endColumn; col++) {
            final cell = sheet.cell(
                CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row));
            cell.cellStyle = cellStyle?.copyWith(
              horizontalAlignVal: HorizontalAlign.Center,
              verticalAlignVal: VerticalAlign.Center,
              topBorderVal: borderStyle,
              rightBorderVal: borderStyle,
              leftBorderVal: borderStyle,
            );
          }
        }
      }
    }
  }

  static int _mapDataToCells(
    Sheet sheet,
    InventoryCustodianSlipEntity ics,
    CellStyle? cellStyle,
  ) {
    int startRow = 18;
    int totalRowsInserted = 0;
    int currentRow = startRow;

    final purchaseRequestEntity = ics.purchaseRequestEntity;
    final supplierEntity = ics.supplierEntity;
    final compressedItems = <String, List<IssuanceItemEntity>>{};

    for (var item in ics.items) {
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
      final totalCost = unitCost * totalQuantity;
      final estimatedUsefulLife =
          (representative.itemEntity as InventoryItemEntity)
              .estimatedUsefulLife;

      final dataCellStyle = cellStyle?.copyWith(
        horizontalAlignVal: HorizontalAlign.Center,
        verticalAlignVal: VerticalAlign.Center,
        topBorderVal: Border(borderStyle: BorderStyle.Thin),
        rightBorderVal: Border(borderStyle: BorderStyle.Medium),
        bottomBorderVal: Border(borderStyle: BorderStyle.Thin),
        leftBorderVal: Border(borderStyle: BorderStyle.Medium),
        textWrappingVal: TextWrapping.WrapText,
      );

      for (int j = 0; j < descriptionColumn.length; j++) {
        // For every row after the first, insert a new row
        if (!(i == 0 && j == 0)) {
          sheet.insertRow(currentRow);
          totalRowsInserted++;
        }
        _updateRow(
          sheet,
          currentRow,
          j == 0 ? totalQuantity.toString() : '',
          j == 0 ? readableEnumConverter(unit) : '',
          j == 0 ? formatCurrency(unitCost) : '',
          j == 0 ? formatCurrency(totalCost) : '',
          descriptionColumn[j],
          j == 0 ? baseItemId : '',
          j == 0 ? estimatedUsefulLife : null,
          dataCellStyle,
        );
        currentRow++;
      }

      if (i == itemGroups.length - 1) {
        if (purchaseRequestEntity != null ||
            supplierEntity != null ||
            ics.inspectionAndAcceptanceReportId != null ||
            ics.contractNumber != null ||
            ics.purchaseOrderNumber != null) {
          sheet.insertRow(currentRow);
          _updateRowFooter(
            sheet: sheet,
            index: currentRow,
            dataCellStyle: dataCellStyle,
          );
          totalRowsInserted++;
          currentRow++;
        }

        if (purchaseRequestEntity != null || ics.prReferenceId != null) {
          final prValue = purchaseRequestEntity?.id ?? ics.prReferenceId;
          sheet.insertRow(currentRow);
          _updateRowFooter(
            sheet: sheet,
            index: currentRow,
            data: 'PR: $prValue',
            dataCellStyle: dataCellStyle,
          );
          totalRowsInserted++;
          currentRow++;
        }

        if (ics.purchaseOrderNumber != null) {
          sheet.insertRow(currentRow);
          _updateRowFooter(
            sheet: sheet,
            index: currentRow,
            data: 'PO: ${ics.purchaseOrderNumber}',
            dataCellStyle: dataCellStyle,
          );
          totalRowsInserted++;
          currentRow++;
        }

        if (supplierEntity != null) {
          sheet.insertRow(currentRow);
          _updateRowFooter(
            sheet: sheet,
            index: currentRow,
            data: 'Supplier: ${supplierEntity.name}',
            dataCellStyle: dataCellStyle,
          );
          totalRowsInserted++;
          currentRow++;
        }

        if (ics.deliveryReceiptId != null) {
          sheet.insertRow(currentRow);
          _updateRowFooter(
            sheet: sheet,
            index: currentRow,
            data: 'DR: ${ics.deliveryReceiptId}',
            dataCellStyle: dataCellStyle,
          );
          totalRowsInserted++;
          currentRow++;
        }

        if (ics.dateAcquired != null) {
          sheet.insertRow(currentRow);
          _updateRowFooter(
            sheet: sheet,
            index: currentRow,
            data: 'Date Acquired: ${documentDateFormatter(ics.dateAcquired!)}',
            dataCellStyle: dataCellStyle,
          );
          totalRowsInserted++;
          currentRow++;
        }

        if (ics.inventoryTransferReportId != null) {
          sheet.insertRow(currentRow);
          _updateRowFooter(
            sheet: sheet,
            index: currentRow,
            data: 'ITR: ${ics.inventoryTransferReportId}',
            dataCellStyle: dataCellStyle,
          );
          totalRowsInserted++;
          currentRow++;
        }

        if (ics.inspectionAndAcceptanceReportId != null) {
          sheet.insertRow(currentRow);
          _updateRowFooter(
            sheet: sheet,
            index: currentRow,
            data: 'IAR: ${ics.inspectionAndAcceptanceReportId}',
            dataCellStyle: dataCellStyle,
          );
          totalRowsInserted++;
          currentRow++;
        }

        if (ics.contractNumber != null) {
          sheet.insertRow(currentRow);
          _updateRowFooter(
            sheet: sheet,
            index: currentRow,
            data: 'CN: ${ics.contractNumber}',
            dataCellStyle: dataCellStyle,
          );
          totalRowsInserted++;
          currentRow++;
        }
      }
    }
    return totalRowsInserted;
  }

  static void _updateRow(
    Sheet sheet,
    int rowIndex,
    String quantity,
    String unit,
    String unitCost,
    String totalCost,
    String description,
    String inventoryItemNo,
    int? estimatedUsefulLife,
    CellStyle? cellStyle,
  ) {
    final cells = [
      CellInfo(
        1,
        quantity,
      ),
      CellInfo(
        2,
        unit,
      ),
      CellInfo(
        3,
        unitCost,
      ),
      CellInfo(
        4,
        totalCost,
      ),
      CellInfo(
        5,
        description,
      ),
      CellInfo(
        6,
        inventoryItemNo,
      ),
      CellInfo(
        7,
        estimatedUsefulLife != null
            ? estimatedUsefulLife > 1
                ? '$estimatedUsefulLife years'
                : '$estimatedUsefulLife year'
            : '',
      ),
    ];

    for (var cellInfo in cells) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(
          columnIndex: cellInfo.columnIndex,
          rowIndex: rowIndex,
        ),
      );
      cell.value = TextCellValue(cellInfo.value);

      cell.cellStyle = cellStyle;
    }
  }

  static void _addFooter(
    Sheet sheet,
    int footerStartRow,
    String issuingOfficerName,
    String issuingOfficerPosition,
    String issuingOfficerOffice,
    DateTime issuedDate,
    String receivingOfficerName,
    String receivingOfficerPosition,
    String receivingOfficerOffice,
    DateTime? receivedDate,
    CellStyle? cellStyle,
  ) {
    int startingRow = footerStartRow + 3;

    /**
     * Iterate through each cell, setting a styling
     */
    final startFooterCell = CellIndex.indexByColumnRow(
      columnIndex: 1,
      rowIndex: footerStartRow + 1,
    );
    final endFooterCell = CellIndex.indexByColumnRow(
      columnIndex: 7,
      rowIndex: footerStartRow + 1,
    );

    for (int col = startFooterCell.columnIndex;
        col < endFooterCell.columnIndex;
        col++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(
          columnIndex: col,
          rowIndex: footerStartRow + 1,
        ),
      );
      cell.cellStyle = cellStyle?.copyWith(
        horizontalAlignVal: HorizontalAlign.Center,
        verticalAlignVal: VerticalAlign.Center,
        topBorderVal: Border(
          borderStyle: BorderStyle.Medium,
        ),
      );
    }

    /**
     * Mapped data and set a style for Received From cell
     */
    final startReceivedFromCell = CellIndex.indexByColumnRow(
      columnIndex: 1,
      rowIndex: footerStartRow + 1,
    );
    final receivedFromCell = sheet.cell(
      startReceivedFromCell,
    );
    receivedFromCell.value = TextCellValue(
      'Received from:',
    );
    receivedFromCell.cellStyle = cellStyle?.copyWith(
      topBorderVal: Border(
        borderStyle: BorderStyle.Medium,
      ),
      leftBorderVal: Border(
        borderStyle: BorderStyle.Medium,
      ),
    );

    /**
     * Merged Issuing Officer Name cells, mapped data and set a style
     */
    final startIssuingOfficerNameCell = CellIndex.indexByColumnRow(
      columnIndex: 1,
      rowIndex: startingRow,
    );
    final endIssuingOfficerNameCell = CellIndex.indexByColumnRow(
      columnIndex: 5,
      rowIndex: startingRow,
    );
    sheet.merge(
      startIssuingOfficerNameCell,
      endIssuingOfficerNameCell,
    );
    final issuingOfficerNameCell = sheet.cell(
      startIssuingOfficerNameCell,
    );
    issuingOfficerNameCell.value = TextCellValue(
      capitalizeWord(issuingOfficerName),
    );
    issuingOfficerNameCell.cellStyle = cellStyle?.copyWith(
      horizontalAlignVal: HorizontalAlign.Center,
      verticalAlignVal: VerticalAlign.Center,
      leftBorderVal: Border(
        borderStyle: BorderStyle.Medium,
      ),
    );

    /**
     * Merged Issuing Officer Name Description cells, mapped data and set a style
     */
    final startingIssuingOfficerNameDescriptionCell =
        CellIndex.indexByColumnRow(
      columnIndex: 1,
      rowIndex: startingRow + 1,
    );
    final endingIssuingOfficerNameDescriptionCell = CellIndex.indexByColumnRow(
      columnIndex: 5,
      rowIndex: startingRow + 1,
    );
    sheet.merge(
      startingIssuingOfficerNameDescriptionCell,
      endingIssuingOfficerNameDescriptionCell,
    );
    final issuingOfficerPositionCell = sheet.cell(
      startingIssuingOfficerNameDescriptionCell,
    );
    issuingOfficerPositionCell.value = TextCellValue(
      'Signarature over Printed Name',
    );
    issuingOfficerPositionCell.cellStyle = cellStyle?.copyWith(
      horizontalAlignVal: HorizontalAlign.Center,
      verticalAlignVal: VerticalAlign.Center,
      leftBorderVal: Border(
        borderStyle: BorderStyle.Medium,
      ),
    );

    /**
     * Merged Issuing Officer Position Name Description cells, mapped data and set a style
     */
    final startIssuingOfficerPositionNameCell = CellIndex.indexByColumnRow(
      columnIndex: 1,
      rowIndex: startingRow + 2,
    );
    final endIssuingOfficerPositionNameCell = CellIndex.indexByColumnRow(
      columnIndex: 5,
      rowIndex: startingRow + 2,
    );
    sheet.merge(
      startIssuingOfficerPositionNameCell,
      endIssuingOfficerPositionNameCell,
    );
    final issuingOfficerPositionNameCell = sheet.cell(
      startIssuingOfficerPositionNameCell,
    );
    issuingOfficerPositionNameCell.value = TextCellValue(
      '${issuingOfficerPosition.toUpperCase()} - ${issuingOfficerOffice.toUpperCase()}',
    );
    issuingOfficerPositionNameCell.cellStyle = cellStyle?.copyWith(
      horizontalAlignVal: HorizontalAlign.Center,
      verticalAlignVal: VerticalAlign.Center,
      leftBorderVal: Border(
        borderStyle: BorderStyle.Medium,
      ),
    );

    /**
     * Merged Issuing Officer Position Description cells, mapped data and set a style
     */
    final startIssuingOfficerPositionDescriptionCell =
        CellIndex.indexByColumnRow(
      columnIndex: 1,
      rowIndex: startingRow + 3,
    );
    final endIssuingOfficerPositionDescriptionCell = CellIndex.indexByColumnRow(
      columnIndex: 5,
      rowIndex: startingRow + 3,
    );
    sheet.merge(
      startIssuingOfficerPositionDescriptionCell,
      endIssuingOfficerPositionDescriptionCell,
    );
    final issuingOfficerPositionDescriptionCell = sheet.cell(
      startIssuingOfficerPositionDescriptionCell,
    );
    issuingOfficerPositionDescriptionCell.value = TextCellValue(
      'Position/Office',
    );
    issuingOfficerPositionDescriptionCell.cellStyle = cellStyle?.copyWith(
      horizontalAlignVal: HorizontalAlign.Center,
      verticalAlignVal: VerticalAlign.Center,
      leftBorderVal: Border(
        borderStyle: BorderStyle.Medium,
      ),
    );

    /**
     * Merged Issued Date cells, mapped data and set a style
     */
    final startIssuedDateCell = CellIndex.indexByColumnRow(
      columnIndex: 1,
      rowIndex: startingRow + 4,
    );
    final endIssuedDateCell = CellIndex.indexByColumnRow(
      columnIndex: 5,
      rowIndex: startingRow + 4,
    );
    sheet.merge(
      startIssuedDateCell,
      endIssuedDateCell,
    );
    final issuedDateCell = sheet.cell(
      startIssuedDateCell,
    );
    issuedDateCell.value = TextCellValue(
      documentDateFormatter(issuedDate),
    );
    issuedDateCell.cellStyle = cellStyle?.copyWith(
      horizontalAlignVal: HorizontalAlign.Center,
      verticalAlignVal: VerticalAlign.Center,
      leftBorderVal: Border(
        borderStyle: BorderStyle.Medium,
      ),
    );

    /**
     * Merged Issued Date Description cells, mapped data and set a style
     */
    final startIssuedDateDescriptionCell = CellIndex.indexByColumnRow(
      columnIndex: 1,
      rowIndex: startingRow + 5,
    );
    final endIssuedDateDescriptionCell = CellIndex.indexByColumnRow(
      columnIndex: 5,
      rowIndex: startingRow + 5,
    );
    sheet.merge(
      startIssuedDateDescriptionCell,
      endIssuedDateDescriptionCell,
    );
    final issuedDateDescriptionCell = sheet.cell(
      startIssuedDateDescriptionCell,
    );
    issuedDateDescriptionCell.value = TextCellValue(
      'Date',
    );
    issuedDateDescriptionCell.cellStyle = cellStyle?.copyWith(
      horizontalAlignVal: HorizontalAlign.Center,
      verticalAlignVal: VerticalAlign.Center,
      leftBorderVal: Border(
        borderStyle: BorderStyle.Medium,
      ),
    );

    /**
     * Mapped data and set a style for Received By cell
     */
    final startReceivedByCell = CellIndex.indexByColumnRow(
      columnIndex: 6,
      rowIndex: footerStartRow + 1,
    );
    final receivedByCell = sheet.cell(
      startReceivedByCell,
    );
    receivedByCell.value = TextCellValue(
      'Received by:',
    );
    receivedByCell.cellStyle = cellStyle?.copyWith(
      topBorderVal: Border(
        borderStyle: BorderStyle.Medium,
      ),
      leftBorderVal: Border(
        borderStyle: BorderStyle.Medium,
      ),
    );

    /**
     * Merged Receiving Officer Name cells, mapped data and set a style
     */
    final startReceivingOfficerNameCell = CellIndex.indexByColumnRow(
      columnIndex: 6,
      rowIndex: startingRow,
    );
    final endReceivingOfficerNameCell = CellIndex.indexByColumnRow(
      columnIndex: 7,
      rowIndex: startingRow,
    );
    sheet.merge(
      startReceivingOfficerNameCell,
      endReceivingOfficerNameCell,
    );
    final receivingOfficerNameCell = sheet.cell(
      startReceivingOfficerNameCell,
    );
    receivingOfficerNameCell.value = TextCellValue(
      capitalizeWord(receivingOfficerName),
    );
    receivingOfficerNameCell.cellStyle = cellStyle?.copyWith(
      horizontalAlignVal: HorizontalAlign.Center,
      verticalAlignVal: VerticalAlign.Center,
      leftBorderVal: Border(
        borderStyle: BorderStyle.Medium,
      ),
    );
    sheet.cell(endReceivingOfficerNameCell).cellStyle = cellStyle?.copyWith(
      rightBorderVal: Border(
        borderStyle: BorderStyle.Medium,
      ),
    );

    /**
     * Merged Receiving Officer Name Description cells, mapped data and set a style
     */
    final startingReceivingOfficerNameDescriptionCell =
        CellIndex.indexByColumnRow(
      columnIndex: 6,
      rowIndex: startingRow + 1,
    );
    final endingReceivingOfficerNameDescriptionCell =
        CellIndex.indexByColumnRow(
      columnIndex: 7,
      rowIndex: startingRow + 1,
    );
    sheet.merge(
      startingReceivingOfficerNameDescriptionCell,
      endingReceivingOfficerNameDescriptionCell,
    );
    final receivingOfficerPositionCell = sheet.cell(
      startingReceivingOfficerNameDescriptionCell,
    );
    receivingOfficerPositionCell.value = TextCellValue(
      'Signarature over Printed Name',
    );
    receivingOfficerPositionCell.cellStyle = cellStyle?.copyWith(
      horizontalAlignVal: HorizontalAlign.Center,
      verticalAlignVal: VerticalAlign.Center,
      leftBorderVal: Border(
        borderStyle: BorderStyle.Medium,
      ),
    );
    sheet.cell(endingReceivingOfficerNameDescriptionCell).cellStyle =
        cellStyle?.copyWith(
      rightBorderVal: Border(
        borderStyle: BorderStyle.Medium,
      ),
    );

    /**
     * Merged Receiving Officer Position Name Description cells, mapped data and set a style
     */
    final startReceivingOfficerPositionNameCell = CellIndex.indexByColumnRow(
      columnIndex: 6,
      rowIndex: startingRow + 2,
    );
    final endReceivingOfficerPositionNameCell = CellIndex.indexByColumnRow(
      columnIndex: 7,
      rowIndex: startingRow + 2,
    );
    sheet.merge(
      startReceivingOfficerPositionNameCell,
      endReceivingOfficerPositionNameCell,
    );
    final receivingOfficerPositionNameCell = sheet.cell(
      startReceivingOfficerPositionNameCell,
    );
    receivingOfficerPositionNameCell.value = TextCellValue(
      '${receivingOfficerPosition.toUpperCase()} - ${receivingOfficerOffice.toUpperCase()}',
    );
    receivingOfficerPositionNameCell.cellStyle = cellStyle?.copyWith(
      horizontalAlignVal: HorizontalAlign.Center,
      verticalAlignVal: VerticalAlign.Center,
      leftBorderVal: Border(
        borderStyle: BorderStyle.Medium,
      ),
    );
    sheet.cell(endReceivingOfficerPositionNameCell).cellStyle =
        cellStyle?.copyWith(
      rightBorderVal: Border(
        borderStyle: BorderStyle.Medium,
      ),
    );

    /**
     * Merged Receiving Officer Position Description cells, mapped data and set a style
     */
    final startReceivingOfficerPositionDescriptionCell =
        CellIndex.indexByColumnRow(
      columnIndex: 6,
      rowIndex: startingRow + 3,
    );
    final endReceivingOfficerPositionDescriptionCell =
        CellIndex.indexByColumnRow(
      columnIndex: 7,
      rowIndex: startingRow + 3,
    );
    sheet.merge(
      startReceivingOfficerPositionDescriptionCell,
      endReceivingOfficerPositionDescriptionCell,
    );
    final receivingOfficerPositionDescriptionCell = sheet.cell(
      startReceivingOfficerPositionDescriptionCell,
    );
    receivingOfficerPositionDescriptionCell.value = TextCellValue(
      'Position/Office',
    );
    receivingOfficerPositionDescriptionCell.cellStyle = cellStyle?.copyWith(
      horizontalAlignVal: HorizontalAlign.Center,
      verticalAlignVal: VerticalAlign.Center,
      leftBorderVal: Border(
        borderStyle: BorderStyle.Medium,
      ),
    );
    sheet.cell(endReceivingOfficerPositionDescriptionCell).cellStyle =
        cellStyle?.copyWith(
      rightBorderVal: Border(
        borderStyle: BorderStyle.Medium,
      ),
    );

    /**
     * Merged Received Date cells, mapped data and set a style
     */
    final startReceivedDateCell = CellIndex.indexByColumnRow(
      columnIndex: 6,
      rowIndex: startingRow + 4,
    );
    final endReceivedDateCell = CellIndex.indexByColumnRow(
      columnIndex: 7,
      rowIndex: startingRow + 4,
    );
    sheet.merge(
      startReceivedDateCell,
      endReceivedDateCell,
    );
    final receivedDateCell = sheet.cell(
      startReceivedDateCell,
    );
    receivedDateCell.value = TextCellValue(
      receivedDate != null ? documentDateFormatter(receivedDate) : '',
    );
    receivedDateCell.cellStyle = cellStyle?.copyWith(
      horizontalAlignVal: HorizontalAlign.Center,
      verticalAlignVal: VerticalAlign.Center,
      leftBorderVal: Border(
        borderStyle: BorderStyle.Medium,
      ),
    );
    sheet.cell(endReceivedDateCell).cellStyle = cellStyle?.copyWith(
      rightBorderVal: Border(
        borderStyle: BorderStyle.Medium,
      ),
    );

    /**
     * Merged Received Date Description cells, mapped data and set a style
     */
    final startReceivedDateDescriptionCell = CellIndex.indexByColumnRow(
      columnIndex: 6,
      rowIndex: startingRow + 5,
    );
    final endReceivedDateDescriptionCell = CellIndex.indexByColumnRow(
      columnIndex: 7,
      rowIndex: startingRow + 5,
    );
    sheet.merge(
      startReceivedDateDescriptionCell,
      endReceivedDateDescriptionCell,
    );
    final receivedDateDescriptionCell = sheet.cell(
      startReceivedDateDescriptionCell,
    );
    receivedDateDescriptionCell.value = TextCellValue(
      'Date',
    );
    receivedDateDescriptionCell.cellStyle = cellStyle?.copyWith(
      horizontalAlignVal: HorizontalAlign.Center,
      verticalAlignVal: VerticalAlign.Center,
      leftBorderVal: Border(
        borderStyle: BorderStyle.Medium,
      ),
    );

    final startFooterBottomCell = CellIndex.indexByColumnRow(
      columnIndex: 1,
      rowIndex: startingRow + 5,
    );
    final endFooterBottomCell = CellIndex.indexByColumnRow(
      columnIndex: 7,
      rowIndex: startingRow + 5,
    );
    for (int col = startFooterBottomCell.columnIndex;
        col <= endFooterBottomCell.columnIndex;
        col++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(
          columnIndex: col,
          rowIndex: startingRow + 5,
        ),
      );
      cell.cellStyle = cellStyle?.copyWith(
        horizontalAlignVal: HorizontalAlign.Center,
        verticalAlignVal: VerticalAlign.Center,
        rightBorderVal: col == 5 || col == 7
            ? Border(
                borderStyle: BorderStyle.Medium,
              )
            : null,
        bottomBorderVal: Border(
          borderStyle: BorderStyle.Medium,
        ),
        leftBorderVal: col == 1
            ? Border(
                borderStyle: BorderStyle.Medium,
              )
            : null,
      );
    }
  }

  static void _updateRowFooter({
    required Sheet sheet,
    required int index,
    String? data,
    CellStyle? dataCellStyle,
  }) {
    _updateRow(
      sheet,
      index,
      ' ',
      ' ',
      ' ',
      ' ',
      data ?? ' ',
      ' ',
      null,
      dataCellStyle,
    );
  }
}
