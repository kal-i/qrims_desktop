import '../../domain/entities/paginated_item_name.dart';

class PaginatedItemNameModel extends PaginatedItemNameEntity {
  const PaginatedItemNameModel({
    required super.itemNames,
    required super.totalItemCount,
  });

  factory PaginatedItemNameModel.fromJson(Map<String, dynamic> json) {
    return PaginatedItemNameModel(
      itemNames: (json['product_names'] as List<dynamic>)
      .map((itemName) => itemName as String).toList(),
      totalItemCount: json['total_item_count'],
    );
  }
}
