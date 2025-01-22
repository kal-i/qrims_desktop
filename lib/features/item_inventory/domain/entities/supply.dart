import 'base_item.dart';

class SupplyEntity extends BaseItemEntity {
  const SupplyEntity({
    required this.id,
    required super.productStockEntity,
    required super.shareableItemInformationEntity,
  });

  final int id;
}
