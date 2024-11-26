import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../features/item_issuance/data/models/inventory_custodian_slip.dart';
import '../../features/item_issuance/data/models/issuance_item.dart';
import '../../features/item_issuance/data/models/property_acknowledgement_receipt.dart';
import '../constants/assets_path.dart';
import '../enums/document_type.dart';
import '../enums/unit.dart';
import '../utils/capitalizer.dart';
import '../utils/document_date_formatter.dart';
import '../utils/extract_specification.dart';
import '../utils/format_position.dart';
import '../utils/readable_enum_converter.dart';
import '../utils/truncate_text.dart';

class DocumentService {
  DocumentService() {
    _initializeFonts();
    _initializeImageSeal();
  }

  Future<void> initialize() async {
    await _initializeFonts();
    await _initializeImageSeal();
  }

  late final pw.Font calibriRegular;
  late final pw.Font calibriBold;
  late final pw.Font calibriItalic;
  late final pw.Font calibriBoldItalic;
  late final pw.Font oldEnglish;
  late final pw.Font popvlvs;
  late final pw.Font trajanProRegular;
  late final pw.Font trajanProBold;
  late final pw.Font tahomaRegular;
  late final pw.Font tahomaBold;
  late final pw.Font timesNewRomanRegular;
  late final pw.Font timesNewRomanBold;
  late final pw.Image depedSeal;

  Future<pw.Font> _loadFont(String path) async {
    return pw.Font.ttf(await rootBundle.load(path));
  }

  Future<void> _initializeFonts() async {
    calibriRegular = await _loadFont(FontPath.calibriRegular);
    calibriBold = await _loadFont(FontPath.calibriBold);
    calibriItalic = await _loadFont(FontPath.calibriItalic);
    calibriBoldItalic = await _loadFont(FontPath.calibriBoldItalic);
    oldEnglish = await _loadFont(FontPath.oldEnglish);
    popvlvs = await _loadFont(FontPath.popvlvs);
    trajanProRegular = await _loadFont(FontPath.trajanProRegular);
    trajanProBold = await _loadFont(FontPath.trajanProBold);
    tahomaRegular = await _loadFont(FontPath.tahomaRegular);
    tahomaBold = await _loadFont(FontPath.tahomaBold);
    timesNewRomanRegular = await _loadFont(FontPath.timesNewRomanRegular);
    timesNewRomanBold = await _loadFont(FontPath.timesNewRomanBold);
  }

  Future<void> _initializeImageSeal() async {
    final img = await rootBundle.load(ImagePath.depedSeal);
    final imageBytes = img.buffer.asUint8List();
    depedSeal = pw.Image(pw.MemoryImage(imageBytes));
  }

  double getRowHeight(String text, {double fontSize = 8.5}) {
    // Estimate row height based on text length, assuming ~1.5 lines per row
    final lines =
        (text.length / 20).ceil(); // Rough estimation of number of lines needed
    return lines * fontSize * 1.5; // Adjust multiplier for row height
  }

  Future<pw.Document> generateDocument({
    required PdfPageFormat pageFormat,
    required pw.PageOrientation orientation,
    required dynamic data,
    required DocumentType docType,
    bool withQR = true,
  }) async {
    switch (docType) {
      case DocumentType.issuance:
        if (data is InventoryCustodianSlipModel) {
          return generateICS(
            pageFormat: pageFormat,
            orientation: orientation,
            ics: data,
            withQR: withQR,
          );
        }

        if (data is PropertyAcknowledgementReceiptModel) {
          return generatePAR(
            pageFormat: pageFormat,
            orientation: orientation,
            par: data,
            withQR: withQR,
          );
        }
      case DocumentType.ris:
        return generateRIS(
          pageFormat: pageFormat,
          orientation: orientation,
          data: data,
          withQR: withQR,
        );
      case DocumentType.sticker:
        return generateSticker(
          pageFormat: pageFormat,
          orientation: orientation,
          data: data,
          withQR: withQR,
        );
      default:
        throw ArgumentError('Unsupported data type or parameters.');
    }

    throw ArgumentError('Unsupported data type or parameters.');
  }

  Future<pw.Document> generateICS({
    required PdfPageFormat pageFormat,
    required pw.PageOrientation orientation,
    required InventoryCustodianSlipModel ics,
    bool withQR = true,
  }) async {
    final pdf = pw.Document();

    List<Map<String, dynamic>> issuedItemsMap = [];
    List<String> descriptionColumn = [];
    Unit? unit;
    double? unitCost;
    double? totalCost;
    int? estimatedUsefulLife;

    /// extract the issued items, to displayed on table row 0 - qty and row 5 - id
    /// the row count will correspond to the description
    for (int i = 0; i < ics.items.length; i++) {
      // we need to extract each info and skip some
      final item = ics.items[i];

      /// in the first index, we will display all info
      /// but there is a catch, for the description column
      /// we will extract it and display the extracted info one by one in
      /// the description column

      /// extract similar info in the first iteration
      if (i == 0) {
        descriptionColumn.addAll([
          item.itemEntity.productStockEntity.productDescription!.description!,
          'Specifications:',
          ...extractSpecification(item.itemEntity.itemEntity.specification,
              ' - '), // Append the list of specifications
          'Brand: ${item.itemEntity.manufacturerBrandEntity.brand.name}',
          'Model: ${item.itemEntity.modelEntity.modelName}',
          'SN: ${item.itemEntity.itemEntity.serialNo}',
          'PR: ${ics.purchaseRequestEntity.id}',
          'Date Acquired: ${documentDateFormatter(item.itemEntity.itemEntity.acquiredDate!)}'
        ]);

        unit = item.itemEntity.itemEntity.unit;
        unitCost = item.itemEntity.itemEntity.unitCost;
        estimatedUsefulLife = item.itemEntity.itemEntity.estimatedUsefulLife;
      }

      totalCost = unitCost! * ics.items.length;

      issuedItemsMap.add({
        'item_id': item.itemEntity.itemEntity.id,
        'issued_quantity': item.quantity,
      });
    }

    final rowHeights = descriptionColumn.map((row) {
      return getRowHeight(row, fontSize: 8.5);
    }).toList();

    int itemIndexForQuantity = 0;
    int itemIndex = 0;

    print('desc length: ${descriptionColumn.length}');

    pdf.addPage(
      pw.Page(
        pageTheme: _getPageTheme(
          pageFormat: pageFormat,
          orientation: orientation,
        ),
        build: (context) => pw.Column(
          children: [
            _buildHeader(),

            pw.SizedBox(
              height: 20.0,
            ),

            pw.Text(
              'INVENTORY CUSTODIAN SLIP',
              style: pw.TextStyle(
                font: timesNewRomanBold,
                fontSize: 14.0,
                //fontWeight: pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(
              height: 20.0,
            ),

            _buildRowTextValue(
              text: 'Entity Name:',
              value: ics.purchaseRequestEntity.entity.name,
            ),

            pw.SizedBox(
              height: 3.0,
            ),

            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _buildRowTextValue(
                  text: 'Fund Cluster:',
                  value: readableEnumConverter(
                      ics.purchaseRequestEntity.fundCluster),
                ),
                _buildRowTextValue(
                  text: 'ICS No:',
                  value: ics.icsId,
                ),
              ],
            ),

            pw.SizedBox(
              height: 3.0,
            ),

            /// Table
            pw.Table(
              columnWidths: {
                0: const pw.FixedColumnWidth(75),
                1: const pw.FixedColumnWidth(50),
                2: const pw.FixedColumnWidth(150),
                3: const pw.FixedColumnWidth(240),
                4: const pw.FixedColumnWidth(150),
                5: const pw.FixedColumnWidth(100),
              },
              children: [
                // Header part
                pw.TableRow(
                  children: [
                    _buildHeaderContainerCell(
                      data: 'Quantity',
                      verticalPadding: 13.2,
                      borderRight: false,
                    ),
                    _buildHeaderContainerCell(
                      data: 'Unit',
                      verticalPadding: 13.2,
                      borderRight: false,
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                      children: [
                        _buildHeaderContainerCell(
                          data: 'Amount',
                          verticalPadding: 1.0,
                          borderWidthBottom: 2.0,
                          borderRight: false,
                        ),
                        pw.Row(
                          children: [
                            pw.SizedBox(
                              width: 45.0,
                              child: _buildHeaderContainerCell(
                                data: 'Unit Cost',
                                horizontalPadding: 6.0,
                                verticalPadding: 1.0,
                                isBold: false,
                                borderTop: false,
                                borderRight: false,
                              ),
                            ),
                            pw.Expanded(
                              child: _buildHeaderContainerCell(
                                data: 'Total Cost',
                                horizontalPadding: 1.0,
                                verticalPadding: 5.7,
                                isBold: false,
                                borderWidthLeft: 2.0,
                                borderWidthBottom: 2.0,
                                borderTop: false,
                                borderRight: false,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    _buildHeaderContainerCell(
                      data: 'Description',
                      verticalPadding: 13.2,
                      borderRight: false,
                    ),
                    _buildHeaderContainerCell(
                      data: 'Inventory Item No.',
                      verticalPadding: 13.2,
                      borderRight: false,
                    ),
                    _buildHeaderContainerCell(
                      data: 'Estimated Useful Life',
                      //horizontalPadding: 3.0,
                      verticalPadding: 7.7,
                    ),
                  ],
                ),

                // Add more rows for your table data here...
                for (int i = 0; i < descriptionColumn.length; i++)
                  _buildIcsTableRow(
                    quantity: (i == 0 ||
                            (i >= 5 &&
                                itemIndexForQuantity < issuedItemsMap.length))
                        ? issuedItemsMap[itemIndexForQuantity++]
                                    ['issued_quantity']
                                ?.toString() ??
                            '\n'
                        : '\n',
                    unit: i == 0 ? readableEnumConverter(unit) : '\n',
                    unitCost: i == 0 ? unitCost.toString() : '\n',
                    totalCost: i == 0 ? totalCost.toString() : '\n',
                    description: descriptionColumn[i],
                    itemId: (i == 0 ||
                            (i >= 5 && itemIndex < issuedItemsMap.length))
                        ? issuedItemsMap[itemIndex++]['item_id']?.toString() ??
                            '\n'
                        : '\n',
                    estimatedUsefulLife: i == 0 ? estimatedUsefulLife : null,
                    rowHeight: rowHeights[i],
                    borderBottom:
                        i == descriptionColumn.length - 1 ? false : true,
                  ),
              ],
            ),

            /// footer
            pw.Table(
              columnWidths: {
                0: const pw.FixedColumnWidth(515.0),
                1: const pw.FixedColumnWidth(250.0),
              },
              children: [
                pw.TableRow(
                  children: [
                    _buildReusableIssuanceFooterContainer(
                      title: 'Received from:',
                      officerName: ics.sendingOfficerEntity.name,
                      officerPosition: ics.sendingOfficerEntity.positionName,
                      officerOffice: ics.sendingOfficerEntity.officeName,
                      date: DateTime.now(),
                      borderRight: false,
                    ),
                    _buildReusableIssuanceFooterContainer(
                      title: 'Received by:',
                      officerName: ics.receivingOfficerEntity.name,
                      officerPosition: ics.receivingOfficerEntity.positionName,
                      officerOffice: ics.receivingOfficerEntity.officeName,
                    ),
                  ],
                ),
              ],
            ),

            pw.SizedBox(height: 30.0),

            if (withQR)
              pw.Align(
                alignment: pw.AlignmentDirectional.bottomEnd,
                child: _buildQrContainer(
                  data: ics.id,
                ),
              ),
          ],
        ),
      ),
    );

    return pdf;
  }

  pw.TableRow _buildIcsTableRow({
    String? quantity,
    String? unit,
    String? unitCost,
    String? totalCost,
    String? description,
    String? itemId,
    int? estimatedUsefulLife,
    double? rowHeight,
    borderBottom = true,
  }) {
    return pw.TableRow(
      children: [
        _buildTableRowColumn(
          data: quantity.toString(),
          borderRight: false,
          rowHeight: rowHeight,
          borderBottom: borderBottom,
          isBottomBorderSlashed: true,
        ),
        _buildTableRowColumn(
          data: readableEnumConverter(unit),
          borderRight: false,
          rowHeight: rowHeight,
          borderBottom: borderBottom,
          isBottomBorderSlashed: true,
        ),
        pw.Row(
          children: [
            pw.SizedBox(
              width: 45.0,
              child: _buildTableRowColumn(
                data: unitCost.toString(),
                borderRight: false,
                rowHeight: rowHeight,
                borderBottom: borderBottom,
                isBottomBorderSlashed: true,
              ),
            ),
            pw.Expanded(
              child: _buildTableRowColumn(
                data: totalCost.toString(),
                solidBorderWidth: 2.0,
                borderRight: false,
                rowHeight: rowHeight,
                borderBottom: borderBottom,
                isBottomBorderSlashed: true,
              ),
            ),
          ],
        ),
        _buildTableRowColumn(
          data: description ?? '\n', // truncateText(description ?? '\n', 40),
          borderRight: false,
          rowHeight: rowHeight,
          borderBottom: borderBottom,
          isBottomBorderSlashed: true,
        ),
        _buildTableRowColumn(
          data: itemId ?? '\n', //truncateText(itemId ?? '\n', 21),
          fontSize: 7.0,
          borderRight: false,
          rowHeight: rowHeight,
          borderBottom: borderBottom,
          isBottomBorderSlashed: true,
        ),
        _buildTableRowColumn(
          data: estimatedUsefulLife != null
              ? estimatedUsefulLife > 1
                  ? '$estimatedUsefulLife years'
                  : '$estimatedUsefulLife year'
              : '\n',
          rowHeight: rowHeight,
          borderBottom: borderBottom,
          isBottomBorderSlashed: true,
        ),
      ],
    );
  }

  Future<pw.Document> generatePAR({
    required PdfPageFormat pageFormat,
    required pw.PageOrientation orientation,
    required PropertyAcknowledgementReceiptModel par,
    bool withQR = true,
  }) async {
    final pdf = pw.Document();

    List<Map<String, dynamic>> issuedItemsMap = [];
    List<String> descriptionColumn = [];
    Unit? unit;
    double? unitCost;
    double? totalCost;
    int? estimatedUsefulLife;

    /// extract the issued items, to displayed on table row 0 - qty and row 5 - id
    /// the row count will correspond to the description
    for (int i = 0; i < par.items.length; i++) {
      // we need to extract each info and skip some
      final item = par.items[i];

      /// in the first index, we will display all info
      /// but there is a catch, for the description column
      /// we will extract it and display the extracted info one by one in
      /// the description column

      /// extract similar info in the first iteration
      if (i == 0) {
        descriptionColumn.addAll([
          item.itemEntity.productStockEntity.productDescription!.description!,
          'Specifications:',
          ...extractSpecification(item.itemEntity.itemEntity.specification,
              ' - '), // Append the list of specifications
          'Brand: ${item.itemEntity.manufacturerBrandEntity.brand.name}',
          'Model: ${item.itemEntity.modelEntity.modelName}',
          'SN: ${item.itemEntity.itemEntity.serialNo}',
          'PR: ${par.purchaseRequestEntity.id}',
          'Date Acquired: ${documentDateFormatter(item.itemEntity.itemEntity.acquiredDate!)}'
        ]);

        unit = item.itemEntity.itemEntity.unit;
        unitCost = item.itemEntity.itemEntity.unitCost;
        estimatedUsefulLife = item.itemEntity.itemEntity.estimatedUsefulLife;
      }

      totalCost = unitCost! * par.items.length;

      issuedItemsMap.add({
        'item_id': item.itemEntity.itemEntity.id,
        'issued_quantity': item.quantity,
      });
    }

    int itemIndexForQuantity = 0;
    int itemIndex = 0;

    print('desc length: ${descriptionColumn.length}');

    final rowHeights = descriptionColumn.map((row) {
      return getRowHeight(row, fontSize: 8.5);
    }).toList();

    pdf.addPage(
      pw.Page(
        pageTheme: _getPageTheme(
          pageFormat: pageFormat,
          orientation: orientation,
          marginTop: 2.5,
          marginRight: 2.5,
          marginBottom: 1.3,
          marginLeft: 3.2,
        ),
        build: (context) => pw.Column(
          children: [
            _buildHeader(),

            pw.SizedBox(
              height: 20.0,
            ),

            pw.Text(
              'PROPERTY ACKNOWLEDGEMENT RECEIPT',
              style: pw.TextStyle(
                font: timesNewRomanBold,
                fontSize: 14.0,
                //fontWeight: pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(
              height: 20.0,
            ),

            _buildRowTextValue(
              text: 'Entity Name:',
              value: par.purchaseRequestEntity.entity.name,
              isUnderlined: true,
            ),

            pw.SizedBox(
              height: 3.0,
            ),

            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _buildRowTextValue(
                  text: 'Fund Cluster:',
                  value: readableEnumConverter(
                      par.purchaseRequestEntity.fundCluster),
                ),
                _buildRowTextValue(
                  text: 'PAR No:',
                  value: par.parId,
                  isUnderlined: true,
                ),
              ],
            ),

            pw.SizedBox(
              height: 3.0,
            ),

            /// Table
            pw.Table(
              columnWidths: {
                0: const pw.FixedColumnWidth(80),
                1: const pw.FixedColumnWidth(40),
                2: const pw.FixedColumnWidth(240),
                3: const pw.FixedColumnWidth(90),
                4: const pw.FixedColumnWidth(90),
                5: const pw.FixedColumnWidth(90),
              },
              children: [
                // Header part
                pw.TableRow(
                  children: [
                    _buildHeaderContainerCell(
                      data: 'Quantity',
                      horizontalPadding: 3.0,
                      verticalPadding: 8.6,
                      borderRight: false,
                    ),
                    _buildHeaderContainerCell(
                      data: 'Unit',
                      verticalPadding: 8.6,
                      borderRight: false,
                    ),
                    _buildHeaderContainerCell(
                      data: 'Description',
                      verticalPadding: 8.6,
                      borderRight: false,
                    ),
                    _buildHeaderContainerCell(
                      data: 'Property Number',
                      horizontalPadding: 3.0,
                      verticalPadding: 3.0,
                      borderRight: false,
                    ),
                    _buildHeaderContainerCell(
                      data: 'Date Acquired',
                      horizontalPadding: 3.0,
                      verticalPadding: 3.0,
                      borderRight: false,
                    ),
                    _buildHeaderContainerCell(
                      data: 'Amount',
                      horizontalPadding: 3.0,
                      verticalPadding: 8.6,
                    ),
                  ],
                ),

                // Add more rows for your table data here...
                for (int i = 0; i < descriptionColumn.length; i++)
                  _buildParTableRow(
                    quantity: (i == 0 ||
                            (i >= 5 &&
                                itemIndexForQuantity < issuedItemsMap.length))
                        ? issuedItemsMap[itemIndexForQuantity++]
                                    ['issued_quantity']
                                ?.toString() ??
                            '\n'
                        : '\n',
                    unit: i == 0 ? readableEnumConverter(unit) : '\n',
                    description: descriptionColumn[i],
                    propertyNumber: (i == 0 ||
                            (i >= 5 && itemIndex < issuedItemsMap.length))
                        ? issuedItemsMap[itemIndex++]['item_id']?.toString() ??
                            '\n'
                        : '\n',
                    dateAcquired:
                        i == 0 ? documentDateFormatter(DateTime.now()) : null,
                    amount: i == 0 ? '' : '\n',
                    borderBottom:
                        i == descriptionColumn.length - 1 ? false : true,
                    rowHeight: rowHeights[i],
                  ),
              ],
            ),

            /// footer
            pw.Table(
              columnWidths: {
                0: const pw.FixedColumnWidth(360.0),
                1: const pw.FixedColumnWidth(270.0),
              },
              children: [
                pw.TableRow(
                  children: [
                    _buildReusableIssuanceFooterContainer(
                      title: 'Received from:',
                      officerName: par.sendingOfficerEntity.name,
                      officerPosition: par.sendingOfficerEntity.positionName,
                      officerOffice: par.sendingOfficerEntity.officeName,
                      borderRight: false,
                      isPAR: true,
                    ),
                    _buildReusableIssuanceFooterContainer(
                      title: 'Received by:',
                      officerName: par.receivingOfficerEntity.name,
                      officerPosition: par.receivingOfficerEntity.positionName,
                      officerOffice: par.receivingOfficerEntity.officeName,
                      isPAR: true,
                    ),
                  ],
                ),
              ],
            ),

            pw.SizedBox(height: 30.0),

            if (withQR)
              pw.Align(
                alignment: pw.AlignmentDirectional.bottomEnd,
                child: _buildQrContainer(
                  data: par.id,
                ),
              ),
          ],
        ),
      ),
    );

    return pdf;
  }

  pw.TableRow _buildParTableRow({
    String? quantity,
    String? unit,
    String? description,
    String? propertyNumber,
    String? dateAcquired,
    String? amount,
    double? rowHeight,
    borderBottom = true,
  }) {
    return pw.TableRow(
      children: [
        _buildTableRowColumn(
          data: quantity.toString(),
          borderRight: false,
          rowHeight: rowHeight,
          borderBottom: borderBottom,
        ),
        _buildTableRowColumn(
          data: readableEnumConverter(unit),
          borderRight: false,
          rowHeight: rowHeight,
          borderBottom: borderBottom,
        ),
        _buildTableRowColumn(
          data: description ?? '\n',
          borderRight: false,
          rowHeight: rowHeight,
          borderBottom: borderBottom,
        ),
        _buildTableRowColumn(
          data: propertyNumber ?? '\n',
          fontSize: 7.0,
          borderRight: false,
          rowHeight: rowHeight,
          borderBottom: borderBottom,
        ),
        _buildTableRowColumn(
          data: dateAcquired ?? '\n',
          solidBorderWidth: 2.0,
          borderRight: false,
          rowHeight: rowHeight,
          borderBottom: borderBottom,
        ),
        _buildTableRowColumn(
          data: amount.toString(),
          rowHeight: rowHeight,
          borderBottom: borderBottom,
        ),
      ],
    );
  }

  Future<pw.Document> generateRIS({
    required PdfPageFormat pageFormat,
    required pw.PageOrientation orientation,
    required dynamic data,
    bool withQR = true,
  }) async {
    final pdf = pw.Document();

    final List<IssuanceItemModel> items;

    final String entityName;
    final String fundCluster;

    final String division;
    final String office;
    final String rcc;
    final String pr;
    final String stockNo;
    final int requestQuantity;
    final String purpose;

    final String requestingOfficerName;
    final String requestingOfficerPosition;
    final String approvingOfficerName;
    final String approvingOfficerPosition;
    final String issuingOfficerName;
    final String issuingOfficerPosition;
    final String receivingOfficerName;
    final String receivingOfficerPosition;

    if (data is InventoryCustodianSlipModel) {
      entityName = data.purchaseRequestEntity.entity.name;
      fundCluster =
          readableEnumConverter(data.purchaseRequestEntity.fundCluster);

      items = data.items as List<IssuanceItemModel>;

      pr = data.purchaseRequestEntity.id;
      stockNo = data.purchaseRequestEntity.productNameEntity.id;
      requestQuantity = data.purchaseRequestEntity.quantity;
      purpose = data.purchaseRequestEntity.purpose;

      requestingOfficerName =
          data.purchaseRequestEntity.requestingOfficerEntity.name;
      requestingOfficerPosition =
          data.purchaseRequestEntity.requestingOfficerEntity.positionName;
      approvingOfficerName =
          data.purchaseRequestEntity.approvingOfficerEntity.name;
      approvingOfficerPosition =
          data.purchaseRequestEntity.approvingOfficerEntity.positionName;
      issuingOfficerName = data.sendingOfficerEntity.name;
      issuingOfficerPosition = data.sendingOfficerEntity.positionName;
      receivingOfficerName = data.receivingOfficerEntity.name;
      receivingOfficerPosition = data.receivingOfficerEntity.positionName;
    } else if (data is PropertyAcknowledgementReceiptModel) {
      entityName = data.purchaseRequestEntity.entity.name;
      fundCluster =
          readableEnumConverter(data.purchaseRequestEntity.fundCluster);

      items = data.items as List<IssuanceItemModel>;

      rcc = data.purchaseRequestEntity.responsibilityCenterCode ?? '';
      pr = data.purchaseRequestEntity.id;
      stockNo = data.purchaseRequestEntity.productNameEntity.id;
      requestQuantity = data.purchaseRequestEntity.quantity;
      purpose = data.purchaseRequestEntity.purpose;

      requestingOfficerName =
          data.purchaseRequestEntity.requestingOfficerEntity.name;
      requestingOfficerPosition =
          data.purchaseRequestEntity.requestingOfficerEntity.positionName;
      approvingOfficerName =
          data.purchaseRequestEntity.approvingOfficerEntity.name;
      approvingOfficerPosition =
          data.purchaseRequestEntity.approvingOfficerEntity.positionName;
      issuingOfficerName = data.sendingOfficerEntity.name;
      issuingOfficerPosition = data.sendingOfficerEntity.positionName;
      receivingOfficerName = data.receivingOfficerEntity.name;
      receivingOfficerPosition = data.receivingOfficerEntity.positionName;
    } else {
      throw ArgumentError('Unsupported data type for RIS generation');
    }

    List<Map<String, dynamic>> issuedItemsMap = [];
    List<String> descriptionColumn = [];
    Unit? unit;
    double? unitCost;
    double? totalCost;
    int? estimatedUsefulLife;

    /// extract the issued items, to displayed on table row 0 - qty and row 5 - id
    /// the row count will correspond to the description
    for (int i = 0; i < items.length; i++) {
      // we need to extract each info and skip some
      final item = items[i];

      /// in the first index, we will display all info
      /// but there is a catch, for the description column
      /// we will extract it and display the extracted info one by one in
      /// the description column

      /// extract similar info in the first iteration
      if (i == 0) {
        descriptionColumn.addAll([
          item.itemEntity.productStockEntity.productDescription!.description!,
          'Specifications:',
          ...extractSpecification(item.itemEntity.itemEntity.specification,
              ' - '), // Append the list of specifications
          'Brand: ${item.itemEntity.manufacturerBrandEntity.brand.name}',
          'Model: ${item.itemEntity.modelEntity.modelName}',
          'SN: ${item.itemEntity.itemEntity.serialNo}',
          'PR: $pr',
          'Date Acquired: ${documentDateFormatter(item.itemEntity.itemEntity.acquiredDate!)}'
        ]);

        unit = item.itemEntity.itemEntity.unit;
        unitCost = item.itemEntity.itemEntity.unitCost;
        estimatedUsefulLife = item.itemEntity.itemEntity.estimatedUsefulLife;
      }

      totalCost = unitCost! * items.length;

      issuedItemsMap.add({
        'item_id': item.itemEntity.itemEntity.id,
        'issued_quantity': item.quantity,
      });
    }

    final rowHeights = descriptionColumn.map((row) {
      return getRowHeight(row, fontSize: 8.5);
    }).toList();

    int itemIndexForQuantity = 0;
    int itemIndex = 0;

    pdf.addPage(
      pw.Page(
        pageTheme: _getPageTheme(
          pageFormat: pageFormat,
          orientation: orientation,
          marginTop: 1.9,
          marginRight: 1.2,
          marginBottom: 0.8,
          marginLeft: 0.9,
        ),
        build: (context) => pw.Column(
          children: [
            _buildHeader(),

            pw.SizedBox(
              height: 20.0,
            ),

            pw.Text(
              'REQUISITION AND ISSUE SLIP',
              style: pw.TextStyle(
                font: timesNewRomanBold,
                fontSize: 14.0,
                //fontWeight: pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(
              height: 20.0,
            ),

            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _buildRowTextValue(
                  text: 'Entity Name:',
                  value: entityName,
                  font: calibriBold,
                ),
                _buildRowTextValue(
                  text: 'Fund Cluster:',
                  value: fundCluster,
                  font: calibriBold,
                ),
              ],
            ),

            pw.SizedBox(
              height: 6.0,
            ),

            /// Table Header Section
            pw.Table(
              columnWidths: {
                0: const pw.FixedColumnWidth(825.0),
                1: const pw.FixedColumnWidth(450.0),
              },
              children: [
                pw.TableRow(
                  children: [
                    _buildRISHeaderContainer(
                      row1Title: 'Division:',
                      row2Title: 'Office:',
                      borderRight: false,
                    ),
                    _buildRISHeaderContainer(
                      row1Title: 'Responsibility Center Code:',
                      //row1Value: rcc,
                      row2Title: 'RIS No.:',
                      isRow1Underlined: true,
                    ),
                  ],
                ),
              ],
            ),

            pw.Table(
              columnWidths: {
                0: const pw.FixedColumnWidth(675),
                1: const pw.FixedColumnWidth(275),
                2: const pw.FixedColumnWidth(325),
              },
              children: [
                pw.TableRow(
                  children: [
                    _buildHeaderContainerCell(
                      data: 'Requisition',
                      verticalPadding: 3.0,
                      borderTop: false,
                      borderRight: false,
                      font: calibriBoldItalic,
                    ),
                    _buildHeaderContainerCell(
                      data: 'Stock Available?',
                      verticalPadding: 3.0,
                      borderTop: false,
                      borderRight: false,
                      font: calibriBoldItalic,
                    ),
                    _buildHeaderContainerCell(
                      data: 'Issue',
                      verticalPadding: 3.0,
                      borderTop: false,
                      font: calibriBoldItalic,
                    ),
                  ],
                ),
              ],
            ),

            pw.Table(
              columnWidths: {
                0: const pw.FixedColumnWidth(100),
                1: const pw.FixedColumnWidth(125),
                2: const pw.FixedColumnWidth(300),
                3: const pw.FixedColumnWidth(150),
                4: const pw.FixedColumnWidth(150),
                5: const pw.FixedColumnWidth(125),
                6: const pw.FixedColumnWidth(100),
                7: const pw.FixedColumnWidth(225),
              },
              children: [
                pw.TableRow(
                  children: [
                    _buildHeaderContainerCell(
                      data: 'Stock No.',
                      verticalPadding: 3.0,
                      borderTop: false,
                      borderRight: false,
                      font: calibriRegular,
                    ),
                    _buildHeaderContainerCell(
                      data: 'Unit',
                      verticalPadding: 3.0,
                      borderTop: false,
                      borderRight: false,
                      font: calibriRegular,
                    ),
                    _buildHeaderContainerCell(
                      data: 'Description',
                      verticalPadding: 3.0,
                      borderTop: false,
                      borderRight: false,
                      font: calibriRegular,
                    ),
                    _buildHeaderContainerCell(
                      data: 'Quantity',
                      verticalPadding: 3.0,
                      borderTop: false,
                      borderRight: false,
                      font: calibriRegular,
                    ),
                    _buildHeaderContainerCell(
                      data: 'Yes',
                      verticalPadding: 3.0,
                      borderTop: false,
                      borderRight: false,
                      font: calibriRegular,
                    ),
                    _buildHeaderContainerCell(
                      data: 'No',
                      verticalPadding: 3.0,
                      borderTop: false,
                      borderRight: false,
                      font: calibriRegular,
                    ),
                    _buildHeaderContainerCell(
                      data: 'Quantity',
                      verticalPadding: 3.0,
                      borderTop: false,
                      borderRight: false,
                      font: calibriRegular,
                    ),
                    _buildHeaderContainerCell(
                      data: 'Remarks',
                      verticalPadding: 3.0,
                      borderTop: false,
                      font: calibriRegular,
                    ),
                  ],
                ),
                for (int i = 0; i < descriptionColumn.length; i++)
                  _buildRISTableRow(
                    stockNo: i == 0 ? stockNo : '\n',
                    unit: i == 0 ? readableEnumConverter(unit) : '\n',
                    description: descriptionColumn[i],
                    requestQuantity: i == 0 ? requestQuantity.toString() : '\n',
                    issueQuantity: (i == 0 ||
                            (i >= 5 &&
                                itemIndexForQuantity < issuedItemsMap.length))
                        ? issuedItemsMap[itemIndexForQuantity++]
                                    ['issued_quantity']
                                ?.toString() ??
                            '\n'
                        : '\n',
                    borderBottom:
                        i == descriptionColumn.length - 1 ? false : true,
                    rowHeight: rowHeights[i],
                  ),
              ],
            ),

            pw.Table(
              children: [
                pw.TableRow(
                  children: [
                    _buildContainer(
                      horizontalPadding: 5.0,
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _buildTableRowColumn(
                            data: 'Purpose:',
                            borderRight: false,
                            borderBottom: false,
                            borderLeft: false,
                          ),
                          _buildTableRowColumn(
                            data: '\n\n\n\n',
                            borderRight: false,
                            borderLeft: false,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            pw.Table(
              columnWidths: {
                0: const pw.FixedColumnWidth(225),
                1: const pw.FixedColumnWidth(300),
                2: const pw.FixedColumnWidth(300),
                3: const pw.FixedColumnWidth(225),
                4: const pw.FixedColumnWidth(225),
              },
              children: [
                _buildRISFooterTableHeader(),
                _buildRISFooterTableRow(
                  title: 'Printed Name:',
                  dataRowColumnOne: requestingOfficerName,
                  dataRowColumnTwo: approvingOfficerName,
                  dataRowColumnThree: issuingOfficerName,
                  dataRowColumnFour: receivingOfficerName,
                ),
                _buildRISFooterTableRow(
                  title: 'Designation:',
                  dataRowColumnOne: requestingOfficerPosition,
                  dataRowColumnTwo: approvingOfficerPosition,
                  dataRowColumnThree: issuingOfficerPosition,
                  dataRowColumnFour: receivingOfficerPosition,
                ),
                _buildRISFooterTableRow(
                  title: 'Date:',
                ),
              ],
            ),
          ],
        ),
      ),
    );

    return pdf;
  }

  pw.TableRow _buildRISTableRow({
    String? stockNo,
    String? unit,
    String? description,
    String? requestQuantity,
    String? yes,
    String? no,
    String? issueQuantity,
    String? remarks,
    double? rowHeight,
    borderBottom = true,
  }) {
    return pw.TableRow(
      children: [
        _buildTableRowColumn(
          data: stockNo ?? '\n',
          borderRight: false,
          rowHeight: rowHeight,
          borderBottom: borderBottom,
        ),
        _buildTableRowColumn(
          data: readableEnumConverter(unit),
          borderRight: false,
          rowHeight: rowHeight,
          borderBottom: borderBottom,
        ),
        _buildTableRowColumn(
          data: description ?? '\n',
          borderRight: false,
          rowHeight: rowHeight,
          borderBottom: borderBottom,
        ),
        _buildTableRowColumn(
          data: requestQuantity ?? '\n',
          borderRight: false,
          rowHeight: rowHeight,
          borderBottom: borderBottom,
        ),
        _buildTableRowColumn(
          data: yes ?? '\n',
          solidBorderWidth: 2.0,
          borderRight: false,
          rowHeight: rowHeight,
          borderBottom: borderBottom,
        ),
        _buildTableRowColumn(
          data: no ?? '\n',
          borderRight: false,
          rowHeight: rowHeight,
          borderBottom: borderBottom,
        ),
        _buildTableRowColumn(
          data: issueQuantity ?? '\n',
          solidBorderWidth: 2.0,
          borderRight: false,
          rowHeight: rowHeight,
          borderBottom: borderBottom,
        ),
        _buildTableRowColumn(
          data: remarks ?? '\n',
          rowHeight: rowHeight,
          borderBottom: borderBottom,
        ),
      ],
    );
  }

  pw.Widget _buildRISHeaderContainer({
    required String row1Title,
    String? row1Value,
    required String row2Title,
    String? row2Value,
    bool borderRight = true,
    bool isRow1Underlined = false,
    bool isRow2Underlined = false,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(3.0),
      decoration: pw.BoxDecoration(
        border: pw.Border(
          top: const pw.BorderSide(
            width: 3.0,
          ),
          right: borderRight
              ? const pw.BorderSide(
                  width: 3.0,
                )
              : pw.BorderSide.none,
          bottom: const pw.BorderSide(
            width: 3.0,
          ),
          left: const pw.BorderSide(
            width: 3.0,
          ),
        ),
      ),
      child: pw.Column(
        children: [
          _buildRowTextValue(
            text: row1Title,
            value: row1Value ?? (isRow1Underlined ? '________' : ''),
            font: calibriRegular,
          ),
          _buildRowTextValue(
            text: row2Title,
            value: row2Value ?? (isRow2Underlined ? '________' : ''),
            font: calibriRegular,
          ),
        ],
      ),
    );
  }

  pw.TableRow _buildRISFooterTableHeader() {
    return pw.TableRow(
      children: [
        _buildHeaderContainerCell(
          data: '\nSignature:',
          horizontalPadding: 3.0,
          verticalPadding: 3.0,
          font: calibriRegular,
          isAlignCenter: false,
          borderTop: false,
          borderRight: false,
        ),
        _buildHeaderContainerCell(
          data: 'Requested by: \n\n',
          horizontalPadding: 3.0,
          verticalPadding: 3.0,
          font: calibriBold,
          isAlignCenter: false,
          borderTop: false,
          borderRight: false,
        ),
        _buildHeaderContainerCell(
          data: 'Approved by: \n\n',
          horizontalPadding: 3.0,
          verticalPadding: 3.0,
          font: calibriBold,
          isAlignCenter: false,
          borderTop: false,
          borderRight: false,
        ),
        _buildHeaderContainerCell(
          data: 'Issued by: \n\n',
          horizontalPadding: 3.0,
          verticalPadding: 3.0,
          font: calibriBold,
          isAlignCenter: false,
          borderTop: false,
          borderRight: false,
        ),
        _buildHeaderContainerCell(
          data: 'Received by: \n\n',
          horizontalPadding: 3.0,
          verticalPadding: 3.0,
          font: calibriBold,
          isAlignCenter: false,
          borderTop: false,
        ),
      ],
    );
  }

  pw.TableRow _buildRISFooterTableRow({
    required String title,
    String? dataRowColumnOne,
    String? dataRowColumnTwo,
    String? dataRowColumnThree,
    String? dataRowColumnFour,
  }) {
    return pw.TableRow(
      children: [
        _buildTableRowColumn(
          data: title,
          isAlignCenter: false,
          borderRight: false,
          fontSize: 7.0,
        ),
        _buildTableRowColumn(
          data: dataRowColumnOne?.toUpperCase() ?? '\n',
          borderRight: false,
          fontSize: 7.0,
        ),
        _buildTableRowColumn(
          data: dataRowColumnTwo?.toUpperCase() ?? '\n',
          borderRight: false,
          fontSize: 7.0,
        ),
        _buildTableRowColumn(
          data: dataRowColumnThree?.toUpperCase() ?? '\n',
          borderRight: false,
          fontSize: 7.0,
        ),
        _buildTableRowColumn(
          data: dataRowColumnFour?.toUpperCase() ?? '\n',
          fontSize: 7.0,
        ),
      ],
    );
  }

  Future<pw.Document> generateSticker({
    required PdfPageFormat pageFormat,
    required pw.PageOrientation orientation,
    required dynamic data,
    bool withQR = true,
  }) async {
    final pdf = pw.Document();

    final List<IssuanceItemModel> items;
    final List<String> mappableData = [];

    final String fundSource;
    final String acquisitionDate;
    final String personAccountable;

    if (data is InventoryCustodianSlipModel) {
      items = data.items as List<IssuanceItemModel>;
      fundSource =
          readableEnumConverter(data.purchaseRequestEntity.fundCluster);
      personAccountable = data.receivingOfficerEntity.name;
      acquisitionDate = documentDateFormatter(data.issuedDate);
    } else if (data is PropertyAcknowledgementReceiptModel) {
      items = data.items as List<IssuanceItemModel>;
      fundSource =
          readableEnumConverter(data.purchaseRequestEntity.fundCluster);
      personAccountable = data.receivingOfficerEntity.name;
      acquisitionDate = documentDateFormatter(data.issuedDate);
    } else {
      throw ArgumentError('Unsupported data type for RIS generation');
    }

    for (int i = 0; i < items.length; i++) {
      final item = items[i];

      mappableData.addAll([
        '\n${item.itemEntity.itemEntity.id}',
        readableEnumConverter(item.itemEntity.itemEntity.assetClassification),
        fundSource,
        '${item.itemEntity.productStockEntity.productName.name}/ ${item.itemEntity.manufacturerBrandEntity.brand.name}/ ${item.itemEntity.modelEntity.modelName}'
            .toUpperCase(),
        item.itemEntity.itemEntity.serialNo!,
        item.itemEntity.itemEntity.unitCost.toString(),
        acquisitionDate,
        capitalizeWord(personAccountable),
      ]);

      final rowHeights = mappableData.map((row) {
        return getRowHeight(row, fontSize: 8.5);
      }).toList();

      pdf.addPage(
        pw.Page(
          pageTheme: _getPageTheme(
            pageFormat: pageFormat,
            orientation: orientation,
            marginTop: 1.9,
            marginRight: 1.2,
            marginBottom: 0.8,
            marginLeft: 0.9,
          ),
          build: (context) => _buildContainer(
            width: 225.0,
            height: 400.0,
            borderWidthTop: 2.0,
            borderWidthRight: 2.0,
            borderWidthBottom: 2.0,
            borderWidthLeft: 2.0,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                _buildStickerHeader(),
                pw.SizedBox(
                  height: 5.0,
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.all(3.0),
                  color: PdfColors.lightBlue,
                  child: pw.Text(
                    'PHYSICAL PROPERTY INVENTORY',
                    style: pw.TextStyle(
                      font: calibriBold,
                      fontSize: 12.0,
                      color: PdfColors.white,
                      //fontWeight: pw.FontWeight.bold,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.SizedBox(
                  height: 10.0,
                ),
                pw.Table(
                  columnWidths: {
                    0: const pw.FixedColumnWidth(150.0),
                    1: const pw.FixedColumnWidth(165.0),
                  },
                  children: [
                    _buildStickerTableRow(
                      title: data is InventoryCustodianSlipModel
                          ? 'SEMI-EXPENDABLE \nPROPERTY NUMBER'
                          : '\nPROPERTY NUMBER',
                      value: mappableData[i * 8 + 0],
                      borderRight: false,
                    ),
                    _buildStickerTableRow(
                      title: 'ASSET CLASSIFICATION',
                      value: mappableData[i * 8 + 1],
                      borderTop: false,
                      borderRight: false,
                    ),
                    _buildStickerTableRow(
                      title: 'FUND SOURCE',
                      value: mappableData[i * 8 + 2],
                      borderTop: false,
                      borderRight: false,
                    ),
                    _buildStickerTableRow(
                      title: 'ITEM/BRAND/MODEL',
                      value: mappableData[i * 8 + 3],
                      borderTop: false,
                      borderRight: false,
                    ),
                    _buildStickerTableRow(
                      title: 'SERIAL NUMBER',
                      value: mappableData[i * 8 + 4],
                      borderTop: false,
                      borderRight: false,
                    ),
                    _buildStickerTableRow(
                      title: 'ACQUISITION COST',
                      value: mappableData[i * 8 + 5],
                      borderTop: false,
                      borderRight: false,
                    ),
                    _buildStickerTableRow(
                      title: 'ACQUISITION DATE',
                      value: mappableData[i * 8 + 6],
                      borderTop: false,
                      borderRight: false,
                    ),
                    _buildStickerTableRow(
                      title: 'PERSON ACCOUNTABLE',
                      value: mappableData[i * 8 + 7],
                      borderTop: false,
                      borderRight: false,
                    ),
                    _buildStickerTableRow(
                      title: '\nVALIDATION/SIGNATURE',
                      value: '\n\n', // This row doesn't depend on the list
                      borderTop: false,
                      borderRight: false,
                    ),
                    if (withQR)
                      pw.TableRow(
                        children: [
                          _buildQrContainer(data: item.itemEntity.itemEntity.encryptedId)
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    return pdf;
  }

  pw.TableRow _buildStickerTableRow({
    required String title,
    String? value,
    double? height,
    bool borderTop = true,
    bool borderRight = true,
    bool borderBottom = true,
    bool borderLeft = true,
  }) {
    return pw.TableRow(
      children: [
        _buildContainer(
          height: height,
          horizontalPadding: 3.0,
          verticalPadding: 3.0,
          borderTop: borderTop,
          borderRight: borderRight,
          borderBottom: borderBottom,
          borderLeft: false,
          child: pw.Text(
            title,
            style: pw.TextStyle(
              font: calibriBold,
              fontSize: 8.5,
            ),
          ),
        ),
        _buildContainer(
          height: height,
          horizontalPadding: 3.0,
          verticalPadding: 3.0,
          borderTop: borderTop,
          borderRight: borderRight,
          borderBottom: borderBottom,
          borderLeft: borderLeft,
          child: pw.Text(
            value ?? '',
            style: pw.TextStyle(
              font: calibriBold,
              fontSize: 8.5,
            ),
          ),
        ),
      ],
    );
  }

  pw.PageTheme _getPageTheme({
    required PdfPageFormat pageFormat,
    required pw.PageOrientation orientation,
    double? marginTop,
    double? marginRight,
    double? marginBottom,
    double? marginLeft,
  }) {
    return pw.PageTheme(
      pageFormat: pageFormat,
      orientation: orientation,
      margin: pw.EdgeInsets.only(
        top: marginTop != null
            ? marginTop * PdfPageFormat.cm
            : 1.2 * PdfPageFormat.cm,
        right: marginRight != null
            ? marginRight * PdfPageFormat.cm
            : 1.2 * PdfPageFormat.cm,
        bottom: marginBottom != null
            ? marginBottom * PdfPageFormat.cm
            : 1.3 * PdfPageFormat.cm,
        left: marginLeft != null
            ? marginLeft * PdfPageFormat.cm
            : 1.2 * PdfPageFormat.cm,
      ),
    );
  }

  pw.Container _buildContainer({
    double? width,
    double? height,
    double? horizontalPadding,
    double? verticalPadding,
    double borderWidthTop = 3.5,
    double borderWidthRight = 3.5,
    double borderWidthBottom = 3.5,
    double borderWidthLeft = 3.5,
    bool borderTop = true,
    bool borderRight = true,
    bool borderBottom = true,
    bool borderLeft = true,
    pw.Widget? child,
  }) {
    return pw.Container(
      width: width,
      height: height,
      padding: pw.EdgeInsets.symmetric(
        horizontal: horizontalPadding ?? 0.0,
        vertical: verticalPadding ?? 0.0,
      ),
      decoration: pw.BoxDecoration(
        border: pw.Border(
          top: borderTop
              ? pw.BorderSide(
                  width: borderWidthTop,
                )
              : pw.BorderSide.none,
          right: borderRight
              ? pw.BorderSide(
                  width: borderWidthRight,
                )
              : pw.BorderSide.none,
          bottom: borderBottom
              ? pw.BorderSide(
                  width: borderWidthBottom,
                )
              : pw.BorderSide.none,
          left: borderLeft
              ? pw.BorderSide(
                  width: borderWidthLeft,
                )
              : pw.BorderSide.none,
        ),
      ),
      child: child,
    );
  }

  pw.Container _buildHeaderContainerCell({
    required String data,
    double? horizontalPadding,
    double? verticalPadding,
    bool isBold = true,
    bool isAlignCenter = true,
    double borderWidthTop = 3.5,
    double borderWidthRight = 3.5,
    double borderWidthBottom = 3.5,
    double borderWidthLeft = 3.5,
    bool borderTop = true,
    bool borderRight = true,
    bool borderBottom = true,
    bool borderLeft = true,
    pw.Font? font,
  }) {
    return pw.Container(
      padding: pw.EdgeInsets.symmetric(
        horizontal: horizontalPadding ?? 0.0,
        vertical: verticalPadding ?? 0.0,
      ),
      child: pw.Text(
        data,
        style: pw.TextStyle(
          font: font ?? (isBold ? timesNewRomanBold : timesNewRomanRegular),
          fontSize: 10.0,
        ),
        textAlign: isAlignCenter ? pw.TextAlign.center : null,
      ),
      decoration: pw.BoxDecoration(
        border: pw.Border(
          top: borderTop
              ? pw.BorderSide(
                  width: borderWidthTop,
                )
              : pw.BorderSide.none,
          right: borderRight
              ? pw.BorderSide(
                  width: borderWidthRight,
                )
              : pw.BorderSide.none,
          bottom: borderBottom
              ? pw.BorderSide(
                  width: borderWidthBottom,
                )
              : pw.BorderSide.none,
          left: borderLeft
              ? pw.BorderSide(
                  width: borderWidthLeft,
                )
              : pw.BorderSide.none,
        ),
      ),
    );
  }

  pw.Widget _buildTableRowColumn({
    required String data,
    double? fontSize,
    double? rowHeight,
    double solidBorderWidth = 3.0,
    double slashedBorderWidth = 1.5,
    bool isAlignCenter = true,
    bool isBottomBorderSlashed = false,
    bool borderRight = true,
    bool borderBottom = true,
    bool borderLeft = true,
  }) {
    return pw.Container(
      height: rowHeight,
      padding: const pw.EdgeInsets.all(2),
      child: pw.Text(
        data,
        style: pw.TextStyle(
          font: tahomaRegular,
          fontSize: fontSize ?? 8.5,
        ),
        textAlign: isAlignCenter ? pw.TextAlign.center : null,
      ),
      decoration: pw.BoxDecoration(
        border: pw.Border(
          right: borderRight
              ? pw.BorderSide(
                  width: solidBorderWidth,
                )
              : pw.BorderSide.none,
          left: borderLeft
              ? pw.BorderSide(
                  width: solidBorderWidth,
                )
              : pw.BorderSide.none,
          bottom: borderBottom
              ? pw.BorderSide(
                  style: isBottomBorderSlashed
                      ? pw.BorderStyle.dashed
                      : pw.BorderStyle.solid,
                  width: slashedBorderWidth,
                )
              : pw.BorderSide.none,
        ),
      ),
    );
  }

  pw.Widget _buildHeader() {
    return pw.Column(
      children: [
        pw.Container(
          height: 60.0,
          width: 60.0,
          child: depedSeal,
        ),
        pw.SizedBox(height: 5.0),
        pw.Text(
          'Republic of the Philippines',
          style: pw.TextStyle(
            font: oldEnglish,
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 5.0),
        pw.Text('Department of Education',
            style: pw.TextStyle(
              font: oldEnglish,
              fontSize: 18,
              // fontWeight: pw.FontWeight.bold,
            )),
        pw.SizedBox(height: 5.0),
        pw.Text('Region V - Bicol',
            style: pw.TextStyle(
              fontBold: popvlvs,
              // font: popvlvs,
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
            )),
        pw.SizedBox(height: 5.0),
        pw.Text('SCHOOLS DIVISION OF LEGAZPI CITY',
            style: pw.TextStyle(
              font: tahomaBold,
              fontSize: 10,
              //fontWeight: pw.FontWeight.bold,
            )),
      ],
    );
  }

  pw.Widget _buildStickerHeader() {
    return pw.Column(
      children: [
        pw.Container(
          height: 48.75,
          width: 48.75,
          child: depedSeal,
        ),
        pw.SizedBox(
          height: 5.0,
        ),
        pw.Text(
          'DEPARTMENT OF EDUCATION',
          style: pw.TextStyle(
            font: calibriBold,
            fontSize: 10,
            // fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(
          height: 5.0,
        ),
        pw.Text(
          'Schools Division of Legazpi City',
          style: pw.TextStyle(
            font: calibriBold,
            fontSize: 10,
            //fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(
          height: 5.0,
        ),
        pw.Text(
          'Legazpi City',
          style: pw.TextStyle(
            font: calibriBold,
            fontSize: 10,
            //fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildRowTextValue({
    required String text,
    required String value,
    bool isUnderlined = false,
    pw.Font? font,
    double? fontSize,
  }) {
    return pw.Row(
      children: [
        pw.Text(
          text,
          style: pw.TextStyle(
            font: font ?? timesNewRomanBold,
            fontSize: fontSize ?? 10.0,
            //fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(
          width: 10.0,
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            font: font ?? timesNewRomanBold,
            fontSize: fontSize ?? 10.0,
            decoration: isUnderlined ? pw.TextDecoration.underline : null,
            //fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildReusableIssuanceFooterContainer({
    required String title,
    required String officerName,
    required String officerPosition,
    required String officerOffice,
    DateTime? date,
    bool borderRight = true,
    bool isPAR = false,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(3.0),
      decoration: pw.BoxDecoration(
        border: pw.Border(
          top: const pw.BorderSide(
            width: 3.0,
          ),
          right: borderRight
              ? const pw.BorderSide(
                  width: 3.0,
                )
              : pw.BorderSide.none,
          bottom: const pw.BorderSide(
            width: 3.0,
          ),
          left: const pw.BorderSide(
            width: 3.0,
          ),
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              font: isPAR ? timesNewRomanBold : timesNewRomanRegular,
              fontSize: 10.0,
            ),
          ),
          pw.SizedBox(
            height: 10.0,
          ),
          pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Text(
                officerName.toUpperCase(),
                style: pw.TextStyle(
                  font: timesNewRomanBold,
                  fontSize: 10.0,
                  decoration: isPAR ? pw.TextDecoration.underline : null,
                ),
              ),
              pw.Text(
                'Signature Over Printed Name',
                style: pw.TextStyle(
                  font: timesNewRomanRegular,
                  fontSize: 10.0,
                ),
              ),
              pw.Text(
                '${formatPosition(officerPosition.toUpperCase())} - ${officerOffice.toUpperCase()}',
                style: pw.TextStyle(
                  font: timesNewRomanRegular,
                  fontSize: 10.0,
                ),
              ),
              pw.Text(
                'Position/Office',
                style: pw.TextStyle(
                  font: timesNewRomanRegular,
                  fontSize: 10.0,
                ),
              ),
              pw.Text(
                isPAR
                    ? '_______________________'
                    : date != null
                        ? documentDateFormatter(date)
                        : '\n',
                style: pw.TextStyle(
                  font: timesNewRomanRegular,
                  fontSize: 10.0,
                ),
              ),
              pw.Text(
                'Date',
                style: pw.TextStyle(
                  font: timesNewRomanRegular,
                  fontSize: 10.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildQrContainer({
    required String data,
  }) {
    return pw.BarcodeWidget(
      data: data,
      barcode: pw.Barcode.qrCode(),
      width: 60,
      height: 60,
      drawText: false,
    );
  }
}
