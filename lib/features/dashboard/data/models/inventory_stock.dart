import '../../domain/entities/inventory_stock.dart';

class InventoryStockModel extends InventoryStockEntity {
  const InventoryStockModel({
    required super.itemType,
    required super.totalQuantity,
  });

  factory InventoryStockModel.fromJson(Map<String, dynamic> json) {
    print('received by inventory stock model: $json');
    return InventoryStockModel(
      itemType: json['item_type'] as String,
      totalQuantity: json['total_stock'] as int,
    );
  }
}
