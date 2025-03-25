import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';
import '../../../utils/capitalizer.dart';

/// Handles mapping of RPCI data to the Excel template
class ExcelRPCI {
  static void mapData(
    SpreadsheetDecoder decoder,
    String sheetName,
    dynamic data,
  ) {
    final accountableOfficer =
        data['accountable_officer'] as Map<String, String>?;
    final inventorySupplies =
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
    int startRow = 14;

    // Loop through inventory supplies and map data to rows
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

      // Insert a new row if needed
      if (i > 0) {
        final rowIndex = startRow + i - 1;
        decoder.insertRow(sheetName, rowIndex);

        // Update cells in the current row
        decoder.updateCell(sheetName, 1, rowIndex, article);
        decoder.updateCell(sheetName, 2, rowIndex, description);
        decoder.updateCell(sheetName, 3, rowIndex, stockNumber);
        decoder.updateCell(sheetName, 4, rowIndex, unit);
        decoder.updateCell(sheetName, 5, rowIndex, unitValue);
        decoder.updateCell(sheetName, 6, rowIndex, totalQuantity);
        decoder.updateCell(sheetName, 7, rowIndex, balanceAfterIssue);
        decoder.updateCell(sheetName, 10, rowIndex, remarks);
      }

      // Update cells in the current row
      decoder.updateCell(sheetName, 1, startRow + i, article);
      decoder.updateCell(sheetName, 2, startRow + i, description);
      decoder.updateCell(sheetName, 3, startRow + i, stockNumber);
      decoder.updateCell(sheetName, 4, startRow + i, unit);
      decoder.updateCell(sheetName, 5, startRow + i, unitValue);
      decoder.updateCell(sheetName, 6, startRow + i, totalQuantity);
      decoder.updateCell(sheetName, 7, startRow + i, balanceAfterIssue);
      decoder.updateCell(sheetName, 10, startRow + i, remarks);
    }
  }
}
