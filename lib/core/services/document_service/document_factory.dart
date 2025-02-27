import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../enums/document_type.dart';

import 'models/a73.dart';
import 'models/annex_a8.dart';
import 'models/base_document.dart';
import 'models/inventory_custodian_slip.dart';
import 'models/property_acknowledgement_receipt.dart';
import 'models/property_card.dart';
import 'models/purchase_order.dart';
import 'models/purchase_request.dart';
import 'models/requisition_and_issue_slip.dart';
import 'models/rpci.dart';
import 'models/rspi.dart';
import 'models/spc.dart';
import 'models/sticker.dart';
import 'models/rsmi.dart';
import 'models/stock_card.dart';

class DocumentFactory {
  final Map<DocumentType, BaseDocument Function()> _documentMap;

  DocumentFactory()
      : _documentMap = {
          DocumentType.pr: () => PurchaseRequest(),
          DocumentType.po: () => PurchaseOrder(),
          DocumentType.ics: () => InventoryCustodianSlip(),
          DocumentType.par: () => PropertyAcknowledgementReceipt(),
          DocumentType.ris: () => RequisitionAndIssueSlip(),
          DocumentType.sticker: () => Sticker(),
          DocumentType.rpci: () => RPCI(),
          DocumentType.annexA8: () => AnnexA8(),
          DocumentType.a73: () => A73(),
          DocumentType.propertyCard: () => PropertyCard(),
          DocumentType.spc: () => SPC(),
          DocumentType.rspi: () => RSPI(),
          DocumentType.rsmi: () => RSMI(),
          DocumentType.stockCard: () => StockCard(),
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
      //orientation: orientation,
      data: data,
      withQr: withQR,
    );
  }
}
