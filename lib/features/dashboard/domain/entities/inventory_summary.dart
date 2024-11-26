import 'categorical_inventory_data.dart';

class InventorySummaryEntity {
  const InventorySummaryEntity({
    required this.inStocksCount,
    required this.lowStocksCount,
    required this.outOfStocksCount,
    required this.categoricalInventoryData,
  });

  final int inStocksCount;
  final int lowStocksCount;
  final int outOfStocksCount;
  final List<CategoricalInventoryDataEntity> categoricalInventoryData;
}
