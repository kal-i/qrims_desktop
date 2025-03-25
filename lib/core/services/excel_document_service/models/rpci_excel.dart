import 'package:excel/excel.dart';
import '../../../utils/capitalizer.dart';

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

    final fundClusterCell = sheet.cell(
      CellIndex.indexByString('B8'),
    );
    fundClusterCell.value = TextCellValue(
      'Fund Cluster: ${data['fund_cluster']}',
    );
    fundClusterCell.cellStyle = CellStyle(
      bold: true,
    );

    final accountableOfficerCell = sheet.cell(
      CellIndex.indexByString('B10'),
    );
    accountableOfficerCell.value = TextCellValue.span(
      TextSpan(
        text: 'For which ',
        children: [
          TextSpan(
            text: accountableOfficer?['name'] != null &&
                    accountableOfficer!['name']!.isNotEmpty
                ? '${accountableOfficer['name']}'
                : '_________________',
            style: CellStyle(
              underline: Underline.Single,
            ),
          ),
          const TextSpan(
            text: ', ',
          ),
          TextSpan(
            text: accountableOfficer?['position'] != null &&
                    accountableOfficer!['position']!.isNotEmpty
                ? '${accountableOfficer['position']}'
                : '_________________',
            style: CellStyle(
              underline: Underline.Single,
            ),
          ),
          const TextSpan(
            text: ', ',
          ),
          TextSpan(
            text: accountableOfficer?['location'] != null &&
                    accountableOfficer!['location']!.isNotEmpty
                ? '${accountableOfficer['location']}'
                : '_________________',
            style: CellStyle(
              underline: Underline.Single,
            ),
          ),
          const TextSpan(
            text: 'is accountable, having assumed such accountability on ',
          ),
          TextSpan(
            text: accountableOfficer?['accountability_date'] != null &&
                    accountableOfficer!['accountability_date']!.isNotEmpty
                ? '${accountableOfficer['accountability_date']}'
                : '_________________',
            style: CellStyle(
              underline: Underline.Single,
            ),
          ),
          const TextSpan(
            text: '.',
          ),
        ],
      ),
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
    _addFooter(
      sheet,
      footerStartRow,
      certifyingOfficers,
      approvingEntityOrAuthorizedRepresentative,
      coaRepresentative,
    );
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
      final stockNumber = inventorySupply['stock_number'];
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

      final remarks = inventorySupply['receiving_officer_name'] != null
          ? '${capitalizeWord(inventorySupply['receiving_officer_name'])} - ${inventorySupply['total_quantity_issued_for_a_particular_row']}'
          : '\n';

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
      const CellInfo(11, ''),
      const CellInfo(12, ''),
      const CellInfo(13, ''),
      const CellInfo(14, ''),
    ];

    for (var cellInfo in cells) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(
          columnIndex: cellInfo.columnIndex, rowIndex: rowIndex));
      cell.value = TextCellValue(cellInfo.value);
      cell.cellStyle = CellStyle(
        topBorder: Border(borderStyle: BorderStyle.Thin),
        bottomBorder: Border(borderStyle: BorderStyle.Thin),
        leftBorder: borderStyle,
        rightBorder: borderStyle,
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
      );
    }
  }

  static void _addFooter(
    Sheet sheet,
    int footerStartRow,
    List<Map<String, dynamic>>? certifyingOfficers,
    String? approvingEntityOrAuthorizedRepresentativeName,
    String? coaRepresentativeName,
  ) {
    int startingRow = footerStartRow + 3;
    int currentRow = startingRow;

    if (certifyingOfficers != null && certifyingOfficers.isNotEmpty) {
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
        certifyingOfficerNameCell.cellStyle = CellStyle(
          horizontalAlign: HorizontalAlign.Center,
          verticalAlign: VerticalAlign.Center,
          bottomBorder: Border(borderStyle: BorderStyle.Thin),
        );

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
        certifyingOfficerPositionCell.cellStyle = CellStyle(
          horizontalAlign: HorizontalAlign.Center,
          verticalAlign: VerticalAlign.Center,
        );

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
    } else {
      for (int col = 1; col <= 10; col++) {
        final cell = sheet.cell(
          CellIndex.indexByColumnRow(
            columnIndex: col,
            rowIndex: startingRow + 3,
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

    // ** Add Approving Entity (Merged Cells with Borders) **
    final startApprovingEntityOrAuthorizedRepresentativeCell =
        CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: startingRow);
    final endApprovingEntityOrAuthorizedRepresentativeCell =
        CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: startingRow);

    sheet.cell(startApprovingEntityOrAuthorizedRepresentativeCell).value =
        TextCellValue(approvingEntityOrAuthorizedRepresentativeName ??
            '_______________________________');

    sheet.merge(
      startApprovingEntityOrAuthorizedRepresentativeCell,
      endApprovingEntityOrAuthorizedRepresentativeCell,
    );

    for (int col = 6; col <= 8; col++) {
      final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: col, rowIndex: startingRow));
      cell.cellStyle = CellStyle(
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
        bottomBorder: Border(borderStyle: BorderStyle.Thin),
      );
    }

    final startingApprovingEntityOrAuthorizedRepresentativeTitleCell =
        CellIndex.indexByColumnRow(
      columnIndex: 6,
      rowIndex: startingRow + 1,
    );
    final endingApprovingEntityOrAuthorizedRepresentativeTitleCell =
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
      cell.cellStyle = CellStyle(
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
        topBorder: Border(
          borderStyle: BorderStyle.Thin,
        ),
        bottomBorder: Border(
          borderColorHex: ExcelColor.grey,
          borderStyle: BorderStyle.Thin,
        ),
      );
    }

    sheet.merge(
      startingApprovingEntityOrAuthorizedRepresentativeTitleCell,
      endingApprovingEntityOrAuthorizedRepresentativeTitleCell,
    );

    // ** Add COA Representative **
    final coaRepresentativeCell = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: startingRow),
    );
    coaRepresentativeCell.value = TextCellValue(
        coaRepresentativeName ?? '_______________________________');
    coaRepresentativeCell.cellStyle = CellStyle(
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
      underline: Underline.Single,
    );

    final startingCell = CellIndex.indexByColumnRow(
      columnIndex: 1,
      rowIndex: startingRow + 2,
    );
    final endingCell = CellIndex.indexByColumnRow(
      columnIndex: 10,
      rowIndex: startingRow + 2,
    );

    for (int col = 1; col <= 10; col++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(
          columnIndex: col,
          rowIndex: startingRow + 2,
        ),
      );
      cell.cellStyle = CellStyle(
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
        bottomBorder: Border(
          borderColorHex: ExcelColor.grey,
          borderStyle: BorderStyle.Thin,
        ),
      );
    }

    sheet.merge(
      startingCell,
      endingCell,
    );
  }
}
