import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/services.dart';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';
import '../../constants/assets_path.dart';
import '../../enums/document_type.dart';
import 'excel_document_factory.dart';
import 'models/excel_rpci.dart';
import 'models/excel_rpppe.dart';
import 'models/excel_rpsep.dart';
import 'models/ics_excel_document.dart';
import 'models/rpci_excel.dart';
import 'models/rpppe_excel.dart';
import 'models/rpsep_excel.dart';

/// Service to generate an Excel file from a template by mapping data
class ExcelDocumentService {
  /// Generates an Excel document using spreadsheet_decoder
  Future<void> generateAndSaveExcelWithSpreadsheetDecoder({
    required dynamic data,
    required DocumentType docType,
    required String outputPath,
  }) async {
    try {
      // Debug: Print the output path
      print('Saving file to: $outputPath');

      // Get the template path
      final templatePath = _getTemplatePath(docType);
      print('Loading template from: $templatePath');

      // Load the template from assets
      final ByteData templateData = await rootBundle.load(templatePath);
      final List<int> templateBytes = templateData.buffer.asUint8List();

      // Decode the Excel file
      final decoder = SpreadsheetDecoder.decodeBytes(
        templateBytes,
        update: true,
      );

      // Get the first table in the template
      final sheet = decoder.tables.values.first as SpreadsheetTable?;
      if (sheet == null) {
        throw Exception('No table found in the template.');
      }

      // Map data to the table
      _mapDataToTemplate(
        decoder,
        sheet.name,
        data,
        docType,
      );

      // Encode the workbook back to bytes
      final modifiedBytes = decoder.encode();

      // Save the modified file
      final file = File(outputPath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(modifiedBytes);

      print('File successfully saved at: $outputPath');
    } catch (e, stackTrace) {
      print('Error generating Excel with spreadsheet_decoder: $e');
      print('Stack trace: $stackTrace');
    }
  }

  /// Returns the template path based on the document type
  String _getTemplatePath(DocumentType docType) {
    switch (docType) {
      case DocumentType.ics:
        return TemplatePath.ics;
      case DocumentType.rpci:
        return TemplatePath.rpci;
      case DocumentType.annexA8:
        return TemplatePath.rpsep;
      case DocumentType.a73:
        return TemplatePath.rpppe;
      default:
        throw ArgumentError('Unsupported document type: $docType');
    }
  }

  /// Maps data to the Excel table based on the document type
  void _mapDataToTemplate(
    SpreadsheetDecoder decoder,
    String sheetName,
    dynamic data,
    DocumentType docType,
  ) {
    switch (docType) {
      case DocumentType.rpci:
        ExcelRPCI.mapData(
          decoder,
          sheetName,
          data,
        );
        break;
      case DocumentType.annexA8:
        ExcelRPSEP.mapData(
          decoder,
          sheetName,
          data,
        );
        break;
      case DocumentType.a73:
        ExcelRPPPE.mapData(
          decoder,
          sheetName,
          data,
        );
        break;
      default:
        throw ArgumentError('Unsupported document type: $docType');
    }
  }

  /// Generates an Excel document based on the document type
  Future<void> generateAndSaveExcel({
    required dynamic data,
    required DocumentType docType,
    required String outputPath,
  }) async {
    try {
      // Debug: Print the output path
      print('Saving file to: $outputPath');

      // Get the template path
      final templatePath = _getTemplatePath(docType);
      print('Loading template from: $templatePath');

      // Load the Excel template
      final excel = await _loadExcelTemplate(templatePath);
      print('Loaded template');

      // Get the first sheet
      final sheet = excel.sheets.values.first as Sheet?;
      if (sheet == null) {
        throw Exception('Sheet is null. Check the template file.');
      }

      // Debug: Print data to be mapped
      print('Data to be mapped: $data');

      // Map data using the appropriate mapper
      print('Mapping data...');
      _mapDataToExcelTemplate(sheet, data, docType);
      print('mapped data');

      // Convert to bytes and save the file
      print('Encoding Excel file...');
      final fileBytes = excel.encode();
      if (fileBytes == null) {
        throw Exception('Excel encoding returned null bytes.');
      }

      // Save the file
      final file = File(outputPath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes);

      // Debug: Verify file was saved
      if (file.existsSync()) {
        print('File successfully saved at: $outputPath');
      } else {
        throw Exception('File not saved. Check permissions or path.');
      }
    } catch (e, stackTrace) {
      print('Error generating Excel: $e');
      print('Stack trace: $stackTrace');
    }
  }

  /// Loads an Excel file from assets
  Future<Excel> _loadExcelTemplate(String assetPath) async {
    try {
      final ByteData data = await rootBundle.load(assetPath);
      final List<int> bytes = data.buffer.asUint8List();
      return Excel.decodeBytes(bytes);
    } catch (e) {
      throw Exception('Failed to load template: $e');
    }
  }

  /// Maps data to the Excel sheet based on the document type
  void _mapDataToExcelTemplate(
    Sheet sheet,
    dynamic data,
    DocumentType docType,
  ) {
    switch (docType) {
      case DocumentType.ics:
        IcsExcelDocument.modifyAndMapData(
          sheet,
          data,
        );
        break;
      case DocumentType.rpci:
        RPCIExcelDocument.modifyAndMapData(
          sheet,
          data,
        );
        break;
      case DocumentType.annexA8:
        RPSEPExcelDocument.modifyAndMapData(
          sheet,
          data,
        );
        break;
      case DocumentType.a73:
        RPPPEExcelDocument.modifyAndMapData(
          sheet,
          data,
        );
        break;
      default:
        throw ArgumentError('Unsupported document type: $docType');
    }
  }

  Future<void> generateAndSaveExcelFromScratch({
    required dynamic data,
    required DocumentType docType,
    required String outputPath,
  }) async {
    try {
      print('Creating Excel from scratch for: $docType');

      // Use factory to create and generate the appropriate template
      final excel = await ExcelDocumentFactory().createExcelDocument(
        data: data,
        docType: docType,
      );

      print('Template created.');

      // Encode and save the file
      final fileBytes = excel.encode();
      if (fileBytes == null) throw Exception('Failed to encode Excel.');

      final file = File(outputPath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes);

      print('File successfully saved at: $outputPath');
    } catch (e, stackTrace) {
      print('Error generating Excel from scratch: $e');
      print('Stack trace: $stackTrace');
    }
  }
}
