import '../../../officer/data/models/officer.dart';
import '../../../purchase_request/data/models/purchase_request.dart';
import '../../domain/entities/requisition_and_issue_slip.dart';
import 'issuance.dart';
import 'issuance_item.dart';

class RequisitionAndIssuanceSlipModel extends RequisitionAndIssueSlipEntity
    implements IssuanceModel {
  const RequisitionAndIssuanceSlipModel({
    required super.id,
    required super.risId,
    super.purpose,
    super.responsibilityCenterCode,
    required super.items,
    required super.purchaseRequestEntity,
    required super.receivingOfficerEntity,
    required super.approvingOfficerEntity,
    required super.issuingOfficerEntity,
    required super.issuedDate,
    super.returnDate,
    required super.qrCodeImageData,
    super.isReceived,
    super.isArchived,
  });

  factory RequisitionAndIssuanceSlipModel.fromJson(Map<String, dynamic> json) {
    print('ris model: $json');
    final purchaseRequest =
        PurchaseRequestModel.fromJson(json['purchase_request']);
    print('converted pr ----- $purchaseRequest');
    print('moving on items');

    final items = (json['items'] as List<dynamic>).map((item) {
      final issuanceItem = IssuanceItemModel.fromJson(item);
      return issuanceItem;
    }).toList();
    print('converted items -----');

    final receivingOfficer = OfficerModel.fromJson(json['receiving_officer']);
    print('converted rec off -----');

    final approvingOfficer = OfficerModel.fromJson(json['approving_officer']);
    print('converted app off -----');

    final issuingOfficer = OfficerModel.fromJson(json['issuing_officer']);
    print('converted iss off -----');

    final ris = RequisitionAndIssuanceSlipModel(
      id: json['id'] as String,
      risId: json['ris_id'] as String,
      items: items,
      purpose: json['purpose'] as String?,
      responsibilityCenterCode: json['responsibility_center_code'] as String?,
      purchaseRequestEntity: purchaseRequest,
      receivingOfficerEntity: receivingOfficer,
      approvingOfficerEntity: approvingOfficer,
      issuingOfficerEntity: issuingOfficer,
      issuedDate: json['issued_date'] is String
          ? DateTime.parse(json['issued_date'] as String)
          : json['issued_date'] as DateTime,
      returnDate: json['return_date'] != null && json['return_date'] is String
          ? DateTime.parse(json['return_date'] as String)
          : json['return_date'] as DateTime?,
      qrCodeImageData: json['qr_code_image_data'] as String,
      isReceived: json['is_received'] as bool,
      isArchived: json['is_archived'] as bool,
    );
    print(ris);
    print('converted ris -----');

    return ris;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ris_id': risId,
      'items':
          items.map((item) => (item as IssuanceItemModel).toJson()).toList(),
      'purchase_request':
          (purchaseRequestEntity as PurchaseRequestModel).toJson(),
      'purpose': purpose,
      'responsibility_center_code': responsibilityCenterCode,
      'receiving_officer': (receivingOfficerEntity as OfficerModel).toJson(),
      'approving_officer': (approvingOfficerEntity as OfficerModel).toJson(),
      'issuing_officer': (issuingOfficerEntity as OfficerModel).toJson(),
      'issued_date': issuedDate.toIso8601String(),
      'return_date': returnDate?.toIso8601String(),
      'qr_code_image_data': qrCodeImageData,
      'is_received': isReceived,
      'is_archived': isArchived,
    };
  }
}
