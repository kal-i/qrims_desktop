import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';
import '../../../utils/capitalizer.dart';

/// Handles mapping of RPCI data to the Excel template
class ExcelRPSEP {
  static void mapData(
    SpreadsheetDecoder decoder,
    String sheetName,
    dynamic data,
  ) {
    final accountableOfficer =
        data['accountable_officer'] as Map<String, String>?;
    final inventorySemiExpendableProperties =
        data['inventory_report'] as List<Map<String, dynamic>>;
    final approvingEntityOrAuthorizedRepresentative =
        data['approving_entity_or_authorized_representative'] as String?;
    final coaRepresentative = data['coa_representative'] as String?;
    final certifyingOfficers =
        data['certifying_officers'] as List<Map<String, dynamic>>?;

    // Map data to specific cells
    decoder.updateCell(sheetName, 1, 5, 'As at ${data['as_at_date']}');

    if (data['fund_cluster'] != null) {
      decoder.updateCell(
          sheetName, 1, 7, 'Fund Cluster: ${data['fund_cluster']}');
    }

    if (accountableOfficer != null && accountableOfficer.isNotEmpty) {
      decoder.updateCell(
        sheetName,
        1,
        9,
        'For which ${accountableOfficer['name']}, ${accountableOfficer['position']}, ${accountableOfficer['location']} is accountable, having assumed such accountability on ${accountableOfficer['accountability_date']} .',
      );
    }

    // Define the starting row for inventory supplies
    int startRow = 11;

    // Loop through inventory supplies and map data to rows
    for (int i = 0; i < inventorySemiExpendableProperties.length; i++) {
      final inventorySemiExpendableProperty =
          inventorySemiExpendableProperties[i];
      final article =
          inventorySemiExpendableProperty['article'].toString().toUpperCase();
      final description = inventorySemiExpendableProperty['description'];
      final semiExpendablePropertyNo =
          inventorySemiExpendableProperty['semi_expendable_property_no'];
      final unit = inventorySemiExpendableProperty['unit'];
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

      final remarks = inventorySemiExpendableProperty[
                  'receiving_officer_name'] !=
              null
          ? '${capitalizeWord(inventorySemiExpendableProperty['receiving_officer_name'])} - ${inventorySemiExpendableProperty['total_quantity_issued_for_a_particular_row']}'
          : '\n';

      // Insert a new row if needed
      if (i > 0) {
        final rowIndex = startRow + i - 1;
        decoder.insertRow(sheetName, rowIndex);

        // Update cells in the current row
        decoder.updateCell(sheetName, 0, rowIndex, article);
        decoder.updateCell(sheetName, 1, rowIndex, description);
        decoder.updateCell(sheetName, 5, rowIndex, semiExpendablePropertyNo);
        decoder.updateCell(sheetName, 6, rowIndex, unit);
        decoder.updateCell(sheetName, 7, rowIndex, unitValue);
        decoder.updateCell(sheetName, 8, rowIndex, totalQuantity);
        decoder.updateCell(sheetName, 9, rowIndex, balanceAfterIssue);
        decoder.updateCell(sheetName, 12, rowIndex, remarks);
      }

      // Update cells in the current row
      decoder.updateCell(sheetName, 0, startRow + i, article);
      decoder.updateCell(sheetName, 1, startRow + i, description);
      decoder.updateCell(sheetName, 5, startRow + i, semiExpendablePropertyNo);
      decoder.updateCell(sheetName, 6, startRow + i, unit);
      decoder.updateCell(sheetName, 7, startRow + i, unitValue);
      decoder.updateCell(sheetName, 8, startRow + i, totalQuantity);
      decoder.updateCell(sheetName, 9, startRow + i, balanceAfterIssue);
      decoder.updateCell(sheetName, 12, startRow + i, remarks);
    }
  }
}
