import '../../domain/entities/inventory_summary.dart';
import 'categorical_inventory_data.dart';

class InventorySummaryModel extends InventorySummaryEntity {
  const InventorySummaryModel({
    required super.inStocksCount,
    required super.lowStocksCount,
    required super.outOfStocksCount,
    required super.categoricalInventoryData,
  });

  factory InventorySummaryModel.fromJson(Map<String, dynamic> json) {
    return InventorySummaryModel(
      inStocksCount: json['in_stocks_count'] as int,
      lowStocksCount: json['low_stocks_count'] as int,
      outOfStocksCount: json['out_of_stocks_count'] as int,
      categoricalInventoryData: List<CategoricalInventoryDataModel>.from(
          json["categorical_inventory_data"]
              .map((x) => CategoricalInventoryDataModel.fromJson(x))),
    );
  }
}
