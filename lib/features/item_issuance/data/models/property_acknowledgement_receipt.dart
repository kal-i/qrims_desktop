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
    required super.items,
    required super.purchaseRequestEntity,
    required super.issuedDate,
    super.returnDate,
    required super.receivingOfficerEntity,
    required super.sendingOfficerEntity,
    required super.qrCodeImageData,
    super.isReceived,
    super.isArchived,
  });

  factory PropertyAcknowledgementReceiptModel.fromJson(
      Map<String, dynamic> json) {
    print('par model: $json');
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

    final sendingOfficer = OfficerModel.fromJson(json['sending_officer']);
    print('converted sen off -----');

    final par = PropertyAcknowledgementReceiptModel(
      id: json['id'] as String,
      parId: json['par_id'] as String,
      items: items,
      purchaseRequestEntity: purchaseRequest,
      issuedDate: json['issued_date'] is String
          ? DateTime.parse(json['issued_date'] as String)
          : json['issued_date'] as DateTime,
      returnDate: json['return_date'] != null && json['return_date'] is String
          ? DateTime.parse(json['return_date'] as String)
          : json['return_date'] as DateTime?,
      receivingOfficerEntity: receivingOfficer,
      sendingOfficerEntity: sendingOfficer,
      qrCodeImageData: json['qr_code_image_data'] as String,
      isReceived: json['is_received'] as bool,
      isArchived: json['is_archived'] as bool,
    );
    print(par);
    print('converted par -----');

    return par;
  }

  factory PropertyAcknowledgementReceiptModel.fromEntity(
      PropertyAcknowledgementReceiptEntity propertyAcknowledgementReceipt) {
    return PropertyAcknowledgementReceiptModel(
      id: propertyAcknowledgementReceipt.id,
      parId: propertyAcknowledgementReceipt.parId,
      items: propertyAcknowledgementReceipt.items,
      purchaseRequestEntity:
          propertyAcknowledgementReceipt.purchaseRequestEntity,
      issuedDate: propertyAcknowledgementReceipt.issuedDate,
      receivingOfficerEntity:
          propertyAcknowledgementReceipt.receivingOfficerEntity,
      sendingOfficerEntity: propertyAcknowledgementReceipt.sendingOfficerEntity,
      qrCodeImageData: propertyAcknowledgementReceipt.qrCodeImageData,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'par_id': parId,
      'items':
          items.map((item) => (item as IssuanceItemModel).toJson()).toList(),
      'issued_date': issuedDate.toIso8601String(),
      'return_date': returnDate?.toIso8601String(),
      'purchase_request':
          (purchaseRequestEntity as PurchaseRequestModel).toJson(),
      'receiving_officer': (receivingOfficerEntity as OfficerModel).toJson(),
      'sending_officer': (sendingOfficerEntity as OfficerModel).toJson(),
      'qr_code_image_data': qrCodeImageData,
      'is_received': isReceived,
      'is_archived': isArchived,
    };
  }
}
