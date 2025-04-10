import 'inventory_stock.dart';
import 'weekly_item_trend.dart';

class InventorySummaryEntity {
  const InventorySummaryEntity({
    required this.supplyWeeklyTrendEntities,
    required this.inventoryWeeklyTrendEntities,
    required this.inventoryStocks,
    required this.supplyPercentageChange,
    required this.inventoryPercentageChange,
    required this.suppliesCount,
    required this.inventoryCount,
  });

  final List<WeeklyItemTrendEntity> supplyWeeklyTrendEntities;
  final List<WeeklyItemTrendEntity> inventoryWeeklyTrendEntities;
  final List<InventoryStockEntity> inventoryStocks;
  final double supplyPercentageChange;
  final double inventoryPercentageChange;
  final int suppliesCount;
  final int inventoryCount;
}
