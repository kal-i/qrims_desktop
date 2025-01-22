import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../enums/unit.dart';
import '../document_service.dart';
import '../font_service.dart';
import '../image_service.dart';
import '../utils/document_components.dart';
import '../utils/document_page_util.dart';
import 'base_document.dart';

class PurchaseOrder implements BaseDocument {
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
    // for (int i = 0; i < par.items.length; i++) {
    //   // we need to extract each info and skip some
    //   final item = par.items[i];
    //
    //   /// in the first index, we will display all info
    //   /// but there is a catch, for the description column
    //   /// we will extract it and display the extracted info one by one in
    //   /// the description column
    //
    //   /// extract similar info in the first iteration
    //   if (i == 0) {
    //     descriptionColumn.addAll([
    //       item.itemEntity.productStockEntity.productDescription!.description!,
    //       'Specifications:',
    //       ...extractSpecification(item.itemEntity.itemEntity.specification,
    //           ' - '), // Append the list of specifications
    //       'Brand: ${item.itemEntity.manufacturerBrandEntity.brand.name}',
    //       'Model: ${item.itemEntity.modelEntity.modelName}',
    //       'SN: ${item.itemEntity.itemEntity.serialNo}',
    //       'PR: ${par.purchaseRequestEntity.id}',
    //       'Date Acquired: ${documentDateFormatter(item.itemEntity.itemEntity.acquiredDate!)}'
    //     ]);
    //
    //     unit = item.itemEntity.itemEntity.unit;
    //     unitCost = item.itemEntity.itemEntity.unitCost;
    //     estimatedUsefulLife = item.itemEntity.itemEntity.estimatedUsefulLife;
    //   }
    //
    //   totalCost = unitCost! * par.items.length;
    //
    //   issuedItemsMap.add({
    //     'item_id': item.itemEntity.itemEntity.id,
    //     'issued_quantity': item.quantity,
    //   });
    // }

    int itemIndexForQuantity = 0;
    int itemIndex = 0;

    print('desc length: ${descriptionColumn.length}');

    final rowHeights = descriptionColumn.map((row) {
      return DocumentService.getRowHeight(row);
    }).toList();

    pdf.addPage(
      pw.Page(
        pageTheme: DocumentPageUtil.getPageTheme(
          pageFormat: pageFormat,
          orientation: pw.PageOrientation.portrait,
          marginTop: 1.9,
          marginRight: 1.8,
          marginBottom: 1.9,
          marginLeft: 2.8,
        ),
        build: (context) => pw.Column(
          children: [
            DocumentComponents.buildDocumentHeader(),
            pw.SizedBox(
              height: 20.0,
            ),
            pw.Text(
              'PURCHASE ORDER',
              style: pw.TextStyle(
                font: FontService().getFont('algeria'),
                fontSize: 16.0,
                //fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(
              height: 20.0,
            ),
            pw.Table(
              columnWidths: {
                0: const pw.FixedColumnWidth(150.0),
                1: const pw.FixedColumnWidth(675.0),
                2: const pw.FixedColumnWidth(450.0),
              },
              children: [
                pw.TableRow(
                  children: [
                    DocumentComponents.buildContainer(
                      horizontalPadding: 3.0,
                      verticalPadding: 3.0,
                      borderWidthTop: 2.0,
                      borderWidthBottom: 2.0,
                      borderWidthLeft: 2.0,
                      borderRight: false,
                      child: pw.Text(
                        'Supplier:',
                        style: pw.TextStyle(
                          font: FontService().getFont('arial'),
                          fontSize: 9.0,
                        ),
                      ),
                    ),
                    DocumentComponents.buildContainer(
                      horizontalPadding: 3.0,
                      verticalPadding: 3.5,
                      borderWidthTop: 2.0,
                      borderWidthBottom: 2.0,
                      borderWidthLeft: 2.0,
                      borderRight: false,
                      child: pw.Text(
                        '\n',
                        style: pw.TextStyle(
                          font: FontService().getFont('calibriBold'),
                          fontSize: 9.0,
                        ),
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Row(
                        children: [
                          pw.Expanded(
                            child: DocumentComponents.buildContainer(
                              horizontalPadding: 3.0,
                              verticalPadding: 3.0,
                              borderWidthTop: 2.0,
                              borderWidthBottom: 2.0,
                              borderWidthLeft: 2.0,
                              borderRight: false,
                              child: pw.Text(
                                'PO No.',
                                style: pw.TextStyle(
                                  font: FontService().getFont('arial'),
                                  fontSize: 9.0,
                                ),
                              ),
                            ),
                          ),
                          pw.Expanded(
                            child: DocumentComponents.buildContainer(
                              horizontalPadding: 3.0,
                              verticalPadding: 3.4,
                              borderWidthTop: 2.0,
                              borderWidthRight: 2.0,
                              borderWidthBottom: 2.0,
                              borderWidthLeft: 2.0,
                              child: pw.Text(
                                '\n',
                                style: pw.TextStyle(
                                  font: FontService().getFont('calibriBold'),
                                  fontSize: 9.0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    DocumentComponents.buildContainer(
                      horizontalPadding: 5.0,
                      verticalPadding: 10.0,
                      borderWidthTop: 2.0,
                      borderWidthBottom: 2.0,
                      borderWidthLeft: 2.0,
                      borderTop: false,
                      borderRight: false,
                      child: pw.Text(
                        'Address:',
                        style: pw.TextStyle(
                          font: FontService().getFont('arial'),
                          fontSize: 9.0,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    DocumentComponents.buildContainer(
                      horizontalPadding: 5.0,
                      verticalPadding: 10.5,
                      borderWidthTop: 2.0,
                      borderWidthBottom: 2.0,
                      borderWidthLeft: 2.0,
                      borderTop: false,
                      borderRight: false,
                      child: pw.Text(
                        '\n',
                        style: pw.TextStyle(
                          font: FontService().getFont('calibriRegular'),
                          fontSize: 9.0,
                        ),
                      ),
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                      children: [
                        pw.Row(
                          children: [
                            pw.Expanded(
                              child: DocumentComponents.buildContainer(
                                horizontalPadding: 3.0,
                                verticalPadding: 3.0,
                                borderWidthRight: 2.0,
                                borderWidthBottom: 2.0,
                                borderWidthLeft: 2.0,
                                borderTop: false,
                                child: pw.Text(
                                  'Date:',
                                  style: pw.TextStyle(
                                    font: FontService().getFont('calibriBold'),
                                    fontSize: 9.0,
                                  ),
                                ),
                              ),
                            ),
                            pw.Expanded(
                              child: DocumentComponents.buildContainer(
                                horizontalPadding: 3.0,
                                verticalPadding: 3.0,
                                borderWidthRight: 2.0,
                                borderWidthBottom: 2.0,
                                borderWidthLeft: 0.0,
                                borderTop: false,
                                child: pw.Text(
                                  '\n',
                                  style: pw.TextStyle(
                                    font: FontService().getFont('calibriBold'),
                                    fontSize: 9.0,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        DocumentComponents.buildHeaderContainerCell(
                          data: 'Mode of Procurement: ',
                          horizontalPadding: 3.0,
                          verticalPadding: 3.0,
                          borderWidthRight: 2.0,
                          borderWidthBottom: 2.0,
                          borderWidthLeft: 2.0,
                          borderTop: false,
                          font: FontService().getFont('calibriRegular'),
                          fontSize: 9.0,
                          isAlignCenter: false,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            pw.Table(
              columnWidths: {
                0: const pw.FixedColumnWidth(150.0),
                1: const pw.FixedColumnWidth(1125.0),
              },
              children: [
                pw.TableRow(
                  children: [
                    DocumentComponents.buildContainer(
                      horizontalPadding: 3.0,
                      verticalPadding: 4.6,
                      borderTop: false,
                      borderRight: false,
                      borderWidthBottom: 2.0,
                      borderWidthLeft: 2.0,
                      child: pw.Text(
                        'Gentleman:\n\n\n\n',
                        style: pw.TextStyle(
                          font: FontService().getFont('arial'),
                          fontSize: 8.0,
                        ),
                      ),
                    ),
                    DocumentComponents.buildContainer(
                      horizontalPadding: 3.0,
                      verticalPadding: 18.0,
                      borderTop: false,
                      borderLeft: false,
                      borderWidthRight: 2.0,
                      borderWidthBottom: 2.0,
                      child: pw.Text(
                        'Please furnish this office the following articles subject to the terms and conditions contained herein:',
                        style: pw.TextStyle(
                          font: FontService().getFont('arial'),
                          fontSize: 8.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            pw.Table(
              columnWidths: {
                0: const pw.FixedColumnWidth(825.0),
                1: const pw.FixedColumnWidth(450.0),
              },
              children: [
                pw.TableRow(
                  children: [
                    DocumentComponents.buildContainer(
                      horizontalPadding: 3.0,
                      verticalPadding: 3.0,
                      borderTop: false,
                      borderRight: false,
                      borderBottom: false,
                      borderWidthBottom: 2.0,
                      borderWidthLeft: 2.0,
                      child: pw.Text(
                        'Place of Delivery:\t\t\t SDO Legazpi, Rawis Legazpi City',
                        style: pw.TextStyle(
                          font: FontService().getFont('arial'),
                          fontSize: 8.0,
                        ),
                      ),
                    ),
                    DocumentComponents.buildContainer(
                      horizontalPadding: 3.0,
                      verticalPadding: 3.0,
                      borderTop: false,
                      borderBottom: false,
                      borderWidthRight: 2.0,
                      borderWidthBottom: 2.0,
                      borderWidthLeft: 2.0,
                      child: pw.Text(
                        'Delivery Term:\t ',
                        style: pw.TextStyle(
                          font: FontService().getFont('arial'),
                          fontSize: 8.0,
                        ),
                      ),
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    DocumentComponents.buildContainer(
                      horizontalPadding: 3.0,
                      verticalPadding: 3.0,
                      borderTop: false,
                      borderRight: false,
                      borderWidthBottom: 2.0,
                      borderWidthLeft: 2.0,
                      child: pw.Text(
                        'Date of Delivery:',
                        style: pw.TextStyle(
                          font: FontService().getFont('arial'),
                          fontSize: 8.0,
                        ),
                      ),
                    ),
                    DocumentComponents.buildContainer(
                      horizontalPadding: 3.0,
                      verticalPadding: 3.0,
                      borderTop: false,
                      borderWidthRight: 2.0,
                      borderWidthBottom: 2.0,
                      borderWidthLeft: 2.0,
                      child: pw.Text(
                        'Payment Term:\t ',
                        style: pw.TextStyle(
                          font: FontService().getFont('arial'),
                          fontSize: 8.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            pw.Table(
              columnWidths: {
                0: const pw.FixedColumnWidth(150.0),
                1: const pw.FixedColumnWidth(125.0),
                2: const pw.FixedColumnWidth(100.0),
                3: const pw.FixedColumnWidth(450.0),
                4: const pw.FixedColumnWidth(225.0),
                5: const pw.FixedColumnWidth(225.0),
              },
              children: [
                pw.TableRow(
                  children: [
                    DocumentComponents.buildHeaderContainerCell(
                      data: 'Stock No.',
                      font: FontService().getFont('arial'),
                      fontSize: 8.0,
                      horizontalPadding: 3.0,
                      verticalPadding: 3.0,
                      borderTop: false,
                      borderRight: false,
                      borderWidthBottom: 2.0,
                      borderWidthLeft: 2.0,
                    ),
                    DocumentComponents.buildHeaderContainerCell(
                      data: 'Unit',
                      font: FontService().getFont('arial'),
                      fontSize: 8.0,
                      horizontalPadding: 3.0,
                      verticalPadding: 3.0,
                      borderTop: false,
                      borderRight: false,
                      borderWidthBottom: 2.0,
                      borderWidthLeft: 2.0,
                    ),
                    DocumentComponents.buildHeaderContainerCell(
                      data: 'Quantity',
                      font: FontService().getFont('arial'),
                      fontSize: 8.0,
                      horizontalPadding: 3.0,
                      verticalPadding: 3.0,
                      borderTop: false,
                      borderRight: false,
                      borderWidthBottom: 2.0,
                      borderWidthLeft: 2.0,
                    ),
                    DocumentComponents.buildHeaderContainerCell(
                      data: 'Description',
                      font: FontService().getFont('arial'),
                      fontSize: 8.0,
                      horizontalPadding: 3.0,
                      verticalPadding: 3.0,
                      borderTop: false,
                      borderRight: false,
                      borderWidthBottom: 2.0,
                      borderWidthLeft: 2.0,
                    ),
                    DocumentComponents.buildHeaderContainerCell(
                      data: 'Unit Cost',
                      font: FontService().getFont('arial'),
                      fontSize: 8.0,
                      horizontalPadding: 3.0,
                      verticalPadding: 3.0,
                      borderTop: false,
                      borderRight: false,
                      borderWidthBottom: 2.0,
                      borderWidthLeft: 2.0,
                    ),
                    DocumentComponents.buildHeaderContainerCell(
                      data: 'Amount',
                      font: FontService().getFont('arial'),
                      fontSize: 8.0,
                      horizontalPadding: 3.0,
                      verticalPadding: 3.0,
                      borderTop: false,
                      borderWidthRight: 2.0,
                      borderWidthBottom: 2.0,
                      borderWidthLeft: 2.0,
                    ),
                  ],
                ),
                for (int i = 0; i < 5; i++)
                  pw.TableRow(
                    children: [
                      DocumentComponents.buildHeaderContainerCell(
                        data: '\n',
                        font: FontService().getFont('arial'),
                        fontSize: 8.0,
                        horizontalPadding: 3.0,
                        verticalPadding: 3.0,
                        borderTop: false,
                        borderRight: false,
                        borderWidthBottom: 2.0,
                        borderWidthLeft: 2.0,
                      ),
                      DocumentComponents.buildHeaderContainerCell(
                        data: '\n',
                        font: FontService().getFont('arial'),
                        fontSize: 8.0,
                        horizontalPadding: 3.0,
                        verticalPadding: 3.0,
                        borderTop: false,
                        borderRight: false,
                        borderWidthBottom: 2.0,
                        borderWidthLeft: 2.0,
                      ),
                      DocumentComponents.buildHeaderContainerCell(
                        data: '\n',
                        font: FontService().getFont('arial'),
                        fontSize: 8.0,
                        horizontalPadding: 3.0,
                        verticalPadding: 3.0,
                        borderTop: false,
                        borderRight: false,
                        borderWidthBottom: 2.0,
                        borderWidthLeft: 2.0,
                      ),
                      DocumentComponents.buildHeaderContainerCell(
                        data: '\n',
                        font: FontService().getFont('arial'),
                        fontSize: 8.0,
                        horizontalPadding: 3.0,
                        verticalPadding: 3.0,
                        borderTop: false,
                        borderRight: false,
                        borderWidthBottom: 2.0,
                        borderWidthLeft: 2.0,
                      ),
                      DocumentComponents.buildHeaderContainerCell(
                        data: '\n',
                        font: FontService().getFont('arial'),
                        fontSize: 8.0,
                        horizontalPadding: 3.0,
                        verticalPadding: 3.0,
                        borderTop: false,
                        borderRight: false,
                        borderWidthBottom: 2.0,
                        borderWidthLeft: 2.0,
                      ),
                      DocumentComponents.buildHeaderContainerCell(
                        data: '\n',
                        font: FontService().getFont('arial'),
                        fontSize: 8.0,
                        horizontalPadding: 3.0,
                        verticalPadding: 3.0,
                        borderTop: false,
                        borderWidthRight: 2.0,
                        borderWidthBottom: 2.0,
                        borderWidthLeft: 2.0,
                      ),
                    ],
                  ),
              ],
            ),
            pw.Table(
              columnWidths: {
                0: const pw.FixedColumnWidth(275.0),
                1: const pw.FixedColumnWidth(775.0),
                2: const pw.FixedColumnWidth(225.0),
              },
              children: [
                pw.TableRow(
                  children: [
                    DocumentComponents.buildHeaderContainerCell(
                      data: '(Total Amount in Words)',
                      font: FontService().getFont('arial'),
                      fontSize: 8.0,
                      horizontalPadding: 3.0,
                      verticalPadding: 3.5,
                      borderTop: false,
                      borderRight: false,
                      borderWidthBottom: 2.0,
                      borderWidthLeft: 2.0,
                    ),
                    DocumentComponents.buildHeaderContainerCell(
                      data: '\n',
                      font: FontService().getFont('calibriBold'),
                      fontSize: 8.0,
                      horizontalPadding: 3.0,
                      verticalPadding: 3.5,
                      isAlignCenter: false,
                      borderTop: false,
                      borderRight: false,
                      borderWidthBottom: 2.0,
                      borderWidthLeft: 2.0,
                    ),
                    DocumentComponents.buildHeaderContainerCell(
                      data: '\n',
                      font: FontService().getFont('calibriBold'),
                      fontSize: 8.0,
                      horizontalPadding: 3.0,
                      verticalPadding: 3.5,
                      borderTop: false,
                      borderWidthRight: 2.0,
                      borderWidthBottom: 2.0,
                      borderWidthLeft: 2.0,
                    ),
                  ],
                ),
              ],
            ),
            pw.Table(
              columnWidths: {
                0: const pw.FixedColumnWidth(1275.0),
              },
              children: [
                pw.TableRow(
                  children: [
                    DocumentComponents.buildContainer(
                      horizontalPadding: 3.0,
                      verticalPadding: 3.0,
                      borderTop: false,
                      borderWidthRight: 2.0,
                      borderWidthBottom: 2.0,
                      borderWidthLeft: 2.0,
                      child: pw.Column(
                        children: [
                          pw.Text(
                            '\n\t\t\tIn case of failure to make the full delivery within the time specified above, a penalty of one tenth (1/10) of one percent for every day of delay shall be imposed.',
                            style: pw.TextStyle(
                              font: FontService().getFont('arial'),
                              fontSize: 10.0,
                            ),
                          ),
                          pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Row(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(
                                    '\n\n\n\nConforme:',
                                    style: pw.TextStyle(
                                      font: FontService().getFont('arial'),
                                      fontSize: 8.0,
                                    ),
                                  ),
                                  pw.Column(
                                    mainAxisAlignment:
                                        pw.MainAxisAlignment.center,
                                    children: [
                                      pw.SizedBox(height: 10.0),
                                      pw.Text(
                                        '\n\n\n______________________________',
                                        style: pw.TextStyle(
                                          font: FontService()
                                              .getFont('calibriRegular'),
                                          fontSize: 11.0,
                                          decoration:
                                              pw.TextDecoration.underline,
                                        ),
                                      ),
                                      pw.SizedBox(
                                        height: 5.0,
                                      ),
                                      pw.Text(
                                        '(Signature over printed name)',
                                        style: pw.TextStyle(
                                          font: FontService().getFont('arial'),
                                          fontSize: 8.0,
                                        ),
                                      ),
                                      pw.Text(
                                        '\n______________________',
                                        style: pw.TextStyle(
                                          font: FontService().getFont('arial'),
                                          fontSize: 8.0,
                                          decoration:
                                              pw.TextDecoration.underline,
                                        ),
                                      ),
                                      pw.SizedBox(
                                        height: 5.0,
                                      ),
                                      pw.Text(
                                        '(Date)',
                                        style: pw.TextStyle(
                                          font: FontService().getFont('arial'),
                                          fontSize: 8.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              /// 2nd col
                              pw.Padding(
                                padding: const pw.EdgeInsets.only(
                                  right: 20.0,
                                ),
                                child: pw.Column(
                                  mainAxisAlignment:
                                      pw.MainAxisAlignment.center,
                                  children: [
                                    pw.Align(
                                      alignment: pw.Alignment.topRight,
                                      child: pw.Text(
                                        'Very truly yours,\n\n\n',
                                        style: pw.TextStyle(
                                          font: FontService()
                                              .getFont('calibriRegular'),
                                          fontSize: 11.0,
                                        ),
                                      ),
                                    ),
                                    pw.Text(
                                      'DANILO E. DESPI',
                                      style: pw.TextStyle(
                                        font: FontService()
                                            .getFont('calibriBold'),
                                        fontSize: 10.0,
                                      ),
                                    ),
                                    pw.SizedBox(
                                      height: 5.0,
                                    ),
                                    pw.Text(
                                      'Schools Division Superintendent',
                                      style: pw.TextStyle(
                                        font: FontService()
                                            .getFont('calibriRegular'),
                                        fontSize: 8.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
                0: const pw.FixedColumnWidth(275.0),
                1: const pw.FixedColumnWidth(100.0),
                2: const pw.FixedColumnWidth(450.0),
                3: const pw.FixedColumnWidth(225.0),
                4: const pw.FixedColumnWidth(225.0),
              },
              children: [
                pw.TableRow(
                  children: [
                    DocumentComponents.buildContainer(
                      horizontalPadding: 3.0,
                      verticalPadding: 3.0,
                      borderTop: false,
                      borderRight: false,
                      borderBottom: false,
                      borderWidthLeft: 2.0,
                      child: pw.Text(
                        'Funds Available:\n\n',
                        style: pw.TextStyle(
                          font: FontService().getFont('arial'),
                          fontSize: 8.0,
                        ),
                      ),
                    ),
                    DocumentComponents.buildContainer(
                      horizontalPadding: 3.0,
                      verticalPadding: 3.0,
                      borderTop: false,
                      borderRight: false,
                      borderBottom: false,
                      borderLeft: false,
                      child: pw.Text(
                        'PR:',
                        style: pw.TextStyle(
                          font: FontService().getFont('arial'),
                          fontSize: 8.0,
                        ),
                      ),
                    ),
                    DocumentComponents.buildContainer(
                      horizontalPadding: 3.0,
                      verticalPadding: 3.0,
                      borderTop: false,
                      borderRight: false,
                      borderWidthBottom: 2.0,
                      borderWidthLeft: 2.0,
                      child: pw.Text(
                        '\n',
                        style: pw.TextStyle(
                          font: FontService().getFont('arial'),
                          fontSize: 8.0,
                        ),
                      ),
                    ),
                    DocumentComponents.buildContainer(
                      horizontalPadding: 3.0,
                      verticalPadding: 3.0,
                      borderTop: false,
                      borderRight: false,
                      borderWidthBottom: 2.0,
                      borderWidthLeft: 2.0,
                      child: pw.Text(
                        '\nAmount',
                        style: pw.TextStyle(
                          font: FontService().getFont('arial'),
                          fontSize: 8.0,
                        ),
                      ),
                    ),
                    DocumentComponents.buildContainer(
                      horizontalPadding: 3.0,
                      verticalPadding: 4.0,
                      borderTop: false,
                      borderLeft: false,
                      borderWidthRight: 2.0,
                      borderWidthBottom: 2.0,
                      child: pw.Text(
                        '\nP ',
                        style: pw.TextStyle(
                          font: FontService().getFont('calibriRegular'),
                          fontSize: 8.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            pw.Table(
              columnWidths: {
                0: const pw.FixedColumnWidth(825.0),
                1: const pw.FixedColumnWidth(450.0),
              },
              children: [
                pw.TableRow(
                  children: [
                    DocumentComponents.buildContainer(
                      horizontalPadding: 3.0,
                      //verticalPadding: 3.0,
                      borderTop: false,
                      borderRight: false,
                      borderWidthBottom: 2.0,
                      borderWidthLeft: 2.0,
                      child: pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          pw.Text(
                            'HAYDEE G. QUIOPA',
                            style: pw.TextStyle(
                              font: FontService().getFont('arial'),
                              fontSize: 12.0,
                              decoration: pw.TextDecoration.underline,
                            ),
                          ),
                          pw.Text(
                            'Accountant III',
                            style: pw.TextStyle(
                              font: FontService().getFont('arial'),
                              fontSize: 10.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    DocumentComponents.buildContainer(
                      horizontalPadding: 3.0,
                      verticalPadding: 4.3,
                      borderTop: false,
                      borderWidthRight: 2.0,
                      borderWidthBottom: 2.0,
                      borderWidthLeft: 2.0,
                      child: pw.Text(
                        '\nALOBS NO.',
                        style: pw.TextStyle(
                          font: FontService().getFont('calibriRegular'),
                          fontSize: 8.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            pw.Row(
              children: [
                pw.Container(
                  height: 60.0,
                  width: 60.0,
                  child: ImageService().getImage('sdoLogo'),
                ),
                pw.SizedBox(
                  width: 5.0,
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    DocumentComponents.richText(
                      title: 'Address:',
                      value: 'Purok 3, Rawis, Legazpi City',
                    ),
                    DocumentComponents.richText(
                      title: 'Telephone No.:',
                      value: '(052) 742-8227',
                    ),
                    DocumentComponents.richText(
                      title: 'Email:',
                      value: 'legazpi.city@deped.gov.ph',
                    ),
                  ],
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
