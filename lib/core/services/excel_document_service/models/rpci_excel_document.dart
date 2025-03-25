import 'package:excel/excel.dart';
import 'base_excel_document.dart';

class RPCIExcelDocument extends BaseExcelDocument {
  @override
  Future<Excel> generate({
    required dynamic data,
  }) async {
    // Create a new Excel document
    final excel = Excel.createExcel();

    // Remove default sheet
    if (excel.sheets.containsKey('Sheet1')) {
      excel.sheets.remove('Sheet1');
    }

    // Create a new Excel sheet
    final sheet = excel['RPCI'];

    // Set RPCI as the default sheet
    excel.setDefaultSheet('RPCI');

    // Define a centered style
    CellStyle centeredStyle = CellStyle(
      bold: true,
      fontSize: 14,
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );

    // Add headers
    var appendix = sheet.cell(CellIndex.indexByString('K1'));
    appendix.value = TextCellValue(
      'Appendix 66',
    );
    appendix.cellStyle = CellStyle(
      fontSize: 16,
      italic: true,
    );

    var headerCell = sheet.cell(CellIndex.indexByString('B3'));
    headerCell.value = TextCellValue(
      'REPORT ON THE PHYSICAL COUNT OF INVENTORIES',
    );
    //headerCell.cellStyle = centeredStyle;
    sheet.merge(
      CellIndex.indexByString('B3'),
      CellIndex.indexByString('K3'),
    );

    var type = sheet.cell(CellIndex.indexByString('B4'));
    type.value = TextCellValue(
      'OFFICE SUPPLIES',
    );
    //type.cellStyle = centeredStyle;
    sheet.merge(
      CellIndex.indexByString('B4'),
      CellIndex.indexByString('OK3'),
    );

    var typeLabel = sheet.cell(CellIndex.indexByString('B5'));
    typeLabel.value = TextCellValue(
      '(Type of Inventory Item)',
    );
    //type.cellStyle = centeredStyle;
    sheet.merge(
      CellIndex.indexByString('B5'),
      CellIndex.indexByString('K3'),
    );

    var assumptionDate = sheet.cell(CellIndex.indexByString('B6'));
    assumptionDate.value = TextCellValue(
      'As at ______________________',
    );
    //assumptionDate.cellStyle = centeredStyle;
    sheet.merge(
      CellIndex.indexByString('B6'),
      CellIndex.indexByString('K3'),
    );

    return excel;
  }

  CellStyle _cellStyle({
    bool isBold = false,
    String? fontFamily,
    int? fontSize = 9,
    bool topBorder = true,
    bool rightBorder = true,
    bool bottomBorder = true,
    bool leftBorder = true,
  }) {
    return CellStyle(
      bold: isBold,
      fontColorHex: ExcelColor.black,
      fontFamily: fontFamily,
      fontSize: fontSize,
      topBorder: topBorder ? Border(borderStyle: BorderStyle.Thin) : null,
      rightBorder: rightBorder ? Border(borderStyle: BorderStyle.Thin) : null,
      bottomBorder: bottomBorder ? Border(borderStyle: BorderStyle.Thin) : null,
      leftBorder: leftBorder ? Border(borderStyle: BorderStyle.Thin) : null,
    );
  }
}
