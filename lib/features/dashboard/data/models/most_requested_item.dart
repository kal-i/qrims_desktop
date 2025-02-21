import '../../domain/entities/most_requested_item.dart';

class MostRequestedItemModel extends MostRequestedItemEntity {
  const MostRequestedItemModel({
    required super.productName,
    required super.requestCount,
  });

  factory MostRequestedItemModel.fromJson(Map<String, dynamic> json) {
    return MostRequestedItemModel(
      productName: json['product_name'],
      requestCount: json['request_count'],
    );
  }
}
