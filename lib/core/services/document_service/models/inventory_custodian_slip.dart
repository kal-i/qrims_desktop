import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../enums/unit.dart';
import '../../../utils/document_date_formatter.dart';
import '../../../utils/extract_specification.dart';
import '../../../utils/readable_enum_converter.dart';
import '../document_service.dart';
import '../font_service.dart';
import '../utils/document_components.dart';
import '../utils/document_page_util.dart';
import 'base_document.dart';

class InventoryCustodianSlip implements BaseDocument {
  @override
  Future<pw.Document> generate({
    required PdfPageFormat pageFormat,
    //required pw.PageOrientation orientation,
    required data,
    required bool withQr,
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
    for (int i = 0; i < data.items.length; i++) {
      // we need to extract each info and skip some
      final item = data.items[i];

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
          'PR: ${data.purchaseRequestEntity.id}',
          'Date Acquired: ${documentDateFormatter(item.itemEntity.itemEntity.acquiredDate!)}'
        ]);

        unit = item.itemEntity.itemEntity.unit;
        unitCost = item.itemEntity.itemEntity.unitCost;
        estimatedUsefulLife = item.itemEntity.itemEntity.estimatedUsefulLife;
      }

      totalCost = unitCost! * data.items.length;

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
          orientation: pw.PageOrientation.portrait,
        ),
        build: (context) => pw.Column(
          children: [
            DocumentComponents.buildDocumentHeader(),

            pw.SizedBox(
              height: 20.0,
            ),

            pw.Text(
              'INVENTORY CUSTODIAN SLIP',
              style: pw.TextStyle(
                font: FontService().getFont('timesNewRomanBold'),
                fontSize: 14.0,
              ),
            ),

            pw.SizedBox(
              height: 20.0,
            ),

            DocumentComponents.buildRowTextValue(
              text: 'Entity Name:',
              value: data.purchaseRequestEntity.entity.name,
            ),

            pw.SizedBox(
              height: 3.0,
            ),

            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                DocumentComponents.buildRowTextValue(
                  text: 'Fund Cluster:',
                  value: readableEnumConverter(
                      data.purchaseRequestEntity.fundCluster),
                ),
                DocumentComponents.buildRowTextValue(
                  text: 'ICS No:',
                  value: data.icsId,
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
                    DocumentComponents.buildHeaderContainerCell(
                      data: 'Quantity',
                      verticalPadding: 13.2,
                      borderRight: false,
                    ),
                    DocumentComponents.buildHeaderContainerCell(
                      data: 'Unit',
                      verticalPadding: 13.2,
                      borderRight: false,
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                      children: [
                        DocumentComponents.buildHeaderContainerCell(
                          data: 'Amount',
                          verticalPadding: 1.0,
                          borderWidthBottom: 2.0,
                          borderRight: false,
                        ),
                        pw.Row(
                          children: [
                            pw.SizedBox(
                              width: 45.0,
                              child:
                                  DocumentComponents.buildHeaderContainerCell(
                                data: 'Unit Cost',
                                horizontalPadding: 6.0,
                                verticalPadding: 1.0,
                                isBold: false,
                                borderTop: false,
                                borderRight: false,
                              ),
                            ),
                            pw.Expanded(
                              child:
                                  DocumentComponents.buildHeaderContainerCell(
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
                    DocumentComponents.buildHeaderContainerCell(
                      data: 'Description',
                      verticalPadding: 13.2,
                      borderRight: false,
                    ),
                    DocumentComponents.buildHeaderContainerCell(
                      data: 'Inventory Item No.',
                      verticalPadding: 13.2,
                      borderRight: false,
                    ),
                    DocumentComponents.buildHeaderContainerCell(
                      data: 'Estimated Useful Life',
                      //horizontalPadding: 3.0,
                      verticalPadding: 7.7,
                    ),
                  ],
                ),

                // Add more rows for your table data here...
                for (int i = 0; i < descriptionColumn.length; i++)
                  DocumentComponents.buildIcsTableRow(
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
                    DocumentComponents.buildReusableIssuanceFooterContainer(
                      title: 'Received from:',
                      officerName: data.sendingOfficerEntity.name,
                      officerPosition: data.sendingOfficerEntity.positionName,
                      officerOffice: data.sendingOfficerEntity.officeName,
                      date: DateTime.now(),
                      borderRight: false,
                    ),
                    DocumentComponents.buildReusableIssuanceFooterContainer(
                      title: 'Received by:',
                      officerName: data.receivingOfficerEntity.name,
                      officerPosition: data.receivingOfficerEntity.positionName,
                      officerOffice: data.receivingOfficerEntity.officeName,
                    ),
                  ],
                ),
              ],
            ),

            pw.SizedBox(height: 30.0),

            if (withQr)
              pw.Align(
                alignment: pw.AlignmentDirectional.bottomEnd,
                child: DocumentComponents.buildQrContainer(
                  data: data.id,
                ),
              ),
          ],
        ),
      ),
    );

    return pdf;
  }
}
