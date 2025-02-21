import '../../../item_inventory/data/models/base_item.dart';
import '../../../item_inventory/data/models/equipment.dart';
import '../../../item_inventory/data/models/supply.dart';
import '../../../item_inventory/domain/entities/supply.dart';
import '../../domain/entities/issuance_item.dart';

class IssuanceItemModel extends IssuanceItemEntity {
  const IssuanceItemModel({
    required super.issuanceId,
    required super.itemEntity,
    required super.quantity,
  });

  factory IssuanceItemModel.fromJson(Map<String, dynamic> json) {
    print('received json: $json');
    final item = BaseItemModel.fromJson(json['item']);

    return IssuanceItemModel(
      issuanceId: json['issuance_id'] as String,
      itemEntity: item,
      quantity: json['issued_quantity'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'issuance_id': issuanceId,
      'item': itemEntity is SupplyEntity
          ? (itemEntity as SupplyModel).toJson()
          : (itemEntity as EquipmentModel).toJson(),
      'issued_quantity': quantity,
    };
  }
}
