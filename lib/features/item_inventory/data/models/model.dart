import '../../domain/entities/model.dart';

class Model extends ModelEntity {
  const Model({
    required super.id,
    required super.stockId,
    required super.brandId,
    required super.modelName,
  });

  factory Model.fromJson(Map<String, dynamic> json) {
    return Model(
      id: json['model_id'] as String? ?? '',
      stockId: json['stock_id'] as String? ?? '',
      brandId: json['brand_id'] as String? ?? '',
      modelName: json['model_name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'model_id': id,
      'stock_id': stockId,
      'brand_id': brandId,
      'model_name': modelName,
    };
  }
}