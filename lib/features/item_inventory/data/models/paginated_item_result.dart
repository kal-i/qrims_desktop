import '../../domain/entities/paginated_item_result.dart';
import 'base_item.dart';

class PaginatedItemResultModel extends PaginatedItemResultEntity {
  const PaginatedItemResultModel({
    required super.items,
    required super.totalItemCount,
    required super.suppliesCount,
    required super.equipmentCount,
    required super.outOfStockCount,
  });

  factory PaginatedItemResultModel.fromJson(Map<String, dynamic> json) {
    return PaginatedItemResultModel(
      items: (json['items'] as List<dynamic>)
          .map(
            (item) => BaseItemModel.fromJson(item),
          )
          .toList(),
      totalItemCount: json['total_item_count'],
      suppliesCount: json['supplies_count'] ?? 0,
      equipmentCount: json['equipment_count'] ?? 0,
      outOfStockCount: json['out_of_stock_count'] ?? 0,
    );
  }
}
