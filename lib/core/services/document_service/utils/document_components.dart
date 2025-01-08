import 'package:pdf/widgets.dart' as pw;

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
          child: ImageService().getImage('depedSeal'),
        ),
        pw.SizedBox(height: 5.0),
        pw.Text(
          'Republic of the Philippines',
          style: pw.TextStyle(
            font: FontService().getFont('oldEnglish'),
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 5.0),
        pw.Text('Department of Education',
            style: pw.TextStyle(
              font: FontService().getFont('oldEnglish'),
              fontSize: 18,
            )),
        pw.SizedBox(height: 5.0),
        pw.Text('Region V - Bicol',
            style: pw.TextStyle(
              fontBold: FontService().getFont('popvlvs'),
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
            )),
        pw.SizedBox(height: 5.0),
        pw.Text('SCHOOLS DIVISION OF LEGAZPI CITY',
            style: pw.TextStyle(
              fontBold: FontService().getFont('tahomaBold'),
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
              FontService().getFont(
                isBold ? 'timesNewRomanBold' : 'timesNewRomanRegular',
              ),
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
            font: font ?? FontService().getFont('timesNewRomanBold'),
            fontSize: fontSize ?? 10.0,
          ),
        ),
        pw.SizedBox(
          width: 10.0,
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            font: font ?? FontService().getFont('timesNewRomanBold'),
            fontSize: fontSize ?? 10.0,
            decoration: isUnderlined ? pw.TextDecoration.underline : null,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildTableRowColumn({
    required String data,
    double? fontSize,
    double? rowHeight,
    double solidBorderWidth = 3.0,
    double slashedBorderWidth = 1.5,
    bool isAlignCenter = true,
    bool isBottomBorderSlashed = false,
    bool borderTop = false,
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
          font: FontService().getFont('tahomaRegular'),
          fontSize: fontSize ?? 8.5,
        ),
        textAlign: isAlignCenter ? pw.TextAlign.center : null,
      ),
      decoration: pw.BoxDecoration(
        border: pw.Border(
          top: borderTop
              ? pw.BorderSide(
                  width: solidBorderWidth,
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

  static pw.TableRow buildParTableRow({
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

  static pw.Widget buildReusableIssuanceFooterContainer({
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
              font: FontService().getFont(
                isPAR ? 'timesNewRomanBold' : 'timesNewRomanRegular',
              ),
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
                  font: FontService().getFont('timesNewRomanBold'),
                  fontSize: 10.0,
                  decoration: isPAR ? pw.TextDecoration.underline : null,
                ),
              ),
              pw.Text(
                'Signature Over Printed Name',
                style: pw.TextStyle(
                  font: FontService().getFont('timesNewRomanRegular'),
                  fontSize: 10.0,
                ),
              ),
              pw.Text(
                '${formatPosition(officerPosition.toUpperCase())} - ${officerOffice.toUpperCase()}',
                style: pw.TextStyle(
                  font: FontService().getFont('timesNewRomanRegular'),
                  fontSize: 10.0,
                ),
              ),
              pw.Text(
                'Position/Office',
                style: pw.TextStyle(
                  font: FontService().getFont('timesNewRomanRegular'),
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
                  font: FontService().getFont('timesNewRomanRegular'),
                  fontSize: 10.0,
                ),
              ),
              pw.Text(
                'Date',
                style: pw.TextStyle(
                  font: FontService().getFont('timesNewRomanRegular'),
                  fontSize: 10.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
