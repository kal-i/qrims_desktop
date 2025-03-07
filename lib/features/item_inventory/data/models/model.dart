import '../../domain/entities/model.dart';

class Model extends ModelEntity {
  const Model({
    required super.id,
    required super.productNameId,
    required super.brandId,
    required super.modelName,
  });

  factory Model.fromJson(Map<String, dynamic> json) {
    return Model(
      id: json['model_id'] as String? ?? '',
      productNameId: json['stock_id'] as int? ?? 0,
      brandId: json['brand_id'] as String? ?? '',
      modelName: json['model_name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'model_id': id,
      'stock_id': productNameId,
      'brand_id': brandId,
      'model_name': modelName,
    };
  }
}
