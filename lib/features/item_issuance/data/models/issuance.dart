import '../../domain/entities/issuance.dart';
import 'inventory_custodian_slip.dart';
import 'property_acknowledgement_receipt.dart';

abstract class IssuanceModel extends IssuanceEntity {
  const IssuanceModel({
    required super.id,
    required super.items,
    required super.purchaseRequestEntity,
    required super.receivingOfficerEntity,
    required super.issuedDate,
    required super.returnDate,
    required super.qrCodeImageData,
    super.isReceived,
    super.isArchived,
  });

  factory IssuanceModel.fromJson(Map<String, dynamic> json) {
    print('issuance model: $json');
    if (json['ics_id'] != null) {
      print('issuance model to ics: $json');
      return InventoryCustodianSlipModel.fromJson(json);
    } else {
      print('issuance model to par: $json');
      return PropertyAcknowledgementReceiptModel.fromJson(json);
    }
  }

  Map<String, dynamic> toJson();
}
