import '../../domain/entities/item.dart';

class ItemModel extends ItemEntity {
  const ItemModel({
    required super.productName,
    required super.quantity,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    print('received json by item model: $json');
    return ItemModel(
      productName: json['product_name'],
      quantity: json['total_quantity'],
    );
  }
}
