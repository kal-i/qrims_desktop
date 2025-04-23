import 'package:excel/excel.dart';

import '../../../../features/item_inventory/domain/entities/inventory_item.dart';
import '../../../../features/item_issuance/domain/entities/inventory_custodian_slip.dart';
import '../../../utils/capitalizer.dart';
import '../../../utils/currency_formatter.dart';
import '../../../utils/document_date_formatter.dart';
import '../../../utils/extract_specification.dart';
import '../../../utils/fund_cluster_to_readable_string.dart';
import '../../../utils/get_position_at.dart';
import '../../../utils/readable_enum_converter.dart';
import 'cell_info.dart';
import 'header_info.dart';

class IcsExcelDocument {
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

    final entityTitleCell = sheet
        .cell(
          CellIndex.indexByString('A13'),
        )
        .cellStyle = generalCellStyle;

    final fundClusterTitleCell = sheet
        .cell(
          CellIndex.indexByString('A14'),
        )
        .cellStyle = generalCellStyle;

    final entityCell = sheet.cell(
      CellIndex.indexByString('B13'),
    );
    entityCell.value = TextCellValue(
      capitalizeWord(ics.entity?.name ?? ''),
    );
    entityCell.cellStyle = generalCellStyle;

    final fundClusterCell = sheet.cell(
      CellIndex.indexByString('B14'),
    );

    fundClusterCell.value = TextCellValue(
      capitalizeWord(ics.fundCluster?.toReadableString() ?? ''),
    );
    fundClusterCell.cellStyle = generalCellStyle;

    final icsNoCell = sheet.cell(
      CellIndex.indexByString('F14'),
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
      issuingOfficerPositionHistory?.positionName ?? '',
      issuingOfficerPositionHistory?.officeName ?? '',
      ics.issuedDate,
      ics.receivingOfficerEntity?.name ?? '',
      receivingOfficerPositonHistory?.positionName ?? '',
      receivingOfficerPositonHistory?.officeName ?? '',
      ics.receivedDate,
      generalCellStyle,
    );
  }

  static void _applyHeadersAndStyles(
      Sheet sheet, Border borderStyle, CellStyle? cellStyle) {
    final headers = [
      const HeaderInfo('A16', 'A18', 'Quantity'),
      const HeaderInfo('B16', 'B18', 'Unit'),
      const HeaderInfo('C16', 'D16', 'Quantity'),
      const HeaderInfo('C17', 'C18', 'Unit Cost'),
      const HeaderInfo('D17', 'D18', 'Total Cost'),
      const HeaderInfo('E16', 'E18', 'Description'),
      const HeaderInfo('F16', 'F18', 'Inventory Item No.'),
      const HeaderInfo('G16', 'G18', 'Estimated Useful Life'),
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
    final items = ics.items;
    int startRow = 18;
    int totalRowsInserted = 0;
    int currentRow = startRow;

    for (int i = 0; i < items.length; i++) {
      final issuance = items[i];
      final itemEntity = issuance.itemEntity;
      final shareableItemInformationEntity =
          itemEntity.shareableItemInformationEntity;
      final productDescriptionEntity =
          itemEntity.productStockEntity.productDescription;

      final dataCellStyle = cellStyle?.copyWith(
        horizontalAlignVal: HorizontalAlign.Center,
        verticalAlignVal: VerticalAlign.Center,
        topBorderVal: i == 1
            ? Border(borderStyle: BorderStyle.Medium)
            : Border(borderStyle: BorderStyle.Thin),
        rightBorderVal: Border(borderStyle: BorderStyle.Medium),
        bottomBorderVal: i == 0
            ? Border(borderStyle: BorderStyle.Medium)
            : Border(borderStyle: BorderStyle.Thin),
        leftBorderVal: Border(borderStyle: BorderStyle.Medium),
      );

      final descriptionColumn = [
        productDescriptionEntity?.description,
      ];

      final specification = shareableItemInformationEntity.specification;
      if (specification != null) {
        descriptionColumn.addAll([
          'Specifications',
          ...extractSpecification(specification, ','),
        ]);
      }

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

      final baseItemId = shareableItemInformationEntity.id;
      final quantity = issuance.quantity;
      final unit = shareableItemInformationEntity.unit;
      final unitCost = shareableItemInformationEntity.unitCost;
      final totalCost = unitCost * quantity;
      final estimatedUsefulLife =
          (itemEntity as InventoryItemEntity).estimatedUsefulLife;

      for (int j = 0; j < descriptionColumn.length; j++) {
        // For every row after the first, insert a new row
        if (!(i == 0 && j == 0)) {
          sheet.insertRow(currentRow);
          totalRowsInserted++;
        }
        _updateRow(
          sheet,
          currentRow,
          j == 0 ? quantity.toString() : '',
          j == 0 ? readableEnumConverter(unit) : '',
          j == 0 ? formatCurrency(unitCost) : '',
          j == 0 ? formatCurrency(totalCost) : '',
          descriptionColumn[j] ?? '',
          j == 0 ? baseItemId : '',
          j == 0 ? estimatedUsefulLife : null,
          dataCellStyle,
        );
        currentRow++;
      }

      final purchaseRequestEntity = ics.purchaseRequestEntity;
      final supplierEntity = ics.supplierEntity;

      if (i == items.length - 1) {
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

        if (purchaseRequestEntity != null) {
          sheet.insertRow(currentRow);
          _updateRowFooter(
            sheet: sheet,
            index: currentRow,
            data: 'PR: ${purchaseRequestEntity.id}',
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
        0,
        quantity,
      ),
      CellInfo(
        1,
        unit,
      ),
      CellInfo(
        2,
        unitCost,
      ),
      CellInfo(
        3,
        totalCost,
      ),
      CellInfo(
        4,
        description,
      ),
      CellInfo(
        5,
        inventoryItemNo,
      ),
      CellInfo(
        6,
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

      cell.cellStyle = cellStyle?.copyWith(
        horizontalAlignVal: HorizontalAlign.Center,
        verticalAlignVal: VerticalAlign.Center,
        topBorderVal: Border(borderStyle: BorderStyle.Thin),
        rightBorderVal: Border(borderStyle: BorderStyle.Medium),
        bottomBorderVal: Border(borderStyle: BorderStyle.Thin),
        leftBorderVal: Border(borderStyle: BorderStyle.Medium),
      );
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
      columnIndex: 0,
      rowIndex: footerStartRow + 1,
    );
    final endFooterCell = CellIndex.indexByColumnRow(
      columnIndex: 6,
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
      columnIndex: 0,
      rowIndex: footerStartRow + 1,
    );
    final receivedFromCell = sheet.cell(
      startReceivedFromCell,
    );
    receivedFromCell.value = TextCellValue(
      'Received From:',
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
      columnIndex: 0,
      rowIndex: startingRow,
    );
    final endIssuingOfficerNameCell = CellIndex.indexByColumnRow(
      columnIndex: 4,
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
      columnIndex: 0,
      rowIndex: startingRow + 1,
    );
    final endingIssuingOfficerNameDescriptionCell = CellIndex.indexByColumnRow(
      columnIndex: 4,
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
      'Signarature Over Printed Name',
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
      columnIndex: 0,
      rowIndex: startingRow + 2,
    );
    final endIssuingOfficerPositionNameCell = CellIndex.indexByColumnRow(
      columnIndex: 4,
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
      columnIndex: 0,
      rowIndex: startingRow + 3,
    );
    final endIssuingOfficerPositionDescriptionCell = CellIndex.indexByColumnRow(
      columnIndex: 4,
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
      columnIndex: 0,
      rowIndex: startingRow + 4,
    );
    final endIssuedDateCell = CellIndex.indexByColumnRow(
      columnIndex: 4,
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
      columnIndex: 0,
      rowIndex: startingRow + 5,
    );
    final endIssuedDateDescriptionCell = CellIndex.indexByColumnRow(
      columnIndex: 4,
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
      columnIndex: 5,
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
      columnIndex: 5,
      rowIndex: startingRow,
    );
    final endReceivingOfficerNameCell = CellIndex.indexByColumnRow(
      columnIndex: 6,
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

    /**
     * Merged Receiving Officer Name Description cells, mapped data and set a style
     */
    final startingReceivingOfficerNameDescriptionCell =
        CellIndex.indexByColumnRow(
      columnIndex: 5,
      rowIndex: startingRow + 1,
    );
    final endingReceivingOfficerNameDescriptionCell =
        CellIndex.indexByColumnRow(
      columnIndex: 6,
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
      'Signarature Over Printed Name',
    );
    receivingOfficerPositionCell.cellStyle = cellStyle?.copyWith(
      horizontalAlignVal: HorizontalAlign.Center,
      verticalAlignVal: VerticalAlign.Center,
      leftBorderVal: Border(
        borderStyle: BorderStyle.Medium,
      ),
    );

    /**
     * Merged Issuing Officer Position Name Description cells, mapped data and set a style
     */
    final startReceivingOfficerPositionNameCell = CellIndex.indexByColumnRow(
      columnIndex: 5,
      rowIndex: startingRow + 2,
    );
    final endReceivingOfficerPositionNameCell = CellIndex.indexByColumnRow(
      columnIndex: 6,
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

    /**
     * Merged Issuing Officer Position Description cells, mapped data and set a style
     */
    final startReceivingOfficerPositionDescriptionCell =
        CellIndex.indexByColumnRow(
      columnIndex: 5,
      rowIndex: startingRow + 3,
    );
    final endReceivingOfficerPositionDescriptionCell =
        CellIndex.indexByColumnRow(
      columnIndex: 6,
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

    /**
     * Merged Received Date cells, mapped data and set a style
     */
    final startReceivedDateCell = CellIndex.indexByColumnRow(
      columnIndex: 5,
      rowIndex: startingRow + 4,
    );
    final endReceivedDateCell = CellIndex.indexByColumnRow(
      columnIndex: 6,
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

    /**
     * Merged Received Date Description cells, mapped data and set a style
     */
    final startReceivedDateDescriptionCell = CellIndex.indexByColumnRow(
      columnIndex: 5,
      rowIndex: startingRow + 5,
    );
    final endReceivedDateDescriptionCell = CellIndex.indexByColumnRow(
      columnIndex: 6,
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
