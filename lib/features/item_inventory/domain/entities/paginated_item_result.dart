import 'base_item.dart';

class PaginatedItemResultEntity {
  const PaginatedItemResultEntity({
    required this.items,
    required this.totalItemCount,
    required this.suppliesCount,
    required this.equipmentCount,
    required this.outOfStockCount,
  });

  final List<BaseItemEntity> items;
  final int totalItemCount;
  final int suppliesCount;
  final int equipmentCount;
  final int outOfStockCount;
}
