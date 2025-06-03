import 'package:excel/excel.dart';

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

    sheet.setColumnWidth(0, 20);
    sheet.setColumnWidth(1, 30);
    sheet.setColumnWidth(2, 25);
    sheet.setColumnWidth(3, 35);
    sheet.setColumnWidth(4, 20);
    sheet.setColumnWidth(5, 30);
    sheet.setColumnWidth(6, 25);
    sheet.setColumnWidth(7, 35);
    sheet.setColumnWidth(8, 20);
    sheet.setColumnWidth(9, 30);
    sheet.setColumnWidth(10, 25);
    sheet.setColumnWidth(11, 35);
    sheet.setColumnWidth(12, 20);
    sheet.setColumnWidth(13, 30);
    sheet.setColumnWidth(14, 25);
    sheet.setColumnWidth(15, 35);
    sheet.setColumnWidth(16, 20);
    sheet.setColumnWidth(17, 30);
    sheet.setColumnWidth(18, 30);
    sheet.setColumnWidth(19, 5);

    final officer = data['officer'];
    final accountabilities =
        List<Map<String, dynamic>>.from(data['accountabilities']);

    final cellStyle = CellStyle(
      fontFamily: getFontFamily(FontFamily.Bookman_Old_Style),
      fontSize: 8,
    );

    // Officer info
    final nameCell = sheet.cell(CellIndex.indexByString("A1"));
    nameCell.value = TextCellValue('Name: ${officer['name']}');
    nameCell.cellStyle = cellStyle;

    final officeCell = sheet.cell(CellIndex.indexByString("A2"));
    officeCell.value = TextCellValue('Office: ${officer['office']}');
    officeCell.cellStyle = cellStyle;

    final positionCell = sheet.cell(CellIndex.indexByString("A3"));
    positionCell.value = TextCellValue('Position: ${officer['position']}');
    positionCell.cellStyle = cellStyle;

    final startHeaderTopCell = CellIndex.indexByColumnRow(
      columnIndex: 0,
      rowIndex: 0,
    );
    final endHeaderTopCell = CellIndex.indexByColumnRow(
      columnIndex: 17,
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
      cell.cellStyle = cellStyle.copyWith(
        topBorderVal: Border(
          borderStyle: BorderStyle.Medium,
          borderColorHex: ExcelColor.white,
        ),
      );
    }

    final startHeaderRightCell = CellIndex.indexByColumnRow(
      columnIndex: 8,
      rowIndex: 0,
    );
    final endHeaderRightCell = CellIndex.indexByColumnRow(
      columnIndex: 18,
      rowIndex: 4,
    );
    for (int row = startHeaderRightCell.rowIndex;
        row <= endHeaderRightCell.rowIndex;
        row++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(
          columnIndex: 18,
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
      rowIndex: 4,
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
      cell.cellStyle = cellStyle.copyWith(
        topBorderVal: row == 0
            ? Border(
                borderStyle: BorderStyle.Medium,
                borderColorHex: ExcelColor.white,
              )
            : null,
        bottomBorderVal: row == endHeaderLeftCell.rowIndex
            ? Border(
                borderStyle: BorderStyle.Medium,
                borderColorHex: ExcelColor.white,
              )
            : null,
        leftBorderVal: Border(
          borderStyle: BorderStyle.Medium,
          borderColorHex: ExcelColor.white,
        ),
      );
    }

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
      'Dispoesed Date',
    ];

    final headerStyle = CellStyle(
      bold: true,
      fontFamily: getFontFamily(FontFamily.Arial),
      fontSize: 10,
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
      fontFamily: getFontFamily(FontFamily.Bookman_Old_Style),
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
        acc['disposed_date']?.toString()?.split('T')?.first ?? '',
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
          fontSizeVal: 9,
          textWrappingVal: TextWrapping.WrapText,
        );
      }
    }

    final startFooterCell = CellIndex.indexByColumnRow(
      columnIndex: 0,
      rowIndex: startRow + accountabilities.length + 1,
    );
    final endFooterCell = CellIndex.indexByColumnRow(
      columnIndex: 18,
      rowIndex: startRow + accountabilities.length + 1,
    );
    for (int col = startFooterCell.columnIndex;
        col <= endFooterCell.columnIndex;
        col++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(
          columnIndex: col,
          rowIndex: startRow + accountabilities.length + 1,
        ),
      );
      cell.cellStyle = cellStyle.copyWith(
        rightBorderVal: Border(
          borderStyle: BorderStyle.Medium,
          borderColorHex: ExcelColor.white,
        ),
        bottomBorderVal: Border(
          borderStyle: BorderStyle.Medium,
          borderColorHex: ExcelColor.white,
        ),
        leftBorderVal: Border(
          borderStyle: BorderStyle.Medium,
          borderColorHex: ExcelColor.white,
        ),
      );
    }

    return excel;
  }
}
