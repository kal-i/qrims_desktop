import '../../domain/entities/inventory_summary.dart';
import 'inventory_stock.dart';
import 'weekly_item_trend.dart';

class InventorySummaryModel extends InventorySummaryEntity {
  const InventorySummaryModel({
    required super.supplyWeeklyTrendEntities,
    required super.inventoryWeeklyTrendEntities,
    required super.inventoryStocks,
    required super.supplyPercentageChange,
    required super.inventoryPercentageChange,
    required super.suppliesCount,
    required super.inventoryCount,
  });

  factory InventorySummaryModel.fromJson(Map<String, dynamic> json) {
    // Debugging: Print the received JSON
    print('json received by inv summ model:\n\n$json');

    // Extract weekly trends
    final supplyWeeklyTrends = (json['weekly_trends']['supply_trends'] as List)
        .map((e) => WeeklyItemTrendModel.fromJson(e))
        .toList();

    final inventoryWeeklyTrends =
        (json['weekly_trends']['inventory_trends'] as List)
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
      inventoryWeeklyTrendEntities: inventoryWeeklyTrends,
      inventoryStocks: inventoryStocks,
      supplyPercentageChange:
          (json['weekly_trends']['supply_percentage_change'] as num).toDouble(),
      inventoryPercentageChange:
          (json['weekly_trends']['inventory_percentage_change'] as num)
              .toDouble(),
      suppliesCount: json['supplies_count'] as int,
      inventoryCount: json['inventory_count'] as int,
    );
  }
}
