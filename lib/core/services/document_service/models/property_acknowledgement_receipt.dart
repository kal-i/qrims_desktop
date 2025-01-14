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

class PropertyAcknowledgementReceipt implements BaseDocument {
  @override
  Future<pw.Document> generate({
    required PdfPageFormat pageFormat,
    required pw.PageOrientation orientation,
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

    int itemIndexForQuantity = 0;
    int itemIndex = 0;

    print('desc length: ${descriptionColumn.length}');

    final rowHeights = descriptionColumn.map((row) {
      return DocumentService.getRowHeight(
        row,
        fontSize: 8.5,
      );
    }).toList();

    pdf.addPage(
      pw.Page(
        pageTheme: DocumentPageUtil.getPageTheme(
          pageFormat: pageFormat,
          orientation: orientation,
          marginTop: 2.5,
          marginRight: 2.5,
          marginBottom: 1.3,
          marginLeft: 3.2,
        ),
        build: (context) => pw.Column(
          children: [
            DocumentComponents.buildDocumentHeader(),

            pw.SizedBox(
              height: 20.0,
            ),

            pw.Text(
              'PROPERTY ACKNOWLEDGEMENT RECEIPT',
              style: pw.TextStyle(
                font: FontService().getFont('timesNewRomanBold'),
                fontSize: 14.0,
                //fontWeight: pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(
              height: 20.0,
            ),

            DocumentComponents.buildRowTextValue(
              text: 'Entity Name:',
              value: data.purchaseRequestEntity.entity.name,
              isUnderlined: true,
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
                  text: 'PAR No:',
                  value: data.parId,
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
                    DocumentComponents.buildHeaderContainerCell(
                      data: 'Quantity',
                      horizontalPadding: 3.0,
                      verticalPadding: 8.6,
                      borderRight: false,
                    ),
                    DocumentComponents.buildHeaderContainerCell(
                      data: 'Unit',
                      verticalPadding: 8.6,
                      borderRight: false,
                    ),
                    DocumentComponents.buildHeaderContainerCell(
                      data: 'Description',
                      verticalPadding: 8.6,
                      borderRight: false,
                    ),
                    DocumentComponents.buildHeaderContainerCell(
                      data: 'Property Number',
                      horizontalPadding: 3.0,
                      verticalPadding: 3.0,
                      borderRight: false,
                    ),
                    DocumentComponents.buildHeaderContainerCell(
                      data: 'Date Acquired',
                      horizontalPadding: 3.0,
                      verticalPadding: 3.0,
                      borderRight: false,
                    ),
                    DocumentComponents.buildHeaderContainerCell(
                      data: 'Amount',
                      horizontalPadding: 3.0,
                      verticalPadding: 8.6,
                    ),
                  ],
                ),

                // Add more rows for your table data here...
                for (int i = 0; i < descriptionColumn.length; i++)
                  DocumentComponents.buildParTableRow(
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
                    DocumentComponents.buildReusableIssuanceFooterContainer(
                      title: 'Received from:',
                      officerName: data.sendingOfficerEntity.name,
                      officerPosition: data.sendingOfficerEntity.positionName,
                      officerOffice: data.sendingOfficerEntity.officeName,
                      borderRight: false,
                      isPAR: true,
                    ),
                    DocumentComponents.buildReusableIssuanceFooterContainer(
                      title: 'Received by:',
                      officerName: data.receivingOfficerEntity.name,
                      officerPosition: data.receivingOfficerEntity.positionName,
                      officerOffice: data.receivingOfficerEntity.officeName,
                      isPAR: true,
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
