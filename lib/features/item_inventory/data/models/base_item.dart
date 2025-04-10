import '../../domain/entities/base_item.dart';
import 'inventory_item.dart';
import 'supply.dart';

abstract class BaseItemModel extends BaseItemEntity {
  const BaseItemModel({
    required super.productStockEntity,
    required super.shareableItemInformationEntity,
  });

  factory BaseItemModel.fromJson(Map<String, dynamic> json) {
    print('json received by base item mod: $json');
    if (json['supply_id'] != null) {
      print('supp received');
      return SupplyModel.fromJson(json);
    } else {
      print('inventory');
      return InventoryItemModel.fromJson(json);
    }
  }

  Map<String, dynamic> toJson();
}
