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
class RPPPEExcelDocument {
  static void modifyAndMapData(Sheet sheet, dynamic data) {
    print('modify and map data reached! $data');

    final assetSubClass = data['asset_sub_class'] as String?;
    final accountableOfficer =
        data['accountable_officer'] as Map<String, String>?;
    final inventorySemiExpendableProperties =
        data['inventory_report'] as List<Map<String, dynamic>>;
    final approvingEntityOrAuthorizedRepresentative =
        data['approving_entity_or_authorized_representative'] as String?;
    final coaRepresentative = data['coa_representative'] as String?;
    final certifyingOfficers =
        data['certifying_officers'] as List<Map<String, dynamic>>?;

    print('data to be map processed');

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

    final regStyle = CellStyle(
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
      // fontFamily: getFontFamily(FontFamily.Garamond),
      //underline: Underline.Double,
    );
    final timesRegStyle = sheet.cell(CellIndex.indexByString('C7')).cellStyle;

    final headerTitleCell = CellIndex.indexByString('C3');
    sheet.cell(headerTitleCell).cellStyle = regStyle;

    final type = sheet.cell(
      CellIndex.indexByString(
        'C4',
      ),
    );
    type.value = assetSubClass != null
        ? TextCellValue(assetSubClass)
        : TextCellValue('_________________________');
    type.cellStyle = CellStyle(
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );

    final typeTitleCell = sheet
        .cell(
          CellIndex.indexByString('C5'),
        )
        .cellStyle = regStyle;

    final asAtDateCell = sheet.cell(
      CellIndex.indexByString(
        'C6',
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
      CellIndex.indexByString('C9'),
    );
    fundClusterCell.value = TextCellValue(
      'Fund Cluster: ${data['fund_cluster']}',
    );
    fundClusterCell.cellStyle = timesRegStyle;

    final accountableOfficerCell = sheet.cell(
      CellIndex.indexByString('C10'),
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
    accountableOfficerCell.cellStyle = timesRegStyle;

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

    // print('total rows inserted: $totalRowsInserted');

    int footerStartRow = 12 + totalRowsInserted + 1;
    final footerRows = _addFooter(
      sheet,
      footerStartRow,
      certifyingOfficers,
      approvingEntityOrAuthorizedRepresentative,
      coaRepresentative,
      regStyle,
    );

    final startHeaderRightCell = CellIndex.indexByColumnRow(
      columnIndex: 28,
      rowIndex: 0,
    );
    final endHeaderRightCell = CellIndex.indexByColumnRow(
      columnIndex: 28,
      rowIndex: footerRows,
    );
    for (int row = startHeaderRightCell.rowIndex;
        row <= endHeaderRightCell.rowIndex;
        row++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(
          columnIndex: 28,
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
        leftBorder: row == 0
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
      columnIndex: 28,
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
    final headers = [
      const HeaderInfo('C12', 'C13', 'Article'),
      const HeaderInfo('D12', 'D13', 'Description'),
      const HeaderInfo('H12', 'H13', 'Property Number'),
      const HeaderInfo('I12', 'I13', 'Unit of Measure'),
      const HeaderInfo('J12', 'J13', 'Unit Value'),
      const HeaderInfo('K12', 'K12', 'Quantity Per'),
      const HeaderInfo('K13', 'K13', 'Property Card'),
      const HeaderInfo('L12', 'L12', 'Quantity Per'),
      const HeaderInfo('L13', 'L13', 'Physical Count'),
      const HeaderInfo('M12', 'N12', 'Shortage/Overage'),
      const HeaderInfo('M13', 'M13', 'Quantity'),
      const HeaderInfo('N13', 'N13', 'Value'),
      const HeaderInfo('O12', 'O13', 'Remarks'),
      const HeaderInfo('P12', 'P13', 'Date Acquired'),
      const HeaderInfo('Q12', 'Q13', 'Accountable Officer'),
      const HeaderInfo('R12', 'R13', 'Location'),
      const HeaderInfo('S12', 'S13', 'Fund Cluster'),
      const HeaderInfo('T12', 'T13', 'Estimated Useful Life'),
      const HeaderInfo('U12', 'U13', 'Current Condiiton'),
      const HeaderInfo('V12', 'V13', 'Asset Classification'),
      const HeaderInfo('W12', 'W13', 'Asset Sub Class'),
      const HeaderInfo('X12', 'AB12', 'Description'),
      const HeaderInfo('X13', 'X13', 'Specification'),
      const HeaderInfo('Y13', 'Y13', 'Manufacturer'),
      const HeaderInfo('Z13', 'Z13', 'Brand'),
      const HeaderInfo('AA13', 'AA13', 'Model'),
      const HeaderInfo('AB13', 'AB13', 'Serial #'),
    ];

    final cellStyle = sheet.cell(CellIndex.indexByString('C14')).cellStyle;

    for (var header in headers) {
      final startCellIndex = CellIndex.indexByString(header.startCell);
      final endCellIndex = CellIndex.indexByString(header.endCell);

      // Apply style to the first cell
      final startCell = sheet.cell(startCellIndex);
      startCell.value = TextCellValue(header.title);
      startCell.cellStyle = cellStyle;
      // startCell.cellStyle = CellStyle(
      //   bold: false,
      //   underline: Underline.None,
      //   //   //   // italic: false,
      //   //   //   fontSize: 9,
      //   //   underline: Underline.None,
      //   horizontalAlign: HorizontalAlign.Center,
      //   verticalAlign: VerticalAlign.Center,
      //   topBorder: borderStyle,
      //   bottomBorder: borderStyle,
      //   leftBorder: borderStyle,
      //   rightBorder: borderStyle,
      // );

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
            // cell.cellStyle = CellStyle(
            //   // bold: false,
            //   // underline: Underline.None,
            //   //   // italic: false,
            //   //   fontSize: 9,
            //   horizontalAlign: HorizontalAlign.Center,
            //   verticalAlign: VerticalAlign.Center,
            //   //leftBorder: borderStyle, // Ensure left border
            //   //rightBorder: borderStyle, // Ensure right border
            // );
          }
        }
      }
    }
  }

  static int _mapDataToCells(
    Sheet sheet,
    List<Map<String, dynamic>> inventoryProperties,
    Border borderStyle,
  ) {
    inventoryProperties.sort((a, b) {
      final idA = a['base_item_id'] ?? 0;
      final idB = b['base_item_id'] ?? 0;
      return idA.compareTo(idB);
    });

    print('sorted: $inventoryProperties');

    int startRow = 13;
    int totalRowsInserted = 0;

    for (int i = inventoryProperties.length - 1; i >= 0; i--) {
      final inventoryProperty = inventoryProperties[i];
      final rowIndex = startRow;

      // Insert a row only if it's not the last one (which will use the original template row)
      if (i != inventoryProperties.length - 1) {
        sheet.insertRow(rowIndex);
        totalRowsInserted++;
      }

      // Mapping logic (unchanged except for style object reused here)
      final article =
          inventoryProperty['article']?.toString().toUpperCase() ?? 'UNKNOWN';
      final desc = inventoryProperty['description'];
      final specs = inventoryProperty['specification'] ?? '';
      final manufacturer = inventoryProperty['manufacturer_name'] ?? '';
      final brand = inventoryProperty['brand_name'] ?? '';
      final model = inventoryProperty['model_name'] ?? '';
      final sn = inventoryProperty['serial_no'] ?? '';

      final description = manufacturer.trim().isNotEmpty &&
              brand.trim().isNotEmpty &&
              model.trim().isNotEmpty &&
              sn.trim().isNotEmpty
          ? '$brand $model with SN: $sn'
          : desc;

      final propertyNo = inventoryProperty['property_no'] ?? 'N/A';
      final unit = inventoryProperty['unit'] ?? 'N/A';

      final unitValue =
          double.parse(inventoryProperty['unit_value'].toString());

      final totalQuantity = inventoryProperty[
                  'balance_from_previous_row_after_issuance'] ==
              0
          ? inventoryProperty['total_quantity_available_and_issued'] != null
              ? int.tryParse(
                      inventoryProperty['total_quantity_available_and_issued']
                              ?.toString() ??
                          '0') ??
                  0
              : inventoryProperty['current_quantity_in_stock'] ?? 0
          : inventoryProperty['balance_from_previous_row_after_issuance'] ?? 0;

      final balanceAfterIssue = int.tryParse(
              inventoryProperty['balance_per_row_after_issuance']?.toString() ??
                  '0') ??
          0;

      final dateAcquired = documentDateFormatter(
          DateTime.parse(inventoryProperty['date_acquired']));

      final accountableOfficer =
          capitalizeWord(inventoryProperty['receiving_officer_name'] ?? '\n');
      final location =
          capitalizeWord(inventoryProperty['receiving_officer_office'] ?? '\n');

      final remarks = accountableOfficer.trim().isNotEmpty
          ? '${capitalizeWord(accountableOfficer)} - ${inventoryProperty['total_quantity_issued_for_a_particular_row']}'
          : '\n';

      FundCluster? matchedFundCluster;
      if (inventoryProperty['fund_cluster'] != null) {
        final match = FundCluster.values.where(
          (e) =>
              e.toString().split('.').last == inventoryProperty['fund_cluster'],
        );
        if (match.isNotEmpty) matchedFundCluster = match.first;
      }
      final fundCluster = matchedFundCluster?.toReadableString() ?? '\n';

      final estimatedUsefulLife = inventoryProperty['estimated_useful_life'];
      final formattedEstimatedUsefulLife = estimatedUsefulLife != null
          ? estimatedUsefulLife > 1
              ? '$estimatedUsefulLife years'
              : '$estimatedUsefulLife year'
          : '\n';

      AssetClassification? matchedAssetClassification;
      if (inventoryProperty['asset_classification'] != null) {
        final match = AssetClassification.values.where(
          (e) =>
              e.toString().split('.').last ==
              inventoryProperty['asset_classification'],
        );
        if (match.isNotEmpty) matchedAssetClassification = match.first;
      }
      final assetClassification = matchedAssetClassification != null
          ? readableEnumConverter(matchedAssetClassification)
          : '\n';

      AssetSubClass? matchedAssetSubClass;
      if (inventoryProperty['asset_sub_class'] != null) {
        final match = AssetSubClass.values.where(
          (e) =>
              e.toString().split('.').last ==
              inventoryProperty['asset_sub_class'],
        );
        if (match.isNotEmpty) matchedAssetSubClass = match.first;
      }
      final assetSubClass = matchedAssetSubClass != null
          ? readableEnumConverter(matchedAssetSubClass)
          : '\n';

      final thinBorder = Border(borderStyle: BorderStyle.Thin);
      final cellStyle =
          sheet.cell(CellIndex.indexByString('C14')).cellStyle = CellStyle(
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
        topBorder: thinBorder,
        rightBorder: borderStyle,
        bottomBorder: thinBorder,
        leftBorder: borderStyle,
        textWrapping: TextWrapping.WrapText,
      );

      _updateRow(
        sheet,
        rowIndex,
        article,
        description,
        propertyNo,
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
  //   List<Map<String, dynamic>> inventoryProperties,
  //   Border borderStyle,
  //   //CellStyle? cellStyle,
  // ) {
  //   inventoryProperties.sort((a, b) {
  //     final idA = a['base_item_id'] ?? 0;
  //     final idB = b['base_item_id'] ?? 0;
  //     return idA.compareTo(idB);
  //   });

  //   print('sorted: $inventoryProperties');

  //   int startRow = 13;
  //   int totalRowsInserted = 0;

  //   for (int i = 0; i < inventoryProperties.length; i++) {
  //     final inventoryProperty = inventoryProperties[i];

  //     print('current inventory property: $inventoryProperty');

  //     final article =
  //         inventoryProperty['article']?.toString().toUpperCase() ?? 'UNKNOWN';
  //     final desc = inventoryProperty['description'];
  //     final specs = inventoryProperty['specification'] ?? '\n';
  //     final manufacturer = inventoryProperty['manufacturer_name'] ?? '\n';
  //     final brand = inventoryProperty['brand_name'] ?? '\n';
  //     final model = inventoryProperty['model_name'] ?? '\n';
  //     final sn = inventoryProperty['serial_no'] ?? '\n';

  //     final description = manufacturer.trim().isNotEmpty &&
  //             brand.trim().isNotEmpty &&
  //             model.trim().isNotEmpty &&
  //             sn.trim().isNotEmpty
  //         ? '$brand $model with SN: $sn'
  //         : desc;

  //     final propertyNo = inventoryProperty['property_no'] ?? 'N/A';
  //     final unit = inventoryProperty['unit'] ?? 'N/A';

  //     final unitValue =
  //         double.parse(inventoryProperty['unit_value'].toString());

  //     // check 1st if we have bal from prev issue, if 0, check if totaal qty avail and issued is not empty, otherwise use current stock
  //     final totalQuantity = inventoryProperty[
  //                 'balance_from_previous_row_after_issuance'] ==
  //             0
  //         ? inventoryProperty['total_quantity_available_and_issued'] != null
  //             ? int.tryParse(
  //                     inventoryProperty['total_quantity_available_and_issued']
  //                             ?.toString() ??
  //                         '0') ??
  //                 0
  //             : inventoryProperty['current_quantity_in_stock'] ?? 0
  //         : inventoryProperty['balance_from_previous_row_after_issuance'] ?? 0;

  //     final balanceAfterIssue = int.tryParse(
  //             inventoryProperty['balance_per_row_after_issuance']?.toString() ??
  //                 '0') ??
  //         0;

  //     final dateAcquired = documentDateFormatter(
  //         DateTime.parse(inventoryProperty['date_acquired']));

  //     final accountableOfficer =
  //         capitalizeWord(inventoryProperty['receiving_officer_name'] ?? '\n');
  //     final location =
  //         capitalizeWord(inventoryProperty['receiving_officer_office'] ?? '\n');

  //     final remarks = accountableOfficer.trim().isNotEmpty
  //         ? '${capitalizeWord(accountableOfficer)} - ${inventoryProperty['total_quantity_issued_for_a_particular_row']}'
  //         : '\n';

  //     FundCluster? matchedFundCluster;
  //     if (inventoryProperty['fund_cluster'] != null) {
  //       final match = FundCluster.values.where(
  //         (e) =>
  //             e.toString().split('.').last == inventoryProperty['fund_cluster'],
  //       );
  //       if (match.isNotEmpty) {
  //         matchedFundCluster = match.first;
  //       }
  //     }
  //     final fundCluster = matchedFundCluster?.toReadableString() ?? '\n';

  //     final estimatedUsefulLife = inventoryProperty['estimated_useful_life'];
  //     final formattedEstimatedUsefulLife = estimatedUsefulLife != null
  //         ? estimatedUsefulLife > 1
  //             ? '$estimatedUsefulLife years'
  //             : '$estimatedUsefulLife year'
  //         : '\n';

  //     AssetClassification? matchedAssetClassification;
  //     if (inventoryProperty['asset_classification'] != null) {
  //       final match = AssetClassification.values.where(
  //         (e) =>
  //             e.toString().split('.').last ==
  //             inventoryProperty['asset_classification'],
  //       );
  //       if (match.isNotEmpty) {
  //         matchedAssetClassification = match.first;
  //       }
  //     }
  //     final assetClassification = matchedAssetClassification != null
  //         ? readableEnumConverter(matchedAssetClassification)
  //         : '\n';

  //     AssetSubClass? matchedAssetSubClass;
  //     if (inventoryProperty['asset_sub_class'] != null) {
  //       final match = AssetSubClass.values.where(
  //         (e) =>
  //             e.toString().split('.').last ==
  //             inventoryProperty['asset_sub_class'],
  //       );
  //       if (match.isNotEmpty) {
  //         matchedAssetSubClass = match.first;
  //       }
  //     }
  //     final assetSubClass = matchedAssetSubClass != null
  //         ? readableEnumConverter(matchedAssetSubClass)
  //         : '\n';

  //     // final thinBorder = Border(borderStyle: BorderStyle.Thin);

  //     /// the 2nd elem (index 1) will be at the top
  //     /// while the 1st elem (index 0) will be at the bottom
  //     // final cellStyle = CellStyle(
  //     //   bold: false,
  //     //   fontFamily: getFontFamily(FontFamily.Book_Antiqua),
  //     //   fontSize: 9,
  //     //   horizontalAlign: HorizontalAlign.Center,
  //     //   verticalAlign: VerticalAlign.Center,
  //     //   topBorder: i == 1 ? borderStyle : thinBorder,
  //     //   rightBorder: borderStyle,
  //     //   bottomBorder: i == 0 ? borderStyle : thinBorder,
  //     //   leftBorder: borderStyle,
  //     // );

  //     final thinBorder = Border(borderStyle: BorderStyle.Thin);
  //     final cellStyle =
  //         sheet.cell(CellIndex.indexByString('C14')).cellStyle = CellStyle(
  //       horizontalAlign: HorizontalAlign.Center,
  //       verticalAlign: VerticalAlign.Center,
  //       topBorder: i == 0 ? borderStyle : thinBorder,
  //       rightBorder: borderStyle,
  //       //bottomBorder: i == 0 ? borderStyle : thinBorder,
  //       leftBorder: borderStyle,
  //     );
  //     // ?.copyWith(
  //     //       horizontalAlignVal: HorizontalAlign.Center,
  //     //       verticalAlignVal: VerticalAlign.Center,
  //     //       topBorderVal: Border(
  //     //         borderStyle: BorderStyle.Thin,
  //     //       ),
  //     //       bottomBorderVal: Border(
  //     //         borderStyle: BorderStyle.Thin,
  //     //       ),
  //     //     );

  //     print('reached here!');

  //     if (i > 0) {
  //       final rowIndex = startRow + i - 1;
  //       sheet.insertRow(rowIndex);
  //       _updateRow(
  //         sheet,
  //         rowIndex,
  //         article,
  //         description,
  //         propertyNo,
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
  //         propertyNo,
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
    String propertyNo,
    String unit,
    double unitValue,
    int totalQuantity,
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
      columnIndex: 3,
      rowIndex: rowIndex,
    );
    final endDescriptionCell = CellIndex.indexByColumnRow(
      columnIndex: 6,
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
      CellInfo(2, article),
      CellInfo(3, description),
      CellInfo(7, propertyNo),
      CellInfo(8, unit),
      CellInfo(9, unitValue.toString()),
      CellInfo(10, totalQuantity.toString()),
      CellInfo(11, balanceAfterIssue.toString()),
      const CellInfo(12, '0'),
      const CellInfo(13, '0'),
      CellInfo(14, remarks),
      CellInfo(15, dateAcquired),
      CellInfo(16, accountableOfficer),
      CellInfo(17, location),
      CellInfo(18, fundCluster),
      CellInfo(19, estimatedUsefulLife),
      const CellInfo(20, ''),
      CellInfo(21, assetClassification),
      CellInfo(22, assetSubClass),
      CellInfo(23, specification),
      CellInfo(24, manufacturer),
      CellInfo(25, brand),
      CellInfo(26, model),
      CellInfo(27, serialNo),
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
    int startingRow = footerStartRow + 4;
    int currentRow = startingRow;

    sheet
        .cell(
          CellIndex.indexByColumnRow(
            columnIndex: 2,
            rowIndex: footerStartRow + 2,
          ),
        )
        .cellStyle = CellStyle(
      leftBorder: Border(
        borderStyle: BorderStyle.Medium,
      ),
    );

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

      /// Add left border to the first cell of Certifying Officer Name
      final startingCertifyingOfficerNameCell = sheet.cell(
        CellIndex.indexByColumnRow(
          columnIndex: 2,
          rowIndex: currentRow,
        ),
      );
      startingCertifyingOfficerNameCell.cellStyle = CellStyle(
        leftBorder: Border(
          borderStyle: BorderStyle.Medium,
        ),
      );

      /// Certifying Officer Name
      /// Merge cells
      final startCertifyingOfficerNameCell = CellIndex.indexByColumnRow(
        columnIndex: 3,
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

      //       // cell.cellStyle = CellStyle(
      //       //   bottomBorder: Border(
      //       //     borderStyle: BorderStyle.Thin,
      //       //   ),
      //       //   horizontalAlign: HorizontalAlign.Center,
      //       //   verticalAlign: VerticalAlign.Center,
      //       //);
      //     }

      /// Add value and style to Certifying Officer Name Cell
      final certifyingOfficerNameCell = sheet.cell(
        CellIndex.indexByColumnRow(
          columnIndex: 3,
          rowIndex: currentRow,
        ),
      );
      certifyingOfficerNameCell.value =
          TextCellValue(certifyingOfficer['name']);
      certifyingOfficerNameCell.cellStyle = CellStyle(
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
      );

      /// Add border right to the last cell of Certifying Officer Name
      final endingCertifyingOfficerNameCell = sheet.cell(
        CellIndex.indexByColumnRow(
          columnIndex: 14,
          rowIndex: currentRow,
        ),
      );
      endingCertifyingOfficerNameCell.cellStyle = CellStyle(
        rightBorder: Border(
          borderStyle: BorderStyle.Medium,
        ),
      );

      /// Add left border to the first cell of Certifying Officer Position
      final startingCertifyingOfficePositionCell = sheet.cell(
        CellIndex.indexByColumnRow(
          columnIndex: 2,
          rowIndex: currentRow + 1,
        ),
      );
      startingCertifyingOfficePositionCell.cellStyle = CellStyle(
        leftBorder: Border(
          borderStyle: BorderStyle.Medium,
        ),
      );

      /// Certifying Officer Position
      /// Merge cells
      final startCertifyingOfficerPositionCell = CellIndex.indexByColumnRow(
        columnIndex: 3,
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
          columnIndex: 3,
          rowIndex: currentRow + 1,
        ),
      );
      certifyingOfficerPositionCell.value = TextCellValue(
        certifyingOfficer['position'],
      );
      certifyingOfficerPositionCell.cellStyle = footerCellStyle?.copyWith(
        horizontalAlignVal: HorizontalAlign.Center,
        verticalAlignVal: VerticalAlign.Center,
      );

      /// Add right border to the last cell of Certifying Officer Position
      final endingCertifyingOfficePositionCell = sheet.cell(
        CellIndex.indexByColumnRow(
          columnIndex: 14,
          rowIndex: currentRow + 1,
        ),
      );
      endingCertifyingOfficePositionCell.cellStyle = CellStyle(
        rightBorder: Border(
          borderStyle: BorderStyle.Medium,
        ),
      );

      /// Add left border to the first allotted cell
      final startingAllotedCell = sheet.cell(
        CellIndex.indexByColumnRow(
          columnIndex: 2,
          rowIndex: currentRow + 2,
        ),
      );
      startingAllotedCell.cellStyle = CellStyle(
        leftBorder: Border(
          borderStyle: BorderStyle.Medium,
        ),
      );

      /// Add right border to the last allotted cell
      final endingAllotedCell = sheet.cell(
        CellIndex.indexByColumnRow(
          columnIndex: 14,
          rowIndex: currentRow + 2,
        ),
      );
      endingAllotedCell.cellStyle = CellStyle(
        rightBorder: Border(
          borderStyle: BorderStyle.Medium,
        ),
      );

      if (i == certifyingOfficers.length - 1) {
        for (int col = 2; col <= 14; col++) {
          final cell = sheet.cell(
            CellIndex.indexByColumnRow(
              columnIndex: col,
              rowIndex: currentRow + 3,
            ),
          );
          cell.cellStyle = CellStyle(
            horizontalAlign: HorizontalAlign.Center,
            verticalAlign: VerticalAlign.Center,
            rightBorder: col == 14
                ? Border(
                    borderStyle: BorderStyle.Medium,
                  )
                : null,
            bottomBorder: Border(
              borderStyle: BorderStyle.Medium,
            ),
            leftBorder: col == 2
                ? Border(
                    borderStyle: BorderStyle.Medium,
                  )
                : null,
          );
        }
      }

      /// Add spacing row after each officer
      currentRow += 3;
    }

    // ** Add Approving Entity (Merged Cells with Borders) **
    final startApprovingEntityOrAuthorizedRepresentativeCell =
        CellIndex.indexByColumnRow(
      columnIndex: 9,
      rowIndex: startingRow,
    );
    final endApprovingEntityOrAuthorizedRepresentativeCell =
        CellIndex.indexByColumnRow(
      columnIndex: 11,
      rowIndex: startingRow,
    );

    sheet.cell(startApprovingEntityOrAuthorizedRepresentativeCell).value =
        TextCellValue(approvingEntityOrAuthorizedRepresentativeName ??
            '_______________________________');

    sheet.merge(
      startApprovingEntityOrAuthorizedRepresentativeCell,
      endApprovingEntityOrAuthorizedRepresentativeCell,
    );

    for (int col =
            startApprovingEntityOrAuthorizedRepresentativeCell.columnIndex;
        col <= endApprovingEntityOrAuthorizedRepresentativeCell.columnIndex;
        col++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(
          columnIndex: col,
          rowIndex: startingRow,
        ),
      );
      cell.cellStyle = CellStyle(
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
      );
    }

    final startApprovingEntityOrAuthorizedRepresentativeTitleCell =
        CellIndex.indexByColumnRow(
      columnIndex: 9,
      rowIndex: startingRow + 1,
    );
    final endApprovingEntityOrAuthorizedRepresentativeTitleCell =
        CellIndex.indexByColumnRow(
      columnIndex: 11,
      rowIndex: startingRow + 1,
    );

    sheet.merge(
      startApprovingEntityOrAuthorizedRepresentativeTitleCell,
      endApprovingEntityOrAuthorizedRepresentativeTitleCell,
    );

    for (int col =
            startApprovingEntityOrAuthorizedRepresentativeTitleCell.columnIndex;
        col <=
            endApprovingEntityOrAuthorizedRepresentativeTitleCell.columnIndex;
        col++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(
          columnIndex: col,
          rowIndex: startingRow + 1,
        ),
      );
      cell.cellStyle = CellStyle(
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
      );
    }

    /// Add Value to COA representative cell
    final startCoaRepresentativeCell = CellIndex.indexByColumnRow(
      columnIndex: 13,
      rowIndex: startingRow,
    );
    final endCoaRepresentativeCell = CellIndex.indexByColumnRow(
      columnIndex: 14,
      rowIndex: startingRow,
    );

    sheet.cell(startCoaRepresentativeCell).value = TextCellValue(
        coaRepresentativeName ?? '_______________________________');
    sheet.cell(startCoaRepresentativeCell).cellStyle = CellStyle(
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
      underline: Underline.Single,
    );

    sheet.merge(
      startCoaRepresentativeCell,
      endCoaRepresentativeCell,
    );

    final startCoaRepresentativeTitleCell = CellIndex.indexByColumnRow(
      columnIndex: 13,
      rowIndex: startingRow + 1,
    );
    final endCoaRepresentativeTitleCell = CellIndex.indexByColumnRow(
      columnIndex: 14,
      rowIndex: startingRow + 1,
    );

    sheet.merge(
      startCoaRepresentativeTitleCell,
      endCoaRepresentativeTitleCell,
    );

    for (int col = startCoaRepresentativeTitleCell.columnIndex;
        col <= endCoaRepresentativeTitleCell.columnIndex;
        col++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(
          columnIndex: col,
          rowIndex: startingRow + 1,
        ),
      );
      cell.cellStyle = CellStyle(
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
      );
    }

    return currentRow;
  }
}
