import 'package:pdf/widgets.dart' as pw;

import '../../../../init_dependencies.dart';
import '../../../utils/document_date_formatter.dart';
import '../../../utils/format_position.dart';
import '../../../utils/readable_enum_converter.dart';
import '../font_service.dart';
import '../image_service.dart';

class DocumentComponents {
  static pw.Widget buildDocumentHeader() {
    return pw.Column(
      children: [
        pw.Container(
          height: 60.0,
          width: 60.0,
          child: serviceLocator<ImageService>().getImage('depedSeal'),
        ),
        pw.SizedBox(height: 5.0),
        pw.Text(
          'Republic of the Philippines',
          style: pw.TextStyle(
            font: serviceLocator<FontService>().getFont('oldEnglish'),
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 5.0),
        pw.Text('Department of Education',
            style: pw.TextStyle(
              font: serviceLocator<FontService>().getFont('oldEnglish'),
              fontSize: 18,
            )),
        pw.SizedBox(height: 5.0),
        pw.Text('Region V - Bicol',
            style: pw.TextStyle(
              fontBold: serviceLocator<FontService>().getFont('popvlvs'),
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
            )),
        pw.SizedBox(height: 5.0),
        pw.Text('SCHOOLS DIVISION OF LEGAZPI CITY',
            style: pw.TextStyle(
              fontBold: serviceLocator<FontService>().getFont('tahomaBold'),
              fontSize: 10,
            )),
      ],
    );
  }

  static pw.Widget buildQrContainer({
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

  static pw.Container buildHeaderContainerCell({
    required String data,
    double? horizontalPadding,
    double? verticalPadding,
    bool isBold = true,
    bool isAlignCenter = true,
    double? fontSize,
    double borderWidthTop = 3.5,
    double borderWidthRight = 3.5,
    double borderWidthBottom = 3.5,
    double borderWidthLeft = 3.5,
    bool borderTop = true,
    bool borderRight = true,
    bool borderBottom = true,
    bool borderLeft = true,
    pw.Font? font,
    pw.FontStyle? fontStyle,
  }) {
    return pw.Container(
      padding: pw.EdgeInsets.symmetric(
        horizontal: horizontalPadding ?? 0.0,
        vertical: verticalPadding ?? 0.0,
      ),
      child: pw.Text(
        data,
        style: pw.TextStyle(
          font: font ??
              serviceLocator<FontService>().getFont('timesNewRomanBold'),
          fontStyle: fontStyle,
          fontSize: fontSize ?? 10.0,
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

  static pw.Widget buildRowTextValue({
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
            font: font ??
                serviceLocator<FontService>().getFont('timesNewRomanBold'),
            fontSize: fontSize ?? 10.0,
          ),
        ),
        pw.SizedBox(
          width: 10.0,
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            font: font ??
                serviceLocator<FontService>().getFont('timesNewRomanBold'),
            fontSize: fontSize ?? 10.0,
            decoration: isUnderlined ? pw.TextDecoration.underline : null,
          ),
        ),
      ],
    );
  }

  static pw.Widget buildTableRowColumn({
    required String data,
    double? fontSize,
    double? rowHeight,
    double solidBorderWidth = 3.0,
    double slashedBorderWidth = 1,
    bool isAlignCenter = true,
    bool isTopBorderSlashed = false,
    bool isBottomBorderSlashed = false,
    bool borderTop = false,
    bool borderRight = true,
    bool borderBottom = true,
    bool borderLeft = true,
    bool isCompressed = false,
  }) {
    return pw.Container(
      height: rowHeight,
      padding: const pw.EdgeInsets.all(2),
      child: pw.Text(
        data,
        style: pw.TextStyle(
          font: serviceLocator<FontService>().getFont('tahomaRegular'),
          fontSize: fontSize ?? 8.5,
        ),
        textAlign: isAlignCenter ? pw.TextAlign.center : null,
        maxLines: isCompressed ? 1 : null,
        overflow: isCompressed ? pw.TextOverflow.clip : null,
        softWrap: isCompressed ? false : null,
      ),
      decoration: pw.BoxDecoration(
        border: pw.Border(
          top: borderTop
              ? pw.BorderSide(
                  style: isTopBorderSlashed
                      ? pw.BorderStyle.dashed
                      : pw.BorderStyle.solid,
                  width: isTopBorderSlashed
                      ? slashedBorderWidth
                      : solidBorderWidth,
                )
              : pw.BorderSide.none,
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

  static pw.TableRow buildIcsTableRow({
    String? quantity,
    String? unit,
    String? unitCost,
    String? totalCost,
    String? description,
    String? itemId,
    int? estimatedUsefulLife,
    double? rowHeight,
    borderTop = false,
    borderBottom = true,
    isTopBorderSlashed = false,
  }) {
    return pw.TableRow(
      children: [
        buildTableRowColumn(
          data: quantity.toString(),
          borderRight: false,
          rowHeight: rowHeight,
          borderTop: borderTop,
          borderBottom: borderBottom,
          isTopBorderSlashed: isTopBorderSlashed,
          isBottomBorderSlashed: true,
        ),
        buildTableRowColumn(
          data: readableEnumConverter(unit),
          borderTop: borderTop,
          borderRight: false,
          rowHeight: rowHeight,
          borderBottom: borderBottom,
          isTopBorderSlashed: isTopBorderSlashed,
          isBottomBorderSlashed: true,
        ),
        pw.Row(
          children: [
            pw.SizedBox(
              width: 45.0,
              child: buildTableRowColumn(
                data: unitCost.toString(),
                borderTop: borderTop,
                borderRight: false,
                rowHeight: rowHeight,
                borderBottom: borderBottom,
                isTopBorderSlashed: isTopBorderSlashed,
                isBottomBorderSlashed: true,
              ),
            ),
            pw.Expanded(
              child: buildTableRowColumn(
                data: totalCost.toString(),
                solidBorderWidth: 1.5,
                borderTop: borderTop,
                borderRight: false,
                rowHeight: rowHeight,
                borderBottom: borderBottom,
                isTopBorderSlashed: isTopBorderSlashed,
                isBottomBorderSlashed: true,
              ),
            ),
          ],
        ),
        buildTableRowColumn(
          data: description ?? '\n',
          borderTop: borderTop,
          borderRight: false,
          rowHeight: rowHeight,
          borderBottom: borderBottom,
          isTopBorderSlashed: isTopBorderSlashed,
          isBottomBorderSlashed: true,
        ),
        buildTableRowColumn(
          data: itemId ?? '\n',
          fontSize: 7.0,
          borderTop: borderTop,
          borderRight: false,
          rowHeight: rowHeight,
          borderBottom: borderBottom,
          isTopBorderSlashed: isTopBorderSlashed,
          isBottomBorderSlashed: true,
        ),
        buildTableRowColumn(
          data: estimatedUsefulLife != null
              ? estimatedUsefulLife > 1
                  ? '$estimatedUsefulLife years'
                  : '$estimatedUsefulLife year'
              : '\n',
          rowHeight: rowHeight,
          borderTop: borderTop,
          borderBottom: borderBottom,
          isTopBorderSlashed: isTopBorderSlashed,
          isBottomBorderSlashed: true,
        ),
      ],
    );
  }

  static pw.TableRow buildParTableRow({
    String? quantity,
    String? unit,
    String? description,
    String? propertyNumber,
    String? dateAcquired,
    String? amount,
    double? rowHeight,
    borderTop = false,
    borderBottom = true,
  }) {
    return pw.TableRow(
      children: [
        buildTableRowColumn(
          data: quantity.toString(),
          borderRight: false,
          rowHeight: rowHeight,
          borderTop: borderTop,
          borderBottom: borderBottom,
        ),
        buildTableRowColumn(
          data: readableEnumConverter(unit),
          borderRight: false,
          rowHeight: rowHeight,
          borderTop: borderTop,
          borderBottom: borderBottom,
        ),
        buildTableRowColumn(
          data: description ?? '\n',
          borderRight: false,
          rowHeight: rowHeight,
          borderTop: borderTop,
          borderBottom: borderBottom,
        ),
        buildTableRowColumn(
          data: propertyNumber ?? '\n',
          fontSize: 7.0,
          borderRight: false,
          rowHeight: rowHeight,
          borderTop: borderTop,
          borderBottom: borderBottom,
        ),
        buildTableRowColumn(
          data: dateAcquired ?? '\n',
          solidBorderWidth: 2.0,
          borderRight: false,
          rowHeight: rowHeight,
          borderTop: borderTop,
          borderBottom: borderBottom,
        ),
        buildTableRowColumn(
          data: amount.toString(),
          rowHeight: rowHeight,
          borderTop: borderTop,
          borderBottom: borderBottom,
        ),
      ],
    );
  }

  static pw.Widget buildReusableIssuanceFooterContainer({
    String? title,
    String? officerName,
    String? officerPosition,
    String? officerOffice,
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
            title ?? '\n',
            style: pw.TextStyle(
              font: serviceLocator<FontService>().getFont(
                isPAR ? 'timesNewRomanBold' : 'timesNewRomanRegular',
              ),
              fontSize: 7.0,
            ),
          ),
          pw.SizedBox(
            height: 10.0,
          ),
          pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Text(
                officerName?.toUpperCase() ?? '\n',
                style: pw.TextStyle(
                  font: serviceLocator<FontService>()
                      .getFont('timesNewRomanBold'),
                  fontSize: 7.0,
                  decoration: isPAR ? pw.TextDecoration.underline : null,
                ),
                overflow: pw.TextOverflow.clip,
                maxLines: 1,
                softWrap: false,
              ),
              pw.Text(
                'Signature Over Printed Name',
                style: pw.TextStyle(
                  font: serviceLocator<FontService>()
                      .getFont('timesNewRomanRegular'),
                  fontSize: 6.0,
                ),
              ),
              pw.Text(
                officerPosition != null && officerOffice != null
                    ? '${officerPosition.toUpperCase()} - ${officerOffice.toUpperCase()}'
                    : '\n',
                style: pw.TextStyle(
                  font: serviceLocator<FontService>()
                      .getFont('timesNewRomanRegular'),
                  fontSize: 6.5,
                ),
                overflow: pw.TextOverflow.clip,
                maxLines: 1,
                softWrap: false,
              ),
              pw.Text(
                'Position/Office',
                style: pw.TextStyle(
                  font: serviceLocator<FontService>()
                      .getFont('timesNewRomanRegular'),
                  fontSize: 6.0,
                ),
              ),
              pw.Text(
                isPAR
                    ? '_______________________'
                    : date != null
                        ? documentDateFormatter(date)
                        : '\n',
                style: pw.TextStyle(
                  font: serviceLocator<FontService>()
                      .getFont('timesNewRomanRegular'),
                  fontSize: 7.0,
                ),
              ),
              pw.Text(
                'Date',
                style: pw.TextStyle(
                  font: serviceLocator<FontService>()
                      .getFont('timesNewRomanRegular'),
                  fontSize: 6.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.TableRow buildRISTableRow({
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
        buildTableRowColumn(
          data: stockNo ?? '\n',
          borderRight: false,
          rowHeight: rowHeight,
          borderBottom: borderBottom,
        ),
        buildTableRowColumn(
          data: readableEnumConverter(unit),
          borderRight: false,
          rowHeight: rowHeight,
          borderBottom: borderBottom,
        ),
        buildTableRowColumn(
          data: description ?? '\n',
          borderRight: false,
          rowHeight: rowHeight,
          borderBottom: borderBottom,
        ),
        buildTableRowColumn(
          data: requestQuantity ?? '\n',
          borderRight: false,
          rowHeight: rowHeight,
          borderBottom: borderBottom,
        ),
        buildTableRowColumn(
          data: yes ?? '\n',
          solidBorderWidth: 2.0,
          borderRight: false,
          rowHeight: rowHeight,
          borderBottom: borderBottom,
        ),
        buildTableRowColumn(
          data: no ?? '\n',
          borderRight: false,
          rowHeight: rowHeight,
          borderBottom: borderBottom,
        ),
        buildTableRowColumn(
          data: issueQuantity ?? '\n',
          solidBorderWidth: 2.0,
          borderRight: false,
          rowHeight: rowHeight,
          borderBottom: borderBottom,
        ),
        buildTableRowColumn(
          data: remarks ?? '\n',
          rowHeight: rowHeight,
          borderBottom: borderBottom,
        ),
      ],
    );
  }

  pw.Widget buildRISHeaderContainer({
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
          buildRowTextValue(
            text: row1Title,
            value: row1Value ?? (isRow1Underlined ? '________' : ''),
            font: serviceLocator<FontService>().getFont('calibriRegular'),
          ),
          buildRowTextValue(
            text: row2Title,
            value: row2Value ?? (isRow2Underlined ? '________' : ''),
            font: serviceLocator<FontService>().getFont('calibriRegular'),
          ),
        ],
      ),
    );
  }

  static pw.TableRow buildRISFooterTableHeader() {
    return pw.TableRow(
      children: [
        buildHeaderContainerCell(
          data: '\nSignature:',
          horizontalPadding: 3.0,
          verticalPadding: 3.0,
          font: serviceLocator<FontService>().getFont('calibriRegular'),
          isAlignCenter: false,
          borderTop: false,
          borderRight: false,
        ),
        buildHeaderContainerCell(
          data: 'Requested by: \n\n',
          horizontalPadding: 3.0,
          verticalPadding: 3.0,
          font: serviceLocator<FontService>().getFont('calibriBold'),
          isAlignCenter: false,
          borderTop: false,
          borderRight: false,
        ),
        buildHeaderContainerCell(
          data: 'Approved by: \n\n',
          horizontalPadding: 3.0,
          verticalPadding: 3.0,
          font: serviceLocator<FontService>().getFont('calibriBold'),
          isAlignCenter: false,
          borderTop: false,
          borderRight: false,
        ),
        buildHeaderContainerCell(
          data: 'Issued by: \n\n',
          horizontalPadding: 3.0,
          verticalPadding: 3.0,
          font: serviceLocator<FontService>().getFont('calibriBold'),
          isAlignCenter: false,
          borderTop: false,
          borderRight: false,
        ),
        buildHeaderContainerCell(
          data: 'Received by: \n\n',
          horizontalPadding: 3.0,
          verticalPadding: 3.0,
          font: serviceLocator<FontService>().getFont('calibriBold'),
          isAlignCenter: false,
          borderTop: false,
        ),
      ],
    );
  }

  static pw.TableRow buildRISFooterTableRow({
    required String title,
    String? dataRowColumnOne,
    String? dataRowColumnTwo,
    String? dataRowColumnThree,
    String? dataRowColumnFour,
  }) {
    return pw.TableRow(
      children: [
        buildTableRowColumn(
          data: title,
          isAlignCenter: false,
          borderRight: false,
          fontSize: 7.0,
          isCompressed: true,
        ),
        buildTableRowColumn(
          data: dataRowColumnOne?.toUpperCase() ?? '\n',
          borderRight: false,
          fontSize: 7.0,
          isCompressed: true,
        ),
        buildTableRowColumn(
          data: dataRowColumnTwo?.toUpperCase() ?? '\n',
          borderRight: false,
          fontSize: 7.0,
          isCompressed: true,
        ),
        buildTableRowColumn(
          data: dataRowColumnThree?.toUpperCase() ?? '\n',
          borderRight: false,
          fontSize: 7.0,
          isCompressed: true,
        ),
        buildTableRowColumn(
          data: dataRowColumnFour?.toUpperCase() ?? '\n',
          fontSize: 7.0,
          isCompressed: true,
        ),
      ],
    );
  }

  static pw.Container buildContainer({
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

  static pw.TableRow buildStickerTableRow({
    required String title,
    String? value,
    double? height,
    bool borderTop = true,
    bool borderBottom = true,
  }) {
    return pw.TableRow(
      children: [
        buildContainer(
          height: height,
          horizontalPadding: 3.0,
          verticalPadding: 3.0,
          borderTop: borderTop,
          borderRight: false,
          borderBottom: borderBottom,
          borderLeft: false,
          borderWidthBottom: 1.5,
          child: pw.Text(
            title,
            style: pw.TextStyle(
              font: serviceLocator<FontService>().getFont('calibriBold'),
              fontSize: 8.0,
            ),
          ),
        ),
        buildContainer(
          height: height,
          horizontalPadding: 3.0,
          verticalPadding: 3.0,
          borderTop: borderTop,
          borderRight: false,
          borderBottom: borderBottom,
          borderWidthBottom: 1.5,
          borderWidthLeft: 1.5,
          child: pw.Text(
            value ?? '',
            style: pw.TextStyle(
              font: serviceLocator<FontService>().getFont('calibriRegular'),
              fontSize: 8.0,
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget buildStickerHeader() {
    return pw.Column(
      children: [
        pw.Container(
          height: 40.0,
          width: 40.0,
          child: serviceLocator<ImageService>().getImage('depedSeal'),
        ),
        pw.SizedBox(
          height: 3.0,
        ),
        pw.Text(
          'DEPARTMENT OF EDUCATION',
          style: pw.TextStyle(
            font: serviceLocator<FontService>().getFont('calibriBold'),
            fontSize: 9.0,
            // fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(
          height: 3.0,
        ),
        pw.Text(
          'Schools Division of Legazpi City',
          style: pw.TextStyle(
            font: serviceLocator<FontService>().getFont('calibriBold'),
            fontSize: 9.0,
            //fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(
          height: 3.0,
        ),
        pw.Text(
          'Legazpi City',
          style: pw.TextStyle(
            font: serviceLocator<FontService>().getFont('calibriBold'),
            fontSize: 9.0,
            //fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    );
  }

  static pw.RichText richText({
    required String title,
    required String value,
  }) {
    return pw.RichText(
      text: pw.TextSpan(
        text: title,
        style: pw.TextStyle(
          font: serviceLocator<FontService>().getFont('calibriBold'),
          fontSize: 11.0,
        ),
        children: [
          pw.TextSpan(
            text: value,
            style: pw.TextStyle(
              font: serviceLocator<FontService>().getFont('calibriRegular'),
              fontSize: 11.0,
            ),
          ),
        ],
      ),
    );
  }
}
