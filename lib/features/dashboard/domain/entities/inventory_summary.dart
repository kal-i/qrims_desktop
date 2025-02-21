import 'inventory_stock.dart';
import 'weekly_item_trend.dart';

class InventorySummaryEntity {
  const InventorySummaryEntity({
    required this.supplyWeeklyTrendEntities,
    required this.equipmentWeeklyTrendEntities,
    required this.inventoryStocks,
    required this.supplyPercentageChange,
    required this.equipmentPercentageChange,
    required this.suppliesCount,
    required this.equipmentCount,
  });

  final List<WeeklyItemTrendEntity> supplyWeeklyTrendEntities;
  final List<WeeklyItemTrendEntity> equipmentWeeklyTrendEntities;
  final List<InventoryStockEntity> inventoryStocks;
  final double supplyPercentageChange;
  final double equipmentPercentageChange;
  final int suppliesCount;
  final int equipmentCount;
}
