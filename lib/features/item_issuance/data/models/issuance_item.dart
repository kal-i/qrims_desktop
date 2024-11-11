import '../../../item_inventory/data/models/item_with_stock.dart';
import '../../domain/entities/issuance_item.dart';

class IssuanceItemModel extends IssuanceItemEntity {
  const IssuanceItemModel({
    required super.issuanceId,
    required super.itemEntity,
    required super.quantity,
  });

  factory IssuanceItemModel.fromJson(Map<String, dynamic> json) {
    final item = ItemWithStockModel.fromJson(json['item']);

    return IssuanceItemModel(
      issuanceId: json['issuance_id'] as String,
      itemEntity: item,
      quantity: json['quantity'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'issuance_id': issuanceId,
      'item': (itemEntity as ItemWithStockModel).toJson(),
      'quantity': quantity,
    };
  }
}
