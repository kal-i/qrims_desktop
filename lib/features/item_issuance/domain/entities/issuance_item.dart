import '../../../item_inventory/domain/entities/item_with_stock.dart';

class IssuanceItemEntity {
  const IssuanceItemEntity({
    required this.issuanceId,
    required this.itemEntity,
    required this.quantity,
  });

  final String issuanceId;
  final ItemWithStockEntity itemEntity;
  final int quantity;
}
