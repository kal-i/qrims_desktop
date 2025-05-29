import '../../../../core/enums/issuance_item_status.dart';
import '../../../item_inventory/data/models/base_item.dart';
import '../../../item_inventory/data/models/inventory_item.dart';
import '../../../item_inventory/data/models/supply.dart';
import '../../../item_inventory/domain/entities/supply.dart';
import '../../domain/entities/issuance_item.dart';

class IssuanceItemModel extends IssuanceItemEntity {
  const IssuanceItemModel({
    required super.issuanceId,
    required super.itemEntity,
    required super.quantity,
    super.status,
    required super.issuedDate,
    super.receivedDate,
    super.returnedDate,
    super.lostDate,
    super.disposedDate,
    super.remarks,
  });

  factory IssuanceItemModel.fromJson(Map<String, dynamic> json) {
    print('received json: $json');
    final item = BaseItemModel.fromJson(json['item']);

    final status = IssuanceItemStatus.values.firstWhere(
      (e) => e.toString().split('.').last == json['status'],
    );

    return IssuanceItemModel(
      issuanceId: json['issuance_id'] as String,
      itemEntity: item,
      quantity: json['issued_quantity'] as int,
      status: status,
      issuedDate: json['issued_date'] is String
          ? DateTime.parse(json['issued_date'] as String)
          : json['issued_date'] as DateTime,
      receivedDate: json['received_date'] != null
          ? json['received_date'] is String
              ? DateTime.parse(json['received_date'] as String)
              : json['received_date'] as DateTime
          : null,
      returnedDate: json['returned_date'] != null
          ? json['returned_date'] is String
              ? DateTime.parse(json['returned_date'] as String)
              : json['returned_date'] as DateTime
          : null,
      lostDate: json['lost_date'] != null
          ? json['lost_date'] is String
              ? DateTime.parse(json['lost_date'] as String)
              : json['lost_date'] as DateTime
          : null,
      disposedDate: json['disposed_date'] != null
          ? json['disposed_date'] is String
              ? DateTime.parse(json['disposed_date'] as String)
              : json['disposed_date'] as DateTime
          : null,
      remarks: json['remarks'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'issuance_id': issuanceId,
      'item': itemEntity is SupplyEntity
          ? (itemEntity as SupplyModel).toJson()
          : (itemEntity as InventoryItemModel).toJson(),
      'issued_quantity': quantity,
      'status': status.toString().split('.').last,
      'issued_date': issuedDate.toIso8601String(),
      'received_date': receivedDate?.toIso8601String(),
      'returned_date': returnedDate?.toIso8601String(),
      'lost_date': lostDate?.toIso8601String(),
      'disposed_date': disposedDate?.toIso8601String(),
      'remarks': remarks,
    };
  }
}
