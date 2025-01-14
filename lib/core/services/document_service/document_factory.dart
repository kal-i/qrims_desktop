import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../enums/document_type.dart';
import 'models/base_document.dart';
import 'models/inventory_custodian_slip.dart';
import 'models/property_acknowledgement_receipt.dart';
import 'models/purchase_order.dart';
import 'models/requisition_and_issuance_slip.dart';
import 'models/rpci.dart';
import 'models/sticker.dart';

class DocumentFactory {
  final Map<DocumentType, BaseDocument Function()> _documentMap;

  DocumentFactory()
      : _documentMap = {
          DocumentType.po: () => PurchaseOrder(),
          DocumentType.ics: () => InventoryCustodianSlip(),
          DocumentType.par: () => PropertyAcknowledgementReceipt(),
          DocumentType.ris: () => RequisitionAndIssuanceSlip(),
          DocumentType.sticker: () => Sticker(),
          DocumentType.rpci: () => RPCI(),
        };

  Future<pw.Document> createDocument({
    required PdfPageFormat pageFormat,
    required pw.PageOrientation orientation,
    required dynamic data,
    required DocumentType docType,
    bool withQR = true,
  }) async {
    final documentBuilder = _documentMap[docType];
    if (documentBuilder == null) {
      throw ArgumentError('Unsupported document type: $docType');
    }
    return documentBuilder().generate(
      pageFormat: pageFormat,
      orientation: orientation,
      data: data,
      withQr: withQR,
    );
  }
}
