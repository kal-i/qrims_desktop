import '../../../item_inventory/domain/entities/item_with_stock.dart';

class IssuanceItem {
  const IssuanceItem({
    required this.issuanceId,
    required this.item,
    required this.quantity,
  });

  final String issuanceId;
  final ItemWithStockEntity item;
  final int quantity;
}
