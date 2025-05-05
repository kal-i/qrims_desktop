import 'package:excel/excel.dart';
import '../../../enums/fund_cluster.dart';
import '../../../utils/fund_cluster_to_readable_string.dart';
import 'base_excel_document.dart';

class OfficerAccountabilityDocument extends BaseExcelDocument {
  @override
  Future<Excel> generate({required data}) async {
    print('received data by excel template: $data');

    final excel = Excel.createExcel();
    if (excel.sheets.containsKey('Sheet1')) {
      excel.sheets.remove('Sheet1');
    }

    final sheet = excel['Accountability'];
    excel.setDefaultSheet('Accountability');

    final officer = data['officer'];
    final accountabilities =
        List<Map<String, dynamic>>.from(data['accountabilities']);

    // Officer info
    sheet.cell(CellIndex.indexByString("A1")).value = TextCellValue('Name');
    sheet.cell(CellIndex.indexByString("B1")).value =
        TextCellValue(officer['name'] ?? '');

    sheet.cell(CellIndex.indexByString("A2")).value = TextCellValue('Office');
    sheet.cell(CellIndex.indexByString("B2")).value =
        TextCellValue(officer['office'] ?? '');

    sheet.cell(CellIndex.indexByString("A3")).value = TextCellValue('Position');
    sheet.cell(CellIndex.indexByString("B3")).value =
        TextCellValue(officer['position'] ?? '');

    // Add spacing before table
    const int startRow = 5;

    final headers = [
      'Issuance ID',
      'Base Item ID',
      'Product Name',
      'Product Description',
      'Unit',
      'Unit Cost',
      'Fund Cluster',
      'Manufacturer',
      'Brand',
      'Model',
      'Serial No.',
      'Issued Quantity',
      'Status',
      'Remarks',
      'Issued Date',
      'Received Date',
      'Returned Date',
      'Lost Date',
    ];

    final headerStyle = CellStyle(
      bold: true,
      fontFamily: getFontFamily(FontFamily.Arial),
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
      topBorder: Border(
        borderStyle: BorderStyle.Medium,
      ),
      rightBorder: Border(
        borderStyle: BorderStyle.Medium,
      ),
      bottomBorder: Border(
        borderStyle: BorderStyle.Medium,
      ),
      leftBorder: Border(
        borderStyle: BorderStyle.Medium,
      ),
      textWrapping: TextWrapping.WrapText,
    );

    // Write header row with style
    for (int i = 0; i < headers.length; i++) {
      final cell = sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: startRow));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = headerStyle;
    }

    // Write each accountability row
    // Define thin border style for accountability cells
    final thinBorderStyle = CellStyle(
      fontFamily: getFontFamily(FontFamily.Arial),
      horizontalAlign: HorizontalAlign.Left,
      verticalAlign: VerticalAlign.Center,
      topBorder: Border(borderStyle: BorderStyle.Thin),
      rightBorder: Border(borderStyle: BorderStyle.Medium),
      bottomBorder: Border(borderStyle: BorderStyle.Thin),
      leftBorder: Border(borderStyle: BorderStyle.Medium),
      textWrapping: TextWrapping.WrapText,
    );

    // Write each accountability row with thin border style
    for (int row = 0; row < accountabilities.length; row++) {
      final acc = accountabilities[row];
      final rowIndex = startRow + row + 1;

      final values = [
        acc['issuance_id'],
        acc['base_item_id'],
        acc['product_name'],
        acc['product_description'],
        acc['unit'],
        acc['unit_cost'],
        acc['fund_cluster'],
        acc['manufacturer'],
        acc['brand'],
        acc['model'],
        acc['serial_no'],
        acc['issued_quantity'],
        acc['status'],
        acc['remarks'],
        acc['issued_date']?.toString()?.split('T')?.first ?? '',
        acc['received_date']?.toString()?.split('T')?.first ?? '',
        acc['returned_date']?.toString()?.split('T')?.first ?? '',
        acc['lost_date']?.toString()?.split('T')?.first ?? '',
      ];

      for (int col = 0; col < values.length; col++) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(
          columnIndex: col,
          rowIndex: rowIndex,
        ));
        cell.value = TextCellValue(values[col]?.toString() ?? '');

        // Determine borders based on row position
        final isFirst = row == 0;
        final isLast = row == accountabilities.length - 1;

        cell.cellStyle = thinBorderStyle.copyWith(
          topBorderVal: Border(
            borderStyle: isFirst ? BorderStyle.Medium : BorderStyle.Thin,
          ),
          bottomBorderVal: Border(
            borderStyle: isLast ? BorderStyle.Medium : BorderStyle.Thin,
          ),
        );
      }
    }

    return excel;
  }
}
