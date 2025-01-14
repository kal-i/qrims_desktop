import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../features/item_issuance/data/models/inventory_custodian_slip.dart';
import '../../../../features/item_issuance/data/models/issuance_item.dart';
import '../../../../features/item_issuance/data/models/property_acknowledgement_receipt.dart';
import '../../../enums/unit.dart';
import '../../../utils/document_date_formatter.dart';
import '../../../utils/extract_specification.dart';
import '../../../utils/format_position.dart';
import '../../../utils/readable_enum_converter.dart';
import '../document_service.dart';
import '../font_service.dart';
import '../utils/document_components.dart';
import '../utils/document_page_util.dart';
import 'base_document.dart';

class RequisitionAndIssuanceSlip implements BaseDocument {
  @override
  Future<pw.Document> generate({
    required PdfPageFormat pageFormat,
    required pw.PageOrientation orientation,
    required data,
    required bool withQr,
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
      return DocumentService.getRowHeight(row, fontSize: 8.5);
    }).toList();

    int itemIndexForQuantity = 0;
    int itemIndex = 0;

    pdf.addPage(
      pw.Page(
        pageTheme: DocumentPageUtil.getPageTheme(
          pageFormat: pageFormat,
          orientation: orientation,
          marginTop: 1.9,
          marginRight: 1.2,
          marginBottom: 0.8,
          marginLeft: 0.9,
        ),
        build: (context) => pw.Column(
          children: [
            DocumentComponents.buildDocumentHeader(),

            pw.SizedBox(
              height: 20.0,
            ),

            pw.Text(
              'REQUISITION AND ISSUE SLIP',
              style: pw.TextStyle(
                font: FontService().getFont('timesNewRomanBold'),
                fontSize: 14.0,
              ),
            ),

            pw.SizedBox(
              height: 20.0,
            ),

            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                DocumentComponents.buildRowTextValue(
                  text: 'Entity Name:',
                  value: entityName,
                  font: FontService().getFont('calibriBold'),
                ),
                DocumentComponents.buildRowTextValue(
                  text: 'Fund Cluster:',
                  value: fundCluster,
                  font: FontService().getFont('calibriBold'),
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
                    DocumentComponents().buildRISHeaderContainer(
                      row1Title: 'Division:',
                      row2Title: 'Office:',
                      borderRight: false,
                    ),
                    DocumentComponents().buildRISHeaderContainer(
                      row1Title: 'Responsibility Center Code:',
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
                    DocumentComponents.buildHeaderContainerCell(
                      data: 'Requisition',
                      verticalPadding: 3.0,
                      borderTop: false,
                      borderRight: false,
                      font: FontService().getFont('calibriBoldItalic'),
                    ),
                    DocumentComponents.buildHeaderContainerCell(
                      data: 'Stock Available?',
                      verticalPadding: 3.0,
                      borderTop: false,
                      borderRight: false,
                      font: FontService().getFont('calibriBoldItalic'),
                    ),
                    DocumentComponents.buildHeaderContainerCell(
                      data: 'Issue',
                      verticalPadding: 3.0,
                      borderTop: false,
                      font: FontService().getFont('calibriBoldItalic'),
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
                    DocumentComponents.buildHeaderContainerCell(
                      data: 'Stock No.',
                      verticalPadding: 3.0,
                      borderTop: false,
                      borderRight: false,
                      font: FontService().getFont('calibriRegular'),
                    ),
                    DocumentComponents.buildHeaderContainerCell(
                      data: 'Unit',
                      verticalPadding: 3.0,
                      borderTop: false,
                      borderRight: false,
                      font: FontService().getFont('calibriRegular'),
                    ),
                    DocumentComponents.buildHeaderContainerCell(
                      data: 'Description',
                      verticalPadding: 3.0,
                      borderTop: false,
                      borderRight: false,
                      font: FontService().getFont('calibriRegular'),
                    ),
                    DocumentComponents.buildHeaderContainerCell(
                      data: 'Quantity',
                      verticalPadding: 3.0,
                      borderTop: false,
                      borderRight: false,
                      font: FontService().getFont('calibriRegular'),
                    ),
                    DocumentComponents.buildHeaderContainerCell(
                      data: 'Yes',
                      verticalPadding: 3.0,
                      borderTop: false,
                      borderRight: false,
                      font: FontService().getFont('calibriRegular'),
                    ),
                    DocumentComponents.buildHeaderContainerCell(
                      data: 'No',
                      verticalPadding: 3.0,
                      borderTop: false,
                      borderRight: false,
                      font: FontService().getFont('calibriRegular'),
                    ),
                    DocumentComponents.buildHeaderContainerCell(
                      data: 'Quantity',
                      verticalPadding: 3.0,
                      borderTop: false,
                      borderRight: false,
                      font: FontService().getFont('calibriRegular'),
                    ),
                    DocumentComponents.buildHeaderContainerCell(
                      data: 'Remarks',
                      verticalPadding: 3.0,
                      borderTop: false,
                      font: FontService().getFont('calibriRegular'),
                    ),
                  ],
                ),
                for (int i = 0; i < descriptionColumn.length; i++)
                  DocumentComponents.buildRISTableRow(
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
                    DocumentComponents.buildContainer(
                      horizontalPadding: 5.0,
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          DocumentComponents.buildTableRowColumn(
                            data: 'Purpose:',
                            borderRight: false,
                            borderBottom: false,
                            borderLeft: false,
                          ),
                          DocumentComponents.buildTableRowColumn(
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
                DocumentComponents.buildRISFooterTableHeader(),
                DocumentComponents.buildRISFooterTableRow(
                  title: 'Printed Name:',
                  dataRowColumnOne: requestingOfficerName,
                  dataRowColumnTwo: approvingOfficerName,
                  dataRowColumnThree: issuingOfficerName,
                  dataRowColumnFour: receivingOfficerName,
                ),
                DocumentComponents.buildRISFooterTableRow(
                  title: 'Designation:',
                  dataRowColumnOne: formatPosition(requestingOfficerPosition),
                  dataRowColumnTwo: formatPosition(approvingOfficerPosition),
                  dataRowColumnThree: formatPosition(issuingOfficerPosition),
                  dataRowColumnFour: formatPosition(receivingOfficerPosition),
                ),
                DocumentComponents.buildRISFooterTableRow(
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
}
