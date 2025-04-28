import 'package:excel/excel.dart';

import '../../../../features/item_inventory/domain/entities/inventory_item.dart';
import '../../../../features/item_issuance/domain/entities/issuance_item.dart';
import '../../../../features/item_issuance/domain/entities/requisition_and_issue_slip.dart';
import '../../../../features/officer/domain/entities/officer.dart';
import '../../../utils/capitalizer.dart';
import '../../../utils/document_date_formatter.dart';
import '../../../utils/extract_specification.dart';
import '../../../utils/fund_cluster_to_readable_string.dart';
import '../../../utils/get_position_at.dart';
import '../../../utils/readable_enum_converter.dart';
import 'cell_info.dart';
import 'header_info.dart';

class RISExcelDocument {
  static void modifyAndMapData(Sheet sheet, dynamic data) {
    final ris = data as RequisitionAndIssueSlipEntity;
    final risId = ris.risId;
    final division = ris.division ?? '\n';

    final purchaseRequestEntity = ris.purchaseRequestEntity;
    OfficerEntity? issuingOfficerEntity = ris.issuingOfficerEntity;
    OfficerEntity? receivingOfficerEntity = ris.receivingOfficerEntity;
    final issuingOfficerPositionHistory = issuingOfficerEntity?.getPositionAt(
      ris.issuedDate,
    );
    final receivingOfficerPositonHistory =
        receivingOfficerEntity?.getPositionAt(
      ris.issuedDate,
    );

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

    final approvingOfficerPositionHistory =
        approvingOfficerEntity?.getPositionAt(
      ris.issuedDate,
    );
    final requestingOfficerPositionHistory =
        requestingOfficerEntity?.getPositionAt(
      ris.issuedDate,
    );

    final generalCellStyle = sheet
        .cell(
          CellIndex.indexByString('H11'),
        )
        .cellStyle;

    final entityTitleCell = sheet
        .cell(
          CellIndex.indexByString('A12'),
        )
        .cellStyle = generalCellStyle;

    final fundClusterTitleCell = sheet
        .cell(
          CellIndex.indexByString('G12'),
        )
        .cellStyle = generalCellStyle;

    final entityCell = sheet.cell(
      CellIndex.indexByString('B12'),
    );
    entityCell.value = TextCellValue(
      capitalizeWord(entity),
    );
    entityCell.cellStyle = generalCellStyle;

    final fundClusterCell = sheet.cell(
      CellIndex.indexByString('H12'),
    );

    fundClusterCell.value = TextCellValue(
      fundCluster,
    );
    fundClusterCell.cellStyle = generalCellStyle;

    final borderStyle = Border(borderStyle: BorderStyle.Medium);

    _outermostHeaders(
      sheet,
      borderStyle,
      generalCellStyle,
      division,
      office,
      responsibilityCenterCode,
      risId,
    );

    _applyHeadersAndStyles(
      sheet,
      borderStyle,
      generalCellStyle,
    );

    int totalRowsInserted = _mapDataToCells(
      sheet,
      ris,
      generalCellStyle,
    );

    int purposeRows = _purpose(
      sheet,
      17 + totalRowsInserted + 1,
      borderStyle,
      generalCellStyle,
      purpose,
    );

    _addFooter(
      sheet,
      17 + totalRowsInserted + 1 + purposeRows,
      generalCellStyle,
      requestingOfficerEntity?.name ?? '',
      requestingOfficerPositionHistory?.positionName ??
          ris.requestingOfficerEntity?.positionName ??
          '',
      ris.requestDate != null ? documentDateFormatter(ris.requestDate!) : '',
      approvingOfficerEntity?.name ?? '',
      approvingOfficerPositionHistory?.positionName ??
          ris.approvingOfficerEntity?.positionName ??
          '',
      ris.approvedDate != null ? documentDateFormatter(ris.approvedDate!) : '',
      issuingOfficerEntity?.name ?? '',
      issuingOfficerPositionHistory?.positionName ??
          ris.issuingOfficerEntity?.positionName ??
          '',
      documentDateFormatter(ris.issuedDate),
      receivingOfficerEntity?.name ?? '',
      receivingOfficerPositonHistory?.positionName ??
          ris.receivingOfficerEntity?.positionName ??
          '',
      ris.receivedDate != null ? documentDateFormatter(ris.receivedDate!) : '',
    );
  }

  static void _outermostHeaders(
    Sheet sheet,
    Border borderStyle,
    CellStyle? cellStyle,
    String division,
    String office,
    String rcc,
    String risId,
  ) {
    /**
     * Apply borders
     */
    final topStartCell = sheet.cell(
      CellIndex.indexByString('A14'),
    );
    final topEndCell = sheet.cell(
      CellIndex.indexByString('H14'),
    );

    for (int col = topStartCell.columnIndex;
        col <= topEndCell.columnIndex;
        col++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(
          columnIndex: col,
          rowIndex: 13,
        ),
      );
      cell.cellStyle = cellStyle?.copyWith(
        topBorderVal: borderStyle,
        rightBorderVal: col == 7 ? borderStyle : null,
        leftBorderVal: col == 0 || col == 5 ? borderStyle : null,
      );
    }

    final bottomStartCell = sheet.cell(
      CellIndex.indexByString('A15'),
    );
    final bottomEndCell = sheet.cell(
      CellIndex.indexByString('H15'),
    );

    for (int col = bottomStartCell.columnIndex;
        col <= bottomEndCell.columnIndex;
        col++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(
          columnIndex: col,
          rowIndex: 14,
        ),
      );
      cell.cellStyle = cellStyle?.copyWith(
        rightBorderVal: col == 7 ? borderStyle : null,
        bottomBorderVal: borderStyle,
        leftBorderVal: col == 0 || col == 5 ? borderStyle : null,
      );
    }

    /**
     * Map values
     */
    final divisionCell = sheet
        .cell(
          CellIndex.indexByString('B14'),
        )
        .value = TextCellValue(
      division.toUpperCase(),
    );

    final officeCell = sheet
        .cell(
          CellIndex.indexByString('B15'),
        )
        .value = TextCellValue(
      capitalizeWord(office),
    );

    final rccCell = sheet
        .cell(
          CellIndex.indexByString('G14'),
        )
        .value = TextCellValue(
      rcc,
    );

    final risIdCell = sheet
        .cell(
          CellIndex.indexByString('G15'),
        )
        .value = TextCellValue(
      risId,
    );
  }

  static void _applyHeadersAndStyles(
    Sheet sheet,
    Border borderStyle,
    CellStyle? cellStyle,
  ) {
    final headers = [
      const HeaderInfo('A16', 'D16', 'Requisition'),
      const HeaderInfo('E16', 'F16', 'Stock Available?'),
      const HeaderInfo('G16', 'H16', 'Issue'),
      const HeaderInfo('A17', 'A17', 'Stock No.'),
      const HeaderInfo('B17', 'B17', 'Unit'),
      const HeaderInfo('C17', 'C17', 'Description'),
      const HeaderInfo('D17', 'D17', 'Quantity'),
      const HeaderInfo('E17', 'E17', 'Yes'),
      const HeaderInfo('F17', 'F17', 'No'),
      const HeaderInfo('G17', 'G17', 'Quantity'),
      const HeaderInfo('H17', 'H17', 'Remarks'),
    ];

    for (var header in headers) {
      final startCellIndex = CellIndex.indexByString(header.startCell);
      final endCellIndex = CellIndex.indexByString(header.endCell);

      final startCell = sheet.cell(startCellIndex);
      startCell.value = TextCellValue(header.title);
      startCell.cellStyle = cellStyle?.copyWith(
        horizontalAlignVal: HorizontalAlign.Center,
        verticalAlignVal: VerticalAlign.Center,
        topBorderVal: borderStyle,
        rightBorderVal: borderStyle,
        bottomBorderVal: borderStyle,
        leftBorderVal: borderStyle,
      );

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
    RequisitionAndIssueSlipEntity ris,
    CellStyle? cellStyle,
  ) {
    final items = ris.items;
    final purchaseRequestEntity = ris.purchaseRequestEntity;

    int startRow = 17;
    int totalRowsInserted = 0;
    int currentRow = startRow;

    for (int i = 0; i < items.length; i++) {
      final issuanceItemEntity = items[i];
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
        // For every row after the first, insert a new row
        if (!(i == 0 && j == 0)) {
          sheet.insertRow(currentRow);
          totalRowsInserted++;
        }
        _updateRow(
          sheet,
          currentRow,
          j == 0 ? stockNo : '',
          j == 0 ? readableEnumConverter(unit) : '',
          descriptionColumn[j],
          j == 0 ? requestedQuantity.toString() : '\n',
          j == 0
              ? stockQuantity > 0
                  ? '/'
                  : '\n'
              : '\n',
          j == 0
              ? stockQuantity == 0
                  ? '/'
                  : '\n'
              : '\n',
          j == 0 ? issuedQuantity.toString() : '\n',
          j == 0 ? '\n' : '\n',
          cellStyle,
        );
        currentRow++;
      }
    }
    return totalRowsInserted;
  }

  static int _purpose(
    Sheet sheet,
    int purposeStartRow,
    Border borderStyle,
    CellStyle? cellStyle,
    String purpose,
  ) {
    // Split purpose into chunks of 100 characters
    List<String> purposeChunks = [];
    int maxLen = 175;
    for (int i = 0; i < purpose.length; i += maxLen) {
      int end = (i + maxLen < purpose.length) ? i + maxLen : purpose.length;
      purposeChunks.add(purpose.substring(i, end));
    }

    for (int i = 0; i < purposeChunks.length; i++) {
      int rowIdx = purposeStartRow + i;
      // Insert a new row for each additional chunk (except the first)
      if (i > 0) {
        sheet.insertRow(rowIdx);
      }
      // Merge columns 1 to 7 for this row
      sheet.merge(
        CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIdx),
        CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: rowIdx),
      );

      for (int col = 0; col <= 7; col++) {
        final cell = sheet.cell(
          CellIndex.indexByColumnRow(
            columnIndex: col,
            rowIndex: rowIdx,
          ),
        );
        cell.cellStyle = cellStyle?.copyWith(
          topBorderVal: i == 0 ? borderStyle : null,
          rightBorderVal: col == 7 ? borderStyle : null,
          bottomBorderVal: i == purposeChunks.length - 1 ? borderStyle : null,
          leftBorderVal: col == 0 ? borderStyle : null,
        );
        // Only set value for column 1
        if (col == 1) {
          cell.value = TextCellValue(purposeChunks[i]);
          cell.cellStyle = cell.cellStyle?.copyWith(
            topBorderVal: i == 0 ? borderStyle : null,
            bottomBorderVal: i == purposeChunks.length - 1 ? borderStyle : null,
          );
        }
      }
    }
    return purposeChunks.length;
  }

  static void _addFooter(
    Sheet sheet,
    int footerStartRow,
    CellStyle? cellStyle,
    String requestingOfficerName,
    String requestingOfficerPosition,
    String requestedDate,
    String approvingOfficerName,
    String approvingOfficerPosition,
    String approvedDate,
    String issuingOfficerName,
    String issuingOfficerPosition,
    String issuedDate,
    String receivingOfficerName,
    String receivingOfficerPosition,
    String receivedDate,
  ) {
    int startingRow = footerStartRow + 2;

    final startSignatureRowCell = CellIndex.indexByColumnRow(
      columnIndex: 0,
      rowIndex: startingRow - 1,
    );
    final endSignatureRowCell = CellIndex.indexByColumnRow(
      columnIndex: 7,
      rowIndex: startingRow - 1,
    );
    for (int col = startSignatureRowCell.columnIndex;
        col <= endSignatureRowCell.columnIndex;
        col++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(
          columnIndex: col,
          rowIndex: startingRow - 1,
        ),
      );
      cell.cellStyle = cellStyle?.copyWith(
        rightBorderVal:
            col == 7 ? Border(borderStyle: BorderStyle.Medium) : null,
        bottomBorderVal: Border(borderStyle: BorderStyle.Thin),
        leftBorderVal:
            col == 0 ? Border(borderStyle: BorderStyle.Medium) : null,
      );
    }

    final startPrintedNameRowCell = CellIndex.indexByColumnRow(
      columnIndex: 0,
      rowIndex: startingRow,
    );
    final endPrintedNameRowCell = CellIndex.indexByColumnRow(
      columnIndex: 7,
      rowIndex: startingRow,
    );
    for (int col = startPrintedNameRowCell.columnIndex;
        col <= endPrintedNameRowCell.columnIndex;
        col++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(
          columnIndex: col,
          rowIndex: startingRow,
        ),
      );
      cell.cellStyle = cellStyle?.copyWith(
        topBorderVal: Border(borderStyle: BorderStyle.Thin),
        rightBorderVal:
            col == 7 ? Border(borderStyle: BorderStyle.Medium) : null,
        bottomBorderVal: Border(borderStyle: BorderStyle.Thin),
        leftBorderVal:
            col == 0 ? Border(borderStyle: BorderStyle.Medium) : null,
      );
    }

    final startDesignationRowCell = CellIndex.indexByColumnRow(
      columnIndex: 0,
      rowIndex: startingRow + 1,
    );
    final endDesignationRowCell = CellIndex.indexByColumnRow(
      columnIndex: 7,
      rowIndex: startingRow + 1,
    );
    for (int col = startDesignationRowCell.columnIndex;
        col <= endDesignationRowCell.columnIndex;
        col++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(
          columnIndex: col,
          rowIndex: startingRow + 1,
        ),
      );
      cell.cellStyle = cellStyle?.copyWith(
        topBorderVal: Border(borderStyle: BorderStyle.Thin),
        rightBorderVal:
            col == 7 ? Border(borderStyle: BorderStyle.Medium) : null,
        bottomBorderVal: Border(borderStyle: BorderStyle.Thin),
        leftBorderVal:
            col == 0 ? Border(borderStyle: BorderStyle.Medium) : null,
      );
    }

    final startDateRowCell = CellIndex.indexByColumnRow(
      columnIndex: 0,
      rowIndex: startingRow + 2,
    );
    final endDateRowCell = CellIndex.indexByColumnRow(
      columnIndex: 7,
      rowIndex: startingRow + 2,
    );
    for (int col = startDateRowCell.columnIndex;
        col <= endDateRowCell.columnIndex;
        col++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(
          columnIndex: col,
          rowIndex: startingRow + 2,
        ),
      );
      cell.cellStyle = cellStyle?.copyWith(
        topBorderVal: Border(borderStyle: BorderStyle.Thin),
        rightBorderVal:
            col == 7 ? Border(borderStyle: BorderStyle.Medium) : null,
        bottomBorderVal: Border(borderStyle: BorderStyle.Medium),
        leftBorderVal:
            col == 0 ? Border(borderStyle: BorderStyle.Medium) : null,
      );
    }

    /**
     * Map Requesting Officer data
     */
    final requestingOfficerNameCell = sheet.cell(
      CellIndex.indexByColumnRow(
        columnIndex: 2,
        rowIndex: startingRow,
      ),
    );
    requestingOfficerNameCell.value = TextCellValue(
      requestingOfficerName.toUpperCase(),
    );
    requestingOfficerNameCell.cellStyle = cellStyle?.copyWith(
      topBorderVal: Border(borderStyle: BorderStyle.Thin),
      bottomBorderVal: Border(borderStyle: BorderStyle.Thin),
    );

    final requestingOfficerPositionCell = sheet.cell(
      CellIndex.indexByColumnRow(
        columnIndex: 2,
        rowIndex: startingRow + 1,
      ),
    );
    requestingOfficerPositionCell.value = TextCellValue(
      requestingOfficerPosition.toUpperCase(),
    );
    requestingOfficerPositionCell.cellStyle = cellStyle?.copyWith(
      topBorderVal: Border(borderStyle: BorderStyle.Thin),
      bottomBorderVal: Border(borderStyle: BorderStyle.Thin),
    );

    final requestDateCell = sheet.cell(
      CellIndex.indexByColumnRow(
        columnIndex: 2,
        rowIndex: startingRow + 2,
      ),
    );
    requestDateCell.value = TextCellValue(
      requestedDate,
    );
    requestDateCell.cellStyle = cellStyle?.copyWith(
      topBorderVal: Border(borderStyle: BorderStyle.Thin),
      bottomBorderVal: Border(borderStyle: BorderStyle.Thin),
    );

    /**
     * Map Approving Officer data
     */
    final approvingOfficerNameCell = sheet.cell(
      CellIndex.indexByColumnRow(
        columnIndex: 3,
        rowIndex: startingRow,
      ),
    );
    approvingOfficerNameCell.value = TextCellValue(
      approvingOfficerName.toUpperCase(),
    );
    approvingOfficerNameCell.cellStyle = cellStyle?.copyWith(
      topBorderVal: Border(borderStyle: BorderStyle.Thin),
      bottomBorderVal: Border(borderStyle: BorderStyle.Thin),
    );

    final approvingOfficerPositionCell = sheet.cell(
      CellIndex.indexByColumnRow(
        columnIndex: 3,
        rowIndex: startingRow + 1,
      ),
    );
    approvingOfficerPositionCell.value = TextCellValue(
      approvingOfficerPosition.toUpperCase(),
    );
    approvingOfficerPositionCell.cellStyle = cellStyle?.copyWith(
      topBorderVal: Border(borderStyle: BorderStyle.Thin),
      bottomBorderVal: Border(borderStyle: BorderStyle.Thin),
    );

    final approvedDateCell = sheet.cell(
      CellIndex.indexByColumnRow(
        columnIndex: 3,
        rowIndex: startingRow + 2,
      ),
    );
    approvedDateCell.value = TextCellValue(
      approvedDate,
    );
    approvedDateCell.cellStyle = cellStyle?.copyWith(
      topBorderVal: Border(borderStyle: BorderStyle.Thin),
      bottomBorderVal: Border(borderStyle: BorderStyle.Thin),
    );

    /**
      * Map Issuing Officer data
      */
    final issuingOfficerNameCell = sheet.cell(
      CellIndex.indexByColumnRow(
        columnIndex: 5,
        rowIndex: startingRow,
      ),
    );
    issuingOfficerNameCell.value = TextCellValue(
      issuingOfficerName.toUpperCase(),
    );
    issuingOfficerNameCell.cellStyle = cellStyle?.copyWith(
      topBorderVal: Border(borderStyle: BorderStyle.Thin),
      bottomBorderVal: Border(borderStyle: BorderStyle.Thin),
    );

    final issuingOfficerPositionCell = sheet.cell(
      CellIndex.indexByColumnRow(
        columnIndex: 5,
        rowIndex: startingRow + 1,
      ),
    );
    issuingOfficerPositionCell.value = TextCellValue(
      issuingOfficerPosition.toUpperCase(),
    );
    issuingOfficerPositionCell.cellStyle = cellStyle?.copyWith(
      topBorderVal: Border(borderStyle: BorderStyle.Thin),
      bottomBorderVal: Border(borderStyle: BorderStyle.Thin),
    );

    final issuedDateCell = sheet.cell(
      CellIndex.indexByColumnRow(
        columnIndex: 5,
        rowIndex: startingRow + 2,
      ),
    );
    issuedDateCell.value = TextCellValue(
      issuedDate,
    );
    issuedDateCell.cellStyle = cellStyle?.copyWith(
      topBorderVal: Border(borderStyle: BorderStyle.Thin),
      bottomBorderVal: Border(borderStyle: BorderStyle.Thin),
    );

    /**
      * Map Receiving Officer data
      */
    final receivingOfficerNameCell = sheet.cell(
      CellIndex.indexByColumnRow(
        columnIndex: 7,
        rowIndex: startingRow,
      ),
    );
    receivingOfficerNameCell.value = TextCellValue(
      receivingOfficerName.toUpperCase(),
    );
    receivingOfficerNameCell.cellStyle = cellStyle?.copyWith(
      topBorderVal: Border(borderStyle: BorderStyle.Thin),
      bottomBorderVal: Border(borderStyle: BorderStyle.Thin),
    );

    final receivingOfficerPositionCell = sheet.cell(
      CellIndex.indexByColumnRow(
        columnIndex: 7,
        rowIndex: startingRow + 1,
      ),
    );
    receivingOfficerPositionCell.value = TextCellValue(
      receivingOfficerPosition.toUpperCase(),
    );
    receivingOfficerPositionCell.cellStyle = cellStyle?.copyWith(
      topBorderVal: Border(borderStyle: BorderStyle.Thin),
      bottomBorderVal: Border(borderStyle: BorderStyle.Thin),
    );

    final receivedDateCell = sheet.cell(
      CellIndex.indexByColumnRow(
        columnIndex: 7,
        rowIndex: startingRow + 2,
      ),
    );
    receivedDateCell.value = TextCellValue(
      receivedDate,
    );

    final startFooterBottomCell = CellIndex.indexByColumnRow(
      columnIndex: 0,
      rowIndex: startingRow + 2,
    );
    final endFooterBottomCell = CellIndex.indexByColumnRow(
      columnIndex: 7,
      rowIndex: startingRow + 2,
    );
    for (int col = startFooterBottomCell.columnIndex;
        col <= endFooterBottomCell.columnIndex;
        col++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(
          columnIndex: col,
          rowIndex: startingRow + 2,
        ),
      );
      cell.cellStyle = cellStyle?.copyWith(
        topBorderVal: Border(borderStyle: BorderStyle.Thin),
        rightBorderVal: col == 7
            ? Border(
                borderStyle: BorderStyle.Medium,
              )
            : null,
        bottomBorderVal: Border(
          borderStyle: BorderStyle.Medium,
        ),
        leftBorderVal: col == 0
            ? Border(
                borderStyle: BorderStyle.Medium,
              )
            : null,
      );
    }
  }

  static void _updateRow(
    Sheet sheet,
    int rowIndex,
    String stockNo,
    String unit,
    String description,
    String requestQuantity,
    String yes,
    String no,
    String issuedQuantity,
    String remarks,
    CellStyle? cellStyle,
  ) {
    final cells = [
      CellInfo(
        0,
        stockNo,
      ),
      CellInfo(
        1,
        unit,
      ),
      CellInfo(
        2,
        description,
      ),
      CellInfo(
        3,
        requestQuantity,
      ),
      CellInfo(
        4,
        yes,
      ),
      CellInfo(
        5,
        no,
      ),
      CellInfo(
        6,
        issuedQuantity,
      ),
      CellInfo(
        7,
        remarks,
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
}
