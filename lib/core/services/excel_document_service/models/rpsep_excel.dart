import 'package:excel/excel.dart';
import '../../../enums/asset_classification.dart';
import '../../../enums/asset_sub_class.dart';
import '../../../enums/fund_cluster.dart';
import '../../../utils/capitalizer.dart';

import '../../../utils/document_date_formatter.dart';
import '../../../utils/fund_cluster_to_readable_string.dart';
import '../../../utils/readable_enum_converter.dart';
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
    final startHeaderTopCell = CellIndex.indexByColumnRow(
      columnIndex: 0,
      rowIndex: 0,
    );
    final endHeaderTopCell = CellIndex.indexByColumnRow(
      columnIndex: 27,
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

    final type = sheet.cell(
      CellIndex.indexByString(
        'B3',
      ),
    );
    type.value = assetSubClass != null
        ? TextCellValue(assetSubClass)
        : TextCellValue('_________________________');
    type.cellStyle = CellStyle(
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );

    final regularCellStyle =
        sheet.cell(CellIndex.indexByString('B3')).cellStyle;

    final asAtDateCell = sheet.cell(
      CellIndex.indexByString(
        'B5',
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
      CellIndex.indexByString('B7'),
    );
    fundClusterCell.value = TextCellValue(
      'Fund Cluster: ${data['fund_cluster']}',
    );

    final accountableOfficerCell = sheet.cell(
      CellIndex.indexByString('B8'),
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
      regularCellStyle,
    );

    print('total rows inserted: $totalRowsInserted');

    int footerStartRow = 11 + totalRowsInserted + 1;
    final footerRows = _addFooter(
      sheet,
      footerStartRow,
      certifyingOfficers,
      approvingEntityOrAuthorizedRepresentative,
      coaRepresentative,
      regularCellStyle,
    );

    final startHeaderRightCell = CellIndex.indexByColumnRow(
      columnIndex: 27,
      rowIndex: 0,
    );
    final endHeaderRightCell = CellIndex.indexByColumnRow(
      columnIndex: 27,
      rowIndex: footerRows,
    );
    for (int row = startHeaderRightCell.rowIndex;
        row <= endHeaderRightCell.rowIndex;
        row++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(
          columnIndex: 27,
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
      rowIndex: footerRows,
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
        // bottomBorder: row == endHeaderLeftCell.rowIndex
        //     ? Border(
        //         borderStyle: BorderStyle.Medium,
        //         borderColorHex: ExcelColor.white,
        //       )
        //     : null,
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
      columnIndex: 27,
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

  static void _applyHeadersAndStyles(Sheet sheet, Border borderStyle) {
    // final headers = [
    //   const HeaderInfo('A10', 'A11', 'Article'),
    //   const HeaderInfo('B10', 'B11', 'Description'),
    //   const HeaderInfo('F10', 'F11', 'Semi-expendable Property No.'),
    //   const HeaderInfo('G10', 'G11', 'Unit of Measure'),
    //   const HeaderInfo('H10', 'H11', 'Unit Value'),
    //   const HeaderInfo('I10', 'I10', 'Balance Per Card'),
    //   const HeaderInfo('I11', 'I11', 'Quantity'),
    //   const HeaderInfo('J10', 'J10', 'On Hand Per Card'),
    //   const HeaderInfo('J11', 'J11', 'Quantity'),
    //   const HeaderInfo('K10', 'L10', 'Shortage/Overage'),
    //   const HeaderInfo('K11', 'K11', 'Quantity'),
    //   const HeaderInfo('L11', 'L11', 'Value'),
    //   const HeaderInfo('M10', 'M11', 'Remarks'),
    //   const HeaderInfo('N10', 'N11', 'Date Acquired'),
    //   const HeaderInfo('O10', 'O11', 'Accountable Officer'),
    //   const HeaderInfo('P10', 'P11', 'Location'),
    //   const HeaderInfo('Q10', 'Q11', 'Fund Cluster'),
    //   const HeaderInfo('R10', 'R11', 'Estimated Useful Life'),
    //   const HeaderInfo('S10', 'S11', 'Current Condiiton'),
    //   const HeaderInfo('T10', 'T11', 'Asset Classification'),
    //   const HeaderInfo('U10', 'U11', 'Asset Sub Class'),
    //   const HeaderInfo('V10', 'Z10', 'Description'),
    //   const HeaderInfo('V11', 'V11', 'Specification'),
    //   const HeaderInfo('W11', 'W11', 'Manufacturer'),
    //   const HeaderInfo('X11', 'X11', 'Brand'),
    //   const HeaderInfo('Y11', 'Y11', 'Model'),
    //   const HeaderInfo('Z11', 'Z11', 'Serial #'),
    // ];

    final headers = [
      const HeaderInfo('B10', 'B11', 'Article'),
      const HeaderInfo('C10', 'C11', 'Description'),
      const HeaderInfo('G10', 'G11', 'Semi-expendable Property No.'),
      const HeaderInfo('H10', 'H11', 'Unit of Measure'),
      const HeaderInfo('I10', 'I11', 'Unit Value'),
      const HeaderInfo('J10', 'J10', 'Balance Per Card'),
      const HeaderInfo('J11', 'J11', 'Quantity'),
      const HeaderInfo('K10', 'K10', 'On Hand Per Card'),
      const HeaderInfo('K11', 'K11', 'Quantity'),
      const HeaderInfo('L10', 'M10', 'Shortage/Overage'),
      const HeaderInfo('L11', 'L11', 'Quantity'),
      const HeaderInfo('M11', 'M11', 'Value'),
      const HeaderInfo('N10', 'N11', 'Remarks'),
      const HeaderInfo('O10', 'O11', 'Date Acquired'),
      const HeaderInfo('P10', 'P11', 'Accountable Officer'),
      const HeaderInfo('Q10', 'Q11', 'Location'),
      const HeaderInfo('R10', 'R11', 'Fund Cluster'),
      const HeaderInfo('S10', 'S11', 'Estimated Useful Life'),
      const HeaderInfo('T10', 'T11', 'Current Condiiton'),
      const HeaderInfo('U10', 'U11', 'Asset Classification'),
      const HeaderInfo('V10', 'V11', 'Asset Sub Class'),
      const HeaderInfo('W10', 'AA10', 'Description'),
      const HeaderInfo('W11', 'W11', 'Specification'),
      const HeaderInfo('X11', 'X11', 'Manufacturer'),
      const HeaderInfo('Y11', 'Y11', 'Brand'),
      const HeaderInfo('Z11', 'Z11', 'Model'),
      const HeaderInfo('AA11', 'AA11', 'Serial #'),
    ];

    for (var header in headers) {
      final startCellIndex = CellIndex.indexByString(header.startCell);
      final endCellIndex = CellIndex.indexByString(header.endCell);

      // Apply style to the first cell
      final startCell = sheet.cell(startCellIndex);
      startCell.value = TextCellValue(header.title);
      startCell.cellStyle = CellStyle(
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
    CellStyle? dataCellStyle,
  ) {
    int startRow = 11;
    int totalRowsInserted = 0;

    // Sort by 'date_acquired' in ascending order
    inventorySemiExpendableProperties.sort((a, b) {
      final dateA =
          DateTime.tryParse(a['date_acquired'] ?? '') ?? DateTime(1900);
      final dateB =
          DateTime.tryParse(b['date_acquired'] ?? '') ?? DateTime(1900);
      return dateA.compareTo(dateB);
    });

    for (int i = 0; i < inventorySemiExpendableProperties.length; i++) {
      final inventorySemiExpendableProperty =
          inventorySemiExpendableProperties[i];

      final article = inventorySemiExpendableProperty['article']
              ?.toString()
              .toUpperCase() ??
          'UNKNOWN';
      final desc = inventorySemiExpendableProperty['description'];
      final specs = inventorySemiExpendableProperty['specification'] ?? '';
      final manufacturer =
          inventorySemiExpendableProperty['manufacturer_name'] ?? '';
      final brand = inventorySemiExpendableProperty['brand_name'] ?? '';
      final model = inventorySemiExpendableProperty['model_name'] ?? '';
      final sn = inventorySemiExpendableProperty['serial_no'] ?? '';

      final description = manufacturer.trim().isNotEmpty &&
              brand.trim().isNotEmpty &&
              model.trim().isNotEmpty &&
              sn.trim().isNotEmpty
          ? '$brand $model with SN: $sn'
          : desc;

      final semiExpendablePropertyNo =
          inventorySemiExpendableProperty['semi_expendable_property_no'] ??
              'N/A';
      final unit = inventorySemiExpendableProperty['unit'] ?? 'N/A';

      final unitValue = double.parse(
          inventorySemiExpendableProperty['unit_value'].toString());

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

      final dateAcquired = documentDateFormatter(
          DateTime.parse(inventorySemiExpendableProperty['date_acquired']));

      final accountableOfficer = capitalizeWord(
          inventorySemiExpendableProperty['receiving_officer_name'] ?? '\n');
      final location = capitalizeWord(
          inventorySemiExpendableProperty['receiving_officer_office'] ?? '\n');

      final remarks = accountableOfficer.trim().isNotEmpty
          ? '${capitalizeWord(accountableOfficer)} - ${inventorySemiExpendableProperty['total_quantity_issued_for_a_particular_row']}'
          : '\n';

      FundCluster? matchedFundCluster;
      if (inventorySemiExpendableProperty['fund_cluster'] != null) {
        final match = FundCluster.values.where(
          (e) =>
              e.toString().split('.').last ==
              inventorySemiExpendableProperty['fund_cluster'],
        );
        if (match.isNotEmpty) {
          matchedFundCluster = match.first;
        }
      }
      final fundCluster = matchedFundCluster?.toReadableString() ?? '\n';

      final estimatedUsefulLife =
          inventorySemiExpendableProperty['estimated_useful_life'];
      final formattedEstimatedUsefulLife = estimatedUsefulLife != null
          ? estimatedUsefulLife > 1
              ? '$estimatedUsefulLife years'
              : '$estimatedUsefulLife year'
          : '\n';

      AssetClassification? matchedAssetClassification;
      if (inventorySemiExpendableProperty['asset_classification'] != null) {
        final match = AssetClassification.values.where(
          (e) =>
              e.toString().split('.').last ==
              inventorySemiExpendableProperty['asset_classification'],
        );
        if (match.isNotEmpty) {
          matchedAssetClassification = match.first;
        }
      }
      final assetClassification = matchedAssetClassification != null
          ? readableEnumConverter(matchedAssetClassification)
          : '\n';

      AssetSubClass? matchedAssetSubClass;
      if (inventorySemiExpendableProperty['asset_sub_class'] != null) {
        final match = AssetSubClass.values.where(
          (e) =>
              e.toString().split('.').last ==
              inventorySemiExpendableProperty['asset_sub_class'],
        );
        if (match.isNotEmpty) {
          matchedAssetSubClass = match.first;
        }
      }
      final assetSubClass = matchedAssetSubClass != null
          ? readableEnumConverter(matchedAssetSubClass)
          : '\n';

      final thinBorder = Border(borderStyle: BorderStyle.Thin);

      final cellStyle = dataCellStyle?.copyWith(
        horizontalAlignVal: HorizontalAlign.Center,
        verticalAlignVal: VerticalAlign.Center,
        topBorderVal: thinBorder,
        rightBorderVal: borderStyle,
        bottomBorderVal: thinBorder,
        leftBorderVal: borderStyle,
        textWrappingVal: TextWrapping.WrapText,
      );

      final rowIndex = startRow + i;

      if (i != inventorySemiExpendableProperties.length - 1) {
        sheet.insertRow(rowIndex);
        totalRowsInserted++;
      }

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
        dateAcquired,
        accountableOfficer,
        location,
        fundCluster,
        formattedEstimatedUsefulLife,
        assetClassification,
        assetSubClass,
        specs,
        manufacturer,
        brand,
        model,
        sn,
        cellStyle,
      );
    }

    return totalRowsInserted;
  }

  // static int _mapDataToCells(
  //   Sheet sheet,
  //   List<Map<String, dynamic>> inventorySemiExpendableProperties,
  //   Border borderStyle,
  //   CellStyle? dataCellStyle,
  // ) {
  //   int startRow = 11;
  //   int totalRowsInserted = 0;

  //   for (int i = 0; i < inventorySemiExpendableProperties.length; i++) {
  //     final inventorySemiExpendableProperty =
  //         inventorySemiExpendableProperties[i];

  //     print(
  //         'current inventory semi expendable property: $inventorySemiExpendableProperty');

  //     final article = inventorySemiExpendableProperty['article']
  //             ?.toString()
  //             .toUpperCase() ??
  //         'UNKNOWN';
  //     final desc = inventorySemiExpendableProperty['description'];
  //     final specs = inventorySemiExpendableProperty['specification'] ?? '\n';
  //     final manufacturer =
  //         inventorySemiExpendableProperty['manufacturer_name'] ?? '\n';
  //     final brand = inventorySemiExpendableProperty['brand_name'] ?? '\n';
  //     final model = inventorySemiExpendableProperty['model_name'] ?? '\n';
  //     final sn = inventorySemiExpendableProperty['serial_no'] ?? '\n';

  //     final description = manufacturer.trim().isNotEmpty &&
  //             brand.trim().isNotEmpty &&
  //             model.trim().isNotEmpty &&
  //             sn.trim().isNotEmpty
  //         ? '$brand $model with SN: $sn'
  //         : desc;

  //     final semiExpendablePropertyNo =
  //         inventorySemiExpendableProperty['semi_expendable_property_no'] ??
  //             'N/A';
  //     final unit = inventorySemiExpendableProperty['unit'] ?? 'N/A';

  //     final unitValue = double.parse(
  //         inventorySemiExpendableProperty['unit_value'].toString());

  //     // check 1st if we have bal from prev issue, if 0, check if totaal qty avail and issued is not empty, otherwise use current stock
  //     final totalQuantity = inventorySemiExpendableProperty[
  //                 'balance_from_previous_row_after_issuance'] ==
  //             0
  //         ? inventorySemiExpendableProperty[
  //                     'total_quantity_available_and_issued'] !=
  //                 null
  //             ? int.tryParse(inventorySemiExpendableProperty[
  //                         'total_quantity_available_and_issued']
  //                     ?.toString() ??
  //                 '0')
  //             : inventorySemiExpendableProperty['current_quantity_in_stock']
  //         : inventorySemiExpendableProperty[
  //             'balance_from_previous_row_after_issuance'];

  //     final balanceAfterIssue = int.tryParse(
  //             inventorySemiExpendableProperty['balance_per_row_after_issuance']
  //                     ?.toString() ??
  //                 '0') ??
  //         0;

  //     final dateAcquired = documentDateFormatter(
  //         DateTime.parse(inventorySemiExpendableProperty['date_acquired']));

  //     final accountableOfficer = capitalizeWord(
  //         inventorySemiExpendableProperty['receiving_officer_name'] ?? '\n');
  //     final location = capitalizeWord(
  //         inventorySemiExpendableProperty['receiving_officer_office'] ?? '\n');

  //     final remarks = accountableOfficer.trim().isNotEmpty
  //         ? '${capitalizeWord(accountableOfficer)} - ${inventorySemiExpendableProperty['total_quantity_issued_for_a_particular_row']}'
  //         : '\n';

  //     FundCluster? matchedFundCluster;
  //     if (inventorySemiExpendableProperty['fund_cluster'] != null) {
  //       final match = FundCluster.values.where(
  //         (e) =>
  //             e.toString().split('.').last ==
  //             inventorySemiExpendableProperty['fund_cluster'],
  //       );
  //       if (match.isNotEmpty) {
  //         matchedFundCluster = match.first;
  //       }
  //     }
  //     final fundCluster = matchedFundCluster?.toReadableString() ?? '\n';

  //     final estimatedUsefulLife =
  //         inventorySemiExpendableProperty['estimated_useful_life'];
  //     final formattedEstimatedUsefulLife = estimatedUsefulLife != null
  //         ? estimatedUsefulLife > 1
  //             ? '$estimatedUsefulLife years'
  //             : '$estimatedUsefulLife year'
  //         : '\n';

  //     AssetClassification? matchedAssetClassification;
  //     if (inventorySemiExpendableProperty['asset_classification'] != null) {
  //       final match = AssetClassification.values.where(
  //         (e) =>
  //             e.toString().split('.').last ==
  //             inventorySemiExpendableProperty['asset_classification'],
  //       );
  //       if (match.isNotEmpty) {
  //         matchedAssetClassification = match.first;
  //       }
  //     }
  //     final assetClassification = matchedAssetClassification != null
  //         ? readableEnumConverter(matchedAssetClassification)
  //         : '\n';

  //     AssetSubClass? matchedAssetSubClass;
  //     if (inventorySemiExpendableProperty['asset_sub_class'] != null) {
  //       final match = AssetSubClass.values.where(
  //         (e) =>
  //             e.toString().split('.').last ==
  //             inventorySemiExpendableProperty['asset_sub_class'],
  //       );
  //       if (match.isNotEmpty) {
  //         matchedAssetSubClass = match.first;
  //       }
  //     }
  //     final assetSubClass = matchedAssetSubClass != null
  //         ? readableEnumConverter(matchedAssetSubClass)
  //         : '\n';

  //     final thinBorder = Border(borderStyle: BorderStyle.Thin);

  //     /// the 2nd elem (index 1) will be at the top
  //     /// while the 1st elem (index 0) will be at the bottom
  //     final cellStyle = dataCellStyle?.copyWith(
  //       //   bold: false,
  //       //   fontFamily: getFontFamily(FontFamily.Book_Antiqua),
  //       //   fontSize: 9,
  //       horizontalAlignVal: HorizontalAlign.Center,
  //       verticalAlignVal: VerticalAlign.Center,
  //       topBorderVal: i == 1 ? borderStyle : thinBorder,
  //       rightBorderVal: borderStyle,
  //       bottomBorderVal: i == 0 ? borderStyle : thinBorder,
  //       leftBorderVal: borderStyle,
  //     );

  //     if (i > 0) {
  //       final rowIndex = startRow + i - 1;
  //       sheet.insertRow(rowIndex);
  //       _updateRow(
  //         sheet,
  //         rowIndex,
  //         article,
  //         description,
  //         semiExpendablePropertyNo,
  //         unit,
  //         unitValue,
  //         totalQuantity,
  //         balanceAfterIssue,
  //         remarks,
  //         dateAcquired,
  //         accountableOfficer,
  //         location,
  //         fundCluster,
  //         formattedEstimatedUsefulLife,
  //         assetClassification,
  //         assetSubClass,
  //         specs,
  //         manufacturer,
  //         brand,
  //         model,
  //         sn,
  //         cellStyle,
  //       );

  //       totalRowsInserted++;
  //     } else {
  //       _updateRow(
  //         sheet,
  //         startRow + i,
  //         article,
  //         description,
  //         semiExpendablePropertyNo,
  //         unit,
  //         unitValue,
  //         totalQuantity,
  //         balanceAfterIssue,
  //         remarks,
  //         dateAcquired,
  //         accountableOfficer,
  //         location,
  //         fundCluster,
  //         formattedEstimatedUsefulLife,
  //         assetClassification,
  //         assetSubClass,
  //         specs,
  //         manufacturer,
  //         brand,
  //         model,
  //         sn,
  //         cellStyle,
  //       );
  //     }
  //   }

  //   return totalRowsInserted;
  // }

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
    String dateAcquired,
    String accountableOfficer,
    String location,
    String fundCluster,
    String estimatedUsefulLife,
    String assetClassification,
    String assetSubClass,
    String specification,
    String manufacturer,
    String brand,
    String model,
    String serialNo,
    CellStyle? dataCellStyle,
  ) {
    /// Merge columns B (1), C (2), D (3), and E (4) into a single cell
    final startDescriptionCell = CellIndex.indexByColumnRow(
      columnIndex: 2,
      rowIndex: rowIndex,
    );
    final endDescriptionCell = CellIndex.indexByColumnRow(
      columnIndex: 5,
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
      CellInfo(1, article),
      CellInfo(2, description),
      CellInfo(6, semiExpendablePropertyNo.toString()),
      CellInfo(7, unit.toString()),
      CellInfo(8, unitValue.toString()),
      CellInfo(9, totalQuantity.toString()),
      CellInfo(10, balanceAfterIssue.toString()),
      const CellInfo(11, '0'),
      const CellInfo(12, '0'),
      CellInfo(13, remarks.toString()),
      CellInfo(14, dateAcquired.toString()),
      CellInfo(15, accountableOfficer.toString()),
      CellInfo(16, location.toString()),
      CellInfo(17, fundCluster.toString()),
      CellInfo(18, estimatedUsefulLife),
      const CellInfo(19, ''),
      CellInfo(20, assetClassification.toString()),
      CellInfo(21, assetSubClass.toString()),
      CellInfo(22, specification.toString()),
      CellInfo(23, manufacturer.toString()),
      CellInfo(24, brand.toString()),
      CellInfo(25, model.toString()),
      CellInfo(26, serialNo.toString()),
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

  static int _addFooter(
    Sheet sheet,
    int footerStartRow,
    List<Map<String, dynamic>>? certifyingOfficers,
    String? approvingEntityOrAuthorizedRepresentativeName,
    String? coaRepresentativeName,
    CellStyle? footerCellStyle,
  ) {
    int startingRow = footerStartRow + 2;
    int currentRow = startingRow;

    print('certifying officers: $certifyingOfficers');

    final calibriRegStyle = sheet
        .cell(
          CellIndex.indexByColumnRow(
            columnIndex: 7,
            rowIndex: footerStartRow,
          ),
        )
        .cellStyle;

    sheet
        .cell(
          CellIndex.indexByColumnRow(
            columnIndex: 1,
            rowIndex: footerStartRow,
          ),
        )
        .cellStyle = calibriRegStyle?.copyWith(
      leftBorderVal: Border(
        borderStyle: BorderStyle.Medium,
      ),
    );

    sheet
        .cell(
          CellIndex.indexByColumnRow(
            columnIndex: 12,
            rowIndex: footerStartRow,
          ),
        )
        .cellStyle = calibriRegStyle;

    print('certifying officers received by footer: $certifyingOfficers');

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

      /// Certifying Officer Name
      /// Merge cells
      final startCertifyingOfficerNameCell = CellIndex.indexByColumnRow(
        columnIndex: 1,
        rowIndex: currentRow,
      );
      final endCertifyingOfficerNameCell = CellIndex.indexByColumnRow(
        columnIndex: 6,
        rowIndex: currentRow,
      );

      sheet.merge(startCertifyingOfficerNameCell, endCertifyingOfficerNameCell);

      for (int col = startCertifyingOfficerNameCell.columnIndex;
          col <= endCertifyingOfficerNameCell.columnIndex;
          col++) {
        final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: col, rowIndex: currentRow),
        );
      }

      /// Add value and style to Certifying Officer Name Cell
      final certifyingOfficerNameCell = sheet.cell(
        CellIndex.indexByColumnRow(
          columnIndex: 1,
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
          columnIndex: 13,
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
        columnIndex: 1,
        rowIndex: currentRow + 1,
      );
      final endCertifyingOfficerPositionCell = CellIndex.indexByColumnRow(
        columnIndex: 6,
        rowIndex: currentRow + 1,
      );

      sheet.merge(
        startCertifyingOfficerPositionCell,
        endCertifyingOfficerPositionCell,
      );

      /// Add value and style to Certifying Officer Position Cell
      final certifyingOfficerPositionCell = sheet.cell(
        CellIndex.indexByColumnRow(
          columnIndex: 1,
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
          columnIndex: 13,
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
          columnIndex: 13,
          rowIndex: currentRow + 2,
        ),
      );
      endingAllotedCell.cellStyle = CellStyle(
        rightBorder: Border(
          borderStyle: BorderStyle.Medium,
        ),
      );

      if (i == certifyingOfficers.length - 1) {
        for (int col = 1; col <= 13; col++) {
          final cell = sheet.cell(
            CellIndex.indexByColumnRow(
              columnIndex: col,
              rowIndex: currentRow + 3,
            ),
          );
          cell.cellStyle = CellStyle(
            horizontalAlign: HorizontalAlign.Center,
            verticalAlign: VerticalAlign.Center,
            rightBorder: col == 13
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
        CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: startingRow);
    final endApprovingEntityOrAuthorizedRepresentativeCell =
        CellIndex.indexByColumnRow(columnIndex: 11, rowIndex: startingRow);

    sheet.cell(startApprovingEntityOrAuthorizedRepresentativeCell).value =
        TextCellValue(approvingEntityOrAuthorizedRepresentativeName ??
            '_______________________________');

    print(
        'Debug: Cell value set for approvingEntityOrAuthorizedRepresentativeName = $approvingEntityOrAuthorizedRepresentativeName');

    sheet.merge(
      startApprovingEntityOrAuthorizedRepresentativeCell,
      endApprovingEntityOrAuthorizedRepresentativeCell,
    );

    for (int col = 7; col <= 11; col++) {
      final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: col, rowIndex: startingRow));
      cell.cellStyle = CellStyle(
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
      );
    }

    final startingApprovingEntityOrAuthorizedRepresentativeTitleCell =
        CellIndex.indexByColumnRow(
      columnIndex: 7,
      rowIndex: startingRow,
    );
    final endingApprovingEntityOrAuthorizedRepresentativeTitleCell =
        CellIndex.indexByColumnRow(
      columnIndex: 11,
      rowIndex: startingRow,
    );

    for (int col = 7; col <= 11; col++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(
          columnIndex: col,
          rowIndex: startingRow,
        ),
      );
      cell.cellStyle = footerCellStyle;
    }

    sheet.merge(
      startingApprovingEntityOrAuthorizedRepresentativeTitleCell,
      endingApprovingEntityOrAuthorizedRepresentativeTitleCell,
    );

    /// Add Value to COA representative cell
    final coaRepresentativeCell = sheet.cell(
      CellIndex.indexByColumnRow(
        columnIndex: 12,
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
        columnIndex: 12,
        rowIndex: startingRow + 1,
      ),
    );
    coaRepresentativeTitleCell.cellStyle = footerCellStyle;

    /**
     * Impose left border to the ff. cells
     * */
    sheet
        .cell(
          CellIndex.indexByColumnRow(
            columnIndex: 14,
            rowIndex: startingRow - 2,
          ),
        )
        .cellStyle = CellStyle(
      leftBorder: Border(
        borderStyle: BorderStyle.Medium,
      ),
    );

    sheet
        .cell(
          CellIndex.indexByColumnRow(
            columnIndex: 14,
            rowIndex: startingRow - 1,
          ),
        )
        .cellStyle = CellStyle(
      leftBorder: Border(
        borderStyle: BorderStyle.Medium,
      ),
    );

    sheet
        .cell(
          CellIndex.indexByColumnRow(
            columnIndex: 14,
            rowIndex: startingRow,
          ),
        )
        .cellStyle = CellStyle(
      leftBorder: Border(
        borderStyle: BorderStyle.Medium,
      ),
    );

    sheet
        .cell(
          CellIndex.indexByColumnRow(
            columnIndex: 14,
            rowIndex: startingRow + 1,
          ),
        )
        .cellStyle = CellStyle(
      leftBorder: Border(
        borderStyle: BorderStyle.Medium,
      ),
    );

    sheet
        .cell(
          CellIndex.indexByColumnRow(
            columnIndex: 14,
            rowIndex: startingRow + 2,
          ),
        )
        .cellStyle = CellStyle(
      leftBorder: Border(
        borderStyle: BorderStyle.Medium,
      ),
    );

    return currentRow;
  }
}
