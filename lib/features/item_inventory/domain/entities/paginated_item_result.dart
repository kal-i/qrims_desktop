import 'item_with_stock.dart';

class PaginatedItemResultEntity {
  const PaginatedItemResultEntity({
    required this.items,
    required this.totalItemCount,
  });

  final List<ItemWithStockEntity> items;
  final int totalItemCount;
}
