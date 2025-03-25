import 'package:excel/excel.dart';

import '../../enums/document_type.dart';
import 'models/base_excel_document.dart';
import 'models/rpci_excel_document.dart';

class ExcelDocumentFactory {
  final Map<DocumentType, BaseExcelDocument Function()> _excelMap;

  ExcelDocumentFactory()
      : _excelMap = {
          DocumentType.rpci: () => RPCIExcelDocument(),
        };

  Future<Excel> createExcelDocument({
    required dynamic data,
    required DocumentType docType,
  }) {
    final excelDocumentBuilder = _excelMap[docType];
    if (excelDocumentBuilder == null) {
      throw ArgumentError('Unsupported document type: $docType');
    }
    return excelDocumentBuilder().generate(
      data: data,
    );
  }
}
