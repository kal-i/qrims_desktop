import '../../domain/entities/base_item.dart';
import 'equipment.dart';
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
      print('equipment');
      return EquipmentModel.fromJson(json);
    }
  }

  Map<String, dynamic> toJson();
}
