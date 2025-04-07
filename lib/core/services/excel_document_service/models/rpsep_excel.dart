import 'package:excel/excel.dart';
import '../../../utils/capitalizer.dart';

import '../../../utils/readable_enum_converter.dart';
import '../../../utils/standardize_position_name.dart';
import 'header_info.dart';
import 'cell_info.dart';

/// Handles mapping of RPCI data to the Excel template
class RPSEPExcelDocument {
  static void modifyAndMapData(Sheet sheet, dynamic data) {
    print('modify and map data reached! $data');

    final assetSubClass = data['asset_sub_class'] as String?;
    final accountableOfficer =
        data['accountable_officer'] as Map<String, String>?;
    final inventorySemiExpendableProperties =
        data['inventory_report'] as List<Map<String, dynamic>>;
    dynamic approvingEntityOrAuthorizedRepresentative;
    try {
      approvingEntityOrAuthorizedRepresentative =
          data.containsKey('approving_entity_or_authorized_representative')
              ? data['approving_entity_or_authorized_representative']
              : null;
    } catch (e) {
      print(
          'Error accessing approving_entity_or_authorized_representative: $e');
      approvingEntityOrAuthorizedRepresentative = null;
    }

    // Safely cast to String or set to null
    final coaRepresentative = data['coa_representative'] as String?;
    final certifyingOfficers =
        data['certifying_officers'] as List<Map<String, dynamic>>?;

    print('data to be map processed');

    /// it is possible to preserve the styling of certain cell then
    /// we can just use the copyWith to change most of the value
    final regularCellStyle =
        sheet.cell(CellIndex.indexByString('A2')).cellStyle;

    final type = sheet.cell(
      CellIndex.indexByString(
        'A3',
      ),
    );
    type.value = assetSubClass != null
        ? TextCellValue(assetSubClass)
        : TextCellValue('_________________________');
    type.cellStyle = CellStyle(
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );

    final asAtDateCell = sheet.cell(
      CellIndex.indexByString(
        'A5',
      ),
    );
    asAtDateCell.value = TextCellValue(
      'As at ${data['as_at_date']}',
    );
    asAtDateCell.cellStyle = CellStyle(
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );

    final fundClusterCell = sheet.cell(
      CellIndex.indexByString('A7'),
    );
    fundClusterCell.value = TextCellValue(
      'Fund Cluster: ${data['fund_cluster']}',
    );

    final accountableOfficerCell = sheet.cell(
      CellIndex.indexByString('A8'),
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
            text: ' is accountable, having assumed such accountability on ',
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

    //print('received inventory from data: $inventorySemiExpendableProperties');

    // Map data to specific cells

    int totalRowsInserted = _mapDataToCells(
      sheet,
      inventorySemiExpendableProperties,
      borderStyle,
      //regularCellStyle,
    );

    print('total rows inserted: $totalRowsInserted');

    int footerStartRow = 11 + totalRowsInserted + 1;
    _addFooter(
      sheet,
      footerStartRow,
      certifyingOfficers,
      approvingEntityOrAuthorizedRepresentative,
      coaRepresentative,
      regularCellStyle,
    );
  }

  static void _applyHeadersAndStyles(Sheet sheet, Border borderStyle) {
    final headers = [
      const HeaderInfo('A10', 'A11', 'Article'),
      const HeaderInfo('B10', 'B11', 'Description'),
      const HeaderInfo('F10', 'F11', 'Semi-expendable Property No.'),
      const HeaderInfo('G10', 'G11', 'Unit of Measure'),
      const HeaderInfo('H10', 'H11', 'Unit Value'),
      const HeaderInfo('I10', 'I10', 'Balance Per Card'),
      const HeaderInfo('I11', 'I11', 'Quantity'),
      const HeaderInfo('J10', 'J10', 'On Hand Per Card'),
      const HeaderInfo('J11', 'J11', 'Quantity'),
      const HeaderInfo('K10', 'L10', 'Shortage/Overage'),
      const HeaderInfo('K11', 'K11', 'Quantity'),
      const HeaderInfo('L11', 'L11', 'Value'),
      const HeaderInfo('M10', 'M11', 'Remarks'),
      const HeaderInfo('N10', 'N11', 'Date Acquired'),
      const HeaderInfo('O10', 'O11', 'Accountable Officer'),
      const HeaderInfo('P10', 'P11', 'Location'),
      const HeaderInfo('Q10', 'Q11', 'Fund Cluster'),
      const HeaderInfo('R10', 'R11', 'Estimated Useful Life'),
      const HeaderInfo('S10', 'S11', 'Current Condiiton'),
      const HeaderInfo('T10', 'T11', 'Asset Classification'),
      const HeaderInfo('U10', 'U11', 'Asset Sub Class'),
      const HeaderInfo('V10', 'Z10', 'Description'),
      const HeaderInfo('V11', 'V11', 'Specification'),
      const HeaderInfo('W11', 'W11', 'Manufacturer'),
      const HeaderInfo('X11', 'X11', 'Brand'),
      const HeaderInfo('Y11', 'Y11', 'Model'),
      const HeaderInfo('Z11', 'Z11', 'Serial #'),
    ];

    for (var header in headers) {
      final startCellIndex = CellIndex.indexByString(header.startCell);
      final endCellIndex = CellIndex.indexByString(header.endCell);

      // Apply style to the first cell
      final startCell = sheet.cell(startCellIndex);
      startCell.value = TextCellValue(header.title);
      startCell.cellStyle = CellStyle(
        //   // bold: false,
        //   // underline: Underline.None,
        //   // italic: false,
        //   fontSize: 9,
        underline: Underline.None,
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
              // bold: false,
              // underline: Underline.None,
              //   // italic: false,
              //   fontSize: 9,
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
    List<Map<String, dynamic>> inventorySemiExpendableProperties,
    Border borderStyle,
    //CellStyle? cellStyle,
  ) {
    int startRow = 11;
    int totalRowsInserted = 0;

    for (int i = 0; i < inventorySemiExpendableProperties.length; i++) {
      final inventorySemiExpendableProperty =
          inventorySemiExpendableProperties[i];

      print(
          'current inventory semi expendable property: $inventorySemiExpendableProperty');

      final article = inventorySemiExpendableProperty['article']
              ?.toString()
              .toUpperCase() ??
          'UNKNOWN';

      final description =
          '${inventorySemiExpendableProperty['brand_name']} ${inventorySemiExpendableProperty['model_name']} with SN: ${inventorySemiExpendableProperty['serial_no']}';
      final semiExpendablePropertyNo =
          inventorySemiExpendableProperty['semi_expendable_property_no'] ??
              'N/A';
      final unit = inventorySemiExpendableProperty['unit'] ?? 'N/A';

      final unitValue = double.parse(
          inventorySemiExpendableProperty['unit_value'].toString());

      // check 1st if we have bal from prev issue, if 0, check if totaal qty avail and issued is not empty, otherwise use current stock
      final totalQuantity = inventorySemiExpendableProperty[
                  'balance_from_previous_row_after_issuance'] ==
              0
          ? inventorySemiExpendableProperty[
                      'total_quantity_available_and_issued'] !=
                  null
              ? int.tryParse(inventorySemiExpendableProperty[
                          'total_quantity_available_and_issued']
                      ?.toString() ??
                  '0')
              : inventorySemiExpendableProperty['current_quantity_in_stock']
          : inventorySemiExpendableProperty[
              'balance_from_previous_row_after_issuance'];

      final balanceAfterIssue = int.tryParse(
              inventorySemiExpendableProperty['balance_per_row_after_issuance']
                      ?.toString() ??
                  '0') ??
          0;

      final remarks = inventorySemiExpendableProperty[
                  'receiving_officer_name'] !=
              null
          ? '${capitalizeWord(inventorySemiExpendableProperty['receiving_officer_name'])}/${capitalizeWord(inventorySemiExpendableProperty['receiving_officer_office'])}-${standardizePositionName(inventorySemiExpendableProperty['receiving_officer_position'])}'
          : '\n';

      final accountableOfficer =
          inventorySemiExpendableProperty['receiving_officer_name'];
      final location =
          inventorySemiExpendableProperty['receiving_officer_office'];
      final estimatedUsefulLife =
          inventorySemiExpendableProperty['estimated_useful_life'];
      final assetClassification = readableEnumConverter(
          inventorySemiExpendableProperty['asset_classification']);
      final assetSubClass = readableEnumConverter(
          inventorySemiExpendableProperty['asset_sub_class']);

      final specification = inventorySemiExpendableProperty['specification'];
      final manufacturer = inventorySemiExpendableProperty['manufacturer_name'];
      final brand = inventorySemiExpendableProperty['brand_name'];
      final model = inventorySemiExpendableProperty['model_name'];
      final serialNo = inventorySemiExpendableProperty['serial_no'];

      final thinBorder = Border(borderStyle: BorderStyle.Thin);

      /// the 2nd elem (index 1) will be at the top
      /// while the 1st elem (index 0) will be at the bottom
      final cellStyle = CellStyle(
        bold: false,
        fontFamily: getFontFamily(FontFamily.Book_Antiqua),
        fontSize: 9,
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
        topBorder: i == 1 ? borderStyle : thinBorder,
        rightBorder: borderStyle,
        bottomBorder: i == 0 ? borderStyle : thinBorder,
        leftBorder: borderStyle,
      );

      if (i > 0) {
        final rowIndex = startRow + i - 1;
        sheet.insertRow(rowIndex);
        _updateRow(
          sheet,
          rowIndex,
          article,
          description,
          semiExpendablePropertyNo,
          unit,
          unitValue,
          totalQuantity,
          balanceAfterIssue,
          remarks,
          accountableOfficer,
          location,
          estimatedUsefulLife,
          assetClassification,
          assetSubClass,
          specification,
          manufacturer,
          brand,
          model,
          serialNo,
          cellStyle,
        );

        totalRowsInserted++;
      } else {
        _updateRow(
          sheet,
          startRow + i,
          article,
          description,
          semiExpendablePropertyNo,
          unit,
          unitValue,
          totalQuantity,
          balanceAfterIssue,
          remarks,
          accountableOfficer,
          location,
          estimatedUsefulLife,
          assetClassification,
          assetSubClass,
          specification,
          manufacturer,
          brand,
          model,
          serialNo,
          cellStyle,
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
    String semiExpendablePropertyNo,
    String unit,
    double unitValue,
    dynamic totalQuantity,
    int balanceAfterIssue,
    String remarks,
    String? accountableOfficer,
    String? location,
    int? estimatedUsefulLife,
    String assetClassification,
    String assetSubClass,
    String? specification,
    String manufacturer,
    String brand,
    String model,
    String serialNo,
    CellStyle? dataCellStyle,
  ) {
    /// Merge columns B (1), C (2), D (3), and E (4) into a single cell
    final startDescriptionCell = CellIndex.indexByColumnRow(
      columnIndex: 1,
      rowIndex: rowIndex,
    );
    final endDescriptionCell = CellIndex.indexByColumnRow(
      columnIndex: 4,
      rowIndex: rowIndex,
    );

    sheet.merge(startDescriptionCell, endDescriptionCell);

    /// Add style to the merged cells
    for (int col = startDescriptionCell.columnIndex;
        col <= endDescriptionCell.columnIndex;
        col++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: col, rowIndex: rowIndex),
      );

      cell.cellStyle = dataCellStyle;
    }

    final cells = [
      CellInfo(0, article),
      CellInfo(1, description),
      CellInfo(5, semiExpendablePropertyNo),
      CellInfo(6, unit),
      CellInfo(7, unitValue.toString()),
      CellInfo(8, totalQuantity.toString()),
      CellInfo(9, balanceAfterIssue.toString()),
      const CellInfo(10, '0'),
      const CellInfo(11, '0'),
      CellInfo(12, remarks),
      const CellInfo(13, ''),
      CellInfo(14, accountableOfficer ?? ''),
      CellInfo(15, location ?? ''),
      const CellInfo(16, ''),
      CellInfo(17, estimatedUsefulLife.toString()),
      const CellInfo(18, ''),
      CellInfo(19, assetClassification),
      CellInfo(20, assetSubClass),
      CellInfo(21, specification ?? ''),
      CellInfo(22, manufacturer),
      CellInfo(23, brand),
      CellInfo(24, model),
      CellInfo(25, serialNo),
    ];

    for (var cellInfo in cells) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(
          columnIndex: cellInfo.columnIndex,
          rowIndex: rowIndex,
        ),
      );
      cell.value = TextCellValue(cellInfo.value);
      cell.cellStyle = dataCellStyle;
    }
  }

  static void _addFooter(
    Sheet sheet,
    int footerStartRow,
    List<Map<String, dynamic>>? certifyingOfficers,
    String? approvingEntityOrAuthorizedRepresentativeName,
    String? coaRepresentativeName,
    CellStyle? footerCellStyle,
  ) {
    int startingRow = footerStartRow + 2;
    int currentRow = startingRow;

    sheet
        .cell(
          CellIndex.indexByColumnRow(
            columnIndex: 0,
            rowIndex: footerStartRow,
          ),
        )
        .cellStyle = CellStyle(
      fontFamily: getFontFamily(FontFamily.Book_Antiqua),
      fontSize: 9,
      leftBorder: Border(
        borderStyle: BorderStyle.Medium,
      ),
    );

    if (certifyingOfficers != null && certifyingOfficers.isNotEmpty) {
      for (int i = 0; i < certifyingOfficers.length; i++) {
        final certifyingOfficer = certifyingOfficers[i];

        final startingCertifyingOfficerNameCell = sheet.cell(
          CellIndex.indexByColumnRow(
            columnIndex: 0,
            rowIndex: currentRow,
          ),
        );
        // startingCertifyingOfficerNameCell.cellStyle = CellStyle(
        //   leftBorder: Border(
        //     borderStyle: BorderStyle.Medium,
        //   ),
        // );

        // final endingCertifyingOfficerNameCell = sheet.cell(
        //   CellIndex.indexByColumnRow(
        //     columnIndex: 12,
        //     rowIndex: currentRow,
        //   ),
        // );
        // endingCertifyingOfficerNameCell.cellStyle = CellStyle(
        //   rightBorder: Border(
        //     borderStyle: BorderStyle.Medium,
        //   ),
        // );

        /// Certifying Officer Name
        /// Merge cells
        final startCertifyingOfficerNameCell = CellIndex.indexByColumnRow(
          columnIndex: 0,
          rowIndex: currentRow,
        );
        final endCertifyingOfficerNameCell = CellIndex.indexByColumnRow(
          columnIndex: 5,
          rowIndex: currentRow,
        );

        sheet.merge(
            startCertifyingOfficerNameCell, endCertifyingOfficerNameCell);

        for (int col = startCertifyingOfficerNameCell.columnIndex;
            col <= endCertifyingOfficerNameCell.columnIndex;
            col++) {
          final cell = sheet.cell(
            CellIndex.indexByColumnRow(columnIndex: col, rowIndex: currentRow),
          );

          // cell.cellStyle = CellStyle(
          //   bottomBorder: Border(
          //     borderStyle: BorderStyle.Thin,
          //   ),
          //   horizontalAlign: HorizontalAlign.Center,
          //   verticalAlign: VerticalAlign.Center,
          //);
        }

        /// Add value and style to Certifying Officer Name Cell
        final certifyingOfficerNameCell = sheet.cell(
          CellIndex.indexByColumnRow(
            columnIndex: 0,
            rowIndex: currentRow,
          ),
        );
        certifyingOfficerNameCell.value =
            TextCellValue(certifyingOfficer['name']);
        certifyingOfficerNameCell.cellStyle = CellStyle(
          horizontalAlign: HorizontalAlign.Center,
          verticalAlign: VerticalAlign.Center,
          leftBorder: Border(
            borderStyle: BorderStyle.Medium,
          ),
        );

        /// Add border right to the last cell of Certifying Officer Name
        final endingCertifyingOfficerNameCell = sheet.cell(
          CellIndex.indexByColumnRow(
            columnIndex: 12,
            rowIndex: currentRow,
          ),
        );
        endingCertifyingOfficerNameCell.cellStyle = CellStyle(
          rightBorder: Border(
            borderStyle: BorderStyle.Medium,
          ),
        );

        /// Certifying Officer Position
        /// Merge cells
        final startCertifyingOfficerPositionCell = CellIndex.indexByColumnRow(
          columnIndex: 0,
          rowIndex: currentRow + 1,
        );
        final endCertifyingOfficerPositionCell = CellIndex.indexByColumnRow(
          columnIndex: 5,
          rowIndex: currentRow + 1,
        );

        sheet.merge(
          startCertifyingOfficerPositionCell,
          endCertifyingOfficerPositionCell,
        );

        /// Add value and style to Certifying Officer Position Cell
        final certifyingOfficerPositionCell = sheet.cell(
          CellIndex.indexByColumnRow(
            columnIndex: 0,
            rowIndex: currentRow + 1,
          ),
        );
        certifyingOfficerPositionCell.value = TextCellValue(
          certifyingOfficer['position'],
        );
        certifyingOfficerPositionCell.cellStyle = footerCellStyle?.copyWith(
          horizontalAlignVal: HorizontalAlign.Center,
          verticalAlignVal: VerticalAlign.Center,
          leftBorderVal: Border(
            borderStyle: BorderStyle.Medium,
          ),
        );

        /// Add right border to the first cell of Certifying Officer Position
        final endingCertifyingOfficePositionCell = sheet.cell(
          CellIndex.indexByColumnRow(
            columnIndex: 12,
            rowIndex: currentRow + 1,
          ),
        );
        endingCertifyingOfficePositionCell.cellStyle = CellStyle(
          rightBorder: Border(
            borderStyle: BorderStyle.Medium,
          ),
        );

        final startingAllotedCell = sheet.cell(
          CellIndex.indexByColumnRow(
            columnIndex: 0,
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
            columnIndex: 12,
            rowIndex: currentRow + 2,
          ),
        );
        endingAllotedCell.cellStyle = CellStyle(
          rightBorder: Border(
            borderStyle: BorderStyle.Medium,
          ),
        );

        if (i == certifyingOfficers.length - 1) {
          for (int col = 0; col <= 12; col++) {
            final cell = sheet.cell(
              CellIndex.indexByColumnRow(
                columnIndex: col,
                rowIndex: currentRow + 3,
              ),
            );
            cell.cellStyle = CellStyle(
              horizontalAlign: HorizontalAlign.Center,
              verticalAlign: VerticalAlign.Center,
              rightBorder: col == 12
                  ? Border(
                      borderStyle: BorderStyle.Medium,
                    )
                  : null,
              bottomBorder: Border(
                borderStyle: BorderStyle.Medium,
              ),
              leftBorder: col == 0
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
      for (int col = 0; col <= 12; col++) {
        final cell = sheet.cell(
          CellIndex.indexByColumnRow(
            columnIndex: col,
            rowIndex: startingRow + 3,
          ),
        );
        cell.cellStyle = CellStyle(
          horizontalAlign: HorizontalAlign.Center,
          verticalAlign: VerticalAlign.Center,
          rightBorder: col == 12
              ? Border(
                  borderStyle: BorderStyle.Medium,
                )
              : null,
          bottomBorder: Border(
            borderStyle: BorderStyle.Medium,
          ),
          leftBorder: col == 0
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
        CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: startingRow);

    sheet.cell(startApprovingEntityOrAuthorizedRepresentativeCell).value =
        TextCellValue(approvingEntityOrAuthorizedRepresentativeName ??
            '_______________________________');

    print(
        'Debug: Cell value set for approvingEntityOrAuthorizedRepresentativeName = $approvingEntityOrAuthorizedRepresentativeName');

    sheet.merge(
      startApprovingEntityOrAuthorizedRepresentativeCell,
      endApprovingEntityOrAuthorizedRepresentativeCell,
    );

    for (int col = 6; col <= 10; col++) {
      final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: col, rowIndex: startingRow));
      cell.cellStyle = CellStyle(
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
      );
    }

    final startingApprovingEntityOrAuthorizedRepresentativeTitleCell =
        CellIndex.indexByColumnRow(
      columnIndex: 6,
      rowIndex: startingRow,
    );
    final endingApprovingEntityOrAuthorizedRepresentativeTitleCell =
        CellIndex.indexByColumnRow(
      columnIndex: 10,
      rowIndex: startingRow,
    );

    for (int col = 6; col <= 10; col++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(
          columnIndex: col,
          rowIndex: startingRow + 1,
        ),
      );
      cell.cellStyle = footerCellStyle;
      // CellStyle(
      //   horizontalAlign: HorizontalAlign.Center,
      //   verticalAlign: VerticalAlign.Center,
      //   topBorder: Border(
      //     borderStyle: BorderStyle.Thin,
      //   ),
      //   bottomBorder: Border(
      //     borderColorHex: ExcelColor.grey,
      //     borderStyle: BorderStyle.Thin,
      //   ),
      // );
    }

    sheet.merge(
      startingApprovingEntityOrAuthorizedRepresentativeTitleCell,
      endingApprovingEntityOrAuthorizedRepresentativeTitleCell,
    );

    /// Add Value to COA representative cell
    final coaRepresentativeCell = sheet.cell(
      CellIndex.indexByColumnRow(
        columnIndex: 11,
        rowIndex: startingRow,
      ),
    );
    coaRepresentativeCell.value = TextCellValue(
        coaRepresentativeName ?? '_______________________________');
    coaRepresentativeCell.cellStyle = CellStyle(
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
      underline: Underline.Single,
    );

    /// Manipulate COA representative title cell
    final coaRepresentativeTitleCell = sheet.cell(
      CellIndex.indexByColumnRow(
        columnIndex: 11,
        rowIndex: startingRow + 1,
      ),
    );
    coaRepresentativeTitleCell.cellStyle = footerCellStyle;

    /// Manipulate the right borders of some Cells
    // sheet
    //     .cell(
    //       CellIndex.indexByColumnRow(
    //         columnIndex: 12,
    //         rowIndex: startingRow,
    //       ),
    //     )
    //     .cellStyle = CellStyle(
    //   rightBorder: Border(
    //     borderColorHex: ExcelColor.black,
    //     borderStyle: BorderStyle.Medium,
    //   ),
    // );

    /// Add bottom border to the last row
    // final startingCell = CellIndex.indexByColumnRow(
    //   columnIndex: 0,
    //   rowIndex: startingRow + 2,
    // );
    // final endingCell = CellIndex.indexByColumnRow(
    //   columnIndex: 12,
    //   rowIndex: startingRow + 2,
    // );

    // for (int col = 0; col <= 12; col++) {
    //   final cell = sheet.cell(
    //     CellIndex.indexByColumnRow(
    //       columnIndex: col,
    //       rowIndex: startingRow + 2,
    //     ),
    //   );
    //   cell.cellStyle = CellStyle(
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
