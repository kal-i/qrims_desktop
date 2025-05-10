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
    print('json received by inv summ model:\n\n$json');

    final weeklyTrends = json['weekly_trends'] as Map<String, dynamic>? ?? {};

    final supplyWeeklyTrends = (weeklyTrends['supply_trends'] as List? ?? [])
        .map((e) => WeeklyItemTrendModel.fromJson(e))
        .toList();

    final inventoryWeeklyTrends =
        (weeklyTrends['inventory_trends'] as List? ?? [])
            .map((e) => WeeklyItemTrendModel.fromJson(e))
            .toList();

    final inventoryStocks = (json['stock_levels'] as List? ?? [])
        .map((e) => InventoryStockModel.fromJson(e))
        .toList();

    print('converted inventory stocks: $inventoryStocks');

    return InventorySummaryModel(
      supplyWeeklyTrendEntities: supplyWeeklyTrends,
      inventoryWeeklyTrendEntities: inventoryWeeklyTrends,
      inventoryStocks: inventoryStocks,
      supplyPercentageChange:
          (weeklyTrends['supply_percentage_change'] as num?)?.toDouble() ?? 0.0,
      inventoryPercentageChange:
          (weeklyTrends['inventory_percentage_change'] as num?)?.toDouble() ??
              0.0,
      suppliesCount: json['supplies_count'] as int? ?? 0,
      inventoryCount: json['inventory_count'] as int? ?? 0,
    );
  }
}
