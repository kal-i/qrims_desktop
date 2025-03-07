import '../../domain/entities/issuance.dart';
import 'inventory_custodian_slip.dart';
import 'property_acknowledgement_receipt.dart';
import 'requisition_and_issue_slip.dart';

abstract class IssuanceModel extends IssuanceEntity {
  const IssuanceModel({
    required super.id,
    required super.issuedDate,
    super.returnDate,
    required super.items,
    //super.batchItems,
    super.purchaseRequestEntity,
    super.entity,
    super.fundCluster,
    super.receivingOfficerEntity,
    super.issuingOfficerEntity,
    required super.qrCodeImageData,
    super.status,
    super.isArchived,
  });

  factory IssuanceModel.fromJson(Map<String, dynamic> json) {
    print('issuance model: $json');
    if (json['ics_id'] != null) {
      print('issuance model to ics: $json');
      return InventoryCustodianSlipModel.fromJson(json);
    }

    if (json['par_id'] != null) {
      print('issuance model to par: $json');
      return PropertyAcknowledgementReceiptModel.fromJson(json);
    }

    if (json['ris_id'] != null) {
      print('issuance model to ris: $json');
      return RequisitionAndIssuanceSlipModel.fromJson(json);
    }

    throw Exception('Unknown issuance type: $json');
  }

  Map<String, dynamic> toJson();
}
