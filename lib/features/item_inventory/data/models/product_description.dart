import '../../domain/entities/product_description.dart';

class ProductDescriptionModel extends ProductDescriptionEntity {
  const ProductDescriptionModel({
    required super.id,
    super.description,
  });

  factory ProductDescriptionModel.fromJson(Map<String, dynamic> json) {
    return ProductDescriptionModel(
      id: json['product_description_id'] as String,
      description: json['product_description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_description_id': id,
      'product_description': description,
    };
  }
}
