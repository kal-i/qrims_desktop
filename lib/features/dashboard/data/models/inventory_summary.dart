import '../../domain/entities/inventory_summary.dart';
import 'inventory_stock.dart';
import 'weekly_item_trend.dart';

class InventorySummaryModel extends InventorySummaryEntity {
  const InventorySummaryModel({
    required super.supplyWeeklyTrendEntities,
    required super.equipmentWeeklyTrendEntities,
    required super.inventoryStocks,
    required super.supplyPercentageChange,
    required super.equipmentPercentageChange,
    required super.suppliesCount,
    required super.equipmentCount,
  });

  factory InventorySummaryModel.fromJson(Map<String, dynamic> json) {
    // Debugging: Print the received JSON
    print('json received by inv summ model:\n\n$json');

    // Extract weekly trends
    final supplyWeeklyTrends = (json['weekly_trends']['supply_trends'] as List)
        .map((e) => WeeklyItemTrendModel.fromJson(e))
        .toList();

    final equipmentWeeklyTrends =
        (json['weekly_trends']['equipment_trends'] as List)
            .map((e) => WeeklyItemTrendModel.fromJson(e))
            .toList();

    // Extract inventory stocks
    final inventoryStocks = (json['stock_levels'] as List)
        .map((e) => InventoryStockModel.fromJson(e))
        .toList();

    // Debugging: Print converted inventory stocks
    print('converted inventory stocks: $inventoryStocks');

    // Create and return the InventorySummaryModel
    return InventorySummaryModel(
      supplyWeeklyTrendEntities: supplyWeeklyTrends,
      equipmentWeeklyTrendEntities: equipmentWeeklyTrends,
      inventoryStocks: inventoryStocks,
      supplyPercentageChange:
          (json['weekly_trends']['supply_percentage_change'] as num).toDouble(),
      equipmentPercentageChange:
          (json['weekly_trends']['equipment_percentage_change'] as num)
              .toDouble(),
      suppliesCount: json['supplies_count'] as int,
      equipmentCount: json['equipment_count'] as int,
    );
  }
}
