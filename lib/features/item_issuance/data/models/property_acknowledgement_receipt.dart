import '../../../../core/enums/fund_cluster.dart';
import '../../../../core/enums/issuance_status.dart';
import '../../../officer/data/models/officer.dart';
import '../../../purchase_request/data/models/purchase_request.dart';
import '../../domain/entities/property_acknowledgement_receipt.dart';
import 'issuance.dart';
import 'issuance_item.dart';

class PropertyAcknowledgementReceiptModel
    extends PropertyAcknowledgementReceiptEntity implements IssuanceModel {
  const PropertyAcknowledgementReceiptModel({
    required super.id,
    required super.parId,
    required super.issuedDate,
    super.returnDate,
    required super.items,
    super.purchaseRequestEntity,
    super.entity,
    super.fundCluster,
    super.receivingOfficerEntity,
    super.issuingOfficerEntity,
    required super.qrCodeImageData,
    super.status,
    super.isArchived,
  });

  factory PropertyAcknowledgementReceiptModel.fromJson(
      Map<String, dynamic> json) {
    print('par model: $json');

    PurchaseRequestModel? purchaseRequest;
    EntityModel? entity;
    FundCluster? fundCluster;
    OfficerModel? receivingOfficer;
    OfficerModel? issuingOfficer;

    if (json['purchase_request'] != null) {
      purchaseRequest = PurchaseRequestModel.fromJson(json['purchase_request']);
    }

    if (json['entity'] != null) {
      entity = EntityModel.fromJson(json['entity']);
    }

    if (json['fund_cluster'] != null) {
      fundCluster = FundCluster.values.firstWhere(
          (e) => e.toString().split('.').last == json['fund_cluster']);
    }

    if (json['receiving_officer'] != null) {
      receivingOfficer = OfficerModel.fromJson(json['receiving_officer']);
    }

    if (json['issuing_officer'] != null) {
      issuingOfficer = OfficerModel.fromJson(json['issuing_officer']);
    }

    final items = (json['items'] as List<dynamic>).map((item) {
      final issuanceItem = IssuanceItemModel.fromJson(item);
      return issuanceItem;
    }).toList();

    final par = PropertyAcknowledgementReceiptModel(
      id: json['id'] as String,
      parId: json['par_id'] as String,
      issuedDate: json['issued_date'] is String
          ? DateTime.parse(json['issued_date'] as String)
          : json['issued_date'] as DateTime,
      returnDate: json['return_date'] != null && json['return_date'] is String
          ? DateTime.parse(json['return_date'] as String)
          : json['return_date'] as DateTime?,
      items: items,
      purchaseRequestEntity: purchaseRequest,
      entity: entity,
      fundCluster: fundCluster,
      receivingOfficerEntity: receivingOfficer,
      issuingOfficerEntity: issuingOfficer,
      qrCodeImageData: json['qr_code_image_data'] as String,
      status: IssuanceStatus.values
          .firstWhere((e) => e.toString().split('.').last == json['status']),
      isArchived: json['is_archived'] as bool,
    );
    print('converted par -----');

    return par;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'par_id': parId,
      'issued_date': issuedDate.toIso8601String(),
      'return_date': returnDate?.toIso8601String(),
      'items':
          items.map((item) => (item as IssuanceItemModel).toJson()).toList(),
      'purchase_request':
          (purchaseRequestEntity as PurchaseRequestModel).toJson(),
      'entity': (entity as EntityModel).toJson(),
      'fund_cluster': fundCluster.toString().split('.').last,
      'receiving_officer': (receivingOfficerEntity as OfficerModel).toJson(),
      'issuing_officer': (issuingOfficerEntity as OfficerModel).toJson(),
      'qr_code_image_data': qrCodeImageData,
      'status': status.toString().split('.').last,
      'is_archived': isArchived,
    };
  }
}
