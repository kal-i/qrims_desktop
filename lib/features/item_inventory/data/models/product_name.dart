import '../../domain/entities/product_name.dart';

class ProductNameModel extends ProductNameEntity {
  const ProductNameModel({
    required super.id,
    required super.name,
  });

  factory ProductNameModel.fromJson(Map<String, dynamic> json) {
    return ProductNameModel(
      id: json['product_name_id'] as String,
      name: json['product_name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_name_id': id,
      'product_name': name,
    };
  }
}
