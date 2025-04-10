import 'base_item.dart';

class PaginatedItemResultEntity {
  const PaginatedItemResultEntity({
    required this.items,
    required this.totalItemCount,
    required this.suppliesCount,
    required this.inventoryCount,
    required this.outOfStockCount,
  });

  final List<BaseItemEntity> items;
  final int totalItemCount;
  final int suppliesCount;
  final int inventoryCount;
  final int outOfStockCount;
}
