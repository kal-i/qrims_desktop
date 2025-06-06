import 'package:excel/excel.dart';
import '../../../enums/fund_cluster.dart';
import '../../../utils/capitalizer.dart';

import '../../../utils/document_date_formatter.dart';
import '../../../utils/fund_cluster_to_readable_string.dart';
import 'header_info.dart';
import 'cell_info.dart';

/// Handles mapping of RPCI data to the Excel template
class RPCIExcelDocument {
  static void modifyAndMapData(Sheet sheet, dynamic data) {
    final accountableOfficer =
        data['accountable_officer'] as Map<String, String>?;
    final inventorySupplies =
        data['inventory_report'] as List<Map<String, dynamic>>;
    final approvingEntityOrAuthorizedRepresentative =
        data['approving_entity_or_authorized_representative'] as String?;
    final coaRepresentative = data['coa_representative'] as String?;
    final certifyingOfficers =
        data['certifying_officers'] as List<Map<String, dynamic>>?;

    final startHeaderTopCell = CellIndex.indexByColumnRow(
      columnIndex: 0,
      rowIndex: 0,
    );
    final endHeaderTopCell = CellIndex.indexByColumnRow(
      columnIndex: 15,
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

    final asAtDateCell = sheet.cell(
      CellIndex.indexByString(
        'B6',
      ),
    );
    asAtDateCell.value = TextCellValue(
      'As at ${data['as_at_date']}',
    );
    asAtDateCell.cellStyle = CellStyle(
      bold: true,
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );

    // Define the border style
    final borderStyle = Border(borderStyle: BorderStyle.Medium);

    // Apply headers and styles
    _applyHeadersAndStyles(sheet, borderStyle);

    // Map data to specific cells
    int totalRowsInserted = _mapDataToCells(
      sheet,
      inventorySupplies,
      borderStyle,
    );

    print('total rows inserted: $totalRowsInserted');

    int footerStartRow = 14 + totalRowsInserted + 1;
    final footerRows = _addFooter(
      sheet,
      footerStartRow,
      certifyingOfficers,
      approvingEntityOrAuthorizedRepresentative,
      coaRepresentative,
    );

    final startHeaderRightCell = CellIndex.indexByColumnRow(
      columnIndex: 15,
      rowIndex: 0,
    );
    final endHeaderRightCell = CellIndex.indexByColumnRow(
      columnIndex: 15,
      rowIndex: footerRows + 1,
    );
    for (int row = startHeaderRightCell.rowIndex;
        row <= endHeaderRightCell.rowIndex;
        row++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(
          columnIndex: 15,
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
        leftBorder: row >= 1 && row <= 10 ||
                row >= footerStartRow && row <= footerRows + 1
            ? Border(
                borderStyle: BorderStyle.Medium,
                borderColorHex: ExcelColor.white,
              )
            : null,
      );
    }

    final startHeaderLeftCell = CellIndex.indexByColumnRow(
      columnIndex: 0,
      rowIndex: 0,
    );
    final endHeaderLeftCell = CellIndex.indexByColumnRow(
      columnIndex: 0,
      rowIndex: footerRows + 1,
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
      cell.cellStyle = CellStyle(
        topBorder: row == 0
            ? Border(
                borderStyle: BorderStyle.Medium,
                borderColorHex: ExcelColor.white,
              )
            : null,
        bottomBorder: row == endHeaderLeftCell.rowIndex
            ? Border(
                borderStyle: BorderStyle.Medium,
                borderColorHex: ExcelColor.white,
              )
            : null,
        leftBorder: Border(
          borderStyle: BorderStyle.Medium,
          borderColorHex: ExcelColor.white,
        ),
      );
    }

    final headerBottomCellRowIndex = footerRows + 1; // footerStartRow + 7;
    final startHeaderBottomCell = CellIndex.indexByColumnRow(
      columnIndex: 0,
      rowIndex: headerBottomCellRowIndex,
    );
    final endHeaderBottomCell = CellIndex.indexByColumnRow(
      columnIndex: 15,
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

    final cellStyle = sheet
        .cell(
          CellIndex.indexByString('B10'),
        )
        .cellStyle;

    final fundClusterCell = sheet.cell(
      CellIndex.indexByString('B8'),
    );
    fundClusterCell.value = TextCellValue(
      'Fund Cluster: ${data['fund_cluster']}',
    );
    fundClusterCell.cellStyle = cellStyle;

    final accountableOfficerCell = sheet.cell(
      CellIndex.indexByString('B10'),
    );
    accountableOfficerCell.value = TextCellValue.span(
      TextSpan(
        style: cellStyle,
        text: 'For which ',
        children: [
          TextSpan(
            text: accountableOfficer?['name'] != null &&
                    accountableOfficer!['name']!.isNotEmpty
                ? '${accountableOfficer['name']}'
                : '_________________',
            style: cellStyle,
          ),
          const TextSpan(
            text: ', ',
          ),
          TextSpan(
            text: accountableOfficer?['position'] != null &&
                    accountableOfficer!['position']!.isNotEmpty
                ? '${accountableOfficer['position']}'
                : '_________________',
            style: cellStyle,
          ),
          const TextSpan(
            text: ', ',
          ),
          TextSpan(
            text: accountableOfficer?['location'] != null &&
                    accountableOfficer!['location']!.isNotEmpty
                ? '${accountableOfficer['location']}'
                : '_________________',
            style: cellStyle,
          ),
          const TextSpan(
            text: 'is accountable, having assumed such accountability on ',
          ),
          TextSpan(
            text: accountableOfficer?['accountability_date'] != null &&
                    accountableOfficer!['accountability_date']!.isNotEmpty
                ? '${accountableOfficer['accountability_date']}'
                : '_________________',
            style: cellStyle,
          ),
          const TextSpan(
            text: '.',
          ),
        ],
      ),
    );
    accountableOfficerCell.cellStyle = cellStyle;
  }

  static void _applyHeadersAndStyles(Sheet sheet, Border borderStyle) {
    final headers = [
      const HeaderInfo('B12', 'B14', 'Article'),
      const HeaderInfo('C12', 'C14', 'Description'),
      const HeaderInfo('D12', 'D14', 'Stock No.'),
      const HeaderInfo('E12', 'E14', 'Unit'),
      const HeaderInfo('F12', 'F14', 'Unit Value'),
      const HeaderInfo('G12', 'G13', 'Balance Per Card'),
      const HeaderInfo('G14', 'G14', 'Quantity'),
      const HeaderInfo('H12', 'H13', 'On Hand Per Card'),
      const HeaderInfo('H14', 'H14', 'Quantity'),
      const HeaderInfo('I12', 'I13', 'Shortage/Overage'),
      const HeaderInfo('I14', 'I14', 'Quantity'),
      const HeaderInfo('J14', 'J14', 'Value'),
      const HeaderInfo('K12', 'K14', 'Remarks'),
      const HeaderInfo('L12', 'L14', 'Date Acquired'),
      const HeaderInfo('M12', 'M14', 'Accountable Officer'),
      const HeaderInfo('N12', 'N14', 'Location'),
      const HeaderInfo('O12', 'O14', 'Fund Cluster'),
    ];

    for (var header in headers) {
      final startCellIndex = CellIndex.indexByString(header.startCell);
      final endCellIndex = CellIndex.indexByString(header.endCell);

      // Apply style to the first cell
      final startCell = sheet.cell(startCellIndex);
      startCell.value = TextCellValue(header.title);
      startCell.cellStyle = CellStyle(
        bold: true,
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
        topBorder: borderStyle,
        bottomBorder: borderStyle,
        leftBorder: borderStyle,
        rightBorder: borderStyle,
      );

      // Merge the cells
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
            cell.cellStyle = CellStyle(
              bold: true,
              horizontalAlign: HorizontalAlign.Center,
              verticalAlign: VerticalAlign.Center,
              leftBorder: borderStyle, // Ensure left border
              rightBorder: borderStyle, // Ensure right border
            );
          }
        }
      }
    }
  }

  static int _mapDataToCells(
    Sheet sheet,
    List<Map<String, dynamic>> inventorySupplies,
    Border borderStyle,
  ) {
    int startRow = 14;
    int totalRowsInserted = 0;

    for (int i = 0; i < inventorySupplies.length; i++) {
      final inventorySupply = inventorySupplies[i];
      final article = inventorySupply['article'].toString().toUpperCase();
      final description = inventorySupply['description'];
      final stockNumber = inventorySupply['stock_number'] != null
          ? inventorySupply['stock_number'].toString()
          : '\n';
      final unit = inventorySupply['unit'];
      final unitValue = double.parse(inventorySupply['unit_value'].toString());
      final totalQuantity =
          inventorySupply['balance_from_previous_row_after_issuance'] == 0
              ? inventorySupply['total_quantity_available_and_issued'] != null
                  ? int.tryParse(
                      inventorySupply['total_quantity_available_and_issued']
                              ?.toString() ??
                          '0')
                  : inventorySupply['current_quantity_in_stock']
              : inventorySupply['balance_from_previous_row_after_issuance'];

      final balanceAfterIssue = int.tryParse(
              inventorySupply['balance_per_row_after_issuance']?.toString() ??
                  '0') ??
          0;

      final dateAcquired = documentDateFormatter(
          DateTime.parse(inventorySupply['date_acquired']));

      final accountableOfficer =
          capitalizeWord(inventorySupply['receiving_officer_name'] ?? '\n');
      final location =
          capitalizeWord(inventorySupply['receiving_officer_office'] ?? '\n');

      final remarks = accountableOfficer.trim().isNotEmpty
          ? '${capitalizeWord(accountableOfficer)} - ${inventorySupply['total_quantity_issued_for_a_particular_row']}'
          : '\n';

      FundCluster? matchedFundCluster;
      if (inventorySupply['fund_cluster'] != null) {
        final match = FundCluster.values.where(
          (e) =>
              e.toString().split('.').last == inventorySupply['fund_cluster'],
        );
        if (match.isNotEmpty) {
          matchedFundCluster = match.first;
        }
      }

      final fundCluster = matchedFundCluster?.toReadableString() ?? '\n';

      if (i > 0) {
        final rowIndex = startRow + i - 1;
        sheet.insertRow(rowIndex);
        _updateRow(
          sheet,
          rowIndex,
          article,
          description,
          stockNumber,
          unit,
          unitValue,
          totalQuantity,
          balanceAfterIssue,
          remarks,
          dateAcquired,
          accountableOfficer,
          location,
          fundCluster,
          borderStyle,
        );

        totalRowsInserted++;
      } else {
        _updateRow(
          sheet,
          startRow + i,
          article,
          description,
          stockNumber,
          unit,
          unitValue,
          totalQuantity,
          balanceAfterIssue,
          remarks,
          dateAcquired,
          accountableOfficer,
          location,
          fundCluster,
          borderStyle,
        );
      }
    }

    return totalRowsInserted;
  }

  static void _updateRow(
    Sheet sheet,
    int rowIndex,
    String article,
    String description,
    String stockNumber,
    String unit,
    double unitValue,
    dynamic totalQuantity,
    int balanceAfterIssue,
    String remarks,
    String dateAcquired,
    String accountableOfficer,
    String location,
    String fundCluster,
    Border borderStyle,
  ) {
    final cells = [
      CellInfo(1, article),
      CellInfo(2, description),
      CellInfo(3, stockNumber),
      CellInfo(4, unit),
      CellInfo(5, unitValue.toString()),
      CellInfo(6, totalQuantity.toString()),
      CellInfo(7, balanceAfterIssue.toString()),
      const CellInfo(8, '0'),
      const CellInfo(9, '0'),
      CellInfo(10, remarks),
      CellInfo(11, dateAcquired),
      CellInfo(12, accountableOfficer),
      CellInfo(13, location),
      CellInfo(14, fundCluster),
    ];

    final cellStyle = sheet
        .cell(
          CellIndex.indexByString('B5'),
        )
        .cellStyle;

    for (var cellInfo in cells) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(
          columnIndex: cellInfo.columnIndex, rowIndex: rowIndex));
      cell.value = TextCellValue(cellInfo.value);
      cell.cellStyle = cellStyle?.copyWith(
        topBorderVal: Border(borderStyle: BorderStyle.Thin),
        bottomBorderVal: Border(borderStyle: BorderStyle.Thin),
        leftBorderVal: borderStyle,
        rightBorderVal: borderStyle,
        horizontalAlignVal: HorizontalAlign.Center,
        verticalAlignVal: VerticalAlign.Center,
      );
    }
  }

  static int _addFooter(
    Sheet sheet,
    int footerStartRow,
    List<Map<String, dynamic>>? certifyingOfficers,
    String? approvingEntityOrAuthorizedRepresentativeName,
    String? coaRepresentativeName,
  ) {
    int startingRow = footerStartRow + 3;
    int currentRow = startingRow;

    final cellStyle = sheet
        .cell(
          CellIndex.indexByColumnRow(
            columnIndex: 1,
            rowIndex: 4,
          ),
        )
        .cellStyle;

    /**
     * Add a default empty string value to preserve styling
     */
    if (certifyingOfficers == null || certifyingOfficers.isEmpty) {
      certifyingOfficers = [
        {
          'name': '',
          'position': '',
        },
      ];
    }

    for (int i = 0; i < certifyingOfficers.length; i++) {
      final certifyingOfficer = certifyingOfficers[i];

      final startingCertifyingOfficerNameCell = sheet.cell(
        CellIndex.indexByColumnRow(
          columnIndex: 1,
          rowIndex: currentRow,
        ),
      );
      startingCertifyingOfficerNameCell.cellStyle = CellStyle(
        leftBorder: Border(
          borderStyle: BorderStyle.Medium,
        ),
      );

      final endingCertifyingOfficerNameCell = sheet.cell(
        CellIndex.indexByColumnRow(
          columnIndex: 10,
          rowIndex: currentRow,
        ),
      );
      endingCertifyingOfficerNameCell.cellStyle = CellStyle(
        rightBorder: Border(
          borderStyle: BorderStyle.Medium,
        ),
      );

      // Add Certifying Officer Name
      final certifyingOfficerNameCell = sheet.cell(
        CellIndex.indexByColumnRow(
          columnIndex: 2,
          rowIndex: currentRow,
        ),
      );
      certifyingOfficerNameCell.value =
          TextCellValue(certifyingOfficer['name']);
      certifyingOfficerNameCell.cellStyle = cellStyle;

      final startingCertifyingOfficerPositionCell = sheet.cell(
        CellIndex.indexByColumnRow(
          columnIndex: 1,
          rowIndex: currentRow + 1,
        ),
      );
      startingCertifyingOfficerPositionCell.cellStyle = CellStyle(
        leftBorder: Border(
          borderStyle: BorderStyle.Medium,
        ),
      );

      final endingCertifyingOfficerPositionCell = sheet.cell(
        CellIndex.indexByColumnRow(
          columnIndex: 10,
          rowIndex: currentRow + 1,
        ),
      );
      endingCertifyingOfficerPositionCell.cellStyle = CellStyle(
        rightBorder: Border(
          borderStyle: BorderStyle.Medium,
        ),
      );

      // Add Certifying Officer Position (Below Name)
      final certifyingOfficerPositionCell = sheet.cell(
        CellIndex.indexByColumnRow(
          columnIndex: 2,
          rowIndex: currentRow + 1,
        ),
      );
      certifyingOfficerPositionCell.value =
          TextCellValue(certifyingOfficer['position']);
      certifyingOfficerPositionCell.cellStyle = cellStyle;

      final startingAllotedCell = sheet.cell(
        CellIndex.indexByColumnRow(
          columnIndex: 1,
          rowIndex: currentRow + 2,
        ),
      );
      startingAllotedCell.cellStyle = CellStyle(
        leftBorder: Border(
          borderStyle: BorderStyle.Medium,
        ),
      );

      final endingAllotedCell = sheet.cell(
        CellIndex.indexByColumnRow(
          columnIndex: 10,
          rowIndex: currentRow + 2,
        ),
      );
      endingAllotedCell.cellStyle = CellStyle(
        rightBorder: Border(
          borderStyle: BorderStyle.Medium,
        ),
      );

      // Add border at the last row index
      if (i == certifyingOfficers.length - 1) {
        for (int col = 1; col <= 10; col++) {
          final cell = sheet.cell(
            CellIndex.indexByColumnRow(
              columnIndex: col,
              rowIndex: currentRow + 3,
            ),
          );
          cell.cellStyle = CellStyle(
            horizontalAlign: HorizontalAlign.Center,
            verticalAlign: VerticalAlign.Center,
            rightBorder: col == 10
                ? Border(
                    borderStyle: BorderStyle.Medium,
                  )
                : null,
            bottomBorder: Border(
              borderStyle: BorderStyle.Medium,
            ),
            leftBorder: col == 1
                ? Border(
                    borderStyle: BorderStyle.Medium,
                  )
                : null,
          );
        }
      }

      // Add spacing row after each officer
      currentRow += 3;
    }

    // ** Add Approving Entity (Merged Cells with Borders) **
    final startApprovingEntityOrAuthorizedRepresentativeCell =
        CellIndex.indexByColumnRow(
      columnIndex: 6,
      rowIndex: startingRow,
    );
    final endApprovingEntityOrAuthorizedRepresentativeCell =
        CellIndex.indexByColumnRow(
      columnIndex: 8,
      rowIndex: startingRow,
    );

    sheet.cell(startApprovingEntityOrAuthorizedRepresentativeCell).value =
        TextCellValue(approvingEntityOrAuthorizedRepresentativeName ??
            '_______________________________');

    sheet.merge(
      startApprovingEntityOrAuthorizedRepresentativeCell,
      endApprovingEntityOrAuthorizedRepresentativeCell,
    );

    for (int col = 6; col <= 8; col++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(
          columnIndex: col,
          rowIndex: startingRow,
        ),
      );
      cell.cellStyle = cellStyle;
    }

    final startingApprovingEntityOrAuthorizedRepresentativeTitleCellIndex =
        CellIndex.indexByColumnRow(
      columnIndex: 6,
      rowIndex: startingRow + 1,
    );
    final endingApprovingEntityOrAuthorizedRepresentativeTitleCellIndex =
        CellIndex.indexByColumnRow(
      columnIndex: 8,
      rowIndex: startingRow + 1,
    );

    for (int col = 6; col <= 8; col++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(
          columnIndex: col,
          rowIndex: startingRow + 1,
        ),
      );
      cell.cellStyle = cellStyle;
    }

    sheet.merge(
      startingApprovingEntityOrAuthorizedRepresentativeTitleCellIndex,
      endingApprovingEntityOrAuthorizedRepresentativeTitleCellIndex,
    );

    final entityOrAuthorizedRepresentativeTitleCell = sheet.cell(
      startingApprovingEntityOrAuthorizedRepresentativeTitleCellIndex,
    );
    entityOrAuthorizedRepresentativeTitleCell.value = TextCellValue(
      'Entity or Authorized Representative',
    );
    entityOrAuthorizedRepresentativeTitleCell.cellStyle = cellStyle;

    // ** Add COA Representative **
    final coaRepresentativeCell = sheet.cell(
      CellIndex.indexByColumnRow(
        columnIndex: 10,
        rowIndex: startingRow,
      ),
    );
    coaRepresentativeCell.value = TextCellValue(
        coaRepresentativeName ?? '_______________________________');
    coaRepresentativeCell.cellStyle = cellStyle;

    final coaRepresentativeTitleCell = sheet.cell(
      CellIndex.indexByColumnRow(
        columnIndex: 10,
        rowIndex: startingRow + 1,
      ),
    );
    coaRepresentativeTitleCell.value = TextCellValue(
      'Signature over Printed Name of COA Representative',
    );
    coaRepresentativeTitleCell.cellStyle = cellStyle;

    return currentRow;

    // final startingCell = CellIndex.indexByColumnRow(
    //   columnIndex: 1,
    //   rowIndex: startingRow + 2,
    // );
    // final endingCell = CellIndex.indexByColumnRow(
    //   columnIndex: 10,
    //   rowIndex: startingRow + 2,
    // );

    // for (int col = 1; col <= 10; col++) {
    //   final cell = sheet.cell(
    //     CellIndex.indexByColumnRow(
    //       columnIndex: col,
    //       rowIndex: startingRow + 2,
    //     ),
    //   );
    //   cell.cellStyle = CellStyle(
    //     horizontalAlign: HorizontalAlign.Center,
    //     verticalAlign: VerticalAlign.Center,
    //     bottomBorder: Border(
    //       borderColorHex: ExcelColor.grey,
    //       borderStyle: BorderStyle.Thin,
    //     ),
    //   );
    // }

    // sheet.merge(
    //   startingCell,
    //   endingCell,
    // );
  }
}
