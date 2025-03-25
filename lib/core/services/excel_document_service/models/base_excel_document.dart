import 'package:excel/excel.dart';

abstract class BaseExcelDocument {
  Future<Excel> generate({
    required dynamic data,
  });
}
