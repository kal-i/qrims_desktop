class InventoryStockEntity {
  const InventoryStockEntity({
    required this.itemType,
    required this.totalQuantity,
  });

  final String itemType;
  final int totalQuantity;
}
