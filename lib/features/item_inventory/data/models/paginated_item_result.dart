import '../../domain/entities/paginated_item_result.dart';
import 'item_with_stock.dart';

class PaginatedItemResultModel extends PaginatedItemResultEntity {
  const PaginatedItemResultModel({
    required super.items,
    required super.totalItemCount,
  });

  factory PaginatedItemResultModel.fromJson(Map<String, dynamic> json) {
    return PaginatedItemResultModel(
      items: (json['items'] as List<dynamic>)
          .map(
            (item) => ItemWithStockModel.fromJson(item), // ItemModel.fromJson(item),
          )
          .toList(),
      totalItemCount: json['totalItemCount'],
    );
  }
}
