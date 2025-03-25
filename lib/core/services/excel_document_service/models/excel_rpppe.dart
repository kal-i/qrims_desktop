import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';
import '../../../utils/capitalizer.dart';

/// Handles mapping of RPCI data to the Excel template
class ExcelRPPPE {
  static void mapData(
    SpreadsheetDecoder decoder,
    String sheetName,
    dynamic data,
  ) {
    final accountableOfficer =
        data['accountable_officer'] as Map<String, String>?;
    final inventoryProperties =
        data['inventory_report'] as List<Map<String, dynamic>>;
    final approvingEntityOrAuthorizedRepresentative =
        data['approving_entity_or_authorized_representative'] as String?;
    final coaRepresentative = data['coa_representative'] as String?;
    final certifyingOfficers =
        data['certifying_officers'] as List<Map<String, dynamic>>?;

    // Map data to specific cells
    // decoder.updateCell(sheetName, 1, 5, 'As at ${data['as_at_date']}');

    // if (data['fund_cluster'] != null) {
    //   decoder.updateCell(
    //       sheetName, 1, 7, 'Fund Cluster: ${data['fund_cluster']}');
    // }

    // if (accountableOfficer != null && accountableOfficer.isNotEmpty) {
    //   decoder.updateCell(
    //     sheetName,
    //     1,
    //     9,
    //     'For which ${accountableOfficer['name']}, ${accountableOfficer['position']}, ${accountableOfficer['location']} is accountable, having assumed such accountability on ${accountableOfficer['accountability_date']} .',
    //   );
    // }

    // Define the starting row for inventory supplies
    int startRow = 13;

    // Loop through inventory supplies and map data to rows
    for (int i = 0; i < inventoryProperties.length; i++) {
      final inventoryProperty = inventoryProperties[i];
      final article = inventoryProperty['article'].toString().toUpperCase();
      final description = inventoryProperty['description'];
      final propertyNo = inventoryProperty['property_no'];
      final unit = inventoryProperty['unit'];
      final unitValue =
          double.parse(inventoryProperty['unit_value'].toString());

      final totalQuantity =
          inventoryProperty['balance_from_previous_row_after_issuance'] == 0
              ? inventoryProperty['total_quantity_available_and_issued'] != null
                  ? int.tryParse(
                      inventoryProperty['total_quantity_available_and_issued']
                              ?.toString() ??
                          '0')
                  : inventoryProperty['current_quantity_in_stock']
              : inventoryProperty['balance_from_previous_row_after_issuance'];

      final balanceAfterIssue = int.tryParse(
              inventoryProperty['balance_per_row_after_issuance']?.toString() ??
                  '0') ??
          0;

      final remarks = inventoryProperty['receiving_officer_name'] != null
          ? '${capitalizeWord(inventoryProperty['receiving_officer_name'])} - ${inventoryProperty['total_quantity_issued_for_a_particular_row']}'
          : '\n';

      // Insert a new row if needed
      if (i > 0) {
        final rowIndex = startRow + i - 1;
        decoder.insertRow(sheetName, rowIndex);

        // Update cells in the current row
        decoder.updateCell(sheetName, 2, rowIndex, article);
        decoder.updateCell(sheetName, 3, rowIndex, description);
        decoder.updateCell(sheetName, 7, rowIndex, propertyNo);
        decoder.updateCell(sheetName, 8, rowIndex, unit);
        decoder.updateCell(sheetName, 9, rowIndex, unitValue);
        decoder.updateCell(sheetName, 10, rowIndex, totalQuantity);
        decoder.updateCell(sheetName, 11, rowIndex, balanceAfterIssue);
        decoder.updateCell(sheetName, 14, rowIndex, remarks);
      }

      // Update cells in the current row
      decoder.updateCell(sheetName, 2, startRow + i, article);
      decoder.updateCell(sheetName, 3, startRow + i, description);
      decoder.updateCell(sheetName, 7, startRow + i, propertyNo);
      decoder.updateCell(sheetName, 8, startRow + i, unit);
      decoder.updateCell(sheetName, 9, startRow + i, unitValue);
      decoder.updateCell(sheetName, 10, startRow + i, totalQuantity);
      decoder.updateCell(sheetName, 11, startRow + i, balanceAfterIssue);
      decoder.updateCell(sheetName, 14, startRow + i, remarks);
    }
  }
}
