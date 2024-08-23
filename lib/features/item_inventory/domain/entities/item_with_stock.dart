import 'item.dart';
import 'stock.dart';

class ItemWithStockEntity {
  const ItemWithStockEntity({
    required this.itemEntity,
    this.stockEntity,
  });

  final ItemEntity itemEntity;
  final StockEntity? stockEntity;
}
