import 'item_with_stock.dart';

class PaginatedItemResultEntity {
  const PaginatedItemResultEntity({
    required this.items,
    required this.totalItemCount,
    required this.inStockCount,
    required this.lowStockCount,
    required this.outOfStockCount,
  });

  final List<ItemWithStockEntity> items;
  final int totalItemCount;
  final int inStockCount;
  final int lowStockCount;
  final int outOfStockCount;
}
