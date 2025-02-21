import '../../../item_inventory/data/models/item_with_stock.dart';
import '../../../officer/data/models/officer.dart';
import '../../../purchase_request/data/models/purchase_request.dart';
import '../../domain/entities/inventory_custodian_slip.dart';
import 'issuance.dart';
import 'issuance_item.dart';

class InventoryCustodianSlipModel extends InventoryCustodianSlipEntity
    implements IssuanceModel {
  const InventoryCustodianSlipModel({
    required super.id,
    required super.icsId,
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

  factory InventoryCustodianSlipModel.fromJson(Map<String, dynamic> json) {
    print('ics model: $json');
    final purchaseRequest =
        PurchaseRequestModel.fromJson(json['purchase_request']);
    print('converted pr -----');

    final items = (json['items'] as List<dynamic>).map((item) {
      final issuanceItem = IssuanceItemModel.fromJson(item);
      return issuanceItem;
    }).toList();
    print('converted items -----');

    final receivingOfficer = OfficerModel.fromJson(json['receiving_officer']);
    print('converted rec off -----');

    final sendingOfficer = OfficerModel.fromJson(json['sending_officer']);
    print('converted sen off -----');

    final ics = InventoryCustodianSlipModel(
      id: json['id'] as String,
      icsId: json['ics_id'] as String,
      items: items,
      purchaseRequestEntity: purchaseRequest,
      issuedDate: json['issued_date'] is String
          ? DateTime.parse(json['issued_date'] as String)
          : json['issued_date'] as DateTime,
      returnDate: json['return_date'] != null
          ? json['return_date'] is String
              ? DateTime.parse(json['return_date'] as String)
              : json['return_date'] as DateTime
          : null,
      receivingOfficerEntity: receivingOfficer,
      sendingOfficerEntity: sendingOfficer,
      qrCodeImageData: json['qr_code_image_data'] as String,
      isReceived: json['is_received'] as bool,
      isArchived: json['is_archived'] as bool,
    );
    print('converted ics ----');

    return ics;
  }

  factory InventoryCustodianSlipModel.fromEntity(
      InventoryCustodianSlipEntity inventoryCustodianSlipEntity) {
    return InventoryCustodianSlipModel(
      id: inventoryCustodianSlipEntity.id,
      icsId: inventoryCustodianSlipEntity.icsId,
      items: inventoryCustodianSlipEntity.items,
      purchaseRequestEntity: inventoryCustodianSlipEntity.purchaseRequestEntity,
      issuedDate: inventoryCustodianSlipEntity.issuedDate,
      receivingOfficerEntity:
          inventoryCustodianSlipEntity.receivingOfficerEntity,
      sendingOfficerEntity: inventoryCustodianSlipEntity.sendingOfficerEntity,
      qrCodeImageData: inventoryCustodianSlipEntity.qrCodeImageData,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ics_id': icsId,
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
